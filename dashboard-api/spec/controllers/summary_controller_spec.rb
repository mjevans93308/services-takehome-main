require "webmock/rspec"

require_relative "../../app/controllers/summary_controller"
require_relative "../../app/services/external_api_service"

RSpec.describe SummaryController, type: :controller do
  user_service_return = "{\"id\":1,\"first_name\":\"Michael\",\"last_name\":\"Scott\"}"
  summary_controller = SummaryController.new
  describe "GET #fetch_user_info" do
    it "returns the user's first and last name" do
      stub_request(:get, "http://user-service:8000/users/1")
        .with(
          headers: {
            "Accept" => "*/*", "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3", "User-Agent" => "Faraday v2.7.10"
          }
        )
        .to_return(status: 200, body: user_service_return.to_s, headers: {})
      expect(summary_controller.fetch_user_info(1, {}, [])).to eq(JSON.parse(user_service_return)["last_name"] + ", " + JSON.parse(user_service_return)["first_name"])
    end
  end
end

RSpec.describe SummaryController, type: :controller do
  calendar_service_return = "{\"events\" : [{\"id\" : 1, \"name\" : \"Hangout\", \"duration\" : 30, \"date\" : \"8/11/2023\", \"attendees\" : 2}, {\"id\" : 2, \"name\" : \"Pre-Screen\", \"duration\" : 60, \"date\" : \"8/9/2023\", \"attendees\" : 3}, {\"id\" : 3, \"name\" : \"Group Interview\", \"duration\" : 120, \"date\" : \"8/10/2023\", \"attendees\" : 3}, {\"id\" : 4, \"name\" : \"1on1\", \"duration\" : 60, \"date\" : \"8/18/2023\", \"attendees\" : 2}]}"
  summary_controller = SummaryController.new
  describe "GET #fetch_calendar_info" do
    it "returns the details of the user's next meeting and the number of their meetings in the next week" do
      stub_request(:get, "http://calendar-service:8000/events?user_id=1")
        .with(
          headers: {
            "Accept" => "*/*", "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3", "User-Agent" => "Faraday v2.7.10"
          }
        )
        .to_return(status: 200, body: calendar_service_return.to_s, headers: {})
      result = {}
      expected_result = {"num_events_next_week" => 1, "next_closest_event" => {"date" => "2023-08-18", "meeting_details" => {"attendees" => 2, "duration" => 60}, "name" => "1on1"}}
      expect(summary_controller.fetch_calendar_info(1, result, [])).to eq(1)
      expect(result).to eq(expected_result)
    end
  end
end

RSpec.describe SummaryController, type: :controller do
  renewal_date = (Date.today + 30).strftime("%m/%d/%Y")
  billing_service_return = "{\"user_id\": 1, \"renewal_date\": \"#{renewal_date}\", \"price_cents\": 1500}"
  summary_controller = SummaryController.new
  describe "GET #fetch_billing_info" do
    it "returns the details of the user's subscription, namely: subscription renewal date and cost" do
      stub_request(:get, "http://billing-service:8000/subscriptions?user_id=1")
        .with(
          headers: {
            "Accept" => "*/*", "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3", "User-Agent" => "Faraday v2.7.10"
          }
        )
        .to_return(status: 200, body: billing_service_return.to_s, headers: {})
      result = {}
      expected_result = {"days_until_renewal" => 30, "price_cents" => 1500}
      expect(summary_controller.fetch_billing_info(1, result, [])).to eq(1500)
      expect(result).to eq(expected_result)
    end
  end
end
