import os
from contextlib import asynccontextmanager
from fastapi import FastAPI, WebSocket, WebSocketDisconnect
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from fastapi.responses import FileResponse
import asyncio
import json
import random

from app.database import init_db
from app.routers import auth, wallet, games, sports, admin

@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup DB init
    await init_db()
    yield
    # Shutdown

app = FastAPI(
    title="RealCash — Cross-Platform Sports Gaming Platform API",
    description="Backend API supporting Sports Betting, Server-Authoritative Casino Games, Immutable Double-Entry Ledger, Daily Spin Wheel, and Admin Management.",
    version="1.0.0",
    lifespan=lifespan
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Register Routers
app.include_router(auth.router)
app.include_router(wallet.router)
app.include_router(games.router)
app.include_router(sports.router)
app.include_router(admin.router)

# Mount web admin frontend static folder if exists
web_admin_path = os.path.join(os.path.dirname(os.path.dirname(__file__)), "web_admin")
if os.path.exists(web_admin_path):
    app.mount("/admin-web", StaticFiles(directory=web_admin_path, html=True), name="admin-web")

@app.get("/")
async def root():
    return {
        "app": "RealCash Platform API",
        "status": "Online",
        "version": "1.0.0",
        "docs_url": "/docs",
        "admin_web_url": "/admin-web"
    }

# Live WebSocket for Real-Time Aviator Crash Stream & Sports Odds updates
@app.websocket("/ws/aviator-stream")
async def aviator_websocket(websocket: WebSocket):
    await websocket.accept()
    try:
        while True:
            # Generate simulated round multiplier curve
            crash = round(random.uniform(1.1, 15.0), 2)
            multiplier = 1.00
            
            await websocket.send_json({"event": "ROUND_START", "message": "Plane taking off!"})
            
            while multiplier < crash:
                await asyncio.sleep(0.2)
                multiplier = round(multiplier + (multiplier * 0.05) + 0.02, 2)
                await websocket.send_json({"event": "MULTIPLIER_UPDATE", "multiplier": multiplier})
            
            await websocket.send_json({"event": "CRASHED", "crash_point": crash})
            await asyncio.sleep(3.0) # Wait before next round
    except WebSocketDisconnect:
        pass
