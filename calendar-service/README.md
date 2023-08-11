[< Back to Assignment](../README.md)

## Calendar (Node / Express)
This service contains information about a users upcoming meetings.
 
### Events Endpoint

**Host Endpoint:** `http://localhost:8000/events`

**Docker Network Endpoint:** `http://calendar-service:8000/events`

**Method:** GET

**Description:** Retrieve a list of upcoming events for the user

### Request Parameters

| Parameter | Type | Requred | Description   |
| --------- | ---- | ------- | ------------- |
| `user_id` | int  | Yes     | The user's ID |

### Example Responses

**Success**
```json
{
    "events":
        [
            {"id": 1, "name": "1on1", "duration": 30, "attendees": 2, "date": "MM/DD/YYY"},
            {"id": 2, "name": "hangout", "duration": 60, "attendees": 5, "date": "MM/DD/YYY"},
            ...
        ]
}
```

**Error**
```json
{
    "message": <error message>
}
```

### Response Codes

| Status Code | Description      |
| ----------- | ---------------- |
| 200         | OK               |
| 404         | Record not Found |
