AddCSLuaFile("autorun/client/cl_gateguardian.lua")
AddCSLuaFile("autorun/sh_gateguardian.lua")
include("autorun/sh_gateguardian.lua")

-- Net Strings
util.AddNetworkString("uiStatus")
util.AddNetworkString("changeWhitelistData")
util.AddNetworkString("removeWhitelistData")
util.AddNetworkString("requestWhitelistData")
util.AddNetworkString("sendWhitelistData")

-- Functions
local defaults = {
    ["settings"] = {
        ["use-blacklist"] = false,
        ["use-whitelist"] = false
    },

    ["users"] = {
        
    }
}
local whitelistData = {}
whitelistData = defaults

local function loadData()
    local data = file.Read("gateguardian_data.json")
    local tblEd
    if (data) then tblEd = util.JSONToTable(data) end

    if (not data or not tblEd) then 
        whitelistData = defaults 
        return 
    else
        whitelistData = tblEd
    end
end

local function saveData(dataType, value, x)
    if (value and type(value) == "string") then
        loadData() -- update list
        if (whitelistData) then
            local tbl = whitelistData[dataType]
            if (tbl ~= nil) then
                whitelistData[dataType][value] = x
                file.Write("gateguardian_data.json", util.TableToJSON(whitelistData, true))
            end
        end
        loadData()
    end
end

-- Hook
hook.Add("PlayerSay", "gateguardian", function(plr, text) -- Chat CMD Hook
    if (text:lower() == "!whitelist") then
        if (IsValid(plr) and plr:IsSuperAdmin()) then
            net.Start("uiStatus")
                net.WriteBool(true)
            net.Send(plr)
        end
    end
end)

hook.Add("CheckPassword", "gateguardian", function(ID64, IP) -- Player join manager
    local ST64 = util.SteamIDFrom64(ID64)

    loadData() -- update
    local userValue = whitelistData["users"][ST64]

    -- blacklist/whitelist conditionals
    if (whitelistData["settings"]["use-blacklist"] == true) then
        if (userValue == true) then
            return false, "#GameUI_ServerRejectLANRestrict"
        end
    elseif (whitelistData["settings"]["use-whitelist"] == true) then
        if (userValue == false or userValue == nil) then
            return false, "#GameUI_ServerRejectLANRestrict"
        end
    end
end)

-- Net
net.Receive("changeWhitelistData", function(len, plr)
    local dataType = net.ReadString()
    local x = net.ReadString()
    local y = net.ReadBool()

    if (type(x) == "string" and plr:IsSuperAdmin()) then
        if (dataType == "users") then
            x = gateutil.grabID(x)

            if (whitelistData["users"][x]) then return end
        end

        saveData(dataType, x, y)

        if (plr:IsSuperAdmin() and not whitelistData["users"][plr:SteamID()]) then
            saveData("users", plr:SteamID(), true)
        end
    end
end)

net.Receive("requestWhitelistData", function(len, plr)
    if (plr:IsSuperAdmin()) then
        loadData()
        local dataType = net.ReadString()
        net.Start("sendWhitelistData")
            if (whitelistData) then
                net.WriteTable(whitelistData)
            end
        net.Send(plr)
    end
end)

net.Receive("removeWhitelistData", function(len, plr)
    local userID = net.ReadString()

    if (userID and plr:IsSuperAdmin()) then
        loadData()
        local tbl = whitelistData["users"]
        local pos = 0
        for k,_ in pairs(tbl) do
            pos = pos + 1
            if (k == userID) then
                table.remove(tbl, pos)
                file.Write("gateguardian_data.json", util.TableToJSON(whitelistData, true))
            end
        end
    end
end)