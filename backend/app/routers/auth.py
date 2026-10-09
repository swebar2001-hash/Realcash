from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from app.database import get_db
from app.models import User, WalletLedger
from app.schemas import UserRegister, UserLogin, TokenResponse, UserProfile
from app.security import hash_password, verify_password, create_access_token, get_current_user
import uuid

router = APIRouter(prefix="/api/auth", tags=["Authentication"])

@router.post("/register", response_model=TokenResponse)
async def register(user_data: UserRegister, db: AsyncSession = Depends(get_db)):
    # Check existing email
    result = await db.execute(select(User).where(User.email == user_data.email))
    if result.scalars().first():
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Email address already registered"
        )
    
    # Check admin email convention
    role = "admin" if user_data.email.lower().startswith("admin@") else "user"

    new_user = User(
        email=user_data.email.lower(),
        phone=user_data.phone,
        hashed_password=hash_password(user_data.password),
        full_name=user_data.full_name,
        role=role,
        balance=0.0,
        status="active"
    )

    db.add(new_user)
    await db.commit()
    await db.refresh(new_user)

    token = create_access_token(data={"sub": new_user.id, "role": new_user.role})

    return TokenResponse(
        access_token=token,
        user_id=new_user.id,
        email=new_user.email,
        role=new_user.role,
        full_name=new_user.full_name,
        balance=new_user.balance,
        status=new_user.status
    )

@router.post("/login", response_model=TokenResponse)
async def login(credentials: UserLogin, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(User).where(User.email == credentials.email.lower()))
    user = result.scalars().first()

    if not user or not verify_password(credentials.password, user.hashed_password):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid email or password"
        )

    if user.status in ["suspended", "closed"]:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail=f"Account is {user.status}. Please contact support."
        )

    token = create_access_token(data={"sub": user.id, "role": user.role})

    return TokenResponse(
        access_token=token,
        user_id=user.id,
        email=user.email,
        role=user.role,
        full_name=user.full_name,
        balance=user.balance,
        status=user.status
    )

@router.get("/me", response_model=UserProfile)
async def get_me(current_user: User = Depends(get_current_user)):
    return UserProfile(
        id=current_user.id,
        email=current_user.email,
        phone=current_user.phone,
        full_name=current_user.full_name,
        role=current_user.role,
        status=current_user.status,
        balance=current_user.balance,
        has_deposited=current_user.has_deposited,
        has_played=current_user.has_played,
        created_at=current_user.created_at
    )
