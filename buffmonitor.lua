--==============================================================
-- buffmonitor.lua
-- Project Lazarus EMU / MQNext
--
-- Controller-driven Buff Monitor
-- Uses /e3bcg to exclude controller
--==============================================================

local mq    = require('mq')
local ImGui = require('ImGui')

local SCRIPT_VERSION = "1.5.0"
local CONFIG_PATH = mq.configDir .. "/buffmonitor_buffs.lua"

print("\atOriginally created by Alektra <Lederhosen>")
print("\agBuffMonitor v" .. SCRIPT_VERSION .. " Loaded")

------------------------------------------------------------
-- State
------------------------------------------------------------
local state = {
    open = true,
    buffs = {},
    removeBuffs = {},
    input = "",
    removeInput = "",
    onlyMissing = true,
    dirty = false,
}

------------------------------------------------------------
-- Persistence
------------------------------------------------------------
local function saveState()
    local f = io.open(CONFIG_PATH, "w")
    if not f then return end

    f:write("return {\n")
    f:write(string.format("  onlyMissing = %s,\n", tostring(state.onlyMissing)))
    f:write("  buffs = {\n")
    for _, b in ipairs(state.buffs) do
        f:write(string.format(
            "    { name = %q, enabled = %s },\n",
            b.name, tostring(b.enabled)
        ))
    end
    f:write("  },\n")
    f:write("  removeBuffs = {\n")
    for _, r in ipairs(state.removeBuffs) do
        f:write(string.format("    %q,\n", r))
    end
    f:write("  }\n}\n")
    f:close()
    state.dirty = false
end

local function loadState()
    local f = io.open(CONFIG_PATH, "r")
    if not f then return end
    local ok, data = pcall(load(f:read("*a")))
    f:close()
    if ok and type(data) == "table" then
        state.onlyMissing = data.onlyMissing ~= false
        state.buffs = data.buffs or {}
        state.removeBuffs = data.removeBuffs or {}
    end
end

loadState()

------------------------------------------------------------
-- Helpers
------------------------------------------------------------
local function trim(s)
    if type(s) ~= "string" then return nil end
    s = s:match("^%s*(.-)%s*$")
    return s ~= "" and s or nil
end

local function buffExists(name)
    local n = name:lower()
    for _, b in ipairs(state.buffs) do
        if b.name:lower() == n then return true end
    end
    return false
end

local function removeBuffExists(name)
    local n = name:lower()
    for _, r in ipairs(state.removeBuffs) do
        if r:lower() == n then return true end
    end
    return false
end

------------------------------------------------------------
-- Controller buff check
------------------------------------------------------------
local MAX_BUFF_SLOTS = 42
local function hasBuff(buff)
    local needle = buff:lower()
    for i = 1, MAX_BUFF_SLOTS do
        local b = mq.TLO.Me.Buff(i)
        if b() and b.Name() and b.Name():lower() == needle then
            return true
        end
    end
    return false
end

------------------------------------------------------------
-- Ask group
------------------------------------------------------------
local function askGroup()
    local enabled = {}
    for _, b in ipairs(state.buffs) do
        if b.enabled then table.insert(enabled, b.name) end
    end
    if #enabled == 0 then return end

    mq.cmd('/g BuffMonitor: Checking buffs...')

    -- Controller reports locally
    local me = mq.TLO.Me.CleanName()
    for _, buff in ipairs(enabled) do
        local active = hasBuff(buff)
        if (not active) or (not state.onlyMissing) then
            mq.cmdf('/g %s: %s = %s',
                me, buff, active and "ACTIVE" or "MISSING")
        end
    end

    -- Send to group EXCEPT controller
    if state.onlyMissing then
        table.insert(enabled, "__ONLY_MISSING__")
    end

    mq.cmdf(
        '/noparse /e3bcg /lua run buffmonitor_agent "%s"',
        table.concat(enabled, "|")
    )
end

------------------------------------------------------------
-- Remove buff from group
------------------------------------------------------------
local function removeBuffFromGroup(buffName)
    mq.cmdf('/noparse /e3bcga /removebuff "%s"', buffName)
    mq.cmdf('/g BuffMonitor: Removing [%s] from group', buffName)
end

------------------------------------------------------------
-- UI
------------------------------------------------------------
local function renderUI()
    if not state.open then return end
    local open = ImGui.Begin("BuffMonitor v" .. SCRIPT_VERSION, true)
    if not open then ImGui.End(); return end

    ImGui.Text("Add buff:")
    local t = ImGui.InputText("##buffinput", state.input)
    if type(t) == "string" then state.input = t end

    ImGui.SameLine()
    if ImGui.Button("Add") then
        local b = trim(state.input)
        if b and not buffExists(b) then
            table.insert(state.buffs, { name = b, enabled = true })
            state.dirty = true
        end
        state.input = ""
    end

    ImGui.Separator()

    local v = ImGui.Checkbox("Only report MISSING buffs", state.onlyMissing)
    if type(v) == "boolean" and v ~= state.onlyMissing then
        state.onlyMissing = v
        state.dirty = true
    end

    ImGui.Separator()
    ImGui.Text("Tracked buffs:")

    for i = #state.buffs, 1, -1 do
        local e = state.buffs[i]
        local c = ImGui.Checkbox("##e" .. i, e.enabled)
        if type(c) == "boolean" and c ~= e.enabled then
            e.enabled = c
            state.dirty = true
        end

        ImGui.SameLine()
        ImGui.Text(e.name)

        ImGui.SameLine()
        if ImGui.SmallButton("Delete##" .. i) then
            table.remove(state.buffs, i)
            state.dirty = true
        end
    end

    ImGui.Separator()
    if ImGui.Button("Save Changes") then saveState() end
    ImGui.SameLine()
    if ImGui.Button("Ask Group to Check") then askGroup() end

    if state.dirty then
        ImGui.TextColored(1, 0.6, 0.2, 1, "Unsaved changes")
    end

    -- NEW SECTION: Remove Buff
    ImGui.Separator()
    ImGui.Text("Remove buff from group:")
    local r = ImGui.InputText("##removebuffinput", state.removeInput)
    if type(r) == "string" then state.removeInput = r end

    ImGui.SameLine()
    if ImGui.Button("Add##removebuff") then
        local rb = trim(state.removeInput)
        if rb and not removeBuffExists(rb) then
            table.insert(state.removeBuffs, rb)
            state.dirty = true
        end
        state.removeInput = ""
    end

    ImGui.Separator()
    ImGui.Text("Stored remove buffs:")

    for i = #state.removeBuffs, 1, -1 do
        local buffName = state.removeBuffs[i]
        if ImGui.Button("Remove##rb" .. i) then
            removeBuffFromGroup(buffName)
        end

        ImGui.SameLine()
        ImGui.Text(buffName)

        ImGui.SameLine()
        if ImGui.SmallButton("Delete##rb" .. i) then
            table.remove(state.removeBuffs, i)
            state.dirty = true
        end
    end

    ImGui.End()
end

mq.imgui.init("buffmonitor_ui", renderUI)

while true do mq.delay(50) end
