-- Speed_Hub_X.lua
-- Minimal loader that fetches required files from raw GitHub and provides an in-memory require

local OWNER = "MuhamadNurikbal"
local REPO  = "UnifiedProject_Refactored"
local BRANCH = "main"
local RAW_BASE = "https://raw.githubusercontent.com/"..OWNER.."/"..REPO.."/"..BRANCH.."/"

-- List modules/files to fetch (paths inside repo). Add whatever files Grow_a_Garden needs.
local files_to_fetch = {
    -- core bootstrap / config
    ["init"] = "init.lua",
    ["config"] = "config.lua",

    -- modules (use dot-name matching the require calls)
    ["Gaspol.Grow_a_Garden"] = "Gaspol/Grow_a_Garden.lua",

    -- add extra dependencies here if Grow_a_Garden calls them, e.g.:
    -- ["Main.Library.Execution"] = "Main/Library/Execution.lua",
    -- ["Gaspol.Fish"] = "Gaspol/Fish.lua",
}

-- fetch helper (uses game's HttpGet; most executors provide it)
local function fetch_raw(path)
    local url = RAW_BASE .. path
    local ok, res = pcall(function() return game:HttpGet(url, true) end)
    if not ok then
        error("Failed to fetch: "..tostring(url).." ("..tostring(res)..")")
    end
    return res
end

-- storage for module sources
local module_sources = {}
-- cache for executed modules
local module_cache = {}

-- fetch all modules
for modname, path in pairs(files_to_fetch) do
    -- try fetch, allow optional missing modules to be diagnosed
    local ok, src = pcall(fetch_raw, path)
    if not ok then
        error(("Speed_Hub_X: cannot fetch %s (%s)"):format(path, tostring(src)))
    end
    module_sources[modname] = src
end

-- override require to load from module_sources first
local orig_require = require
local function up_require(name)
    if module_cache[name] then
        return module_cache[name]
    end
    local src = module_sources[name]
    if not src then
        -- fallback to original require (if available) or error
        if orig_require then
            return orig_require(name)
        else
            error("Module not found: "..tostring(name))
        end
    end
    local fn, err = loadstring(src)
    if not fn then error("load error for "..name..": "..tostring(err)) end

    -- run module with protected environment:
    local ok, result = pcall(function()
        -- the module may return a value; execute and capture
        local ret = fn()
        -- cache either returned value or true marker
        module_cache[name] = ret ~= nil and ret or true
        return module_cache[name]
    end)
    if not ok then error("runtime error for "..name..": "..tostring(result)) end
    return result
end

-- make overridden require global (so modules using require() will call this)
_G.require = up_require
require = up_require -- also shadow local

-- Execute init first if present
if module_sources["init"] then
    local ok, err = pcall(function() up_require("init") end)
    if not ok then
        warn("Init failed: "..tostring(err))
    end
end
-- Execute config if present (some scripts may expect _G.UNIFIED_CONFIG)
if module_sources["config"] then
    pcall(function() up_require("config") end)
end

-- Finally start the Grow a Garden module (adjust if entry function name different)
local garden = up_require("Gaspol.Grow_a_Garden")
-- if module returned a table with start function, call it
if type(garden) == "table" and type(garden.start) == "function" then
    pcall(garden.start)
else
    -- if the module didn't return a table, maybe it ran on load already
    -- nothing else to do
end
