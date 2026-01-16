"""
Initialize database - Create all tables
Run this once to set up the database schema
"""

from database import engine
import models

def init_db():
    """Create all database tables"""
    models.Base.metadata.create_all(bind=engine)
    print("✅ Database tables created successfully!")

if __name__ == "__main__":
    init_db()
