--==============================================================
-- buffmonitor_dashboard.lua
-- Project Lazarus EMU / MQNext
--
-- OPTION 1: Driver GUI (Ask & Respond)
-- BATCHED buff dispatch + "Only report MISSING"
--==============================================================

local mq    = require('mq')
local ImGui = require('ImGui')

------------------------------------------------------------
-- Version / Identity
------------------------------------------------------------
local SCRIPT_VERSION = "1.4.0"

------------------------------------------------------------
-- Paths
------------------------------------------------------------
local CONFIG_PATH = mq.configDir .. "/buffmonitor_buffs.lua"

------------------------------------------------------------
-- Logging helper
------------------------------------------------------------
local function logMessage(msg)
    print("\ao[BuffMonitor] " .. msg)
end

------------------------------------------------------------
-- Startup messages
------------------------------------------------------------
print("\atOriginally created by Alektra <Lederhosen>")
print("\agBuffMonitor v" .. SCRIPT_VERSION .. " Loaded")
logMessage("Script started")

------------------------------------------------------------
-- State
------------------------------------------------------------
local state = {
    open = true,
    buffs = {},        -- { {name=string, enabled=bool}, ... }
    input = "",
    onlyMissing = true,
    dirty = false,
}

------------------------------------------------------------
-- Persistence
------------------------------------------------------------
local function saveState()
    local f = io.open(CONFIG_PATH, "w")
    if not f then
        logMessage("ERROR: Unable to save state.")
        return
    end

    f:write("return {\n")
    f:write(string.format("  onlyMissing = %s,\n", tostring(state.onlyMissing)))
    f:write("  buffs = {\n")

    for _, b in ipairs(state.buffs) do
        f:write(string.format(
            "    { name = %q, enabled = %s },\n",
            b.name,
            tostring(b.enabled)
        ))
    end

    f:write("  }\n")
    f:write("}\n")
    f:close()

    state.dirty = false
    logMessage("State saved.")
end

local function loadState()
    local f = io.open(CONFIG_PATH, "r")
    if not f then
        logMessage("No saved state found. Starting fresh.")
        return
    end

    local ok, data = pcall(load(f:read("*a")))
    f:close()

    if ok and type(data) == "table" then
        state.onlyMissing = data.onlyMissing ~= false
        state.buffs = data.buffs or {}
        logMessage("Loaded state (" .. tostring(#state.buffs) .. " buffs).")
    else
        logMessage("ERROR: Failed to load saved state.")
    end
end

loadState()

------------------------------------------------------------
-- Helpers
------------------------------------------------------------
local function trim(s)
    if type(s) ~= "string" then return nil end
    s = s:match("^%s*(.-)%s*$")
    if s == "" then return nil end
    return s
end

local function buffExists(name)
    local lower = name:lower()
    for _, b in ipairs(state.buffs) do
        if b.name:lower() == lower then return true end
    end
    return false
end

------------------------------------------------------------
-- Ask group via E3 (BATCHED)
------------------------------------------------------------
local function askGroup()
    local enabled = {}

    for _, b in ipairs(state.buffs) do
        if b.enabled then
            table.insert(enabled, b.name)
        end
    end

    if #enabled == 0 then
        mq.cmd('/g BuffMonitor: No enabled buffs to check.')
        return
    end

    if state.onlyMissing then
        table.insert(enabled, "__ONLY_MISSING__")
    end

    local payload = table.concat(enabled, "|")

    mq.cmd('/g BuffMonitor: Checking buffs...')
    mq.cmdf('/noparse /e3bcga /lua run buffmonitor_agent "%s"', payload)
end

------------------------------------------------------------
-- UI (Lazarus-safe)
------------------------------------------------------------
local function renderUI()
    if not state.open then return end

    local title = "BuffMonitor v" .. SCRIPT_VERSION
    local open = ImGui.Begin(title, true)
    if not open then ImGui.End(); return end

    ImGui.Text("Add buff:")
    local txt = ImGui.InputText("##buffinput", state.input)
    if type(txt) == "string" then state.input = txt end

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

    local val = ImGui.Checkbox("Only report MISSING buffs", state.onlyMissing)
    if type(val) == "boolean" and val ~= state.onlyMissing then
        state.onlyMissing = val
        state.dirty = true
    end

    ImGui.Separator()
    ImGui.Text("Tracked buffs:")

    if #state.buffs == 0 then
        ImGui.TextDisabled("(none)")
    else
        for i = #state.buffs, 1, -1 do
            local entry = state.buffs[i]

            local c = ImGui.Checkbox("##enabled_" .. i, entry.enabled)
            if type(c) == "boolean" and c ~= entry.enabled then
                entry.enabled = c
                state.dirty = true
            end

            ImGui.SameLine()
            ImGui.Text(entry.name)

            ImGui.SameLine()
            if ImGui.SmallButton("Delete##" .. i) then
                table.remove(state.buffs, i)
                state.dirty = true
            end
        end
    end

    ImGui.Separator()

    if ImGui.Button("Save Changes") then
        saveState()
    end

    ImGui.SameLine()
    if ImGui.Button("Ask Group to Check") then
        askGroup()
    end

    if state.dirty then
        ImGui.TextColored(1, 0.6, 0.2, 1, "Unsaved changes")
    end

    ImGui.End()
end

mq.imgui.init("buffmonitor_dashboard_ui", renderUI)

while true do
    mq.delay(50)
end
