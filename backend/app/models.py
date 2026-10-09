from datetime import datetime, timezone
import uuid
from sqlalchemy import (
    Column, String, Float, Boolean, DateTime, Integer, ForeignKey, Text, Enum
)
from sqlalchemy.orm import relationship
from app.database import Base

def utc_now():
    return datetime.now(timezone.utc)

def generate_uuid():
    return str(uuid.uuid4())

class User(Base):
    __tablename__ = "users"

    id = Column(String, primary_key=True, default=generate_uuid)
    email = Column(String, unique=True, index=True, nullable=False)
    phone = Column(String, unique=True, index=True, nullable=True)
    hashed_password = Column(String, nullable=False)
    full_name = Column(String, nullable=False, default="Player")
    role = Column(String, nullable=False, default="user") # 'user', 'admin'
    status = Column(String, nullable=False, default="active") # 'pending', 'active', 'restricted', 'suspended', 'closed'
    balance = Column(Float, nullable=False, default=0.0)
    has_deposited = Column(Boolean, nullable=False, default=False)
    has_played = Column(Boolean, nullable=False, default=False)
    created_at = Column(DateTime, default=utc_now)
    updated_at = Column(DateTime, default=utc_now, onupdate=utc_now)

    ledger_entries = relationship("WalletLedger", back_populates="user", cascade="all, delete-orphan")
    transactions = relationship("Transaction", back_populates="user", cascade="all, delete-orphan")
    daily_spins = relationship("DailySpin", back_populates="user", cascade="all, delete-orphan")
    game_sessions = relationship("GameSession", back_populates="user", cascade="all, delete-orphan")

class WalletLedger(Base):
    __tablename__ = "wallet_ledger"

    id = Column(String, primary_key=True, default=generate_uuid)
    user_id = Column(String, ForeignKey("users.id"), nullable=False, index=True)
    amount = Column(Float, nullable=False)
    transaction_type = Column(String, nullable=False) # 'deposit', 'withdrawal', 'game_wager', 'game_payout', 'daily_spin', 'admin_adjustment'
    balance_before = Column(Float, nullable=False)
    balance_after = Column(Float, nullable=False)
    reference_id = Column(String, nullable=False, index=True)
    description = Column(String, nullable=True)
    timestamp = Column(DateTime, default=utc_now, index=True)

    user = relationship("User", back_populates="ledger_entries")

class Transaction(Base):
    __tablename__ = "transactions"

    id = Column(String, primary_key=True, default=generate_uuid)
    tx_ref = Column(String, unique=True, nullable=False, index=True)
    user_id = Column(String, ForeignKey("users.id"), nullable=False, index=True)
    type = Column(String, nullable=False) # 'deposit', 'withdrawal'
    amount = Column(Float, nullable=False)
    status = Column(String, nullable=False, default="pending") # 'pending', 'completed', 'failed', 'reversed'
    disclaimer_accepted = Column(Boolean, default=True)
    payment_method = Column(String, default="UPI / Demo Gateway")
    created_at = Column(DateTime, default=utc_now)

    user = relationship("User", back_populates="transactions")

class DailySpin(Base):
    __tablename__ = "daily_spins"

    id = Column(String, primary_key=True, default=generate_uuid)
    user_id = Column(String, ForeignKey("users.id"), nullable=False, index=True)
    amount_won = Column(Float, nullable=False) # 0 to 10
    spun_at = Column(DateTime, default=utc_now)

    user = relationship("User", back_populates="daily_spins")

class GameSession(Base):
    __tablename__ = "game_sessions"

    id = Column(String, primary_key=True, default=generate_uuid)
    user_id = Column(String, ForeignKey("users.id"), nullable=False, index=True)
    game_type = Column(String, nullable=False) # 'aviator', 'chicken_road', 'mines', 'card', 'tower'
    bet_amount = Column(Float, nullable=False)
    multiplier = Column(Float, default=1.0)
    payout = Column(Float, default=0.0)
    status = Column(String, nullable=False, default="active") # 'active', 'cashed_out', 'crashed', 'lost'
    server_seed = Column(String, nullable=False)
    game_state = Column(Text, nullable=True) # JSON string representation of game grid/deck
    created_at = Column(DateTime, default=utc_now)

    user = relationship("User", back_populates="game_sessions")

class SportsEvent(Base):
    __tablename__ = "sports_events"

    id = Column(String, primary_key=True, default=generate_uuid)
    sport = Column(String, nullable=False, index=True) # 'football', 'cricket', 'tennis', 'basketball'
    tournament = Column(String, nullable=False)
    team_a = Column(String, nullable=False)
    team_b = Column(String, nullable=False)
    team_a_logo = Column(String, nullable=True)
    team_b_logo = Column(String, nullable=True)
    start_time = Column(DateTime, nullable=False)
    status = Column(String, nullable=False, default="upcoming") # 'upcoming', 'live', 'completed'
    score_a = Column(String, default="0")
    score_b = Column(String, default="0")
    
    # Odds
    odds_team_a = Column(Float, default=1.95)
    odds_draw = Column(Float, default=3.20)
    odds_team_b = Column(Float, default=2.10)

class SportsBet(Base):
    __tablename__ = "sports_bets"

    id = Column(String, primary_key=True, default=generate_uuid)
    user_id = Column(String, ForeignKey("users.id"), nullable=False, index=True)
    event_id = Column(String, ForeignKey("sports_events.id"), nullable=False)
    selection = Column(String, nullable=False) # 'team_a', 'draw', 'team_b'
    odds = Column(Float, nullable=False)
    stake = Column(Float, nullable=False)
    potential_payout = Column(Float, nullable=False)
    status = Column(String, nullable=False, default="open") # 'open', 'won', 'lost', 'cashed_out'
    created_at = Column(DateTime, default=utc_now)

class AdminAuditLog(Base):
    __tablename__ = "admin_audit_logs"

    id = Column(String, primary_key=True, default=generate_uuid)
    admin_id = Column(String, nullable=False)
    action = Column(String, nullable=False)
    target_user_id = Column(String, nullable=True)
    details = Column(Text, nullable=True)
    timestamp = Column(DateTime, default=utc_now)

class ResponsibleGamingLimit(Base):
    __tablename__ = "responsible_gaming_limits"

    id = Column(String, primary_key=True, default=generate_uuid)
    user_id = Column(String, ForeignKey("users.id"), nullable=False, unique=True)
    daily_deposit_limit = Column(Float, default=10000.0)
    daily_spend_limit = Column(Float, default=5000.0)
    session_limit_minutes = Column(Integer, default=120)
    self_excluded_until = Column(DateTime, nullable=True)
