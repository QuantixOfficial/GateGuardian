-- Utilities
gateutil = {}

gateutil.grabID = function(str)
    if (str) then
        local _,x = string.find(str, "profiles/")
        if (type(x) == "number") then
            x = string.sub(str, x+1)
            local y = string.find(x, "/")
            if (y) then
                x = string.sub(x, 0, y-1)
                x = util.SteamIDFrom64(x)
                return x
            else
                x = util.SteamIDFrom64(x)
                return x
            end
        elseif (x ~= nil) then
            local y = string.find(x, "/")
            if (y) then
                x = string.sub(x, 0, y-1)
                x = util.SteamIDFrom64(x)
                return x
            else
                x = util.SteamIDFrom64(x)
                if (string.find(x, "STEAM_")) then
                    return x
                end
            end
        end
    end
end

return gateutil