--!nonstrict
---@diagnostic disable: undefined-global, lowercase-global

local helperPath = noctalia.expandPath("~/.local/state/noctalia/plugins/materialized/local/spotify/spotify_helper.py")
local cachedPlaylists = nil

---@param s string?
---@return string
local function trim(s)
    return (s and s:match("^%s*(.-)%s*$")) or ""
end

---@param items table
---@param filter string
---@return table
local function makeRows(items, filter)
    local rows = {}
    for _, item in ipairs(items) do
        local name = item.title or ""
        local subtitle = item.subtitle or ""
        local score = filter == "" and 0 or noctalia.fuzzyScore(filter, name)
        if score == nil and filter ~= "" then
            score = noctalia.fuzzyScore(filter, subtitle)
        end
        if filter == "" or score ~= nil then
            table.insert(rows, {
                id = item.id,
                title = name,
                subtitle = subtitle,
                icon = "spotify",
                score = filter == "" and nil or score,
            })
        end
    end
    return rows
end

---@param query string
---@param items table
---@param filter string
local function showResults(query, items, filter)
    local rows = makeRows(items, filter)
    if #rows == 0 then
        launcher.setResults(query, {
            {
                id = "",
                title = "No matching playlists",
                subtitle = filter ~= "" and ("No playlists matching '" .. filter .. "'") or "No playlists found",
                glyph = "music",
            }
        })
    else
        launcher.setResults(query, rows)
    end
end

---@param query string
function onQuery(query)
    local filter = trim(query)

    if filter == "" then
        cachedPlaylists = nil
    end

    if cachedPlaylists then
        showResults(query, cachedPlaylists, filter)
        return
    end

    launcher.setResults(query, {
        {
            id = "",
            title = "Loading playlists...",
            subtitle = "Fetching your Spotify library",
            glyph = "loader",
        }
    })

    local cmd = string.format("python3 '%s' playlists", helperPath)
    noctalia.runAsync(cmd, function(result)
        if result and result.exitCode == 0 and type(result.stdout) == "string" then
            local data = nil
            if noctalia.json and noctalia.json.decode then
                data = noctalia.json.decode(result.stdout)
            end
            if type(data) == "table" and #data > 0 then
                cachedPlaylists = data
                showResults(query, data, filter)
                return
            end
        end

        launcher.setResults(query, {
            {
                id = "",
                title = "No Playlists Found",
                subtitle = "Make sure spotify_player is authenticated",
                glyph = "music",
            }
        })
    end)
end

---@param id string
function onActivate(id)
    if id == "" then
        return
    end
    local cmd = string.format("python3 '%s' play '%s'", helperPath, id)
    noctalia.runAsync(cmd)
    noctalia.msg("panel-close launcher")
end
