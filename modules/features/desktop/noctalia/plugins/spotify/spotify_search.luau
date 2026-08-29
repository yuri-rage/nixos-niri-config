--!nonstrict
---@diagnostic disable: undefined-global, lowercase-global

local helperPath = noctalia.expandPath("~/.local/state/noctalia/plugins/materialized/local/spotify/spotify_helper.py")

---@param s string?
---@return string
local function trim(s)
    return (s and s:match("^%s*(.-)%s*$")) or ""
end

---@param query string
function onQuery(query)
    local q = trim(query)
    if q == "" then
        launcher.setResults(query, {
            {
                id = "",
                title = "Search Spotify",
                subtitle = "Type a song, artist, or album name...",
                glyph = "music",
            }
        })
        return
    end

    launcher.setResults(query, {
        {
            id = "",
            title = "Searching Spotify...",
            subtitle = "Searching for '" .. q .. "'",
            glyph = "loader",
        }
    })

    local cmd = string.format("python3 '%s' search %s", helperPath, string.format("%q", q))
    noctalia.runAsync(cmd, function(result)
        if result and result.exitCode == 0 and type(result.stdout) == "string" then
            local data = nil
            if noctalia.json and noctalia.json.decode then
                data = noctalia.json.decode(result.stdout)
            end
            if type(data) == "table" and #data > 0 then
                local rows = {}
                for _, item in ipairs(data) do
                    table.insert(rows, {
                        id = item.id,
                        title = item.title,
                        subtitle = item.subtitle,
                        icon = "spotify",
                    })
                end
                launcher.setResults(query, rows)
                return
            end
        end

        launcher.setResults(query, {
            {
                id = "",
                title = "No results found",
                subtitle = "No matches for '" .. q .. "'",
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
