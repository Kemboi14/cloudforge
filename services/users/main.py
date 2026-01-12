from fastapi import FastAPI, HTTPException, Depends, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from pydantic import BaseModel, EmailStr
from typing import List, Optional
import os
import logging
from datetime import datetime
import httpx

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Environment variables
AUTH_SERVICE_URL = os.getenv("AUTH_SERVICE_URL", "http://auth-service:8001")
PORT = int(os.getenv("PORT", 8002))

# FastAPI app
app = FastAPI(
    title="Users Service",
    description="User management microservice for CloudForge Secure Platform",
    version="1.0.0"
)

# Security
security = HTTPBearer()

# Models
class UserBase(BaseModel):
    username: str
    email: str
    full_name: Optional[str] = None
    is_active: bool = True

class UserCreate(UserBase):
    password: str

class UserUpdate(BaseModel):
    email: Optional[EmailStr] = None
    full_name: Optional[str] = None
    is_active: Optional[bool] = None

class UserResponse(UserBase):
    id: int
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True

# Mock user database (in production, use a real database)
class MockUserDB:
    def __init__(self):
        self.users = {}
        self.next_id = 1
        # Add some initial users
        self._create_initial_users()
    
    def _create_initial_users(self):
        initial_users = [
            {"username": "admin", "email": "admin@cloudforge.com", "full_name": "Administrator"},
            {"username": "user", "email": "user@cloudforge.com", "full_name": "Test User"}
        ]
        for user_data in initial_users:
            self.create_user(UserCreate(**user_data, password="temp123"))
    
    def create_user(self, user: UserCreate) -> UserResponse:
        user_dict = user.model_dump(exclude={"password"})
        user_dict["id"] = self.next_id
        user_dict["created_at"] = datetime.utcnow()
        user_dict["updated_at"] = datetime.utcnow()
        
        self.users[self.next_id] = user_dict
        self.next_id += 1
        
        return UserResponse(**user_dict)
    
    def get_user(self, user_id: int) -> Optional[UserResponse]:
        user = self.users.get(user_id)
        return UserResponse(**user) if user else None
    
    def get_user_by_username(self, username: str) -> Optional[UserResponse]:
        for user in self.users.values():
            if user["username"] == username:
                return UserResponse(**user)
        return None
    
    def get_all_users(self) -> List[UserResponse]:
        return [UserResponse(**user) for user in self.users.values()]
    
    def update_user(self, user_id: int, user_update: UserUpdate) -> Optional[UserResponse]:
        if user_id not in self.users:
            return None
        
        user = self.users[user_id]
        update_data = user_update.model_dump(exclude_unset=True)
        
        for field, value in update_data.items():
            user[field] = value
        
        user["updated_at"] = datetime.utcnow()
        return UserResponse(**user)
    
    def delete_user(self, user_id: int) -> bool:
        if user_id in self.users:
            del self.users[user_id]
            return True
        return False

user_db = MockUserDB()

async def verify_token_with_auth_service(token: str) -> bool:
    """Verify token with auth service"""
    try:
        async with httpx.AsyncClient() as client:
            response = await client.post(
                f"{AUTH_SERVICE_URL}/validate",
                headers={"Authorization": f"Bearer {token}"}
            )
            return response.status_code == 200
    except Exception as e:
        logger.error(f"Error validating token: {e}")
        return False

async def get_current_user(credentials: HTTPAuthorizationCredentials = Depends(security)):
    """Get current user by validating token with auth service"""
    token = credentials.credentials
    is_valid = await verify_token_with_auth_service(token)
    
    if not is_valid:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid authentication credentials",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
    # Extract username from token (simplified - in production, decode JWT properly)
    # For now, we'll just return a placeholder
    return {"username": "authenticated_user"}

# Routes
@app.get("/")
async def root():
    return {"message": "Users Service is running", "service": "cloudforge-users"}

@app.get("/health")
async def health_check():
    return {"status": "healthy", "service": "users"}

@app.post("/users", response_model=UserResponse)
async def create_user(user: UserCreate, current_user: dict = Depends(get_current_user)):
    """Create a new user"""
    # Check if user already exists
    existing_user = user_db.get_user_by_username(user.username)
    if existing_user:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Username already registered"
        )
    
    return user_db.create_user(user)

@app.get("/users", response_model=List[UserResponse])
async def get_users(current_user: dict = Depends(get_current_user)):
    """Get all users"""
    return user_db.get_all_users()

@app.get("/users/{user_id}", response_model=UserResponse)
async def get_user(user_id: int, current_user: dict = Depends(get_current_user)):
    """Get user by ID"""
    user = user_db.get_user(user_id)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found"
        )
    return user

@app.put("/users/{user_id}", response_model=UserResponse)
async def update_user(
    user_id: int, 
    user_update: UserUpdate, 
    current_user: dict = Depends(get_current_user)
):
    """Update user"""
    user = user_db.update_user(user_id, user_update)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found"
        )
    return user

@app.delete("/users/{user_id}")
async def delete_user(user_id: int, current_user: dict = Depends(get_current_user)):
    """Delete user"""
    success = user_db.delete_user(user_id)
    if not success:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found"
        )
    return {"message": "User deleted successfully"}

@app.get("/users/me", response_model=UserResponse)
async def get_current_user_info(current_user: dict = Depends(get_current_user)):
    """Get current user info"""
    username = current_user.get("username")
    user = user_db.get_user_by_username(username)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found"
        )
    return user

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=PORT)
