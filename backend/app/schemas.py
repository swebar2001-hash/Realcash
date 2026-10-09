from pydantic import BaseModel, EmailStr, Field
from typing import Optional, List
from datetime import datetime

# Auth Schemas
class UserRegister(BaseModel):
    email: EmailStr
    password: str = Field(..., min_length=6)
    full_name: str
    phone: Optional[str] = None

class UserLogin(BaseModel):
    email: EmailStr
    password: str

class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    user_id: str
    email: str
    role: str
    full_name: str
    balance: float
    status: str

class UserProfile(BaseModel):
    id: str
    email: str
    phone: Optional[str]
    full_name: str
    role: str
    status: str
    balance: float
    has_deposited: bool
    has_played: bool
    created_at: datetime

# Wallet Schemas
class DepositRequest(BaseModel):
    amount: float = Field(..., description="Deposit amount (e.g., 100, 200, 500, 1000)")
    payment_method: str = "UPI Demo"

class WithdrawalRequest(BaseModel):
    amount: float = Field(..., description="Withdrawal amount (minimum Rs 800)")
    disclaimer_accepted: bool = True
    account_number: Optional[str] = None
    ifsc_code: Optional[str] = None

class LedgerEntryResponse(BaseModel):
    id: str
    amount: float
    transaction_type: str
    balance_before: float
    balance_after: float
    reference_id: str
    description: Optional[str]
    timestamp: datetime

# Daily Spin Schemas
class DailySpinResponse(BaseModel):
    amount_won: float
    new_balance: float
    message: str
    next_spin_available_at: datetime

# Games Schemas
class AviatorStartRequest(BaseModel):
    bet_amount: float

class AviatorCashoutRequest(BaseModel):
    game_id: str
    multiplier: float

class MinesStartRequest(BaseModel):
    bet_amount: float
    mines_count: int = Field(3, ge=1, le=24)

class MinesRevealRequest(BaseModel):
    game_id: str
    tile_index: int = Field(..., ge=0, le=24)

class ChickenRoadStepRequest(BaseModel):
    game_id: str
    lane_option: int

class CardGamePlayRequest(BaseModel):
    bet_amount: float
    guess: str # 'higher' or 'lower'

class TowerStepRequest(BaseModel):
    game_id: str
    choice: int # 0, 1, or 2

# Sports Schemas
class SportsBetRequest(BaseModel):
    event_id: str
    selection: str # 'team_a', 'draw', 'team_b'
    stake: float

# Admin Schemas
class UserStatusUpdate(BaseModel):
    status: str # 'active', 'restricted', 'suspended', 'closed'
