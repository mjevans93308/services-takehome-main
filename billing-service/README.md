[< Back to Assignment](../README.md)

## Billing (Python / Falcon)
This service stores information about a user's subscription.

### Subscription Endpoint

**Host Endpoint** `http://localhost:8000/subscriptions`

**Docker Network Endpoint:** `http://billing-service:8000/subscriptions`

**Method:** GET

**Description:** Retrieve the subscription details for a given user

### Request Parameters

| Parameter | Type | Requred | Description   |
| --------- | ---- | ------- | ------------- |
| `user_id` | int  | Yes     | The user's ID |

### Example Responses

**Success**
```json
{
    "user_id": <user_id>,
    "renewal_date": <MM/DD/YYYY>,
    "price_cents": <int>,
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
