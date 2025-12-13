--==============================================================
-- buffmonitor_agent.lua
-- Project Lazarus EMU / MQNext
--
-- DUAL MODE: Buff Check + Buff Removal
-- Supports "Only report MISSING" and batched removals
--==============================================================
local mq = require('mq')

------------------------------------------------------------
-- Version / Identity
------------------------------------------------------------
local SCRIPT_VERSION = "1.3.0"

------------------------------------------------------------
-- Logging helper
------------------------------------------------------------
local function logMessage(msg)
    print("\ao[BuffMonitor_agent] " .. msg)
end

------------------------------------------------------------
-- Startup messages
------------------------------------------------------------
print("\atOriginally created by Alektra <Lederhosen>")
print("\agBuffMonitor_agent v" .. SCRIPT_VERSION .. " Loaded")
logMessage("Script started")

------------------------------------------------------------
-- Args
------------------------------------------------------------
local arg = table.concat({...}, " ")
if not arg or arg == "" then
    logMessage("ERROR: No arguments provided.")
    return
end

------------------------------------------------------------
-- Mode detection
------------------------------------------------------------
local mode = "CHECK" -- default
if arg:sub(1, 9) == "__REMOVE|" then
    mode = "REMOVE"
    arg = arg:sub(10) -- strip prefix
end

------------------------------------------------------------
-- Parse args
------------------------------------------------------------
local buffs = {}
local onlyMissing = false

for token in string.gmatch(arg, "([^|]+)") do
    if token == "__ONLY_MISSING__" then
        onlyMissing = true
    else
        table.insert(buffs, token)
    end
end

if #buffs == 0 then
    logMessage("ERROR: No buffs parsed.")
    return
end

------------------------------------------------------------
-- Mode: REMOVE
------------------------------------------------------------
if mode == "REMOVE" then
    logMessage("REMOVE mode: " .. #buffs .. " buff(s)")
    for _, buff in ipairs(buffs) do
        mq.cmdf('/removebuff "%s"', buff)
        logMessage("Removed: " .. buff)
    end
    return
end

------------------------------------------------------------
-- Mode: CHECK (original behavior)
------------------------------------------------------------
local MAX_BUFF_SLOTS = 42
local toonName = mq.TLO.Me.CleanName()

local function hasBuff(target)
    local needle = target:lower()
    for i = 1, MAX_BUFF_SLOTS do
        local b = mq.TLO.Me.Buff(i)
        if b() and b.Name() then
            if b.Name():lower() == needle then
                return true
            end
        end
    end
    return false
end

------------------------------------------------------------
-- Respond
------------------------------------------------------------
for _, buff in ipairs(buffs) do
    local active = hasBuff(buff)
    if (not active) or (not onlyMissing) then
        local status = active and "ACTIVE" or "MISSING"
        mq.cmdf('/g %s: %s = %s', toonName, buff, status)
    end
end

logMessage("Reported buffs (onlyMissing=" .. tostring(onlyMissing) .. ")")
