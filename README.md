BuffMonitor (Project Lazarus)

BuffMonitor is a controller-driven buff auditing tool designed specifically for the Project Lazarus EverQuest EMU server, built to work reliably with:

MacroQuest MQNext (MQ2Mono)

E3Next

Lazarus-compatible ImGui bindings

It allows a single controller character to query group members on demand and report whether selected buffs are present or missing, without requiring persistent background scripts on every toon.

Design Goals

BuffMonitor is designed to operate within the intended behavior and constraints of the Project Lazarus MQNext environment:

Respect server-side visibility rules

Avoid assumptions about shared group state

Favor explicit execution over background polling

Minimize long-running automation

Maintain UI stability and predictability

The result is a tool that is reliable, lightweight, and restart-safe, even during zoning, relogs, or MacroQuest restarts.

Architecture Overview

BuffMonitor consists of two Lua scripts, each with a clearly defined role:

buffmonitor_dashboard.lua (Controller)

Runs on one designated controller toon

Provides a simple ImGui interface

Manages:

Buff list configuration

Enable/disable state per buff

User options

Persistent saved state

Uses E3 to request buff checks from group members

buffmonitor_agent.lua (Responder)

Executes only when requested

Runs locally on each toon via E3

Checks that toon’s own buff slots

Reports results

Exits immediately after completion

No responder runs continuously, and no background monitoring is performed.

How It Works

The controller selects which buffs to check.

The controller initiates a group check.

A single E3 broadcast triggers the responder on each group member.

Each toon:

Evaluates its own buffs locally

Reports results

Exits cleanly

This model aligns well with Lazarus gameplay, zoning behavior, and MacroQuest usage patterns.

Features

Controller-only execution

Batched buff checks (single E3 broadcast)

Add, delete, enable, and disable buffs

Explicit save and persistent configuration

Optional “Only report MISSING buffs” mode

Lazarus-compatible ImGui usage

No popups or modal windows

Stable across EQ and MacroQuest restarts

Requirements

Project Lazarus server

MacroQuest MQNext (MQ2Mono)

E3Next running on all group members

Characters grouped and within command range

Installation

Copy the following files into your MQ lua directory:

buffmonitor_dashboard.lua
buffmonitor_agent.lua


Ensure E3Next is running on all toons.

On the controller character, run:

/lua run buffmonitor_dashboard

Usage
Managing Buffs

Enter a buff name and click Add

Enable or disable buffs individually

Click Save Changes to persist configuration

Checking Buffs

Click Ask Group to Check

Group members will report their buff status

Options

Only report MISSING buffs suppresses “ACTIVE” messages

Buffs can be stored without being checked

All settings persist across restarts

Persistence

Configuration is stored at:

<MQ Config Directory>/buffmonitor_buffs.lua


The file includes:

Buff definitions

Enable/disable flags

User options

The script safely handles missing or invalid configuration files.

Scope and Limitations

BuffMonitor intentionally:

Checks buffs only on the toon executing the responder

Avoids group-wide polling or shared state assumptions

Avoids persistent background monitoring

These choices prioritize stability, clarity, and compatibility within the Lazarus environment.

Logging

On execution, scripts log:

Author credit

Script version

Startup confirmation

Responder logs provide confirmation that remote execution occurred on each toon.

Rationale

Project Lazarus provides a rich and flexible EMU environment with clear boundaries around visibility and automation. BuffMonitor is designed to work comfortably within those boundaries by:

Using E3 for explicit coordination

Performing checks locally

Keeping automation short-lived and predictable

This approach helps ensure consistent behavior without interfering with gameplay or server expectations.

License / Attribution

Originally created by Alektra <Lederhosen>

Intended for use on the Project Lazarus EverQuest EMU server.
