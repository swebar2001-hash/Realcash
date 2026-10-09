from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from typing import List
import uuid
from app.database import get_db
from app.models import User, WalletLedger, Transaction
from app.schemas import DepositRequest, WithdrawalRequest, LedgerEntryResponse
from app.security import get_current_user

router = APIRouter(prefix="/api/wallet", tags=["Wallet & Ledger"])

VALID_DEPOSIT_AMOUNTS = [100.0, 200.0, 500.0, 1000.0]
MINIMUM_WITHDRAWAL_AMOUNT = 800.0

@router.post("/deposit")
async def deposit(
    req: DepositRequest,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    if req.amount < 10.0:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Minimum deposit amount is Rs 100."
        )

    tx_ref = f"DEP-{uuid.uuid4().hex[:10].upper()}"
    balance_before = current_user.balance
    balance_after = balance_before + req.amount

    # Update User balance & flags
    current_user.balance = balance_after
    current_user.has_deposited = True

    # Record Transaction
    tx = Transaction(
        tx_ref=tx_ref,
        user_id=current_user.id,
        type="deposit",
        amount=req.amount,
        status="completed",
        payment_method=req.payment_method,
        disclaimer_accepted=True
    )
    db.add(tx)

    # Double-entry ledger entry
    ledger = WalletLedger(
        user_id=current_user.id,
        amount=req.amount,
        transaction_type="deposit",
        balance_before=balance_before,
        balance_after=balance_after,
        reference_id=tx_ref,
        description=f"Deposit of Rs {req.amount:.2f} via {req.payment_method}"
    )
    db.add(ledger)

    await db.commit()

    return {
        "success": True,
        "message": f"Successfully deposited Rs {req.amount:.2f}",
        "tx_ref": tx_ref,
        "new_balance": balance_after,
        "disclaimer": "DISCLAIMER: Gaming involves financial risk. Play responsibly."
    }

@router.post("/withdraw")
async def withdraw(
    req: WithdrawalRequest,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    if not req.disclaimer_accepted:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="You must accept the legal disclaimer to process withdrawal."
        )

    # Rule Check 1: User must have deposited and played
    if not current_user.has_deposited or not current_user.has_played:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Withdrawal option is available only after depositing money and playing games."
        )

    # Rule Check 2: Minimum withdrawal threshold Rs 800
    if req.amount < MINIMUM_WITHDRAWAL_AMOUNT:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Minimum withdrawal amount requirement is Rs {MINIMUM_WITHDRAWAL_AMOUNT:.2f}."
        )

    # Rule Check 3: Account balance check
    if current_user.balance < req.amount:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Insufficient balance. Your current balance is Rs {current_user.balance:.2f}."
        )

    tx_ref = f"WTH-{uuid.uuid4().hex[:10].upper()}"
    balance_before = current_user.balance
    balance_after = balance_before - req.amount

    current_user.balance = balance_after

    # Record Transaction
    tx = Transaction(
        tx_ref=tx_ref,
        user_id=current_user.id,
        type="withdrawal",
        amount=req.amount,
        status="completed",
        payment_method="Bank Transfer / UPI",
        disclaimer_accepted=True
    )
    db.add(tx)

    # Double-entry ledger entry
    ledger = WalletLedger(
        user_id=current_user.id,
        amount=-req.amount,
        transaction_type="withdrawal",
        balance_before=balance_before,
        balance_after=balance_after,
        reference_id=tx_ref,
        description=f"Withdrawal request of Rs {req.amount:.2f}"
    )
    db.add(ledger)

    await db.commit()

    return {
        "success": True,
        "message": f"Withdrawal request of Rs {req.amount:.2f} processed successfully.",
        "tx_ref": tx_ref,
        "new_balance": balance_after,
        "disclaimer": "DISCLAIMER: Withdrawals are processed according to standard regulatory security protocols."
    }

@router.get("/ledger", response_model=List[LedgerEntryResponse])
async def get_ledger_history(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    result = await db.execute(
        select(WalletLedger)
        .where(WalletLedger.user_id == current_user.id)
        .order_by(WalletLedger.timestamp.desc())
    )
    return result.scalars().all()
