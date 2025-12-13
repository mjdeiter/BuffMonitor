# BuffMonitor (Project Lazarus)

A controller-driven buff auditing tool for the Project Lazarus EverQuest EMU server.

## What It Does

BuffMonitor lets one character check whether specific buffs are active on all group members. Instead of running background scripts on everyone, it works on-demand: you click a button, and each character quickly reports their buff status.

## Compatible With

- MacroQuest MQNext (MQ2Mono)
- E3Next
- Lazarus-compatible ImGui bindings

---

## How It Works

**Two Simple Scripts:**

1. **Dashboard (Controller)** - Runs on your main character
   - Shows a simple interface
   - Manages which buffs to check
   - Sends requests to the group

2. **Agent (Responder)** - Runs briefly on each character when asked
   - Checks that character's buffs
   - Reports back
   - Exits immediately

**The Process:**

1. You select which buffs to monitor
2. Click "Ask Group to Check"
3. Each group member checks their own buffs and reports
4. Results appear in your chat

No background monitoring. No persistent scripts. Just quick, on-demand checks.

---

## Key Features

- **Controller-only execution** - Only your main character runs the full tool
- **Batched checks** - One broadcast triggers everyone at once
- **Persistent settings** - Your buff list saves automatically
- **Optional filtering** - Hide "buff active" messages, show only missing buffs
- **Restart-safe** - Works reliably through zoning, relogs, and MacroQuest restarts
- **No popups** - Clean, stable interface

---

## Requirements

- Project Lazarus server
- MacroQuest MQNext (MQ2Mono)
- E3Next running on all group members
- Characters must be grouped and in command range

---

## Installation

1. Copy both files to your MQ lua directory:
   - `buffmonitor_dashboard.lua`
   - `buffmonitor_agent.lua`

2. Make sure E3Next is running on all characters

3. On your controller character, type:
   ```
   /lua run buffmonitor_dashboard
   ```

---

## Usage

### Adding Buffs to Monitor

1. Type a buff name in the input field
2. Click **Add**
3. Click **Save Changes** to keep it

### Checking Your Group

Click **Ask Group to Check** - everyone will report their status immediately

### Managing Your Buff List

- **Enable/disable** individual buffs without deleting them
- **Delete** buffs you no longer need
- **Save Changes** to persist your configuration

### Options

- **Only report MISSING buffs** - Suppresses "buff active" messages to reduce spam

---

## Where Settings Are Saved

Configuration file: `<MQ Config Directory>/buffmonitor_buffs.lua`

This includes:
- Your buff list
- Which buffs are enabled
- Your options

The script handles missing or corrupted files gracefully.

---

## Design Philosophy

BuffMonitor respects Project Lazarus's environment by:

- **Using local checks only** - Each character checks their own buffs
- **Avoiding background polling** - Scripts run briefly, then exit
- **Working with server rules** - Respects visibility and automation boundaries
- **Staying predictable** - Explicit actions, no surprises

This keeps things stable, reliable, and compatible with normal gameplay.

---

## Credits

**Created by:** Alektra <Lederhosen>  
**For:** Project Lazarus EverQuest EMU Server  
**Support:** https://buymeacoffee.com/shablagu
