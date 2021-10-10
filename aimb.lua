local players = game:GetService("Players")
local userinputservice = game:GetService("UserInputService")
local runservice = game:GetService("RunService")

local client = players.LocalPlayer
local character = client.Character or client.CharacterAdded:Wait()
local mouse = client:GetMouse()

local settings = {
    Enabled = false,
    AimPart = "Head",
    TeamCheck = false,
    WallCheck = false,
    DrawFOV = false,
    FOVRadius = 200,
    FOVColor = Color3.fromHSV(tick() % 5 / 5, 1, 1),
    Smoothness = 1,
    Keybind = Enum.KeyCode.LeftControl,
    boxes = false
}

local checks = {
    Holding = false
}

local fovCircle = Drawing.new("Circle")
fovCircle.Transparency = 1 
fovCircle.Thickness = 1.5 
fovCircle.Visible = settings.DrawFOV
fovCircle.Color = settings.FOVColor
fovCircle.Filled = false 
fovCircle.Radius = settings.FOVRadius

local function getClosest()
    local dist = math.huge 
    local closestPlayer = nil

    for i, player in ipairs(players:GetPlayers()) do
        if player ~= client then
            if player.Character then
                if player.Character:FindFirstChildWhichIsA("Humanoid") then
                    local characterr = player.Character
                    local humanoid = characterr:FindFirstChildWhichIsA("Humanoid")

                    if humanoid.Health > 0 then
                        if (settings.TeamCheck and player.TeamColor ~= client.TeamColor) or not settings.TeamCheck then
                            if not characterr[settings.AimPart] and not settings.AimPart == "Closest body part" then return end 
                    
                            local characterPartPosition, onScreen = workspace.CurrentCamera:WorldToViewportPoint(characterr[settings.AimPart].Position)

                            if onScreen then
                                local magnitude = (Vector2.new(mouse.X, mouse.Y) - Vector2.new(characterPartPosition.X, characterPartPosition.Y)).Magnitude
                                local ray = Ray.new(character.Head.Position, (characterr[settings.AimPart].Position - character.Head.Position).unit * 5000)
                            
                                if magnitude < dist and magnitude < settings.FOVRadius then
                                    if settings.WallCheck then
                                        local part, point = workspace:FindPartOnRayWithIgnoreList(ray, {character, workspace.CurrentCamera})

                                        if part and part:IsDescendantOf(characterr) then
                                            dist = magnitude
                                            closestPlayer = player
                                        end
                                    else
                                        dist = magnitude
                                        closestPlayer = player
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    
    return closestPlayer
end


userinputservice.InputBegan:Connect(function(input, isTyping)
    if not isTyping then
        if input.KeyCode == settings.Keybind then
            checks.Holding = true 
        end
    end
end)

userinputservice.InputEnded:Connect(function(input, isTyping)
    if not isTyping then
        if input.KeyCode == settings.Keybind then
            checks.Holding = false
        end
    end
end)

runservice.RenderStepped:Connect(function()
    if settings.Enabled and checks.Holding then
        local closestPlayer = getClosest()
        
        if closestPlayer then
            local dd = {}

            for i,v in ipairs(closestPlayer.Character:GetDescendants()) do
                if v:IsA("BasePart") then
                    local characterPartPosition, onScreen = workspace.CurrentCamera:WorldToViewportPoint(v.Position)
                    local x = ((mouse.X - characterPartPosition.X) + (mouse.Y - characterPartPosition.Y))
                    table.insert(dd, {lol = x, instance = v})
                end
            end

            local closest = math.huge 
            local part = nil 

            for i,v in ipairs(dd) do
                if v.lol < closest then
                    closest = v.lol 
                    part = v.instance 
                end
            end

            local characterPartPosition, onScreen = workspace.CurrentCamera:WorldToScreenPoint(closestPlayer.Character[settings.AimPart].Position)
            local magnitudeX = mouse.X - characterPartPosition.X
            local magnitudeY = mouse.Y - characterPartPosition.Y

            mousemoverel(-magnitudeX / settings.Smoothness, -magnitudeY / settings.Smoothness)
        end
    end
    
    if settings.DrawFOV then
        fovCircle.Position = Vector2.new(mouse.X, mouse.Y+game:GetService("GuiService"):GetGuiInset().Y)
        fovCircle.Color = settings.FOVColor
        fovCircle.Visible = settings.DrawFOV
    else
        fovCircle.Visible = false
    end
end)

---

local library = loadstring(game:GetObjects("rbxassetid://7657867786")[1].Source)()
local aimbotWindow = library:CreateWindow({
    Name = "eruptware"
})
local aimbotTab = aimbotWindow:CreateTab({
    Name = "Aimbot"
})
local aimbotSettingsSection = aimbotTab:CreateSection({
    Name = "Aimbot"
})
local fovSettingSection = aimbotTab:CreateSection({
    Name = "FOV"
})
aimbotSettingsSection:AddToggle({
    Name = "Enabled",
    Callback = function(value)
        settings.Enabled = value
    end
})
aimbotSettingsSection:AddDropdown({
    Name = "Hitbox Priority",
    List = {
        "Head",
        "Torso"
    },
    Callback = function(value, oldValue)
        settings.AimPart = value
    end
})
aimbotSettingsSection:AddToggle({
    Name = "Team Check",
    Callback = function(value)
        settings.TeamCheck = value 
    end
})
aimbotSettingsSection:AddToggle({
    Name = "Visibility Check",
    Callback = function(value)
        settings.WallCheck = value 
    end
})
aimbotSettingsSection:AddSlider({
    Name = "Smoothness",
    Callback = function(value)
        settings.Smoothness = value
    end,
    Min = 1,
    Max = 200,
    Value = settings.smoothness
})
aimbotSettingsSection:AddKeybind({
    Name = "Keybind",
    Value = settings.Keybind,
    Callback = function(value, oldValue)
        settings.Keybind = value    
    end,

})
--
fovSettingSection:AddToggle({
    Name = "Enabled",
    Callback = function(value)
        settings.DrawFOV = value 
    end
})
fovSettingSection:AddSlider({
    Name = "Radius",
    Callback = function(value)
        settings.FOVRadius = value 
        fovCircle.Radius = value
    end,
    Min = 5,
    Max = 600,
    Value = settings.FOVRadius
})
fovSettingSection:AddColorpicker({
    Name = "Color",
    Rainbow = false,
    Value = settings.FOVColor,
    Callback = function(value, oldValue)
        settings.FOVColor = value
    end
})
