import React, { useState, useEffect, useRef, useCallback } from 'react';

// --- GAME CONSTANTS & CONFIG ---
const FPS = 60;
const TIMESTEP = 1000 / FPS;
const PIXEL_RATIO = window.devicePixelRatio || 1;

const COLORS = {
  bg: '#050510',
  neonCyan: '#00ffff',
  neonPink: '#ff00ff',
  neonGreen: '#00ffcc',
  neonOrange: '#ffaa00',
  darkCyan: '#003333',
  white: '#ffffff',
  pad: '#ffff00'
};

const LEVELS = [
  {
    id: 1,
    name: "Sea of Tranquility",
    fuel: 1000,
    terrain: [
      { x: 0, y: 600 }, { x: 200, y: 550 }, { x: 350, y: 650 }, 
      { x: 450, y: 650, isPad: true }, { x: 600, y: 650, isPad: true }, 
      { x: 800, y: 500 }, { x: 1000, y: 700 }, { x: 1200, y: 600 },
      { x: 1500, y: 600 }
    ],
    startPos: { x: 100, y: 100 }
  },
  {
    id: 2,
    name: "Tycho Crater",
    fuel: 800,
    terrain: [
      { x: 0, y: 400 }, { x: 150, y: 300 }, { x: 250, y: 500 }, 
      { x: 400, y: 800 }, { x: 500, y: 800, isPad: true }, { x: 600, y: 800, isPad: true },
      { x: 750, y: 450 }, { x: 900, y: 350 }, { x: 1100, y: 650 }, { x: 1500, y: 500 }
    ],
    startPos: { x: 100, y: 100 }
  },
  {
    id: 3,
    name: "Lunar Alps",
    fuel: 600,
    terrain: [
      { x: 0, y: 700 }, { x: 200, y: 700 }, { x: 300, y: 400 }, 
      { x: 450, y: 300 }, { x: 600, y: 600 }, { x: 700, y: 750 },
      { x: 800, y: 750, isPad: true }, { x: 880, y: 750, isPad: true },
      { x: 950, y: 500 }, { x: 1100, y: 200 }, { x: 1300, y: 400 }, { x: 1500, y: 800 }
    ],
    startPos: { x: 150, y: 100 }
  }
];

// --- PHYSICS & RENDERING ENGINE ---
class GameEngine {
  constructor(canvas, updateHUD, onGameOver) {
    this.canvas = canvas;
    this.ctx = canvas.getContext('2d');
    this.updateHUD = updateHUD;
    this.onGameOver = onGameOver;
    this.width = window.innerWidth;
    this.height = window.innerHeight;
    
    // Resize handler
    this.resize();
    window.addEventListener('resize', () => this.resize());

    // Game State
    this.state = 'running'; // running, win, crashed
    this.lastTime = 0;
    this.accumulator = 0;
    this.camera = { x: 0, y: 0 };
    
    // Physics Config (Sandbox overrides these)
    this.config = {
      gravity: 0.04,
      thrustPower: 0.12,
      rotationSpeed: 0.05,
      infiniteFuel: false
    };

    // Inputs
    this.keys = { left: false, right: false, up: false };
    
    // Entities
    this.ship = null;
    this.terrain = [];
    this.particles = [];
    this.stars = this.generateStars(150);
    this.telemetry = { fuel: 0, maxFuel: 100, vx: 0, vy: 0, gForce: 0, maxG: 0 };
  }

  resize() {
    this.width = window.innerWidth;
    this.height = window.innerHeight;
    this.canvas.width = this.width * PIXEL_RATIO;
    this.canvas.height = this.height * PIXEL_RATIO;
    this.ctx.scale(PIXEL_RATIO, PIXEL_RATIO);
  }

  loadLevel(levelData, sandboxConfig = null) {
    if (sandboxConfig) {
      this.config = { ...this.config, ...sandboxConfig };
    }
    
    this.terrain = levelData.terrain;
    this.state = 'running';
    this.particles = [];
    
    const maxF = sandboxConfig ? 9999 : levelData.fuel;
    
    this.ship = {
      x: levelData.startPos.x,
      y: levelData.startPos.y,
      vx: 2, // Slight initial push
      vy: 0,
      angle: 0,
      fuel: maxF,
      width: 24,
      height: 32,
      isThrusting: false,
      color: COLORS.neonCyan
    };
    
    this.telemetry.maxFuel = maxF;
    this.telemetry.maxG = 0;
    
    requestAnimationFrame((t) => this.loop(t));
  }

  generateStars(count) {
    const stars = [];
    for (let i = 0; i < count; i++) {
      stars.push({
        x: Math.random() * 3000 - 500,
        y: Math.random() * 2000 - 500,
        size: Math.random() * 1.5,
        alpha: Math.random()
      });
    }
    return stars;
  }

  loop(timestamp) {
    if (this.state !== 'running') return;

    let deltaTime = timestamp - this.lastTime;
    this.lastTime = timestamp;
    
    // Cap deltaTime to avoid massive jumps if tab is inactive
    if (deltaTime > 250) deltaTime = 250;
    
    this.accumulator += deltaTime;
    
    while (this.accumulator >= TIMESTEP) {
      this.update(TIMESTEP);
      this.accumulator -= TIMESTEP;
    }
    
    this.draw();
    requestAnimationFrame((t) => this.loop(t));
  }

  update(dt) {
    // Controls
    if (this.keys.left) this.ship.angle -= this.config.rotationSpeed;
    if (this.keys.right) this.ship.angle += this.config.rotationSpeed;
    
    this.ship.isThrusting = this.keys.up && (this.ship.fuel > 0 || this.config.infiniteFuel);

    let ax = 0;
    let ay = this.config.gravity;

    if (this.ship.isThrusting) {
      if (!this.config.infiniteFuel) this.ship.fuel -= 1;
      ax = Math.sin(this.ship.angle) * this.config.thrustPower;
      ay -= Math.cos(this.ship.angle) * this.config.thrustPower;
      
      // Spawn particles
      this.spawnExhaust();
    }

    // Velocity & Position
    this.ship.vx += ax;
    this.ship.vy += ay;
    this.ship.x += this.ship.vx;
    this.ship.y += this.ship.vy;

    // G-Force Calculation (approximation of felt acceleration magnitude)
    let currentG = Math.sqrt(ax*ax + (ay - this.config.gravity)*(ay - this.config.gravity)) * 10;
    this.telemetry.gForce = currentG.toFixed(1);
    if (currentG > this.telemetry.maxG) this.telemetry.maxG = currentG;

    this.telemetry.vx = this.ship.vx;
    this.telemetry.vy = this.ship.vy;
    this.telemetry.fuel = this.ship.fuel;

    // Camera follow
    this.camera.x = this.ship.x - this.width / 2;
    this.camera.y = this.ship.y - this.height / 2 + 100;

    // Update Particles
    for (let i = this.particles.length - 1; i >= 0; i--) {
      let p = this.particles[i];
      p.x += p.vx;
      p.y += p.vy;
      p.life -= dt * 0.05;
      if (p.life <= 0) this.particles.splice(i, 1);
    }

    this.checkCollisions();

    // Send data to React via Ref callback
    if (this.updateHUD) {
      this.updateHUD(this.telemetry);
    }
  }

  spawnExhaust() {
    const offset = 16;
    const px = this.ship.x - Math.sin(this.ship.angle) * offset;
    const py = this.ship.y + Math.cos(this.ship.angle) * offset;
    
    this.particles.push({
      x: px + (Math.random() - 0.5) * 6,
      y: py + (Math.random() - 0.5) * 6,
      vx: this.ship.vx - Math.sin(this.ship.angle) * 2 + (Math.random()-0.5),
      vy: this.ship.vy + Math.cos(this.ship.angle) * 2 + (Math.random()-0.5),
      life: 100 + Math.random() * 50,
      color: Math.random() > 0.5 ? COLORS.neonOrange : COLORS.neonPink
    });
  }

  checkCollisions() {
    // Simple line-circle intersection for ship boundary
    const radius = 14; 
    let crashed = false;
    let landed = false;

    for (let i = 0; i < this.terrain.length - 1; i++) {
      const p1 = this.terrain[i];
      const p2 = this.terrain[i+1];
      
      const dist = this.pointLineDistance(this.ship.x, this.ship.y, p1.x, p1.y, p2.x, p2.y);
      
      if (dist < radius) {
        // Collision!
        if (p1.isPad && p2.isPad) {
          // Check landing conditions
          const angleDeg = Math.abs(this.ship.angle * 180 / Math.PI) % 360;
          const isUpright = angleDeg < 15 || angleDeg > 345;
          const isSlowV = this.ship.vy < 1.5;
          const isSlowH = Math.abs(this.ship.vx) < 0.8;
          
          if (isUpright && isSlowV && isSlowH) {
            landed = true;
          } else {
            crashed = true;
          }
        } else {
          crashed = true;
        }
      }
    }

    if (crashed || landed) {
      this.state = landed ? 'win' : 'crashed';
      if (crashed) this.createExplosion();
      this.draw(); // One last draw
      
      setTimeout(() => {
        let score = 0;
        if (landed) {
          // Scoring logic
          const fuelScore = this.ship.fuel * 2;
          const velocityPenalty = (this.ship.vy + Math.abs(this.ship.vx)) * 100;
          score = Math.max(0, Math.floor(10000 + fuelScore - velocityPenalty - (this.telemetry.maxG * 50)));
        }
        if (this.onGameOver) this.onGameOver({ status: this.state, score, telemetry: this.telemetry });
      }, 1000);
    }
  }

  createExplosion() {
    for (let i = 0; i < 50; i++) {
      this.particles.push({
        x: this.ship.x,
        y: this.ship.y,
        vx: (Math.random() - 0.5) * 10,
        vy: (Math.random() - 0.5) * 10,
        life: 100 + Math.random() * 100,
        color: Math.random() > 0.5 ? COLORS.neonPink : COLORS.neonCyan
      });
    }
  }

  pointLineDistance(px, py, x1, y1, x2, y2) {
    const A = px - x1;
    const B = py - y1;
    const C = x2 - x1;
    const D = y2 - y1;
  
    const dot = A * C + B * D;
    const len_sq = C * C + D * D;
    let param = -1;
    if (len_sq !== 0) param = dot / len_sq;
  
    let xx, yy;
  
    if (param < 0) {
      xx = x1; yy = y1;
    } else if (param > 1) {
      xx = x2; yy = y2;
    } else {
      xx = x1 + param * C;
      yy = y1 + param * D;
    }
  
    const dx = px - xx;
    const dy = py - yy;
    return Math.sqrt(dx * dx + dy * dy);
  }

  // --- RENDERING PROCEDURES ---
  
  drawNeonLine(x1, y1, x2, y2, color, width, glow = true) {
    this.ctx.beginPath();
    this.ctx.moveTo(x1, y1);
    this.ctx.lineTo(x2, y2);
    
    if (glow) {
      this.ctx.strokeStyle = color;
      this.ctx.globalAlpha = 0.4;
      this.ctx.lineWidth = width * 4;
      this.ctx.stroke();
    }

    this.ctx.globalAlpha = 1.0;
    this.ctx.lineWidth = width;
    this.ctx.strokeStyle = '#fff';
    this.ctx.stroke();
  }

  draw() {
    // Clear
    this.ctx.fillStyle = COLORS.bg;
    this.ctx.fillRect(0, 0, this.width, this.height);

    this.ctx.save();
    
    // Parallax Stars (Background)
    this.ctx.fillStyle = COLORS.white;
    this.stars.forEach(s => {
      this.ctx.globalAlpha = s.alpha;
      // Moving camera very slightly for stars
      let sx = s.x - this.camera.x * 0.1;
      let sy = s.y - this.camera.y * 0.1;
      // wrap stars
      sx = ((sx % 3000) + 3000) % 3000 - 500;
      sy = ((sy % 2000) + 2000) % 2000 - 500;
      this.ctx.beginPath();
      this.ctx.arc(sx, sy, s.size, 0, Math.PI * 2);
      this.ctx.fill();
    });
    this.ctx.globalAlpha = 1.0;

    // Apply Camera Transform for main world
    this.ctx.translate(-this.camera.x, -this.camera.y);

    // 1. Draw 2.5D Extruded Plains (Depth effect)
    // Draw the drop-shadow/3D faces first
    const depthX = -30;
    const depthY = 60;
    
    this.ctx.fillStyle = '#0a0a1a';
    this.ctx.strokeStyle = '#111122';
    this.ctx.lineWidth = 1;
    
    for (let i = 0; i < this.terrain.length - 1; i++) {
      const p1 = this.terrain[i];
      const p2 = this.terrain[i+1];
      
      this.ctx.beginPath();
      this.ctx.moveTo(p1.x, p1.y);
      this.ctx.lineTo(p2.x, p2.y);
      this.ctx.lineTo(p2.x + depthX, p2.y + depthY);
      this.ctx.lineTo(p1.x + depthX, p1.y + depthY);
      this.ctx.closePath();
      
      // Gradient for extrusion
      const grad = this.ctx.createLinearGradient(p1.x, p1.y, p1.x + depthX, p1.y + depthY);
      grad.addColorStop(0, COLORS.darkCyan);
      grad.addColorStop(1, '#020205');
      this.ctx.fillStyle = grad;
      this.ctx.fill();
      this.ctx.stroke();
    }

    // 2. Draw the main front-facing Terrain Fill
    this.ctx.beginPath();
    this.ctx.moveTo(this.terrain[0].x, this.height + this.camera.y + 500);
    this.terrain.forEach(p => this.ctx.lineTo(p.x, p.y));
    this.ctx.lineTo(this.terrain[this.terrain.length-1].x, this.height + this.camera.y + 500);
    this.ctx.closePath();
    this.ctx.fillStyle = '#01050a';
    this.ctx.fill();

    // 3. Draw Neon Surface Lines
    for (let i = 0; i < this.terrain.length - 1; i++) {
      const p1 = this.terrain[i];
      const p2 = this.terrain[i+1];
      const isPad = p1.isPad && p2.isPad;
      const color = isPad ? COLORS.pad : COLORS.neonCyan;
      const width = isPad ? 4 : 2;
      this.drawNeonLine(p1.x, p1.y, p2.x, p2.y, color, width, true);
    }

    // 4. Draw Particles
    this.particles.forEach(p => {
      this.ctx.globalAlpha = p.life / 150;
      this.ctx.fillStyle = p.color;
      this.ctx.beginPath();
      this.ctx.arc(p.x, p.y, 3, 0, Math.PI * 2);
      this.ctx.fill();
      
      // Glow
      this.ctx.shadowBlur = 10;
      this.ctx.shadowColor = p.color;
      this.ctx.fill();
      this.ctx.shadowBlur = 0; // reset
    });
    this.ctx.globalAlpha = 1.0;

    // 5. Draw Ship
    if (this.state !== 'crashed') {
      this.ctx.translate(this.ship.x, this.ship.y);
      this.ctx.rotate(this.ship.angle);
      
      // Ship Body Drawing (High detail sprite simulation)
      this.ctx.lineJoin = 'round';
      
      // Main Hull Glow
      this.ctx.shadowBlur = 15;
      this.ctx.shadowColor = COLORS.neonPink;
      
      // Hull Polygon
      this.ctx.beginPath();
      this.ctx.moveTo(0, -16); // Nose
      this.ctx.lineTo(10, 8);  // Right wing
      this.ctx.lineTo(6, 12);  // Right engine base
      this.ctx.lineTo(-6, 12); // Left engine base
      this.ctx.lineTo(-10, 8); // Left wing
      this.ctx.closePath();
      
      this.ctx.fillStyle = '#111';
      this.ctx.fill();
      this.ctx.lineWidth = 2;
      this.ctx.strokeStyle = COLORS.neonPink;
      this.ctx.stroke();

      this.ctx.shadowBlur = 0; // reset
      
      // Landing Legs
      this.ctx.strokeStyle = COLORS.neonCyan;
      this.ctx.lineWidth = 1.5;
      // Left leg
      this.ctx.beginPath(); this.ctx.moveTo(-8, 8); this.ctx.lineTo(-14, 18); this.ctx.lineTo(-18, 18); this.ctx.stroke();
      // Right leg
      this.ctx.beginPath(); this.ctx.moveTo(8, 8); this.ctx.lineTo(14, 18); this.ctx.lineTo(18, 18); this.ctx.stroke();

      // Cockpit Window
      this.ctx.fillStyle = COLORS.neonCyan;
      this.ctx.beginPath();
      this.ctx.arc(0, -2, 4, 0, Math.PI*2);
      this.ctx.fill();

      // Reset transform
      this.ctx.rotate(-this.ship.angle);
      this.ctx.translate(-this.ship.x, -this.ship.y);
    }

    this.ctx.restore();
  }
}

// --- REACT COMPONENTS ---

export default function App() {
  const [view, setView] = useState('menu'); // menu, campaign, sandbox, game
  const [selectedLevel, setSelectedLevel] = useState(null);
  const [sandboxConfig, setSandboxConfig] = useState({ gravity: 0.04, thrustPower: 0.12, infiniteFuel: true });
  
  const [gameResult, setGameResult] = useState(null);

  const startGame = (level, config = null) => {
    setSelectedLevel(level);
    setSandboxConfig(config);
    setGameResult(null);
    setView('game');
  };

  return (
    <div className="w-full h-screen bg-[#050510] text-white font-mono overflow-hidden select-none">
      {view === 'menu' && (
        <MainMenu onPlayCampaign={() => setView('campaign')} onPlaySandbox={() => setView('sandbox')} />
      )}
      {view === 'campaign' && (
        <LevelSelect onBack={() => setView('menu')} onSelect={(lvl) => startGame(lvl)} />
      )}
      {view === 'sandbox' && (
        <SandboxSetup onBack={() => setView('menu')} onStart={(config) => startGame(LEVELS[0], config)} />
      )}
      {view === 'game' && selectedLevel && (
        <GameUI 
          level={selectedLevel} 
          sandboxConfig={sandboxConfig} 
          onExit={() => setView('menu')}
          onGameOver={(res) => setGameResult(res)}
        />
      )}
      
      {/* Game Over Modal overlaying the game */}
      {gameResult && view === 'game' && (
        <GameOverModal 
          result={gameResult} 
          onRetry={() => startGame(selectedLevel, sandboxConfig)}
          onMenu={() => setView('menu')}
        />
      )}
    </div>
  );
}

// --- MENUS ---

function MainMenu({ onPlayCampaign, onPlaySandbox }) {
  return (
    <div className="flex flex-col items-center justify-center h-full bg-black/80">
      <div className="text-center mb-12">
        <h1 className="text-5xl md:text-7xl font-bold tracking-widest text-transparent bg-clip-text bg-gradient-to-r from-cyan-400 to-pink-500 drop-shadow-[0_0_15px_rgba(0,255,255,0.8)]">
          NEON<br/>LANDER
        </h1>
        <p className="mt-4 text-cyan-200 tracking-widest uppercase">2.5D Physics Simulation</p>
      </div>
      
      <div className="space-y-6 flex flex-col w-64">
        <MenuButton onClick={onPlayCampaign} label="Campaign Mode" color="cyan" />
        <MenuButton onClick={onPlaySandbox} label="Sandbox Mode" color="pink" />
      </div>
    </div>
  );
}

function LevelSelect({ onBack, onSelect }) {
  return (
    <div className="flex flex-col items-center justify-center h-full px-6">
      <h2 className="text-3xl mb-8 text-cyan-400 drop-shadow-[0_0_8px_cyan]">Select Sector</h2>
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-12">
        {LEVELS.map((lvl) => (
          <div 
            key={lvl.id} 
            onClick={() => onSelect(lvl)}
            className="border border-cyan-500/50 hover:border-cyan-400 hover:shadow-[0_0_15px_cyan] bg-cyan-900/20 p-6 rounded-lg cursor-pointer transition-all flex flex-col items-center"
          >
            <h3 className="text-xl text-white mb-2">{lvl.name}</h3>
            <p className="text-sm text-cyan-300">Fuel: {lvl.fuel}kg</p>
          </div>
        ))}
      </div>
      <button onClick={onBack} className="text-gray-400 hover:text-white uppercase tracking-widest text-sm">
        ← Back to Menu
      </button>
    </div>
  );
}

function SandboxSetup({ onBack, onStart }) {
  const [gravity, setGravity] = useState(0.04);
  const [thrust, setThrust] = useState(0.12);
  const [infFuel, setInfFuel] = useState(true);

  return (
    <div className="flex flex-col items-center justify-center h-full px-6">
      <h2 className="text-3xl mb-8 text-pink-400 drop-shadow-[0_0_8px_pink]">Sandbox Protocol</h2>
      
      <div className="w-full max-w-md space-y-6 bg-pink-900/10 p-8 border border-pink-500/30 rounded-lg">
        <div>
          <label className="flex justify-between text-pink-200 mb-2">
            <span>Gravity</span> <span>{(gravity * 100).toFixed(1)} m/s²</span>
          </label>
          <input type="range" min="0.01" max="0.1" step="0.01" value={gravity} onChange={e => setGravity(parseFloat(e.target.value))} className="w-full accent-pink-500" />
        </div>
        
        <div>
          <label className="flex justify-between text-pink-200 mb-2">
            <span>Thrust Power</span> <span>{(thrust * 100).toFixed(1)} kN</span>
          </label>
          <input type="range" min="0.05" max="0.3" step="0.01" value={thrust} onChange={e => setThrust(parseFloat(e.target.value))} className="w-full accent-pink-500" />
        </div>

        <div className="flex items-center justify-between mt-4">
          <span className="text-pink-200">Infinite Fuel</span>
          <button 
            onClick={() => setInfFuel(!infFuel)}
            className={`w-12 h-6 rounded-full relative transition-colors ${infFuel ? 'bg-pink-500' : 'bg-gray-600'}`}
          >
            <div className={`w-4 h-4 bg-white rounded-full absolute top-1 transition-transform ${infFuel ? 'translate-x-7' : 'translate-x-1'}`} />
          </button>
        </div>
      </div>

      <div className="flex gap-6 mt-12">
        <button onClick={onBack} className="px-6 py-3 border border-gray-600 text-gray-400 hover:text-white rounded">Cancel</button>
        <button 
          onClick={() => onStart({ gravity, thrustPower: thrust, infiniteFuel: infFuel })}
          className="px-8 py-3 bg-pink-600/20 border border-pink-500 text-pink-100 hover:bg-pink-600/40 rounded shadow-[0_0_15px_rgba(255,0,255,0.4)]"
        >
          Launch Simulation
        </button>
      </div>
    </div>
  );
}

function MenuButton({ onClick, label, color }) {
  const colors = {
    cyan: "border-cyan-500 text-cyan-300 hover:bg-cyan-900/40 hover:shadow-[0_0_15px_cyan]",
    pink: "border-pink-500 text-pink-300 hover:bg-pink-900/40 hover:shadow-[0_0_15px_pink]"
  };
  return (
    <button 
      onClick={onClick}
      className={`px-8 py-4 border-2 rounded uppercase tracking-[0.2em] font-bold transition-all duration-300 ${colors[color]}`}
    >
      {label}
    </button>
  );
}

function GameOverModal({ result, onRetry, onMenu }) {
  const isWin = result.status === 'win';
  
  return (
    <div className="absolute inset-0 z-50 flex items-center justify-center bg-black/80 backdrop-blur-sm pointer-events-auto">
      <div className={`p-8 rounded-xl border-2 flex flex-col items-center max-w-sm w-full ${isWin ? 'border-cyan-500 shadow-[0_0_30px_rgba(0,255,255,0.3)]' : 'border-red-500 shadow-[0_0_30px_rgba(255,0,0,0.3)]'}`}>
        <h2 className={`text-4xl font-bold mb-2 uppercase tracking-wider ${isWin ? 'text-cyan-400' : 'text-red-500'}`}>
          {isWin ? 'Touchdown' : 'Catastrophe'}
        </h2>
        <p className="text-gray-400 mb-6 text-center">
          {isWin ? 'Flawless execution, Commander.' : 'Structural integrity compromised.'}
        </p>

        {isWin && (
          <div className="w-full bg-cyan-900/30 p-4 rounded mb-6 text-center">
            <p className="text-sm text-cyan-200">Mission Score</p>
            <p className="text-4xl font-bold text-white tracking-widest">{result.score}</p>
          </div>
        )}

        <div className="w-full space-y-2 mb-8 text-sm">
          <div className="flex justify-between border-b border-gray-700 pb-1">
            <span className="text-gray-400">Impact Velocity</span>
            <span className={result.telemetry.vy > 1.5 ? 'text-red-400' : 'text-green-400'}>
              {Math.abs(result.telemetry.vy * 10).toFixed(1)} m/s
            </span>
          </div>
          <div className="flex justify-between border-b border-gray-700 pb-1">
            <span className="text-gray-400">Max G-Force</span>
            <span className="text-yellow-400">{result.telemetry.maxG.toFixed(1)} G</span>
          </div>
          <div className="flex justify-between border-b border-gray-700 pb-1">
            <span className="text-gray-400">Remaining Fuel</span>
            <span className="text-cyan-400">{Math.max(0, result.telemetry.fuel)} kg</span>
          </div>
        </div>

        <div className="flex w-full gap-4">
          <button onClick={onMenu} className="flex-1 py-3 border border-gray-600 rounded text-gray-300 hover:bg-gray-800">Menu</button>
          <button onClick={onRetry} className={`flex-1 py-3 rounded text-white font-bold ${isWin ? 'bg-cyan-600 hover:bg-cyan-500' : 'bg-red-600 hover:bg-red-500'}`}>
            Retry
          </button>
        </div>
      </div>
    </div>
  );
}

// --- MAIN GAME CONTAINER ---

function GameUI({ level, sandboxConfig, onExit, onGameOver }) {
  const canvasRef = useRef(null);
  const engineRef = useRef(null);
  
  // Refs for fast HUD updates without React re-renders
  const fuelFillRef = useRef(null);
  const fuelTextRef = useRef(null);
  const vyRef = useRef(null);
  const vxRef = useRef(null);
  const gForceRef = useRef(null);

  // Initialize Game
  useEffect(() => {
    const canvas = canvasRef.current;
    
    // Fast HUD update callback
    const updateHUD = (tel) => {
      if (!fuelFillRef.current) return;
      
      const fuelPct = Math.max(0, (tel.fuel / tel.maxFuel) * 100);
      fuelFillRef.current.style.width = `${fuelPct}%`;
      fuelTextRef.current.innerText = `${Math.max(0, Math.floor(tel.fuel))} kg`;
      
      const vyVal = tel.vy * 10;
      vyRef.current.innerText = vyVal.toFixed(1);
      vyRef.current.style.color = vyVal > 15 ? '#ff4444' : '#00ffcc'; // Red if dangerous
      
      const vxVal = tel.vx * 10;
      vxRef.current.innerText = vxVal.toFixed(1);
      vxRef.current.style.color = Math.abs(vxVal) > 8 ? '#ff4444' : '#00ffcc';
      
      gForceRef.current.innerText = tel.gForce;
      gForceRef.current.style.color = tel.gForce > 3.0 ? '#ffaa00' : '#ffffff';
    };

    engineRef.current = new GameEngine(canvas, updateHUD, onGameOver);
    engineRef.current.loadLevel(level, sandboxConfig);

    // Keyboard controls mapping
    const handleKeyDown = (e) => {
      if (e.code === 'ArrowLeft' || e.code === 'KeyA') engineRef.current.keys.left = true;
      if (e.code === 'ArrowRight' || e.code === 'KeyD') engineRef.current.keys.right = true;
      if (e.code === 'ArrowUp' || e.code === 'KeyW') engineRef.current.keys.up = true;
    };
    const handleKeyUp = (e) => {
      if (e.code === 'ArrowLeft' || e.code === 'KeyA') engineRef.current.keys.left = false;
      if (e.code === 'ArrowRight' || e.code === 'KeyD') engineRef.current.keys.right = false;
      if (e.code === 'ArrowUp' || e.code === 'KeyW') engineRef.current.keys.up = false;
    };

    window.addEventListener('keydown', handleKeyDown);
    window.addEventListener('keyup', handleKeyUp);

    return () => {
      window.removeEventListener('keydown', handleKeyDown);
      window.removeEventListener('keyup', handleKeyUp);
      engineRef.current.state = 'stopped'; // Stop loop
    };
  }, [level, sandboxConfig, onGameOver]);

  // Touch controls
  const handleTouchStart = useCallback((key) => (e) => { e.preventDefault(); if(engineRef.current) engineRef.current.keys[key] = true; }, []);
  const handleTouchEnd = useCallback((key) => (e) => { e.preventDefault(); if(engineRef.current) engineRef.current.keys[key] = false; }, []);

  return (
    <div className="relative w-full h-full bg-black">
      {/* The Game Canvas */}
      <canvas ref={canvasRef} className="block w-full h-full" style={{ touchAction: 'none' }} />

      {/* Top Telemetry Banner (Mobile First UI) */}
      <div className="absolute top-0 left-0 w-full bg-gradient-to-b from-[#050510] to-transparent p-2 md:p-4 pointer-events-none">
        <div className="max-w-4xl mx-auto flex items-center gap-2 md:gap-6 backdrop-blur-sm bg-cyan-950/30 border border-cyan-500/30 rounded-xl p-3 shadow-[0_4px_20px_rgba(0,255,255,0.1)]">
          
          {/* Pause / Exit */}
          <button 
            onClick={onExit} 
            className="pointer-events-auto flex items-center justify-center w-10 h-10 rounded-lg bg-black/50 border border-gray-600 text-gray-300 hover:border-red-500 hover:text-red-400 transition-colors"
          >
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg>
          </button>

          {/* Telemetry Grid */}
          <div className="flex-1 grid grid-cols-4 gap-2 md:gap-4 divide-x divide-cyan-500/20 text-center">
            
            {/* FUEL */}
            <div className="flex flex-col items-center justify-center pl-0">
              <span className="text-[10px] md:text-xs text-cyan-400/70 tracking-widest uppercase font-bold mb-1">Fuel</span>
              <div className="w-full max-w-[80px] h-2 bg-gray-800 rounded overflow-hidden mt-1 border border-gray-700">
                <div ref={fuelFillRef} className="h-full bg-gradient-to-r from-pink-500 to-cyan-400 w-full transition-all duration-100 ease-linear shadow-[0_0_8px_cyan]" />
              </div>
              <span ref={fuelTextRef} className="text-xs text-white mt-1">--</span>
            </div>

            {/* V. VEL */}
            <div className="flex flex-col items-center justify-center">
              <span className="text-[10px] md:text-xs text-cyan-400/70 tracking-widest uppercase font-bold mb-1">V.SPD</span>
              <div className="flex items-baseline">
                <span ref={vyRef} className="text-lg md:text-xl font-bold font-mono">0.0</span>
                <span className="text-[10px] ml-1 text-gray-400">m/s</span>
              </div>
            </div>

            {/* H. VEL */}
            <div className="flex flex-col items-center justify-center">
              <span className="text-[10px] md:text-xs text-cyan-400/70 tracking-widest uppercase font-bold mb-1">H.SPD</span>
              <div className="flex items-baseline">
                <span ref={vxRef} className="text-lg md:text-xl font-bold font-mono">0.0</span>
                <span className="text-[10px] ml-1 text-gray-400">m/s</span>
              </div>
            </div>

            {/* G-FORCE */}
            <div className="flex flex-col items-center justify-center">
              <span className="text-[10px] md:text-xs text-cyan-400/70 tracking-widest uppercase font-bold mb-1">G-Force</span>
              <div className="flex items-baseline">
                <span ref={gForceRef} className="text-lg md:text-xl font-bold font-mono">1.0</span>
                <span className="text-[10px] ml-1 text-gray-400">G</span>
              </div>
            </div>

          </div>
        </div>
      </div>

      {/* Touch Controls Overlay (Mobile) */}
      <div className="absolute bottom-6 left-0 w-full px-6 flex justify-between pointer-events-none md:hidden">
        <div className="flex gap-4">
          <TouchBtn 
            icon={<svg width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><path d="M15 18l-6-6 6-6"/></svg>}
            onTouchStart={handleTouchStart('left')} onTouchEnd={handleTouchEnd('left')}
          />
          <TouchBtn 
            icon={<svg width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><path d="M9 18l6-6-6-6"/></svg>}
            onTouchStart={handleTouchStart('right')} onTouchEnd={handleTouchEnd('right')}
          />
        </div>
        <TouchBtn 
          icon={<svg width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><path d="M12 19V5M5 12l7-7 7 7"/></svg>}
          isThrust={true}
          onTouchStart={handleTouchStart('up')} onTouchEnd={handleTouchEnd('up')}
        />
      </div>
      
      {/* Desktop Helper */}
      <div className="absolute bottom-6 left-1/2 -translate-x-1/2 text-gray-500/50 text-sm hidden md:block pointer-events-none tracking-widest uppercase">
        Use Arrow Keys or W-A-D to pilot
      </div>

    </div>
  );
}

function TouchBtn({ icon, onTouchStart, onTouchEnd, isThrust }) {
  return (
    <button
      className={`pointer-events-auto w-16 h-16 rounded-full flex items-center justify-center bg-black/40 border backdrop-blur active:bg-cyan-900/60 transition-colors select-none ${isThrust ? 'border-pink-500 text-pink-400 active:shadow-[0_0_20px_pink]' : 'border-cyan-500 text-cyan-400 active:shadow-[0_0_20px_cyan]'}`}
      onTouchStart={onTouchStart}
      onTouchEnd={onTouchEnd}
      onMouseDown={onTouchStart} // fallback for mouse testing
      onMouseUp={onTouchEnd}
      onMouseLeave={onTouchEnd}
    >
      {icon}
    </button>
  );
}