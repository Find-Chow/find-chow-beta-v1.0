"""
Authentication routes
Handles user signup, login, token refresh
"""

from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from database import get_db

router = APIRouter()

# TODO: Implement auth routes
# POST /auth/register - User signup
# POST /auth/login - User login
# GET /auth/me - Get current user
# POST /auth/logout - Logout
# POST /auth/refresh - Refresh token
