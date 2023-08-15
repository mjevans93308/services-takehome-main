require "uri"
require "net/http"
require "json"
require "active_support/time"
require "time"
require "date"

class SummaryController < ApplicationController
  def initialize
    @external_api_service = ExternalApiService.new
  end

  def show
    result = {}
    errors = []

    user_id = params[:user_id]
    Rails.logger.info("starting summary dashboard data collection for user_id=#{user_id}")

    fetch_user_info(user_id, result, errors)
    fetch_user_admin_data(user_id, result, errors)
    fetch_billing_info(user_id, result, errors)
    fetch_calendar_info(user_id, result, errors)
    if errors.length > 0 then result[:errors] = errors end
    Rails.logger.info("finished summary dashboard data collection for user_id#{user_id}")
    render json: {result: result}
  end

  # fetch_user_info - makes a call to external api service for user info for given user_id
  # and builds user's full name in `last_name, first_name` format
  # updates passed in `result` map if external api call success, updates `errors` list otherwise
  def fetch_user_info(user_id, result, errors)
    user_status_payload = @external_api_service.query_user_service(user_id)
    if user_status_payload[0] == 404
      Rails.logger.error("received 404 from user service")
      errors.append(user_status_payload[1]["message"])
      return
    end
    user_info = user_status_payload[1]
    result["full_name"] = user_info["last_name"] + ", " + user_info["first_name"]
  end

  # fetch_user_admin_data - makes 2 calls to external api service for user info for given user_id
  # calculates whether a user has `admin` role
  # if yes, calls external user service for org-wide user list with their roles
  # and updates `result` map with user list response data
  # if no, updates `errors` list with access-restricted error
  def fetch_user_admin_data(user_id, result, errors)
    is_user_admin_status = @external_api_service.query_user_is_admin_service(user_id)
    is_admin = false
    if is_user_admin_status[0] == 200 && is_user_admin_status[1]["message"] == "admin status confirmed"
      is_admin = true
    end

    if !is_admin
      Rails.logger.error("user is not authorized to fetch list of other users")
      errors.append("User attempted to fetch admin list of other users but was not authorized")
      return
    end

    user_admin_payload = @external_api_service.query_user_admin_service(user_id)
    if user_admin_payload[0] != 200
      Rails.logger.error("did not receive success stats from user service /is_admin endpoint")
      errors.append(user_status_payload[1]["message"])
      return
    end

    result["user_list"] = user_admin_payload[1]
  end

  # fetch_billing_info - makes call to external api service for billing info for user given user_id
  # calculates how many days until user's subscription expires and subscription cost
  # updates passed in `result` map if external api call success, updates `errors` list otherwise
  def fetch_billing_info(user_id, result, errors)
    billing_status_payload = @external_api_service.query_billing_service(user_id)
    if billing_status_payload[0] == 404
      Rails.logger.error("received 404 from billing service")
      errors.append(billing_status_payload[1]["message"])
      return
    end
    # coming in MM/DD/YYYY format
    incoming_date = billing_status_payload[1]["renewal_date"]
    result["days_until_renewal"] = (Date.strptime(incoming_date, "%m/%d/%Y") - Date.today).to_i
    result["price_cents"] = billing_status_payload[1]["price_cents"]
  end

  # fetch_calend_info - make call to external api service for calendar info with user_id param
  # calculate the next closest event for this user and the number of events for this user
  # over the next week
  # updates passed in `result` map if external api call success, updates `errors` list otherwise
  def fetch_calendar_info(user_id, result, errors)
    calendar_status_payload = @external_api_service.query_calendar_service(user_id)
    if calendar_status_payload[0] == 404
      Rails.logger.error("received 404 from calendar service")
      errors.append(calendar_status_payload[1]["message"])
      return
    end

    # convert all incoming datestrings to Date objects
    # guard against Date::Error encountered when using Date.parse
    # hence the explict format using in Date.strptime
    events = []
    calendar_status_payload[1]["events"].each do |event|
      event["date"] = Date.strptime(event["date"], "%m/%d/%Y")
      events.append(event)
    rescue Date::Error
      Rails.logger.error("rescued from Date.parse failure for date #{event["date"]}")
    end

    closest_event = nil
    num_events_last_week = 0
    events.each do |event|
      if Range.new(Date.today, Date.today - 7).cover?(event["date"])
        num_events_last_week += 1
      end

      if closest_event.nil?
        closest_event = event
      elsif Range.new(Date.today, closest_event[:date]).cover?(event["date"])
        closest_event = event
      end
    end

    next_closest_event = {}
    next_closest_event["name"] = closest_event["name"]
    next_closest_event["date"] = closest_event["date"].to_s # converting back to string from date obj
    next_closest_event["meeting_details"] = {
      "attendees" => closest_event["attendees"],
      "duration" => closest_event["duration"]
    }

    result["next_closest_event"] = next_closest_event
    result["num_events_last_week"] = num_events_last_week
  end

  def timezone_conversion
    payload = {}
    event_id = params['event']
    user_id = params['user']
    calendar_status_payload = @external_api_service.query_calendar_service(user_id)
    if calendar_status_payload[0] == 404
      Rails.logger.error("received 404 from calendar service")
      errors.append(calendar_status_payload[1]["message"])
      return
    end
    current_event = nil
    calendar_status_payload[1]["events"].each do |event|
      if event['id'] == event_id
        # date = Date.strptime(event["date"], "%F %T %z")
        Rails.logger.info("received datetime: #{event["date"]}")
        # 8/14/2023, 4:00:27 AM
        event["date"] = Time.strptime(event["date"], "%m/%d/%Y, %T %p")
        current_event = event
        break
      end
    end

    user_status_payload = @external_api_service.query_user_service(user_id)
    if user_status_payload[0] == 404
      Rails.logger.error("received 404 from user service")
      errors.append(user_status_payload[1]["message"])
      return
    end
    user_info = user_status_payload[1]
    user_tz = user_info['time_zone']
    # tz = tzinfo::TimeZone.get(user_tz)
    datetime_obj = current_event["date"].in_time_zone(user_tz)
    current_event["date"] = datetime_obj.strftime("%m/%d/%Y, %T %p")
    render json: {current_event: current_event}
  end
end

# datetime = Time.strptime(event["date"], "%m/%d/%Y, %T %p")
# user_tz = user_info['time_zone']
# datetime = datetime.in_time_zone(user_tz)
# current_event["date"] = datetime.strftime("%m/%d/%Y, %T %p")
