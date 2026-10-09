const API_URL = 'http://127.0.0.1:8000/api';
let userToken = null;
let currentBalance = 1250.00;
let hasDeposited = true;
let hasPlayed = true;

// Tab switcher
function switchTab(tabId) {
    document.querySelectorAll('.tab-content').forEach(el => el.classList.remove('active'));
    document.querySelectorAll('.nav-item').forEach(el => el.classList.remove('active'));

    const targetTab = document.getElementById(tabId);
    if (targetTab) targetTab.classList.add('active');

    if (tabId === 'sportsTab' || tabId === 'homeTab') fetchSportsEvents();
    if (tabId === 'walletTab') fetchLedger();
    if (tabId === 'adminTab') fetchAdminData();
    if (tabId === 'spinTab') drawWheel();
}

function updateBalanceDisplay() {
    document.getElementById('userBalanceDisplay').innerText = `Rs ${currentBalance.toFixed(2)}`;
    const bigBal = document.getElementById('walletBalanceBig');
    if (bigBal) bigBal.innerText = `Rs ${currentBalance.toFixed(2)}`;
}

// Sports
async function fetchSportsEvents() {
    try {
        const res = await fetch(`${API_URL}/sports/events`);
        const events = await res.json();
        renderSportsFeed(events);
    } catch (e) {
        console.log("Using sample sports data");
        renderSportsFeed([
            { team_a: "Mumbai Indians", team_b: "Chennai Super Kings", score_a: "184/5", score_b: "182/6", odds_team_a: 1.75, odds_draw: 15.0, odds_team_b: 2.10 },
            { team_a: "Real Madrid", team_b: "Manchester City", score_a: "2", score_b: "1", odds_team_a: 2.05, odds_draw: 3.40, odds_team_b: 3.10 }
        ]);
    }
}

function renderSportsFeed(events) {
    const container = document.getElementById('sportsLiveFeed');
    if (!container) return;
    container.innerHTML = events.map(ev => `
        <div style="background:#181818; padding:16px; border-radius:12px; border:1px solid rgba(255,255,255,0.08);">
            <div style="display:flex; justify-content:space-between; margin-bottom:8px;">
                <span style="color:#A0A0A0; font-size:12px;">CRICKET / FOOTBALL • LIVE</span>
                <span style="color:#FF5252; font-weight:bold; font-size:11px;">● LIVE</span>
            </div>
            <div style="display:flex; justify-content:space-between; font-weight:bold;">
                <span>${ev.team_a}</span>
                <span style="color:#FFD700">${ev.score_a} - ${ev.score_b}</span>
                <span>${ev.team_b}</span>
            </div>
            <div style="display:flex; gap:8px; margin-top:12px;">
                <button class="btn btn-outline" style="flex:1">1 (${ev.odds_team_a})</button>
                <button class="btn btn-outline" style="flex:1">X (${ev.odds_draw})</button>
                <button class="btn btn-outline" style="flex:1">2 (${ev.odds_team_b})</button>
            </div>
        </div>
    `).join('');
}

// Deposit & Withdrawal
function depositWeb(amount) {
    currentBalance += amount;
    hasDeposited = true;
    updateBalanceDisplay();
    alert(`Successfully deposited Rs ${amount.toFixed(2)} into your account!`);
}

function withdrawWeb() {
    const input = document.getElementById('withdrawAmountInput');
    const amount = parseFloat(input.value) || 0;

    if (!hasDeposited || !hasPlayed) {
        alert("Withdrawal Locked: You must deposit money and play games before requesting a withdrawal.");
        return;
    }

    if (amount < 800) {
        alert("Minimum Withdrawal Limit: The minimum withdrawal requirement is Rs 800.00.");
        return;
    }

    if (currentBalance < amount) {
        alert(`Insufficient Balance: Your current balance is Rs ${currentBalance.toFixed(2)}.`);
        return;
    }

    currentBalance -= amount;
    updateBalanceDisplay();
    alert(`Withdrawal request of Rs ${amount.toFixed(2)} submitted successfully!`);
    input.value = '';
}

// Wheel Canvas Draw
function drawWheel() {
    const canvas = document.getElementById('wheelCanvas');
    if (!canvas) return;
    const ctx = canvas.getContext('2d');
    const sectors = ['Rs 0', 'Rs 1', 'Rs 2', 'Rs 3', 'Rs 5', 'Rs 7', 'Rs 10', 'Rs 0'];
    const colors = ['#8E44AD', '#3498DB', '#2ECC71', '#F1C40F', '#E67E22', '#E74C3C', '#1ABC9C', '#34495E'];

    const angle = (2 * Math.PI) / sectors.length;
    for (let i = 0; i < sectors.length; i++) {
        ctx.beginPath();
        ctx.fillStyle = colors[i];
        ctx.moveTo(150, 150);
        ctx.arc(150, 150, 140, i * angle, (i + 1) * angle);
        ctx.fill();

        ctx.save();
        ctx.translate(150, 150);
        ctx.rotate((i + 0.5) * angle);
        ctx.fillStyle = '#FFFFFF';
        ctx.font = 'bold 14px Inter';
        ctx.fillText(sectors[i], 70, 5);
        ctx.restore();
    }
}

function spinWheelWeb() {
    const rewards = [0, 1, 2, 3, 5, 7, 10];
    const won = rewards[Math.floor(Math.random() * rewards.length)];
    currentBalance += won;
    updateBalanceDisplay();

    const resTag = document.getElementById('spinResultText');
    resTag.innerText = won > 0 ? `🎉 Congratulations! You won Rs ${won}.00!` : `You landed on Rs 0.00. Spin again tomorrow!`;
}

// Admin Panel
async function fetchAdminData() {
    const statsBox = document.getElementById('adminStatsBox');
    if (statsBox) {
        statsBox.innerHTML = `
            <div style="background:#181818; padding:16px; border-radius:10px;">TOTAL USERS: <strong>142</strong></div>
            <div style="background:#181818; padding:16px; border-radius:10px;">ACTIVE USERS: <strong>138</strong></div>
            <div style="background:#181818; padding:16px; border-radius:10px;">SYSTEM STATUS: <strong style="color:#00E676">HEALTHY / OPERATIONAL</strong></div>
        `;
    }
}

// Init
window.onload = function() {
    updateBalanceDisplay();
    fetchSportsEvents();
};
