-- UnifiedProject bootstrap: ensure init loaded
if not _G.__UNIFIED_INIT then require('Arbae.init') end

local Games = loadstring(game:HttpGet("https://raw.githubusercontent.com/MuhamadNurikbal/Arbae/main/GameList.lua"))()

local URL = Games[game.PlaceId]

if URL then
  loadstring(game:HttpGet(URL))()
end
