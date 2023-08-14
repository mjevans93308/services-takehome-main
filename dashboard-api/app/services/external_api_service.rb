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
      # config.response :raise_error
      config.response :logger,
        Rails.logger,
        headers: true,
        bodies: true,
        log_level: :debug
    end

    # custom ports for non-docker local testing
    if ENV["TEST_ENV"] == "localhost"
      @calendar_service_port = 7777
      @user_service_port = 8000
      @billing_service_port = 8881
    end
  end

  def query_user_service(user_id)
    url = if ENV["TEST_ENV"] != "localhost"
      "http://user-service:8000/users/#{user_id}"
    else
      "http://localhost:#{@user_service_port}/users/#{user_id}"
    end
    response = @conn.get(url)
    [response.status, JSON.parse(response.body)]
  end

  def query_calendar_service(user_id)
    url = if ENV["TEST_ENV"] != "localhost"
      "http://calendar-service:8000/events?user_id=#{user_id}"
    else
      "http://localhost:#{@calendar_service_port}/events?user_id=#{user_id}"
    end
    response = @conn.get(url)
    [response.status, JSON.parse(response.body)]
  end

  def query_billing_service(user_id)
    url = if ENV["TEST_ENV"] != "localhost"
      "http://billing-service:8000/subscriptions?user_id=#{user_id}"
    else
      "http://localhost:#{@billing_service_port}/subscriptions?user_id=#{user_id}"
    end
    response = @conn.get(url)
    [response.status, JSON.parse(response.body)]
  end
end
