--==============================================================
-- buffmonitor_agent.lua
-- Project Lazarus EMU / MQNext
--
-- OPTION 1: Responder (BATCHED)
-- Supports "Only report MISSING"
--==============================================================

local mq = require('mq')

------------------------------------------------------------
-- Version / Identity
------------------------------------------------------------
local SCRIPT_VERSION = "1.2.0"

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
-- Buff scan
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
