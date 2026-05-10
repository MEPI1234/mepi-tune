# MEPI-TUNE v2.1.0
### PC Optimization Suite by mepi

---

## How to Install & Run

1. **Download** and extract the `mepi-tune` folder anywhere on your PC (e.g. `C:\mepi-tune`)

2. **Double-click `START.bat`**
   - It will auto-request Administrator privileges
   - A browser window will open automatically with the full UI
   - Keep the PowerShell window open while using the suite

3. That's it.

---

## What It Does

- Opens a live monitoring UI in your browser at `http://localhost:7420`
- Shows real-time CPU and GPU temperatures with live charts
- Lets you toggle 50 tweaks on/off with a single click
- **Creates a system restore point and registry backups before touching anything**
- Saves a full log of every change made to `.\logs\`

---

## Tweaks Included

### System Core
- Auto Login
- Win32 Priority → 18
- Kernel Worker Threads
- Scheduling Reserve
- Disable Hyper-V
- Disable Telemetry (services + hosts file)
- Disable System Animations
- Disable HPET
- Disable Xbox Game Bar
- Spectre/Meltdown Mitigations Off ⚠️

### CPU / Power
- High Performance Power Plan
- Disable CPU Parking
- Disable C-States ⚠️
- Power Throttling Off
- Timer Resolution → 0.5ms

### GPU
- Enable HAGS (Hardware Accelerated GPU Scheduling)
- GPU Max Performance Mode
- Disable NVIDIA Telemetry

### Memory
- Disable Memory Compression
- Disable Superfetch / SysMain
- Clear Standby Memory (instant, runtime)

### Storage
- Disable 8.3 Filename Creation
- Disable Last Access Timestamp
- Fixed Pagefile (4–8GB)

### Network
- DNS → Cloudflare (1.1.1.1)
- Disable Nagle's Algorithm
- TCP Global Optimizations
- Winsock Buffer Tuning
- Disable Network Background Interference
- Stabilize Network Routing
- Disable TCP Heuristics
- Optimize MPP

### Input / Latency
- Raw Mouse Input (disable pointer acceleration)

### Services
- Disable Windows Search Indexing
- Disable Print Spooler
- Disable Windows Update Delivery Optimization
- Game Mode On / DVR Off
- Debloat (removes 30+ built-in apps) ⚠️

---

## Restore / Undo

Every tweak saves its original value before changing anything.
Click the toggle again in the UI to restore a specific tweak.
Or use **Restore All** to revert everything at once.

If something goes wrong, open System Restore and use the
restore point created by MEPI-TUNE at launch.

Registry backups are in `.\backup\`

---

## Requirements

- Windows 10 / 11
- PowerShell 5.1 or higher (built into Windows)
- Administrator rights
- A browser (Chrome/Edge/Firefox)

---

## Notes

- ⚠️ tweaks carry a risk or require a reboot — read the description before enabling
- Debloat **cannot be undone** automatically — only restore from a system image
- GPU tweaks work best with NVIDIA cards. AMD support is partial.
- Keep the PowerShell window open — closing it shuts down the UI server

---

github.com/mepi | GPLv3
