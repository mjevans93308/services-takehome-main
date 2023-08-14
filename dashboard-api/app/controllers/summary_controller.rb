require "uri"
require "net/http"
require "json"

class SummaryController < ApplicationController
  def initialize
    @external_api_service = ExternalApiService.new
  end

  def show
    result = {}
    errors = []

    user_id = params[:user_id]
    fetch_user_info(user_id, result, errors)
    fetch_billing_info(user_id, result, errors)
    fetch_calendar_info(user_id, result, errors)
    if errors.length > 0 then result[:errors] = errors end

    render json: {result: result}
  end

  def fetch_user_info(user_id, result, errors)
    user_status_payload = @external_api_service.query_user_service(user_id)
    if user_status_payload[0] == 404
      errors.append(user_status_payload[1]["message"])
      return
    end
    user_info = user_status_payload[1]
    result["full_name"] = user_info["last_name"] + ", " + user_info["first_name"]
  end

  def fetch_billing_info(user_id, result, errors)
    billing_status_payload = @external_api_service.query_billing_service(user_id)
    if billing_status_payload[0] == 404
      errors.append(billing_status_payload[1]["message"])
      return
    end
    # coming in MM/DD/YYYY format
    result["days_until_renewal"] = (Date.strptime(billing_status_payload[1]["renewal_date"], "%m/%d/%Y") - Date.today).to_i
    result["price_cents"] = billing_status_payload[1]["price_cents"]
  end

  def fetch_calendar_info(user_id, result, errors)
    calendar_status_payload = @external_api_service.query_calendar_service(user_id)
    if calendar_status_payload[0] == 404
      errors.append(calendar_status_payload[1]["message"])
      return
    end

    events = []
    calendar_status_payload[1]["events"].each do |event|
      event["date"] = Date.strptime(event["date"], "%m/%d/%Y")
      events.append(event)
    rescue Date::Error
      puts "rescued from Date.parse failure for date #{event["date"]}"
    end

    closest_event = nil
    num_events_next_week = 0
    events.each do |event|
      if Range.new(Date.today, Date.today + 7).cover?(event["date"])
        num_events_next_week += 1
      end

      if closest_event.nil?
        closest_event = event
      elsif Range.new(Date.today, closest_event[:date]).cover?(event["date"])
        closest_event = event
      end
    end

    next_closest_event = {}

    next_closest_event["name"] = closest_event["name"]
    next_closest_event["date"] = closest_event["date"].to_s
    next_closest_event["meeting_details"] = {"attendees" => closest_event["attendees"], "duration" => closest_event["duration"]}

    result["next_closest_event"] = next_closest_event
    result["num_events_next_week"] = num_events_next_week
  end
end
