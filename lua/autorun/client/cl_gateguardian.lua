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

include("autorun/client/TDLib.lua")
include("autorun/sh_gateguardian.lua")

-- Variables
local lp = LocalPlayer()

-- Main
local c1, c2, dataPanel, delete
local data = {

}

local function updateScroll(dataType, panel)
    net.Start("requestWhitelistData")
    net.SendToServer()
end

net.Receive("sendWhitelistData", function(len)
    if (dataPanel) then
        local tbl = net.ReadTable()

        if (tbl ~= data) then
            delete = nil
            if (tbl["users"] and tbl["settings"]) then
                if (tbl["users"] ~= data["users"]) then
                    dataPanel:Clear()
                    local i = 1
                    for k,_ in pairs(tbl["users"]) do
                        local button = dataPanel:Add("DButton")
                            i = i + 1
                            button:Dock(TOP)
                            button:DockMargin(0,0,0,5)
                            button:SetText(k)
                            button.DoClick = function(self) 
                                delete = self 
                            end

                            button:TDLib()
                                :ClearPaint()
                                :FadeIn(i / 5)
                                :Background(Color(77, 84, 94, 255), 5)
                                :Text(tostring(k), "DermaDefault", Color(236, 240, 241), TEXT_ALIGN_CENTER)
                                :BarHover(Color(41, 128, 185, 60), 4, 5)
                                :CircleClick(Color(255, 255, 255, 45), 3)
                    end
                end

                if (tbl["settings"] ~= data["settings"]) then
                    c1:SetChecked(tbl["settings"]["use-whitelist"])
                    c2:SetChecked(tbl["settings"]["use-blacklist"])
                end

                data = tbl
            end
        end
    end
end)

local function sendUser(userEntry, whitelist)
    if (IsValid(lp)) then
        if (lp:IsSuperAdmin()) then
            net.Start("changeWhitelistData")
                net.WriteString("users")
                net.WriteString(userEntry)
                net.WriteBool(whitelist)
            net.SendToServer()

            updateScroll("frameUpdate", userEntry)
        end
    end
end

local function listToggle(type, value, frame)
    if (IsValid(lp)) then
        if (lp:IsSuperAdmin()) then
            net.Start("changeWhitelistData")
                net.WriteString("settings")
                net.WriteString(type)
                net.WriteBool(value)
            net.SendToServer()

            updateScroll("settings")
        end
    end
end

local function showList()
    local w,h = ScrW(), ScrH()
    local sX, sY = 400, 300

    local frame = vgui.Create("DFrame")
        frame:SetPos((w-sX)/2, (h-sY)/2)
        frame:SetSize(sX, sY)
        frame:SetTitle("GateGuardian - Whitelist")
        frame:ShowCloseButton(false)
        frame:SetDraggable(false)
        frame:SetBackgroundBlur(true)
        frame:SetPaintShadow(false)
        frame:MakePopup()
        frame:TDLib()
            :ClearPaint()
            :Background(Color(48, 43, 99, 255))
            :Gradient(Color(36, 36, 62, 255))

    -- User Input
    local entrySX, entrySY = 150,25
    local userEntry = vgui.Create("DTextEntry", frame)
        userEntry:SetSize(entrySX, entrySY)
        userEntry:SetPos((sX - entrySX) - 10, ((sY - entrySY) / 4) - entrySY)
        userEntry:SetText("Steam Profile Link or ID")
        userEntry.OnEnter = function() sendUser(self:GetValue(), true) end
        userEntry:TDLib()
            :ReadyTextbox()
            :FadeHover()
            :BarHover()
            :SideBlock(Color(255, 0, 0), 4, LEFT)

    local enableWhitelist = vgui.Create("DCheckBox", frame)
        enableWhitelist:SetPos(sX - 45, sY - 25)
        enableWhitelist.OnChange = function(self) listToggle("use-whitelist", enableWhitelist:GetChecked(), self) end
        c1 = enableWhitelist
        enableWhitelist:TDLib()
            :ClearPaint()
            :CircleCheckbox(Color(255, 0, 0))

    
    local enableBlacklist = vgui.Create("DCheckBox", frame)
        enableBlacklist:SetPos(sX - 160, sY - 25)
        enableBlacklist.OnChange = function(self) listToggle("use-blacklist", enableBlacklist:GetChecked(), self) end
        c2 = enableBlacklist
        enableBlacklist:TDLib()
            :ClearPaint()
            :CircleCheckbox(Color(255, 0, 0))

    -- Labels
    local whitelistLabel = vgui.Create("DLabel", frame)
        whitelistLabel:SetSize(100, 35)
        whitelistLabel:SetPos(sX - 65, sY - 50)
        whitelistLabel:SetText("Use Whitelist")

    local blacklistLabel = vgui.Create("DLabel", frame)
        blacklistLabel:SetSize(100, 35)
        blacklistLabel:SetPos(sX - 180, sY - 50)
        blacklistLabel:SetText("Use Blacklist")

    -- Buttons
    local addSX, addSY = 150, 20
    local add = vgui.Create("DButton", frame)
        add:SetSize(addSX, addSY)
        add:SetPos((sX - addSX) - 10, (sY - addSY) / 4)
        add.DoClick = function() sendUser(userEntry:GetValue(), true) end
        add:TDLib()
            :ClearPaint()
            :Background(Color(52, 73, 94, 255), 5)
            :Text("Add User", "HudHintTextLarge", Color(236, 240, 241), TEXT_ALIGN_CENTER)
            :CircleClick()

    local delSX, delSY = 150, 20
    local del = vgui.Create("DButton", frame)
        del:SetSize(delSX, addSY)
        del:SetPos((sX - delSX) - 10, (sY - delSY) - 50)
        del.DoClick = function() 
            if (delete) then 
                net.Start("removeWhitelistData")
                    net.WriteString(delete:GetText())
                net.SendToServer()
                delete:Remove() 
            end 
        end
        del:TDLib()
            :ClearPaint()
            :Background(Color(231, 76, 60, 255), 5)
            :Text("Remove Selected", "HudHintTextLarge", Color(236, 240, 241), TEXT_ALIGN_CENTER)
            :CircleClick()

    local closeButton = vgui.Create("DButton", frame)
        closeButton:SetSize(20, 20)
        closeButton:SetPos(sX - 20, 0)
        closeButton.DoClick = function() frame:Close() end
        closeButton:TDLib()
            :ClearPaint()
            :Background(Color(236, 240, 241, 255), 5)
            :Text("X", "DermaDefaultBold", Color(52, 73, 94), TEXT_ALIGN_CENTER)
            :CircleClick()

    -- Left Side
    local leftPanel = vgui.Create("DPanel", frame)
        leftPanel:SetSize(sX / 2, 0)
        leftPanel:TDLib()
            :ClearPaint()
            :Background(Color(50, 50, 50, 255), 5)
            :Stick(LEFT, 3)
            :LinedCorners()

    local scrollMenu = vgui.Create("DScrollPanel", leftPanel)
        dataPanel = scrollMenu
        scrollMenu:TDLib()
            :ClearPaint()
            :Background(Color(50, 50, 50, 255))
            :Stick(FILL, 2)

    updateScroll()
end
net.Receive("uiStatus", showList)
