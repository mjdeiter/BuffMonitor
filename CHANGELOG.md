# BuffMonitor Changelog
All notable changes to BuffMonitor are documented here. The project prioritizes stability and compatibility with Project Lazarus over strict semantic versioning.

---

## [1.5.0] – Remove Buff Feature
**Group-wide buff removal with stored buff names**

### What's New
- **Remove Buff section** - Store buff names for quick group-wide removal
- **One-click removal** - Execute `/e3bcga /removebuff "Buff Name"` from UI
- **Persistent remove list** - Saved buff names survive script restarts
- **Duplicate prevention** - Stored buff names are validated and deduplicated

### Changes
- Updated configuration file format to include `removeBuffs` array
- Version bumped to 1.5.0

### Architecture Notes
- Remove buff feature uses `/e3bcga` (all group members including controller)
- Stored buff names persist alongside tracked buffs in the same config file
- UI layout preserved - new section added after existing controls

---

## [1.4.3] – Stable Release
**Controller-safe execution and duplicate report fix**

### What's New
- **Controller self-checking** - Controller now checks its own buffs locally for consistent reporting
- **Batched buff checks** - One E3 broadcast triggers all group checks at once
- **"Only report MISSING buffs" option** - Reduce chat spam by hiding active buff messages
- **Persistent settings** - Your buff list, enabled/disabled states, and options are saved automatically

### Changes
- **Switched from `/e3bcga` to `/e3bcg`** - Group members now respond without the controller duplicating reports
- **Single execution per character** - Each character runs the responder once per check instead of multiple times
- **Cleaner output** - Better clarity with less chat noise

### Fixes
- Fixed controller sometimes not reporting its own buffs (caused by MQNext Lua concurrency)
- Fixed controller appearing twice in results
- Fixed race conditions from self-targeted E3 broadcasts

### Architecture Notes
This version represents the final intended design:
- Controller checks itself locally
- Group members respond via short-lived scripts
- No background monitoring
- No assumptions about group-wide visibility

---

## [1.4.0 – 1.4.2] – Iteration and Refinement

### What's New
- Batched buff checking
- Option to suppress "ACTIVE" buff messages
- Better configuration file handling

### Changes
- Improved responder argument parsing
- Better ImGui compatibility for Lazarus

### Fixes
- Fixed checkbox flickering caused by Lazarus ImGui behavior
- Fixed unintended state changes in render loops

---

## [1.3.0] – Batched Responder Support

### What's New
- **Multiple buffs per check** - Responder can now check several buffs in one execution
- **Reduced command spam** - Fewer E3 commands needed

### Changes
- Reworked communication to use delimited payloads between controller and agents

---

## [1.2.x] – Persistence and UI Stability

### What's New
- **Saved buff lists** - Your configuration persists between sessions
- **Enable/disable toggles** - Keep buffs in your list without checking them
- **Explicit save button** - Control when changes are written to disk

### Fixes
- Fixed buff list getting wiped by text input behavior
- Fixed checkbox instability in Lazarus ImGui

---

## [1.0.0] – Initial Release

### What's New
- Basic buff monitoring via group queries
- Simple ImGui interface
- Agent-based buff checking

---

## Design Philosophy
BuffMonitor is intentionally built to:
- **Avoid background monitoring** - Scripts run only when needed
- **Use explicit E3 commands** - No hidden automation
- **Check locally** - Each character checks their own buffs
- **Keep UI simple** - Stable interface compatible with Lazarus

This ensures reliable behavior through zoning, relogs, and MacroQuest restarts.

---

## Credits
**Created by:** Alektra <Lederhosen>  
**Developed for:** Project Lazarus EverQuest EMU Server
