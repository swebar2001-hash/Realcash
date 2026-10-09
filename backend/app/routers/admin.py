from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from typing import List, Optional
import uuid

from app.database import get_db
from app.models import User, WalletLedger, Transaction, AdminAuditLog, GameSession
from app.schemas import UserStatusUpdate
from app.security import get_current_admin

router = APIRouter(prefix="/api/admin", tags=["Admin Dashboard"])

@router.get("/users")
async def list_users(
    admin: User = Depends(get_current_admin),
    db: AsyncSession = Depends(get_db)
):
    result = await db.execute(select(User).order_by(User.created_at.desc()))
    users = result.scalars().all()
    return [
        {
            "id": u.id,
            "email": u.email,
            "full_name": u.full_name,
            "phone": u.phone,
            "role": u.role,
            "status": u.status,
            "balance": u.balance,
            "has_deposited": u.has_deposited,
            "has_played": u.has_played,
            "created_at": u.created_at
        } for u in users
    ]

@router.put("/users/{user_id}/status")
async def update_user_status(
    user_id: str,
    status_update: UserStatusUpdate,
    admin: User = Depends(get_current_admin),
    db: AsyncSession = Depends(get_db)
):
    result = await db.execute(select(User).where(User.id == user_id))
    user = result.scalars().first()

    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    old_status = user.status
    user.status = status_update.status

    # Record append-only audit log
    audit = AdminAuditLog(
        admin_id=admin.id,
        action="UPDATE_USER_STATUS",
        target_user_id=user.id,
        details=f"Status changed from '{old_status}' to '{status_update.status}' by Admin {admin.email}"
    )
    db.add(audit)

    await db.commit()

    return {"success": True, "user_id": user.id, "new_status": user.status}

@router.get("/audit-logs")
async def get_audit_logs(
    admin: User = Depends(get_current_admin),
    db: AsyncSession = Depends(get_db)
):
    result = await db.execute(select(AdminAuditLog).order_by(AdminAuditLog.timestamp.desc()))
    return result.scalars().all()

@router.get("/stats")
async def get_system_stats(
    admin: User = Depends(get_current_admin),
    db: AsyncSession = Depends(get_db)
):
    users_res = await db.execute(select(User))
    users = users_res.scalars().all()

    tx_res = await db.execute(select(Transaction))
    txs = tx_res.scalars().all()

    games_res = await db.execute(select(GameSession))
    games = games_res.scalars().all()

    total_deposits = sum(t.amount for t in txs if t.type == "deposit" and t.status == "completed")
    total_withdrawals = sum(t.amount for t in txs if t.type == "withdrawal" and t.status == "completed")

    return {
        "total_users": len(users),
        "active_users": sum(1 for u in users if u.status == "active"),
        "suspended_users": sum(1 for u in users if u.status == "suspended"),
        "total_deposits": total_deposits,
        "total_withdrawals": total_withdrawals,
        "total_game_sessions": len(games),
        "system_status": "Healthy / Operational"
    }
