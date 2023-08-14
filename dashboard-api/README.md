# Dashboard Summary service
This service will make separate calls to the billing, user, and calendar services to build a comprehensive payload that we can then use to feed the to-be-written dashboard UI. It is a Ruby on Rails service, and the majority of the word done currently resides in `app/controllers/summary_controller.rb` and `app/services/external_api_service.rb`

The endpoint to hit for local testing is `http://localhost:8000/{user_id}`.

### Request Parameters
Parameter | Type | Required | Description
--- | --- | --- | --- 
user_id | `integer` | Yes | Ther user's ID


Sample return payload:
```
{
	"result": {
		"full_name": "Scott, Michael",
		"days_until_renewal": 30,
		"price_cents": 1500,
		"next_closest_event": {
			"name": "1on1",
			"date": "2023-08-18",
			"meeting_details": {
				"attendees": 2,
				"duration": 60
			}
		},
		"num_events_next_week": 1
	}
}
```
If errors are encountered while building the payload, a list of `error` strings will be appended to the payload.

### Testing
Currently we are using the `rspec` and `webmock` gems in this project for test specifications and stubbing our external API calls. 
To run the tests, exec `bundle exec rspec` from the CLI.

### Next Steps
- Build out test suite further
- Investigate running separate HTTP REST API calls in parallel, although this would bring into question whether we want to display any data if one of the calls fails, but the others succeed. As with all things in life, tradeoffs are inevitable.