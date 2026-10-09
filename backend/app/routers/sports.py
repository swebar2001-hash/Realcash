from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from typing import Optional, List
from datetime import datetime, timedelta, timezone
import uuid

from app.database import get_db
from app.models import User, SportsEvent, SportsBet, WalletLedger
from app.schemas import SportsBetRequest
from app.security import get_current_user

router = APIRouter(prefix="/api/sports", tags=["Sports Betting"])

SAMPLE_EVENTS = [
    {
        "sport": "cricket",
        "tournament": "IPL Premier League 2026",
        "team_a": "Mumbai Indians",
        "team_b": "Chennai Super Kings",
        "score_a": "184/5 (19.2)",
        "score_b": "182/6 (20.0)",
        "status": "live",
        "odds_team_a": 1.75,
        "odds_draw": 15.00,
        "odds_team_b": 2.10
    },
    {
        "sport": "football",
        "tournament": "UEFA Champions League",
        "team_a": "Real Madrid",
        "team_b": "Manchester City",
        "score_a": "2",
        "score_b": "1",
        "status": "live",
        "odds_team_a": 2.05,
        "odds_draw": 3.40,
        "odds_team_b": 3.10
    },
    {
        "sport": "football",
        "tournament": "English Premier League",
        "team_a": "Arsenal",
        "team_b": "Liverpool",
        "score_a": "0",
        "score_b": "0",
        "status": "upcoming",
        "odds_team_a": 2.20,
        "odds_draw": 3.30,
        "odds_team_b": 2.90
    },
    {
        "sport": "tennis",
        "tournament": "Wimbledon Finals",
        "team_a": "Carlos Alcaraz",
        "team_b": "Jannik Sinner",
        "score_a": "2 - 1",
        "score_b": "Sets",
        "status": "live",
        "odds_team_a": 1.85,
        "odds_draw": 0.0,
        "odds_team_b": 1.95
    },
    {
        "sport": "basketball",
        "tournament": "NBA Championship",
        "team_a": "Los Angeles Lakers",
        "team_b": "Golden State Warriors",
        "score_a": "104",
        "score_b": "98",
        "status": "upcoming",
        "odds_team_a": 1.90,
        "odds_draw": 0.0,
        "odds_team_b": 1.90
    }
]

@router.get("/events")
async def get_sports_events(
    sport: Optional[str] = None,
    status_filter: Optional[str] = None,
    db: AsyncSession = Depends(get_db)
):
    query = select(SportsEvent)
    if sport:
        query = query.where(SportsEvent.sport == sport.lower())
    if status_filter:
        query = query.where(SportsEvent.status == status_filter.lower())

    result = await db.execute(query)
    events = result.scalars().all()

    # Seed initial sample events if table is empty
    if not events:
        now = datetime.now(timezone.utc)
        for sample in SAMPLE_EVENTS:
            ev = SportsEvent(
                sport=sample["sport"],
                tournament=sample["tournament"],
                team_a=sample["team_a"],
                team_b=sample["team_b"],
                start_time=now + timedelta(hours=2),
                status=sample["status"],
                score_a=sample["score_a"],
                score_b=sample["score_b"],
                odds_team_a=sample["odds_team_a"],
                odds_draw=sample["odds_draw"],
                odds_team_b=sample["odds_team_b"]
            )
            db.add(ev)
        await db.commit()

        result = await db.execute(query)
        events = result.scalars().all()

    return events

@router.post("/bet")
async def place_sports_bet(
    req: SportsBetRequest,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    if current_user.balance < req.stake or req.stake <= 0:
        raise HTTPException(status_code=400, detail="Insufficient wallet balance.")

    result = await db.execute(select(SportsEvent).where(SportsEvent.id == req.event_id))
    event = result.scalars().first()
    if not event:
        raise HTTPException(status_code=404, detail="Sports event not found.")

    odds = event.odds_team_a if req.selection == "team_a" else (event.odds_draw if req.selection == "draw" else event.odds_team_b)
    potential_payout = round(req.stake * odds, 2)

    balance_before = current_user.balance
    balance_after = balance_before - req.stake

    current_user.balance = balance_after
    current_user.has_played = True

    bet_id = f"BET-{uuid.uuid4().hex[:8]}"
    bet = SportsBet(
        id=bet_id,
        user_id=current_user.id,
        event_id=event.id,
        selection=req.selection,
        odds=odds,
        stake=req.stake,
        potential_payout=potential_payout,
        status="open"
    )
    db.add(bet)

    ledger = WalletLedger(
        user_id=current_user.id,
        amount=-req.stake,
        transaction_type="game_wager",
        balance_before=balance_before,
        balance_after=balance_after,
        reference_id=bet_id,
        description=f"Sports Bet on {event.team_a} vs {event.team_b} ({req.selection}) @ {odds}x"
    )
    db.add(ledger)

    await db.commit()

    return {
        "success": True,
        "bet_id": bet_id,
        "stake": req.stake,
        "odds": odds,
        "potential_payout": potential_payout,
        "new_balance": balance_after,
        "message": "Bet placed successfully!"
    }
