from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from datetime import datetime, timedelta, timezone
import random
import json
import uuid

from app.database import get_db
from app.models import User, DailySpin, GameSession, WalletLedger
from app.schemas import (
    DailySpinResponse, AviatorStartRequest, AviatorCashoutRequest,
    MinesStartRequest, MinesRevealRequest, ChickenRoadStepRequest,
    CardGamePlayRequest, TowerStepRequest
)
from app.security import get_current_user

router = APIRouter(prefix="/api/games", tags=["Casino Games"])

# Daily Spin Wheel Config
SPIN_REWARDS = [0.0, 1.0, 2.0, 3.0, 5.0, 7.0, 10.0]

@router.post("/spin/claim", response_model=DailySpinResponse)
async def claim_daily_spin(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    now = datetime.now(timezone.utc)
    
    # Check last spin time
    result = await db.execute(
        select(DailySpin)
        .where(DailySpin.user_id == current_user.id)
        .order_by(DailySpin.spun_at.desc())
    )
    last_spin = result.scalars().first()

    if last_spin:
        # Normalize timezone
        spun_at = last_spin.spun_at.replace(tzinfo=timezone.utc) if last_spin.spun_at.tzinfo is None else last_spin.spun_at
        if now < spun_at + timedelta(hours=24):
            next_available = spun_at + timedelta(hours=24)
            time_left = next_available - now
            hours, remainder = divmod(time_left.seconds, 3600)
            minutes, _ = divmod(remainder, 60)
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Daily spin already claimed! Next spin available in {hours}h {minutes}m."
            )

    # Server RNG reward Rs 0 to Rs 10
    won_amount = random.choice(SPIN_REWARDS)
    balance_before = current_user.balance
    balance_after = balance_before + won_amount

    current_user.balance = balance_after

    # Save Spin record
    spin = DailySpin(
        user_id=current_user.id,
        amount_won=won_amount,
        spun_at=now
    )
    db.add(spin)

    # Add ledger entry
    ledger = WalletLedger(
        user_id=current_user.id,
        amount=won_amount,
        transaction_type="daily_spin",
        balance_before=balance_before,
        balance_after=balance_after,
        reference_id=f"SPIN-{uuid.uuid4().hex[:8]}",
        description=f"Free Daily Spin reward of Rs {won_amount:.2f}"
    )
    db.add(ledger)

    await db.commit()

    return DailySpinResponse(
        amount_won=won_amount,
        new_balance=balance_after,
        message=f"Congratulations! You won Rs {won_amount:.2f} from your Daily Spin!" if won_amount > 0 else "Better luck tomorrow! You landed on Rs 0.",
        next_spin_available_at=now + timedelta(hours=24)
    )

@router.get("/spin/status")
async def spin_status(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    now = datetime.now(timezone.utc)
    result = await db.execute(
        select(DailySpin)
        .where(DailySpin.user_id == current_user.id)
        .order_by(DailySpin.spun_at.desc())
    )
    last_spin = result.scalars().first()

    if not last_spin:
        return {"can_spin": True, "next_spin_available_at": None, "hours_left": 0}

    spun_at = last_spin.spun_at.replace(tzinfo=timezone.utc) if last_spin.spun_at.tzinfo is None else last_spin.spun_at
    if now >= spun_at + timedelta(hours=24):
        return {"can_spin": True, "next_spin_available_at": None, "hours_left": 0}

    next_spin = spun_at + timedelta(hours=24)
    time_left = next_spin - now
    return {
        "can_spin": False,
        "next_spin_available_at": next_spin.isoformat(),
        "hours_left": round(time_left.total_seconds() / 3600.0, 1)
    }

# ==================== AVIATOR GAME ====================
@router.post("/aviator/start")
async def start_aviator(
    req: AviatorStartRequest,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    if current_user.balance < req.bet_amount or req.bet_amount <= 0:
        raise HTTPException(status_code=400, detail="Insufficient balance for Aviator bet.")

    # Server generates crash point using exponential curve (1.01x to 100.0x)
    raw_val = random.random()
    crash_multiplier = max(1.01, round(0.99 / (1.0 - raw_val + 0.001), 2))
    if crash_multiplier > 50.0:
        crash_multiplier = round(random.uniform(5.0, 30.0), 2)

    balance_before = current_user.balance
    balance_after = balance_before - req.bet_amount

    current_user.balance = balance_after
    current_user.has_played = True

    session_id = f"AVI-{uuid.uuid4().hex[:10]}"
    server_seed = uuid.uuid4().hex

    session = GameSession(
        id=session_id,
        user_id=current_user.id,
        game_type="aviator",
        bet_amount=req.bet_amount,
        status="active",
        server_seed=server_seed,
        game_state=json.dumps({"crash_point": crash_multiplier})
    )
    db.add(session)

    ledger = WalletLedger(
        user_id=current_user.id,
        amount=-req.bet_amount,
        transaction_type="game_wager",
        balance_before=balance_before,
        balance_after=balance_after,
        reference_id=session_id,
        description=f"Aviator game bet Rs {req.bet_amount:.2f}"
    )
    db.add(ledger)

    await db.commit()

    return {
        "game_id": session_id,
        "bet_amount": req.bet_amount,
        "new_balance": balance_after,
        "message": "Aviator round started!"
    }

@router.post("/aviator/cashout")
async def cashout_aviator(
    req: AviatorCashoutRequest,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    result = await db.execute(select(GameSession).where(GameSession.id == req.game_id, GameSession.user_id == current_user.id))
    session = result.scalars().first()

    if not session or session.status != "active":
        raise HTTPException(status_code=400, detail="Invalid or inactive Aviator game session.")

    state = json.loads(session.game_state)
    crash_point = state["crash_point"]

    if req.multiplier > crash_point:
        session.status = "crashed"
        session.multiplier = crash_point
        session.payout = 0.0
        await db.commit()
        return {
            "success": False,
            "status": "crashed",
            "crash_point": crash_point,
            "message": f"Plane flew away at {crash_point:.2f}x! You lost Rs {session.bet_amount:.2f}."
        }

    payout = round(session.bet_amount * req.multiplier, 2)
    balance_before = current_user.balance
    balance_after = balance_before + payout

    current_user.balance = balance_after
    session.status = "cashed_out"
    session.multiplier = req.multiplier
    session.payout = payout

    ledger = WalletLedger(
        user_id=current_user.id,
        amount=payout,
        transaction_type="game_payout",
        balance_before=balance_before,
        balance_after=balance_after,
        reference_id=f"PAY-{session.id}",
        description=f"Aviator Cashout at {req.multiplier:.2f}x (Payout Rs {payout:.2f})"
    )
    db.add(ledger)

    await db.commit()

    return {
        "success": True,
        "status": "cashed_out",
        "multiplier": req.multiplier,
        "payout": payout,
        "new_balance": balance_after,
        "crash_point": crash_point
    }

# ==================== MINES GAME ====================
@router.post("/mines/start")
async def start_mines(
    req: MinesStartRequest,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    if current_user.balance < req.bet_amount or req.bet_amount <= 0:
        raise HTTPException(status_code=400, detail="Insufficient balance for Mines bet.")

    # 5x5 Grid (25 tiles)
    mine_positions = random.sample(range(25), req.mines_count)
    balance_before = current_user.balance
    balance_after = balance_before - req.bet_amount

    current_user.balance = balance_after
    current_user.has_played = True

    session_id = f"MNE-{uuid.uuid4().hex[:10]}"
    session = GameSession(
        id=session_id,
        user_id=current_user.id,
        game_type="mines",
        bet_amount=req.bet_amount,
        status="active",
        server_seed=uuid.uuid4().hex,
        game_state=json.dumps({
            "mines": mine_positions,
            "revealed": [],
            "mines_count": req.mines_count,
            "current_multiplier": 1.0
        })
    )
    db.add(session)

    ledger = WalletLedger(
        user_id=current_user.id,
        amount=-req.bet_amount,
        transaction_type="game_wager",
        balance_before=balance_before,
        balance_after=balance_after,
        reference_id=session_id,
        description=f"Mines game bet Rs {req.bet_amount:.2f}"
    )
    db.add(ledger)

    await db.commit()

    return {
        "game_id": session_id,
        "bet_amount": req.bet_amount,
        "mines_count": req.mines_count,
        "new_balance": balance_after
    }

@router.post("/mines/reveal")
async def reveal_mines_tile(
    req: MinesRevealRequest,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    result = await db.execute(select(GameSession).where(GameSession.id == req.game_id, GameSession.user_id == current_user.id))
    session = result.scalars().first()

    if not session or session.status != "active":
        raise HTTPException(status_code=400, detail="Invalid or inactive Mines session.")

    state = json.loads(session.game_state)
    mines = state["mines"]
    revealed = state["revealed"]

    if req.tile_index in revealed:
        raise HTTPException(status_code=400, detail="Tile already revealed.")

    if req.tile_index in mines:
        session.status = "lost"
        session.payout = 0.0
        await db.commit()
        return {
            "status": "lost",
            "hit_mine": True,
            "all_mines": mines,
            "message": f"BOOM! You hit a mine at tile #{req.tile_index}. Bet lost."
        }

    revealed.append(req.tile_index)
    safe_count = len(revealed)
    mines_count = state["mines_count"]
    # Multiplier formula
    multiplier = round(1.0 + (safe_count * (0.15 + (mines_count * 0.08))), 2)
    state["revealed"] = revealed
    state["current_multiplier"] = multiplier
    session.game_state = json.dumps(state)

    await db.commit()

    return {
        "status": "active",
        "hit_mine": False,
        "tile_index": req.tile_index,
        "safe_count": safe_count,
        "current_multiplier": multiplier,
        "potential_payout": round(session.bet_amount * multiplier, 2)
    }

@router.post("/mines/cashout")
async def cashout_mines(
    game_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    result = await db.execute(select(GameSession).where(GameSession.id == game_id, GameSession.user_id == current_user.id))
    session = result.scalars().first()

    if not session or session.status != "active":
        raise HTTPException(status_code=400, detail="Invalid session.")

    state = json.loads(session.game_state)
    multiplier = state.get("current_multiplier", 1.0)
    payout = round(session.bet_amount * multiplier, 2)

    balance_before = current_user.balance
    balance_after = balance_before + payout

    current_user.balance = balance_after
    session.status = "cashed_out"
    session.multiplier = multiplier
    session.payout = payout

    ledger = WalletLedger(
        user_id=current_user.id,
        amount=payout,
        transaction_type="game_payout",
        balance_before=balance_before,
        balance_after=balance_after,
        reference_id=f"PAY-{session.id}",
        description=f"Mines Cashout at {multiplier:.2f}x (Payout Rs {payout:.2f})"
    )
    db.add(ledger)

    await db.commit()

    return {
        "success": True,
        "multiplier": multiplier,
        "payout": payout,
        "new_balance": balance_after,
        "all_mines": state["mines"]
    }

# ==================== CHICKEN ROAD ====================
@router.post("/chicken-road/start")
async def start_chicken_road(
    bet_amount: float,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    if current_user.balance < bet_amount or bet_amount <= 0:
        raise HTTPException(status_code=400, detail="Insufficient balance.")

    # 10 step road, each step has 1 trapped lane out of 4
    traps = [random.randint(0, 3) for _ in range(10)]
    balance_before = current_user.balance
    balance_after = balance_before - bet_amount

    current_user.balance = balance_after
    current_user.has_played = True

    session_id = f"CHK-{uuid.uuid4().hex[:10]}"
    session = GameSession(
        id=session_id,
        user_id=current_user.id,
        game_type="chicken_road",
        bet_amount=bet_amount,
        status="active",
        server_seed=uuid.uuid4().hex,
        game_state=json.dumps({"traps": traps, "step": 0, "multiplier": 1.0})
    )
    db.add(session)

    ledger = WalletLedger(
        user_id=current_user.id,
        amount=-bet_amount,
        transaction_type="game_wager",
        balance_before=balance_before,
        balance_after=balance_after,
        reference_id=session_id,
        description=f"Chicken Road bet Rs {bet_amount:.2f}"
    )
    db.add(ledger)

    await db.commit()

    return {"game_id": session_id, "bet_amount": bet_amount, "new_balance": balance_after}

@router.post("/chicken-road/step")
async def step_chicken_road(
    req: ChickenRoadStepRequest,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    result = await db.execute(select(GameSession).where(GameSession.id == req.game_id, GameSession.user_id == current_user.id))
    session = result.scalars().first()

    if not session or session.status != "active":
        raise HTTPException(status_code=400, detail="Invalid session.")

    state = json.loads(session.game_state)
    step = state["step"]
    traps = state["traps"]

    if req.lane_option == traps[step]:
        session.status = "lost"
        await db.commit()
        return {"status": "lost", "hit_trap": True, "message": "Chicken roasted! You hit a car trap."}

    step += 1
    new_multiplier = round(1.0 + (step * 0.35), 2)
    state["step"] = step
    state["multiplier"] = new_multiplier
    session.game_state = json.dumps(state)

    await db.commit()

    return {
        "status": "active",
        "hit_trap": False,
        "current_step": step,
        "current_multiplier": new_multiplier,
        "potential_payout": round(session.bet_amount * new_multiplier, 2)
    }

# ==================== CARD GAME (Hi-Lo) ====================
@router.post("/card/play")
async def play_card_game(
    req: CardGamePlayRequest,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    if current_user.balance < req.bet_amount or req.bet_amount <= 0:
        raise HTTPException(status_code=400, detail="Insufficient balance.")

    card_a = random.randint(1, 13)
    card_b = random.randint(1, 13)
    while card_b == card_a:
        card_b = random.randint(1, 13)

    is_higher = card_b > card_a
    won = (req.guess == "higher" and is_higher) or (req.guess == "lower" and not is_higher)

    balance_before = current_user.balance
    payout = round(req.bet_amount * 1.90, 2) if won else 0.0
    balance_after = balance_before - req.bet_amount + payout

    current_user.balance = balance_after
    current_user.has_played = True

    session_id = f"CRD-{uuid.uuid4().hex[:8]}"

    ledger = WalletLedger(
        user_id=current_user.id,
        amount=payout - req.bet_amount,
        transaction_type="game_payout" if won else "game_wager",
        balance_before=balance_before,
        balance_after=balance_after,
        reference_id=session_id,
        description=f"Card Hi-Lo ({req.guess}) - Card A: {card_a}, Card B: {card_b}"
    )
    db.add(ledger)

    await db.commit()

    return {
        "card_a": card_a,
        "card_b": card_b,
        "guess": req.guess,
        "won": won,
        "payout": payout,
        "new_balance": balance_after
    }
