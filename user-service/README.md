[< Back to Assignment](../README.md)

## Users (Ruby on Rails)
This service stores information about a user.

### Users Endpoint

**Host Endpoint:** `http://localhost:8000/users/<id>`

**Docker Network Endpoint:** `http://user-service:8000/users/<id>`

**Method:** GET

**Description:** Retrieve a specific user record, also used as a proxy for authorization if a user record can't be found.

### Example Responses

**Success**
```json
{
    "id": <int>,
    "first_name": <string>,
    "last_name": <string>,
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


### Admin Endpoint

**Host Endpoint:** `http://localhost:8000/admin/<id>`

**Docker Network Endpoint:** `http://user-service:8000/admin/<id>`

**Method:** GET

**Description:** Retrieves a json list of user_ids, first_name, last_name, and position values. Can only be accessed by users with `admin` roles.

### Example Responses

**Success**
```json
[{
	"id": <int>,
	"first_name": <string>,
	"last_name": <string>,
	"position": <string>
}, {
	"id": 2,
	"first_name": <string>,
	"last_name": <string>,
	"position": <string>
}
...
]
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
| 403         | Forbidden        |

### Is_Admin Endpoint

**Host Endpoint:** `http://localhost:8000/is_admin/<id>`

**Docker Network Endpoint:** `http://user-service:8000/is_admin/<id>`

**Method:** GET

**Description:** Check whether a given user has an admin role, given their user_id.

### Example Responses

**Success**
```json
{
    "message": "admin status confirmed"
}
```

**Error**
```json
{
    "message": "User does not have access to this endpoint"
}
```

### Response Codes

| Status Code | Description      |
| ----------- | ---------------- |
| 200         | OK               |
| 404         | Record not Found |

### Possible next steps
- Implement batching or pagination for `/admin` view so that we handle large groups of users correctly.