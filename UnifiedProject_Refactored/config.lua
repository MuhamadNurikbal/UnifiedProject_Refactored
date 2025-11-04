-- config.lua
-- Central configuration for UnifiedProject.
-- It first tries to read environment variables (via os.getenv) and falls back to defaults.
local M = {}

-- Example config entries (adjust as needed)
M.env = {
    MODE = os.getenv("UNIFIED_MODE") or "development",
    API_KEY = os.getenv("UNIFIED_API_KEY") or "replace-with-key",
    GAME_PREFIX = os.getenv("UNIFIED_GAME_PREFIX") or "UP_",
    DEBUG = (os.getenv("UNIFIED_DEBUG") == "1") or false,
}

-- Expose function for pretty printing config
function M.print()
    print("UnifiedProject config:")
    for k,v in pairs(M.env) do
        print(string.format("  %s = %s", k, tostring(v)))
    end
end


-- Load .env file if exists
local function load_env_file()
    local env_path = "./.env"
    local vars = {}
    local file = io.open(env_path, "r")
    if file then
        for line in file:lines() do
            local key, val = line:match("^%s*([%w_]+)%s*=%s*(.-)%s*$")
            if key and val then
                vars[key] = val
            end
        end
        file:close()
    end
    return vars
end

local envfile = load_env_file()
for k,v in pairs(envfile) do
    if not os.getenv(k) then
        os.setenv = os.setenv or function() end
    end
end

return M
