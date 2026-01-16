-- USERS TABLE
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  email VARCHAR(255) UNIQUE NOT NULL,
  username VARCHAR(100) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  first_name VARCHAR(100),
  last_name VARCHAR(100),
  phone VARCHAR(20),
  location_zip VARCHAR(10),  -- User's ZIP code
  location_city VARCHAR(100),  -- e.g., "New York"
  location_state VARCHAR(2),  -- e.g., "NY"
  preferred_language VARCHAR(10) DEFAULT 'en',  -- 'en', 'es'
  reputation_score INT DEFAULT 0,  -- Earned from helpful reviews
  verified_shopper BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  deleted_at TIMESTAMP
);

-- PLACES TABLE (Unified: Stores + Restaurants)
CREATE TABLE places (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  description TEXT,
  address VARCHAR(500) NOT NULL,
  city VARCHAR(100) NOT NULL,
  state VARCHAR(2),  -- "NY", "GA", "CA"
  zip_code VARCHAR(10),
  country VARCHAR(2) DEFAULT 'US',
  latitude DECIMAL(10, 8),  -- For map positioning
  longitude DECIMAL(11, 8),
  phone VARCHAR(20),
  website_url VARCHAR(500),
  whatsapp_number VARCHAR(20),
  email VARCHAR(255),
  place_type ENUM('grocery', 'restaurant', 'butcher', 'bakery', 'market'),
  specialization VARCHAR(100),  -- "West African", "East African", "Pan-African"
  description_short TEXT,  -- One sentence about the place
  languages_spoken TEXT,  -- JSON: ["English", "Yoruba", "Twi", "Spanish"]
  accepts_cash BOOLEAN DEFAULT TRUE,
  accepts_card BOOLEAN DEFAULT TRUE,
  accepts_mobile_payment BOOLEAN DEFAULT FALSE,
  has_parking BOOLEAN DEFAULT FALSE,
  delivery_available BOOLEAN DEFAULT FALSE,  -- "Commonly available" not real-time
  delivery_services TEXT,  -- JSON: ["DoorDash", "UberEats", "Direct"]
  delivery_notes VARCHAR(500),  -- e.g., "Delivers to Manhattan and Brooklyn"
  
  -- Hours (US format: HH:MM in 24-hour)
  hours_monday VARCHAR(50),  -- "09:00-21:00"
  hours_tuesday VARCHAR(50),
  hours_wednesday VARCHAR(50),
  hours_thursday VARCHAR(50),
  hours_friday VARCHAR(50),
  hours_saturday VARCHAR(50),
  hours_sunday VARCHAR(50),
  
  -- Rating & Trust
  rating DECIMAL(3, 2) DEFAULT 0.0,  -- 0.0 to 5.0
  review_count INT DEFAULT 0,
  views_count INT DEFAULT 0,
  owner_verified BOOLEAN DEFAULT FALSE,
  owner_name VARCHAR(255),
  
  -- Timestamps
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  deleted_at TIMESTAMP
);

-- PRODUCTS TABLE
CREATE TABLE products (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL,  -- Primary name
  description TEXT,  -- What is it, how is it used
  category VARCHAR(100),  -- "grains", "spices", "proteins", "produce", "pantry"
  cuisine_region VARCHAR(100),  -- "West African", "East African", "Southern African"
  
  -- Names in different languages
  english_name VARCHAR(255),  -- "Cassava Flour"
  alternative_names TEXT,  -- JSON: ["Gari", "Fermented cassava", "Tapioca flour"]
  spanish_name VARCHAR(255),  -- For growing Latino-African communities
  
  brand VARCHAR(255),  -- Brand if applicable
  origin_country VARCHAR(100),  -- "Ghana", "Nigeria", "Cameroon"
  
  image_url VARCHAR(500),
  image_thumbnail_url VARCHAR(500),
  
  -- SEO & Discovery
  search_keywords TEXT,  -- For better search: "cassava, gari, flour, root vegetable"
  
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  deleted_at TIMESTAMP
);

-- PLACE_PRODUCTS TABLE (Inventory mapping)
-- Indicates which products are commonly available at which places
CREATE TABLE place_products (
  id SERIAL PRIMARY KEY,
  place_id INT NOT NULL REFERENCES places(id) ON DELETE CASCADE,
  product_id INT NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  
  -- Availability indicator (not real-time)
  commonly_available BOOLEAN DEFAULT TRUE,  -- Is this typically stocked here?
  
  -- Optional: pricing if available
  typical_price DECIMAL(10, 2),
  currency VARCHAR(3) DEFAULT 'USD',
  
  -- Optional: additional info
  notes VARCHAR(500),  -- e.g., "Fresh on weekends", "Frozen variety available"
  
  last_verified_at TIMESTAMP,  -- When was this last confirmed?
  
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  
  UNIQUE(place_id, product_id)  -- Each place-product combo appears once
);

-- REVIEWS TABLE
CREATE TABLE reviews (
  id SERIAL PRIMARY KEY,
  user_id INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  place_id INT NOT NULL REFERENCES places(id) ON DELETE CASCADE,
  product_id INT REFERENCES products(id) ON DELETE SET NULL,  -- Optional: review specific product
  
  -- Rating & Content
  rating INT CHECK (rating >= 1 AND rating <= 5),
  title VARCHAR(255),
  review_text TEXT NOT NULL,
  
  -- Review type helps organize content
  review_type ENUM('general', 'product_availability', 'freshness', 'service', 'pricing'),
  
  -- Product-specific fields
  product_availability VARCHAR(100),  -- "In stock", "Out of stock", "Just arrived"
  freshness_rating VARCHAR(100),  -- "Fresh today", "Looks good", "Older stock"
  
  -- Media
  photos TEXT,  -- JSON array of photo URLs from Cloudinary
  photo_count INT DEFAULT 0,
  
  -- Engagement
  helpful_count INT DEFAULT 0,
  unhelpful_count INT DEFAULT 0,
  
  -- Moderation
  approved BOOLEAN DEFAULT FALSE,  -- Requires approval before display
  flagged BOOLEAN DEFAULT FALSE,
  flag_reason VARCHAR(255),
  
  -- Store owner response
  owner_response TEXT,
  owner_response_date TIMESTAMP,
  
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  deleted_at TIMESTAMP
);

-- QA TABLE
CREATE TABLE qa (
  id SERIAL PRIMARY KEY,
  user_id INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  place_id INT REFERENCES places(id) ON DELETE CASCADE,
  product_id INT REFERENCES products(id) ON DELETE CASCADE,
  
  question_text TEXT NOT NULL,
  question_category ENUM('product', 'place', 'delivery', 'availability', 'recommendation'),
  
  -- Engagement
  answer_count INT DEFAULT 0,
  answered BOOLEAN DEFAULT FALSE,
  helpful_count INT DEFAULT 0,
  
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- QA_ANSWERS TABLE
CREATE TABLE qa_answers (
  id SERIAL PRIMARY KEY,
  qa_id INT NOT NULL REFERENCES qa(id) ON DELETE CASCADE,
  user_id INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  answer_text TEXT NOT NULL,
  
  place_verified BOOLEAN DEFAULT FALSE,  -- Did place owner answer?
  helpful_count INT DEFAULT 0,
  unhelpful_count INT DEFAULT 0,
  
  created_at TIMESTAMP DEFAULT NOW()
);

-- FAVORITES TABLE
CREATE TABLE favorites (
  id SERIAL PRIMARY KEY,
  user_id INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  place_id INT REFERENCES places(id) ON DELETE CASCADE,
  product_id INT REFERENCES products(id) ON DELETE CASCADE,
  
  created_at TIMESTAMP DEFAULT NOW(),
  
  -- Must save either a place or product, not both
  CHECK (
    (place_id IS NOT NULL AND product_id IS NULL) OR
    (place_id IS NULL AND product_id IS NOT NULL)
  )
);

-- ANALYTICS_EVENTS TABLE
CREATE TABLE analytics_events (
  id SERIAL PRIMARY KEY,
  user_id INT REFERENCES users(id) ON DELETE SET NULL,
  
  event_type VARCHAR(100),  -- "product_search", "place_view", "click_directions"
  search_query VARCHAR(255),
  
  product_id INT REFERENCES products(id) ON DELETE SET NULL,
  place_id INT REFERENCES places(id) ON DELETE SET NULL,
  
  location_zip VARCHAR(10),  -- User's location at time of event
  location_city VARCHAR(100),
  location_state VARCHAR(2),
  
  user_device VARCHAR(50),  -- "mobile", "desktop"
  event_data TEXT,  -- JSON for additional context
  
  created_at TIMESTAMP DEFAULT NOW() WITH TIME ZONE
);