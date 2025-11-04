-- init.lua
-- Project initializer. When required, sets up package.path to allow requiring modules by root name
-- and loads central config into _G.UNIFIED_CONFIG.
if _G.__UNIFIED_INIT then return end
_G.__UNIFIED_INIT = true

local pwd = (... and debug.getinfo(1,"S").source:match("@?(.*/)" ) ) or "./"
-- make package.path include project root and its subdirectories (simple approach)
local root = pwd:gsub("__init.lua$","") or "./"
-- normalize root path (best-effort)
root = root or "./"

-- Add common search patterns
package.path = root .. "?.lua;" .. root .. "?/init.lua;" .. package.path

-- load config
local ok, cfg = pcall(require, "config")
if ok and cfg then
    _G.UNIFIED_CONFIG = cfg
else
    _G.UNIFIED_CONFIG = { env = {} }
end

-- Basic logger utility in _G for scripts to use
_G.UP = _G.UP or {}
function _G.UP.log(...)
    if _G.UNIFIED_CONFIG and _G.UNIFIED_CONFIG.env and _G.UNIFIED_CONFIG.env.DEBUG then
        print("[UP LOG]", ...)
    end
end

-- Signal initialized
_G.UP.INIT = true
