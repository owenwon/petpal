# PetPal's API Documentation 

## User & Auth Routes 
### POST /login
- Description: Logs in an existing user or automatically registers a new one if the username
- Inputs:
    * { 
        "username": "user1", 
        "password": "password123", 
        "role": "owner" 
        }
- Outputs:
    * The complete User object including _id, role, and headline
### GET /users/:id
- Description: Fetches a specific user's profile information.
- Inputs:
    * N/A (ID in URL)
- Outputs:
    * { "_id": "...", 
    "username": 
    "user1", 
    "role": 
    "sitter", 
    "bio": "...",
    "experience": "3 years", 
    "location": "Seattle, WA" 
    }

---

## Request (Job Posting) Routes
### POST /requests
- Description: Allows an owner to post a new sitting job.
- Inputs:
    * {
    "ownerId": "65e2...",
    "ownerName": "Sarah",
    "title": "Dog Sitting for Luna",
    "petName": "Luna",
    "breed": "Golden Retriever",
    "age": 3,
    "weight": 65,
    "description": "Needs a morning walk.",
    "price": 25,
    "dates": "March 12-14",
    "imageUrl": "https://www.google.com/search?q=https://placedog.net/500"
    }
- Outputs:
    * The created Request object with a `status: "open"`.
### POST /requests/owner/:ownerId`
- Description: Gets all requests created by a specific owner for their dashboard.
- Inputs:
    * N/A (ownerId in URL)
- Outputs:
    * An array of Request objects.

--- 

## Application (Handshake) Routes
### POST /requests
- Description: Allows a sitter to apply for a specific request.
- Inputs:
    * { "requestId": "...", 
    "sitterId": "...", 
    "sitterName": "..." 
    }
- Outputs:
    * The created Application object with a `status: "pending"
### GET /requests/:requestId/applicants
- Description: Fetches all sitters who have applied for a specific job.
- Inputs:
    * N/A (requestId in URL)
- Outputs:
    * [{ 
    "sitterName": "John", 
    "status": "pending", 
    "sitterId": "..." }, 
    ... 
    ]
### PATCH /applications/:id`
- Description: Updates the status of an application (Approve/Reject).
- Inputs:
    * { 
    "status": "approved" 
    }
- Outputs:
    * The updated Application object. Note: Approving a sitter automatically sets the parent Request status to "closed"

--- 

### A Technical Note 
- Since we are using Mongoose, every object returned will have a `createdAt` and `updatedAt` field. We can include these in their Swift models so they can show "Posted on [Date]" labels.