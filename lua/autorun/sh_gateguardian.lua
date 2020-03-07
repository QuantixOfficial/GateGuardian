--[[
    Copyright 2020 Quantix

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
]]--

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
