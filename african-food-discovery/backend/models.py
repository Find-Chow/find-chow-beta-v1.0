"""
SQLAlchemy ORM models
Defines all database tables
"""

from sqlalchemy import (
    Column, Integer, String, Float, Boolean, DateTime, 
    Text, ForeignKey, Enum as SQLEnum
)
from sqlalchemy.orm import relationship
from datetime import datetime
from database import Base

# ============================================
# USERS TABLE
# ============================================

class User(Base):
    __tablename__ = "users"
    
    id = Column(Integer, primary_key=True)
    email = Column(String, unique=True, index=True, nullable=False)
    username = Column(String, unique=True, index=True, nullable=False)
    password_hash = Column(String, nullable=False)
    first_name = Column(String)
    last_name = Column(String)
    phone = Column(String)
    location_zip = Column(String)
    location_city = Column(String)
    location_state = Column(String)
    preferred_language = Column(String, default="en")
    reputation_score = Column(Integer, default=0)
    verified_shopper = Column(Boolean, default=False)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    deleted_at = Column(DateTime, nullable=True)
    
    # Relationships
    reviews = relationship("Review", back_populates="user", cascade="all, delete-orphan")
    qa_questions = relationship("QA", back_populates="user", cascade="all, delete-orphan")
    favorites = relationship("Favorite", back_populates="user", cascade="all, delete-orphan")

# ============================================
# PLACES TABLE (Stores, Restaurants, Markets)
# ============================================

class Place(Base):
    __tablename__ = "places"
    
    id = Column(Integer, primary_key=True)
    name = Column(String, nullable=False, index=True)
    description = Column(Text)
    address = Column(String, nullable=False)
    city = Column(String, nullable=False, index=True)
    state = Column(String)
    zip_code = Column(String)
    country = Column(String, default="US")
    latitude = Column(Float)
    longitude = Column(Float)
    phone = Column(String)
    website_url = Column(String)
    whatsapp_number = Column(String)
    email = Column(String)
    place_type = Column(String)  # grocery, restaurant, butcher, bakery, market
    specialization = Column(String)  # West African, East African, Pan-African
    description_short = Column(Text)
    languages_spoken = Column(Text)  # JSON: ["English", "Yoruba", "Spanish"]
    accepts_cash = Column(Boolean, default=True)
    accepts_card = Column(Boolean, default=True)
    accepts_mobile_payment = Column(Boolean, default=False)
    has_parking = Column(Boolean, default=False)
    delivery_available = Column(Boolean, default=False)
    delivery_services = Column(Text)  # JSON: ["DoorDash", "UberEats"]
    delivery_notes = Column(String)  # Free delivery, minimum order, etc
    
    # Hours (HH:MM-HH:MM format, e.g., "09:00-21:00")
    hours_monday = Column(String)
    hours_tuesday = Column(String)
    hours_wednesday = Column(String)
    hours_thursday = Column(String)
    hours_friday = Column(String)
    hours_saturday = Column(String)
    hours_sunday = Column(String)
    
    # Rating and metrics
    rating = Column(Float, default=0.0)
    review_count = Column(Integer, default=0)
    views_count = Column(Integer, default=0)
    owner_verified = Column(Boolean, default=False)
    owner_name = Column(String)
    
    # Timestamps
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    deleted_at = Column(DateTime, nullable=True)
    
    # Relationships
    products = relationship("PlaceProduct", back_populates="place", cascade="all, delete-orphan")
    reviews = relationship("Review", back_populates="place", cascade="all, delete-orphan")
    qa = relationship("QA", back_populates="place", cascade="all, delete-orphan")
    favorites = relationship("Favorite", back_populates="place", cascade="all, delete-orphan")

# ============================================
# PRODUCTS TABLE
# ============================================

class Product(Base):
    __tablename__ = "products"
    
    id = Column(Integer, primary_key=True)
    name = Column(String, nullable=False, index=True)
    description = Column(Text)
    category = Column(String)  # grains, spices, proteins, produce, pantry
    cuisine_region = Column(String)  # West African, East African, Southern African
    english_name = Column(String)
    alternative_names = Column(Text)  # JSON: ["Gari", "Fermented cassava"]
    spanish_name = Column(String)
    brand = Column(String)
    origin_country = Column(String)  # Ghana, Nigeria, Cameroon, etc
    image_url = Column(String)
    image_thumbnail_url = Column(String)
    search_keywords = Column(Text)  # For SEO: "cassava, gari, flour"
    
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    deleted_at = Column(DateTime, nullable=True)
    
    # Relationships
    places = relationship("PlaceProduct", back_populates="product", cascade="all, delete-orphan")
    reviews = relationship("Review", back_populates="product", cascade="all, delete-orphan")
    qa = relationship("QA", back_populates="product", cascade="all, delete-orphan")
    favorites = relationship("Favorite", back_populates="product", cascade="all, delete-orphan")

# ============================================
# PLACE_PRODUCTS TABLE (Inventory Mapping)
# ============================================

class PlaceProduct(Base):
    __tablename__ = "place_products"
    
    id = Column(Integer, primary_key=True)
    place_id = Column(Integer, ForeignKey("places.id"), nullable=False, index=True)
    product_id = Column(Integer, ForeignKey("products.id"), nullable=False, index=True)
    
    # Availability (not real-time, just "commonly available here?")
    commonly_available = Column(Boolean, default=True)
    typical_price = Column(Float)
    currency = Column(String, default="USD")
    notes = Column(String)  # "Fresh on weekends", "Frozen only", etc
    last_verified_at = Column(DateTime)
    
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Relationships
    place = relationship("Place", back_populates="products")
    product = relationship("Product", back_populates="places")

# ============================================
# REVIEWS TABLE
# ============================================

class Review(Base):
    __tablename__ = "reviews"
    
    id = Column(Integer, primary_key=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False, index=True)
    place_id = Column(Integer, ForeignKey("places.id"), nullable=False, index=True)
    product_id = Column(Integer, ForeignKey("products.id"), nullable=True)
    
    # Review content
    rating = Column(Integer, nullable=False)  # 1-5
    title = Column(String)
    review_text = Column(Text, nullable=False)
    review_type = Column(String)  # general, product_availability, freshness, service, pricing
    
    # Product-specific fields
    product_availability = Column(String)  # In stock, Out of stock, Just arrived
    freshness_rating = Column(String)  # Fresh today, Looks good, Older stock
    
    # Media
    photos = Column(Text)  # JSON array of URLs
    photo_count = Column(Integer, default=0)
    
    # Engagement
    helpful_count = Column(Integer, default=0)
    unhelpful_count = Column(Integer, default=0)
    
    # Moderation
    approved = Column(Boolean, default=False)
    flagged = Column(Boolean, default=False)
    flag_reason = Column(String)
    
    # Owner response
    owner_response = Column(Text)
    owner_response_date = Column(DateTime)
    
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    deleted_at = Column(DateTime, nullable=True)
    
    # Relationships
    user = relationship("User", back_populates="reviews")
    place = relationship("Place", back_populates="reviews")
    product = relationship("Product", back_populates="reviews")

# ============================================
# QA TABLE (Questions)
# ============================================

class QA(Base):
    __tablename__ = "qa"
    
    id = Column(Integer, primary_key=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False, index=True)
    place_id = Column(Integer, ForeignKey("places.id"), nullable=True, index=True)
    product_id = Column(Integer, ForeignKey("products.id"), nullable=True, index=True)
    
    question_text = Column(Text, nullable=False)
    question_category = Column(String)  # product, place, delivery, availability, recommendation
    
    # Engagement
    answer_count = Column(Integer, default=0)
    answered = Column(Boolean, default=False)
    helpful_count = Column(Integer, default=0)
    
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Relationships
    user = relationship("User", back_populates="qa_questions")
    place = relationship("Place", back_populates="qa")
    product = relationship("Product", back_populates="qa")
    answers = relationship("QAAnswer", back_populates="qa", cascade="all, delete-orphan")

# ============================================
# QA_ANSWERS TABLE (Answers to Questions)
# ============================================

class QAAnswer(Base):
    __tablename__ = "qa_answers"
    
    id = Column(Integer, primary_key=True)
    qa_id = Column(Integer, ForeignKey("qa.id"), nullable=False, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False, index=True)
    answer_text = Column(Text, nullable=False)
    place_verified = Column(Boolean, default=False)
    helpful_count = Column(Integer, default=0)
    unhelpful_count = Column(Integer, default=0)
    
    created_at = Column(DateTime, default=datetime.utcnow)
    
    # Relationships
    qa = relationship("QA", back_populates="answers")

# ============================================
# FAVORITES TABLE (Bookmarks)
# ============================================

class Favorite(Base):
    __tablename__ = "favorites"
    
    id = Column(Integer, primary_key=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False, index=True)
    place_id = Column(Integer, ForeignKey("places.id"), nullable=True)
    product_id = Column(Integer, ForeignKey("products.id"), nullable=True)
    
    created_at = Column(DateTime, default=datetime.utcnow)
    
    # Relationships
    user = relationship("User", back_populates="favorites")
    place = relationship("Place", back_populates="favorites")
    product = relationship("Product", back_populates="favorites")

# ============================================
# ANALYTICS_EVENTS TABLE
# ============================================

class AnalyticsEvent(Base):
    __tablename__ = "analytics_events"
    
    id = Column(Integer, primary_key=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=True)
    
    event_type = Column(String, nullable=False, index=True)  # product_search, place_view, click_directions
    search_query = Column(String)
    
    product_id = Column(Integer, ForeignKey("products.id"), nullable=True)
    place_id = Column(Integer, ForeignKey("places.id"), nullable=True)
    
    location_zip = Column(String)
    location_city = Column(String)
    location_state = Column(String)
    
    user_device = Column(String)  # mobile, desktop
    event_data = Column(Text)  # JSON for additional context
    
    created_at = Column(DateTime, default=datetime.utcnow, index=True)
