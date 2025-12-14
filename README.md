[![Support](https://img.shields.io/badge/Support-Buy%20Me%20a%20Coffee-6f4e37)](https://buymeacoffee.com/shablagu)

# BuffMonitor (Project Lazarus)

A controller-driven buff auditing tool for the Project Lazarus EverQuest EMU server.

---

## Credits
**Created by:** Alektra  
**For:** Project Lazarus EverQuest EMU Server  

---

## Description
BuffMonitor allows one designated controller character to check whether specific buffs are active on all group members.

Rather than running background scripts on every toon, BuffMonitor operates **on demand**. When you click a button, each group member briefly checks their own buffs, reports the result, and immediately exits.

This approach avoids persistent monitoring, reduces overhead, and stays aligned with Project Lazarus scripting constraints.

---

## Key Features
- **Controller-only execution**  
  Only one character runs the dashboard and coordinates checks.

- **On-demand buff auditing**  
  No background polling or always-on scripts.

- **Batched group checks**  
  One action triggers all group members to report at once.

- **Persistent configuration**  
  Buff lists and options are saved automatically.

- **Optional message filtering**  
  Suppress “buff active” messages and report only missing buffs.

- **Restart-safe operation**  
  Works reliably through zoning, relogs, and MacroQuest restarts.

- **Clean ImGui interface**  
  No popups or modal windows.

---

## How It Works

### Two-Script Model

#### Dashboard (Controller)
Runs on your main character and:
- Provides the ImGui interface
- Manages the list of buffs to check
- Sends check requests to the group
- Displays results

#### Agent (Responder)
Runs briefly on each group member when requested and:
- Checks that character’s active buffs
- Reports status back to the controller
- Exits immediately

---

### Process Flow
1. Select which buffs to monitor
2. Click **Ask Group to Check**
3. Each group member checks their own buffs
4. Results are reported to chat
5. Scripts exit — no background activity remains

---

## Requirements
- Project Lazarus EverQuest EMU server
- MacroQuest MQNext (MQ2Mono)
- E3Next running on all group members
- Characters must be grouped and in command range

---

## Installation
1. Copy both files to your MacroQuest Lua directory:
