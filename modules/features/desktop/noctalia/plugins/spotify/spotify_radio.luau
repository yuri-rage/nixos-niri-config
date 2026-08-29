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

    launcher.setResults(query, {
        {
            id = "",
            title = "Loading Radio Stations...",
            subtitle = q == "" and "Checking current track..." or ("Searching stations for '" .. q .. "'"),
            glyph = "loader",
        }
    })

    local cmd = q == "" and string.format("python3 '%s' radio", helperPath)
        or string.format("python3 '%s' radio %s", helperPath, string.format("%q", q))

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
                        icon = item.icon or "spotify",
                        glyph = item.glyph or "music",
                    })
                end
                launcher.setResults(query, rows)
                return
            end
        end

        launcher.setResults(query, {
            {
                id = "",
                title = "No Radio Stations Found",
                subtitle = "Make sure music is playing or type an artist/track name",
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
