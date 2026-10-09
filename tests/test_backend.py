import pytest
import pytest_asyncio
from httpx import AsyncClient, ASGITransport
import sys
import os

# Add backend directory to sys.path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "backend"))

from app.main import app
from app.database import init_db

@pytest_asyncio.fixture(autouse=True)
async def setup_database():
    await init_db()

@pytest.mark.asyncio
async def test_root_endpoint():
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as ac:
        response = await ac.get("/")
    assert response.status_code == 200
    assert response.json()["app"] == "RealCash Platform API"

@pytest.mark.asyncio
async def test_user_flow_and_wallet_rules():
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as ac:
        # 1. Register User
        email = "testplayer@gamezone.com"
        reg_payload = {
            "email": email,
            "password": "Password123!",
            "full_name": "Test Player",
            "phone": "+919876543210"
        }
        res = await ac.post("/api/auth/register", json=reg_payload)
        assert res.status_code == 200
        token = res.json()["access_token"]
        headers = {"Authorization": f"Bearer {token}"}

        # 2. Daily Spin
        spin_res = await ac.post("/api/games/spin/claim", headers=headers)
        assert spin_res.status_code == 200
        data = spin_res.json()
        assert 0.0 <= data["amount_won"] <= 10.0

        # Try second spin immediately (should fail due to 24h lock)
        spin_again = await ac.post("/api/games/spin/claim", headers=headers)
        assert spin_again.status_code == 400

        # 3. Attempt Withdrawal before depositing/playing (should fail)
        wth_fail1 = await ac.post("/api/wallet/withdraw", json={"amount": 1000.0, "disclaimer_accepted": True}, headers=headers)
        assert wth_fail1.status_code == 400
        assert "after depositing" in wth_fail1.json()["detail"]

        # 4. Deposit Rs 1000
        dep_res = await ac.post("/api/wallet/deposit", json={"amount": 1000.0, "payment_method": "UPI"}, headers=headers)
        assert dep_res.status_code == 200
        assert dep_res.json()["new_balance"] >= 1000.0

        # 5. Play Aviator game (to fulfill play requirement)
        start_avi = await ac.post("/api/games/aviator/start", json={"bet_amount": 50.0}, headers=headers)
        assert start_avi.status_code == 200
        game_id = start_avi.json()["game_id"]

        cashout_avi = await ac.post("/api/games/aviator/cashout", json={"game_id": game_id, "multiplier": 1.5}, headers=headers)
        assert cashout_avi.status_code == 200

        # 6. Attempt Withdrawal below Rs 800 minimum threshold (should fail)
        wth_fail2 = await ac.post("/api/wallet/withdraw", json={"amount": 500.0, "disclaimer_accepted": True}, headers=headers)
        assert wth_fail2.status_code == 400
        assert "Minimum withdrawal" in wth_fail2.json()["detail"]

        # 7. Valid Withdrawal of Rs 800 (should succeed)
        wth_success = await ac.post("/api/wallet/withdraw", json={"amount": 800.0, "disclaimer_accepted": True}, headers=headers)
        assert wth_success.status_code == 200
        assert wth_success.json()["success"] is True

@pytest.mark.asyncio
async def test_admin_flow():
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as ac:
        # Register Admin
        admin_email = "admin@gamezone.com"
        reg_payload = {
            "email": admin_email,
            "password": "AdminPassword123!",
            "full_name": "Main Admin"
        }
        res = await ac.post("/api/auth/register", json=reg_payload)
        token = res.json()["access_token"]
        headers = {"Authorization": f"Bearer {token}"}

        # Fetch System Stats
        stats_res = await ac.get("/api/admin/stats", headers=headers)
        assert stats_res.status_code == 200
        assert stats_res.json()["system_status"] == "Healthy / Operational"
