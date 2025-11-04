-- UnifiedProject bootstrap: ensure init loaded
if not _G.__UNIFIED_INIT then require('Arbae.init') end

local _env = getgenv and getgenv() or {}

local Ver = "Version: 3.7.0"
local Dis = "https://discord.gg/md5WNwbW9v"

_env.Discord = Dis
_env.Version = Ver
