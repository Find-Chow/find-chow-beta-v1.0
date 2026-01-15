# find-chow-beta-v1.0
Diaspora food finding app

```
┌─────────────────────────────────────────────────────────────┐
│                     FRONTEND (React-Vite)                   │
│              (Runs in browser on user's device)              │
└────────────────────┬────────────────────────────────────────┘
                     │ HTTP/REST API calls
                     │
┌────────────────────▼────────────────────────────────────────┐
│                   FastAPI Backend Server                     │
│                  (Runs on your server)                       │
├─────────────────────────────────────────────────────────────┤
│  API ROUTES:                                                │
│  ├─ /auth (Login, Register, JWT tokens)                     │
│  ├─ /stores (CRUD for stores)                               │
│  ├─ /products (CRUD for products)                           │
│  ├─ /reviews (Create, read reviews)                         │
│  ├─ /qa (Create, read Q&A)                                  │
│  ├─ /search (Search products/stores)                        │
│  ├─ /map (Get store locations)                              │
│  └─ /analytics (Track user behavior)                        │
├─────────────────────────────────────────────────────────────┤
│  MIDDLEWARE:                                                │
│  ├─ JWT Authentication (verify user tokens)                │
│  ├─ CORS (allow frontend to call backend)                  │
│  ├─ Rate limiting (prevent abuse)                          │
│  └─ Request logging                                         │
├─────────────────────────────────────────────────────────────┤
│  BUSINESS LOGIC:                                            │
│  ├─ User management (registration, profiles)               │
│  ├─ Store management (verification, updates)               │
│  ├─ Product catalog (search indexing, availability)        │
│  ├─ Review moderation (spam/abuse detection)               │
│  ├─ Q&A system (answer tracking, voting)                   │
│  └─ Analytics (user behavior tracking)                     │
└─────────────────────┬────────────────────────────────────────┘
                      │ Database queries
                      │
┌────────────────────▼────────────────────────────────────────┐
│                  PostgreSQL Database                         │
│                                                              │
│  TABLES:                                                    │
│  ├─ users (diaspora users)                                  │
│  ├─ stores (grocery stores, restaurants)                    │
│  ├─ products (cassava flour, plantain, etc.)                │
│  ├─ store_products (inventory: which stores carry which)    │
│  ├─ reviews (store reviews with photos)                     │
│  ├─ qa (questions and answers)                              │
│  ├─ favorites (bookmarked stores/products)                  │
│  └─ analytics_events (user behavior tracking)               │
└─────────────────────────────────────────────────────────────┘
                      │ File storage
                      │
┌────────────────────▼────────────────────────────────────────┐
│          Cloud Storage (Cloudinary or AWS S3)               │
│                                                              │
│  Store images, product photos, review photos                │
└──────────────────────────────────────────────────────────────┘
```

```
backend/
├── main.py                 # Entry point, app initialization
├── requirements.txt        # Dependencies
├── .env.example           # Environment variables template
├── config.py              # Configuration (database, auth settings)
├── models.py              # SQLAlchemy ORM models (maps to database)
├── schemas.py             # Pydantic schemas (API request/response validation)
├── database.py            # Database connection setup
├── dependencies.py        # Shared dependencies (JWT validation, etc.)
├── auth/
│   ├── __init__.py
│   ├── routes.py          # Login, register endpoints
│   ├── utils.py           # JWT token generation, password hashing
│   └── oauth2.py          # OAuth2 configuration
├── stores/
│   ├── __init__.py
│   ├── routes.py          # Store CRUD endpoints
│   ├── services.py        # Business logic for stores
│   └── schemas.py         # Store request/response schemas
├── products/
│   ├── __init__.py
│   ├── routes.py          # Product CRUD endpoints
│   ├── services.py        # Business logic for products
│   └── schemas.py         # Product schemas
├── reviews/
│   ├── __init__.py
│   ├── routes.py          # Review endpoints
│   ├── services.py        # Review logic, moderation
│   └── schemas.py         # Review schemas
├── qa/
│   ├── __init__.py
│   ├── routes.py          # Q&A endpoints
│   ├── services.py        # Q&A logic
│   └── schemas.py         # Q&A schemas
├── search/
│   ├── __init__.py
│   ├── routes.py          # Search endpoints
│   └── services.py        # Search logic (Elasticsearch integration)
├── analytics/
│   ├── __init__.py
│   ├── routes.py          # Analytics tracking
│   └── services.py        # Analytics logic
├── uploads/
│   ├── __init__.py
│   └── services.py        # Image upload to Cloudinary
└── middleware/
    ├── __init__.py
    ├── cors.py            # CORS configuration
    ├── auth.py            # JWT verification middleware
    └── rate_limit.py      # Rate limiting
```


## Authentication Flow
```
Frontend (React) 
  → User enters email + password on login page
  → POST /auth/login (email, password)
  → Backend validates password hash
  → Backend generates JWT token (includes user_id, exp time)
  → Backend returns token + user data
  → Frontend stores token in memory (NOT localStorage per requirements)
  → Frontend includes token in all future requests: Authorization: Bearer {token}
  → Middleware validates token on each request
  → If invalid/expired, return 401 Unauthorized, user redirected to login
```

## Product Search Flow
```
Frontend (React)
  → User types "cassava flour" in search bar
  → POST /search (query: "cassava flour", city: "Toronto", filters: {...})
  → Backend queries PostgreSQL (or Elasticsearch for speed):
     - Find all products matching "cassava flour" or alternative names
     - Find all stores carrying that product
     - Get reviews and Q&A for each product/store
  → Backend returns list of matching products with:
     - Product name + translations
     - Store names carrying it
     - Price per store
     - Stock status
     - Review highlights
  → Frontend displays results in grid/list/map view
  → User clicks on product
  → GET /products/{product_id}
  → Backend returns full product details + all store locations
  → Frontend displays store cards with call/directions CTAs
```

## Store Review Creation
```
Frontend (React)
  → User fills review form (rating, text, photos)
  → User selects photo from device
  → Frontend uploads photo to Cloudinary (direct upload)
  → POST /reviews (store_id, rating, text, photo_urls)
  → Middleware validates JWT (checks user is authenticated)
  → Backend validates review content (checks for health claims, spam keywords)
  → Backend stores review in PostgreSQL with approved: false (pending moderation)
  → Backend sends approval to you (email notification for MVP)
  → You approve in admin panel (future: automated moderation AI)
  → Review becomes visible to all users
  → Store owner gets notification, can respond
  → Backend increments store's review count, recalculates rating average
```

## Q&A Flow

```
Frontend (React)
  → User clicks "Ask about [store]"
  → User types question: "Do you carry fresh fufu?"
  → POST /qa (store_id, question_text, category: "product")
  → Backend stores in qa table
  → Backend notifies store owner (SMS/WhatsApp integration future)
  → Other users see question with "0 answers" badge
  → User or store owner answers: POST /qa/{qa_id}/answers (answer_text)
  → Backend stores answer linked to question
  → Answer appears under question (sorted by helpful votes)
  → Users upvote/downvote answers
  → Answers with more helpful votes float to top
```

## Analytics Tracking Flow
```
Frontend (React)
  → User performs action (search, view store, click call button)
  → Frontend fires event: POST /analytics/events
     {
       event_type: "click_to_call",
       store_id: 123,
       user_device: "mobile"
     }
  → Backend stores event in analytics_events table
  → No wait, no user experience interruption (async event)
  → Later, you run analytics queries:
     - "How many searches for cassava flour last week?"
     - "Which neighborhoods have most searches?"
     - "Which stores get most clicks-to-call?"
  → You use insights to identify supply gaps, recruit stores, guide product development
```


## Key Endpoints

```
AUTH:
POST   /auth/register         - New user signup
POST   /auth/login            - Login, returns JWT token
POST   /auth/logout           - Logout
POST   /auth/refresh          - Refresh JWT token
GET    /auth/me               - Get current user info

STORES:
GET    /stores                - List all stores (with filters, pagination)
GET    /stores/{store_id}     - Get store details
POST   /stores                - Create store (admin/store owner only)
PUT    /stores/{store_id}     - Update store (store owner only)
DELETE /stores/{store_id}     - Delete store (admin only)
GET    /stores/{store_id}/inventory - Get store's products + stock

PRODUCTS:
GET    /products              - List all products
GET    /products/{product_id} - Get product details
POST   /products              - Create product
PUT    /products/{product_id} - Update product
DELETE /products/{product_id} - Delete product
GET    /products/{product_id}/availability - Which stores carry this

REVIEWS:
GET    /stores/{store_id}/reviews - Get store reviews
POST   /stores/{store_id}/reviews - Create review
GET    /reviews/{review_id}   - Get review details
PUT    /reviews/{review_id}   - Edit review (owner only)
DELETE /reviews/{review_id}   - Delete review (owner/admin only)
POST   /reviews/{review_id}/helpful - Mark as helpful

Q&A:
GET    /stores/{store_id}/qa  - Get Q&As for store
POST   /stores/{store_id}/qa  - Ask question
GET    /qa/{qa_id}/answers    - Get answers to question
POST   /qa/{qa_id}/answers    - Answer question
POST   /qa/{qa_id}/answers/{answer_id}/helpful - Mark answer as helpful

SEARCH:
GET    /search                - Full-text search (products + stores)
  Query params: q, city, filters (region, type, delivery, etc.), limit, offset

ANALYTICS:
POST   /analytics/events      - Track user event
GET    /analytics/dashboard   - Analytics for stores/admins

FAVORITES:
GET    /favorites             - Get user's saved stores/products
POST   /favorites             - Save store/product
DELETE /favorites/{favorite_id} - Unsave
```


## React Project Structure
```
frontend/
├── vite.config.js
├── package.json
├── .env.example
├── index.html
├── src/
│   ├── main.jsx             # Entry point
│   ├── App.jsx              # Root component
│   ├── App.css              # Global styles
│   ├── components/
│   │   ├── Layout/
│   │   │   ├── Header.jsx
│   │   │   ├── Navigation.jsx
│   │   │   ├── Footer.jsx
│   │   │   └── Layout.css
│   │   ├── Search/
│   │   │   ├── SearchBar.jsx
│   │   │   ├── SearchResults.jsx
│   │   │   ├── Filters.jsx
│   │   │   └── Search.css
│   │   ├── Store/
│   │   │   ├── StoreCard.jsx
│   │   │   ├── StoreDetail.jsx
│   │   │   ├── StoreList.jsx
│   │   │   └── Store.css
│   │   ├── Product/
│   │   │   ├── ProductCard.jsx
│   │   │   ├── ProductDetail.jsx
│   │   │   ├── ProductAvailability.jsx
│   │   │   └── Product.css
│   │   ├── Review/
│   │   │   ├── ReviewCard.jsx
│   │   │   ├── ReviewForm.jsx
│   │   │   ├── ReviewList.jsx
│   │   │   └── Review.css
│   │   ├── QA/
│   │   │   ├── QAForm.jsx
│   │   │   ├── QAList.jsx
│   │   │   ├── AnswerForm.jsx
│   │   │   └── QA.css
│   │   ├── Map/
│   │   │   ├── StoreMap.jsx
│   │   │   └── Map.css
│   │   ├── Auth/
│   │   │   ├── Login.jsx
│   │   │   ├── Register.jsx
│   │   │   ├── ProtectedRoute.jsx
│   │   │   └── Auth.css
│   │   ├── Common/
│   │   │   ├── Loading.jsx
│   │   │   ├── Error.jsx
│   │   │   ├── Modal.jsx
│   │   │   └── Common.css
│   ├── pages/
│   │   ├── HomePage.jsx
│   │   ├── SearchPage.jsx
│   │   ├── StorePage.jsx
│   │   ├── ProductPage.jsx
│   │   ├── ProfilePage.jsx
│   │   ├── SavedPage.jsx
│   │   ├── CommunityPage.jsx
│   │   └── Pages.css
│   ├── hooks/
│   │   ├── useAuth.js        # Auth context hook
│   │   ├── useAPI.js         # API calls hook
│   │   ├── useLocation.js    # Geolocation hook
│   │   └── useLocalStorage.js# In-memory state hook
│   ├── context/
│   │   ├── AuthContext.jsx   # Auth state management
│   │   └── AppContext.jsx    # Global app state
│   ├── services/
│   │   ├── api.js            # API client (axios configured)
│   │   ├── auth.js           # Auth API calls
│   │   ├── stores.js         # Store API calls
│   │   ├── products.js       # Product API calls
│   │   ├── reviews.js        # Review API calls
│   │   ├── qa.js             # Q&A API calls
│   │   ├── search.js         # Search API calls
│   │   └── uploads.js        # Image upload
│   ├── utils/
│   │   ├── formatters.js     # Date, currency formatting
│   │   ├── validators.js     # Form validation
│   │   ├── constants.js      # App constants
│   │   └── helpers.js        # Utility functions
│   ├── styles/
│   │   ├── variables.css     # CSS custom properties (colors, fonts)
│   │   ├── globals.css       # Global styles
│   │   ├── responsive.css    # Media queries
│   │   └── accessibility.css # A11y styles
│   └── assets/
│       ├── images/
│       ├── icons/
│       └── fonts/
```