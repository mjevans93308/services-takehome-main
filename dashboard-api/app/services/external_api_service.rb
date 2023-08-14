require "faraday"
require "json"

class ExternalApiService
  def initialize
    faraday_options = {
      request: {
        open_timeout: 1,
        read_timeout: 5,
        write_timeout: 5
      }
    }
    @conn = Faraday.new(**faraday_options) do |config|
      config.response :logger,
        Rails.logger,
        log_level: :debug
    end
  end

  def query_user_service(user_id)
    Rails.logger.info("starting call to user service")
    url = "http://user-service:8000/users/#{user_id}"
    response = @conn.get(url)
    [response.status, JSON.parse(response.body)]
  end

  def query_user_is_admin_service(user_id)
    Rails.logger.info("starting call to user service for is_admin check")
    url = "http://user-service:8000/is_admin/#{user_id}"
    response = @conn.get(url)
    [response.status, JSON.parse(response.body)]
  end

  def query_user_admin_service(user_id)
    Rails.logger.info("starting call to user service for admin user-list endpoint")
    url = "http://user-service:8000/admin/#{user_id}"
    response = @conn.get(url)
    [response.status, JSON.parse(response.body)]
  end

  def query_calendar_service(user_id)
    Rails.logger.info("starting call to calendar service")
    url = "http://calendar-service:8000/events?user_id=#{user_id}"
    response = @conn.get(url)
    [response.status, JSON.parse(response.body)]
  end

  def query_billing_service(user_id)
    Rails.logger.info("starting call to billing service")
    url = "http://billing-service:8000/subscriptions?user_id=#{user_id}"
    response = @conn.get(url)
    [response.status, JSON.parse(response.body)]
  end
end
