Week 3-4 ROADMAP (THINK LIKE THIS)
═══════════════════════════════════════════════════════════

STEP 1: Database Setup (FOUNDATION)
   ↓ You create PostgreSQL database
   ↓ SQLAlchemy reads models.py → creates tables automatically
   ↓ Now your tables exist in the database

STEP 2: Authentication System (THE BRAIN)
   ↓ User submits email + password
   ↓ We hash the password (bcrypt) + store in database
   ↓ User logs in → we verify password + create JWT token
   ↓ Token sent back to frontend, stored in sessionStorage
   ↓ Frontend includes token in future requests

STEP 3: Product Routes (THE PRODUCT CATALOG)
   ↓ GET /products → list all products
   ↓ POST /products → create new product (admin only)
   ↓ GET /products/search → search by name

STEP 4: Test Everything (VERIFICATION)
   ↓ Use Swagger UI at http://localhost:8000/docs
   ↓ Manually test each endpoint
   ↓ Check database to see if data saved correctly