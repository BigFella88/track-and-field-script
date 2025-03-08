local HttpService = game:GetService("HttpService")
local KILLSWITCH_URL = "https://pastebin.com/raw/3LNQJM1Q" -- Your Pastebin raw URL

local function checkKillswitch()
    local success, response = pcall(function()
        return HttpService:GetAsync(KILLSWITCH_URL)
    end)
    if not success or response ~= "on" then
        error("This script has been disabled by the creator.")
    end
end

checkKillswitch()

-- Your original script starts here
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

local originalSizes = {}
local isRunning = false
local beams = {}
local raceTypes = {"110 METER HURDLES", "200 METER DASH"}

local function createUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "TrackAndFieldUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 400, 0, 330)
    mainFrame.Position = UDim2.new(0.5, -200, 0.5, -165)
    mainFrame.BackgroundColor3 = Color3.fromRGB(10, 30, 40)
    mainFrame.BorderSizePixel = 0
    Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 5)
    mainFrame.Parent = screenGui
    mainFrame.Visible = false

    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 30)
    titleBar.BackgroundColor3 = Color3.fromRGB(20, 50, 70)
    titleBar.BorderSizePixel = 0
    titleBar.Parent = mainFrame

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -50, 1, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "Track And Field"
    titleLabel.TextColor3 = Color3.fromRGB(220, 220, 230)
    titleLabel.TextSize = 16
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Position = UDim2.new(0, 10, 0, 0)
    titleLabel.Parent = titleBar

    local menuButton = Instance.new("ImageButton")
    menuButton.Size = UDim2.new(0, 60, 0, 60)
    menuButton.Position = UDim2.new(0.5, -30, 0.5, -30)
    menuButton.BackgroundColor3 = Color3.fromRGB(0, 100, 180)
    menuButton.BorderSizePixel = 0
    Instance.new("UICorner", menuButton).CornerRadius = UDim.new(0, 15)
    menuButton.Parent = screenGui

    local logoImage = Instance.new("ImageLabel")
    logoImage.Size = UDim2.new(0, 50, 0, 50)
    logoImage.Position = UDim2.new(0.5, -25, 0.5, -25)
    logoImage.BackgroundTransparency = 1
    logoImage.ImageTransparency = 0
    logoImage.Image = "rbxassetid://14581054949"
    logoImage.Parent = menuButton

    if not pcall(function() logoImage.Image = logoImage.Image end) then
        warn("Track logo (rbxassetid://14581054949) failed to load. Using fallback image.")
        logoImage.Image = "rbxassetid://7072724"
    end

    local tween = TweenService:Create(logoImage, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, -1, true), {ImageColor3 = Color3.fromRGB(0, 150, 200)})
    tween:Play()

    local contentFrame = Instance.new("Frame")
    contentFrame.Size = UDim2.new(1, -20, 1, -100)
    contentFrame.Position = UDim2.new(0, 10, 0, 100)
    contentFrame.BackgroundTransparency = 1
    contentFrame.Parent = mainFrame

    local finishLabel = Instance.new("TextLabel")
    finishLabel.Size = UDim2.new(1, -20, 0, 30)
    finishLabel.Position = UDim2.new(0, 10, 0, 70)
    finishLabel.BackgroundTransparency = 1
    finishLabel.Text = "Finish Line Extended"
    finishLabel.TextColor3 = Color3.fromRGB(0, 150, 200)
    finishLabel.TextSize = 16
    finishLabel.Font = Enum.Font.GothamBold
    finishLabel.TextXAlignment = Enum.TextXAlignment.Center
    finishLabel.Parent = mainFrame

    local statusFrame = Instance.new("Frame")
    statusFrame.Size = UDim2.new(1, 0, 0, 50)
    statusFrame.BackgroundColor3 = Color3.fromRGB(30, 20, 40)
    statusFrame.BorderSizePixel = 0
    Instance.new("UICorner", statusFrame).CornerRadius = UDim.new(0, 5)
    statusFrame.Parent = contentFrame

    local statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(1, -10, 1, 0)
    statusLabel.Position = UDim2.new(0, 5, 0, 0)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "Status: Initializing"
    statusLabel.TextColor3 = Color3.fromRGB(150, 200, 210)
    statusLabel.TextSize = 14
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.Parent = statusFrame

    local raceFrame = Instance.new("Frame")
    raceFrame.Size = UDim2.new(1, 0, 0, 50)
    raceFrame.Position = UDim2.new(0, 0, 0, 60)
    raceFrame.BackgroundColor3 = Color3.fromRGB(30, 20, 40)
    raceFrame.BorderSizePixel = 0
    Instance.new("UICorner", raceFrame).CornerRadius = UDim.new(0, 5)
    raceFrame.Parent = contentFrame

    local raceLabel = Instance.new("TextLabel")
    raceLabel.Size = UDim2.new(1, -10, 1, 0)
    raceLabel.Position = UDim2.new(0, 5, 0, 0)
    raceLabel.BackgroundTransparency = 1
    raceLabel.Text = "Current Race: None"
    raceLabel.TextColor3 = Color3.fromRGB(150, 200, 210)
    raceLabel.TextSize = 14
    raceLabel.Font = Enum.Font.Gotham
    raceLabel.Parent = raceFrame

    local enableFrame = Instance.new("Frame")
    enableFrame.Size = UDim2.new(1, 0, 0, 50)
    enableFrame.Position = UDim2.new(0, 0, 0, 120)
    enableFrame.BackgroundColor3 = Color3.fromRGB(30, 20, 40)
    enableFrame.BorderSizePixel = 0
    Instance.new("UICorner", enableFrame).CornerRadius = UDim.new(0, 5)
    enableFrame.Parent = contentFrame

    local enableButton = Instance.new("TextButton")
    enableButton.Size = UDim2.new(0, 120, 0, 30)
    enableButton.Position = UDim2.new(0, 10, 0, 10)
    enableButton.BackgroundColor3 = Color3.fromRGB(0, 150, 200)
    enableButton.Text = "Enable"
    enableButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    enableButton.TextSize = 14
    enableButton.Font = Enum.Font.Gotham
    Instance.new("UICorner", enableButton).CornerRadius = UDim.new(0, 5)
    enableButton.Parent = enableFrame

    local beamFrame = Instance.new("Frame")
    beamFrame.Size = UDim2.new(1, 0, 0, 50)
    beamFrame.Position = UDim2.new(0, 0, 0, 180)
    beamFrame.BackgroundColor3 = Color3.fromRGB(30, 20, 40)
    beamFrame.BorderSizePixel = 0
    Instance.new("UICorner", beamFrame).CornerRadius = UDim.new(0, 5)
    beamFrame.Parent = contentFrame

    local beamToggle = Instance.new("TextButton")
    beamToggle.Size = UDim2.new(0, 120, 0, 30)
    beamToggle.Position = UDim2.new(0, 10, 0, 10)
    beamToggle.BackgroundColor3 = Color3.fromRGB(0, 100, 180)
    beamToggle.Text = "Beams: ON"
    beamToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    beamToggle.TextSize = 14
    beamToggle.Font = Enum.Font.Gotham
    Instance.new("UICorner", beamToggle).CornerRadius = UDim.new(0, 5)
    beamToggle.Parent = beamFrame

    local toggleSwitch = Instance.new("Frame")
    toggleSwitch.Size = UDim2.new(0, 40, 0, 20)
    toggleSwitch.Position = UDim2.new(0, 140, 0, 15)
    toggleSwitch.BackgroundColor3 = Color3.fromRGB(50, 30, 60)
    toggleSwitch.BorderSizePixel = 0
    Instance.new("UICorner", toggleSwitch).CornerRadius = UDim.new(0, 10)
    toggleSwitch.Parent = beamFrame

    local toggleKnob = Instance.new("Frame")
    toggleKnob.Size = UDim2.new(0, 20, 0, 20)
    toggleKnob.Position = UDim2.new(0, 20, 0, 0)
    toggleKnob.BackgroundColor3 = Color3.fromRGB(180, 180, 190)
    toggleKnob.BorderSizePixel = 0
    Instance.new("UICorner", toggleKnob).CornerRadius = UDim.new(0, 10)
    toggleKnob.Parent = toggleSwitch

    local checkpointFrame = Instance.new("Frame")
    checkpointFrame.Size = UDim2.new(1, 0, 0, 50)
    checkpointFrame.Position = UDim2.new(0, 0, 0, 240)
    checkpointFrame.BackgroundColor3 = Color3.fromRGB(30, 20, 40)
    checkpointFrame.BorderSizePixel = 0
    Instance.new("UICorner", checkpointFrame).CornerRadius = UDim.new(0, 5)
    checkpointFrame.Parent = contentFrame

    local checkpointLabel = Instance.new("TextLabel")
    checkpointLabel.Size = UDim2.new(1, -10, 1, 0)
    checkpointLabel.Position = UDim2.new(0, 5, 0, 0)
    checkpointLabel.BackgroundTransparency = 1
    checkpointLabel.Text = "Checkpoints: 0"
    checkpointLabel.TextColor3 = Color3.fromRGB(150, 200, 210)
    checkpointLabel.TextSize = 14
    checkpointLabel.Font = Enum.Font.Gotham
    checkpointLabel.Parent = checkpointFrame

    return {
        gui = screenGui,
        mainFrame = mainFrame,
        titleBar = titleBar,
        menuButton = menuButton,
        statusLabel = statusLabel,
        raceLabel = raceLabel,
        enableButton = enableButton,
        beamToggle = beamToggle,
        toggleSwitch = toggleSwitch,
        toggleKnob = toggleKnob,
        checkpointLabel = checkpointLabel
    }
end

local function makeDraggable(draggable)
    local dragging = false
    local dragInput
    local dragStart
    local startPos

    draggable.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = draggable.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)

            if input.UserInputType == Enum.UserInputType.Touch then
                local delta = input.Position - dragStart
                draggable.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end
    end)

    draggable.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            draggable.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

local function createBeam(target)
    local attachment0 = Instance.new("Attachment")
    attachment0.Parent = Character.HumanoidRootPart
    local attachment1 = Instance.new("Attachment")
    attachment1.Parent = target
    local beam = Instance.new("Beam")
    beam.Parent = Character.HumanoidRootPart
    beam.Attachment0 = attachment0
    beam.Attachment1 = attachment1
    beam.Width0 = 0.5
    beam.Width1 = 0.5
    beam.FaceCamera = true
    beam.Color = ColorSequence.new(Color3.new(0, 0, 1))
    table.insert(beams, {beam = beam, att1 = attachment0, att2 = attachment1})
end

local function addHighlightAndBeam(part)
    local selectionBox = Instance.new("SelectionBox")
    selectionBox.Parent = part
    selectionBox.Adornee = part
    selectionBox.LineThickness = 0.1
    selectionBox.Color3 = Color3.new(0, 0, 1)
    createBeam(part)
end

local uiElements = createUI()
local isEnabled = true
local showBeams = true

makeDraggable(uiElements.mainFrame)
makeDraggable(uiElements.menuButton)

if UserInputService.TouchEnabled then
    uiElements.menuButton.Visible = true
end

uiElements.menuButton.MouseButton1Click:Connect(function()
    uiElements.mainFrame.Visible = not uiElements.mainFrame.Visible
    updateButtonPosition()
end)

local function updateButtonPosition()
    if uiElements.mainFrame.Visible then
        uiElements.menuButton.Position = UDim2.new(0, 10, 0, 10)
    else
        uiElements.menuButton.Position = UDim2.new(0.5, -30, 0.5, -30)
    end
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.LeftControl then
        uiElements.mainFrame.Visible = not uiElements.mainFrame.Visible
        updateButtonPosition()
    end
end)

local function updateUI()
    if not isEnabled then
        uiElements.statusLabel.Text = "Status: Disabled"
        return
    end
    uiElements.statusLabel.Text = "Status: Active"
    local success, err = pcall(function()
        local raceTitle = Workspace.Map.Timers.Timer.Title.SurfaceGui.TitleText
        uiElements.raceLabel.Text = "Current Race: " .. raceTitle.Text
        local checkpointCount = 0
        for _, part in ipairs(Workspace:GetDescendants()) do
            if part:IsA("Part") then
                if part.Name == "EndPoint" or part.Name:match("^Checkpoint%d+$") then
                    checkpointCount = checkpointCount + 1
                    if part.Name == "EndPoint" and showBeams then
                        part.Transparency = 0.9
                        addHighlightAndBeam(part)
                    end
                    if not originalSizes[part] then
                        originalSizes[part] = part.Size
                    end
                    local newSize
                    if raceTitle.Text == "300 METER DASH" then
                        newSize = Vector3.new(part.Size.X, part.Size.Y, 285)
                    elseif raceTitle.Text == "60 METER DASH" then
                        newSize = Vector3.new(part.Size.X, part.Size.Y, 40)
                    elseif raceTitle.Text == "100 METER DASH" then
                        newSize = Vector3.new(part.Size.X, part.Size.Y, 40)
                    elseif table.find(raceTypes, raceTitle.Text) then
                        newSize = Vector3.new(part.Size.X, part.Size.Y, 85)
                    elseif raceTitle.Text:find("RELAY") then
                        newSize = Vector3.new(part.Size.X, part.Size.Y, 65)
                    else
                        newSize = Vector3.new(part.Size.X, part.Size.Y, 380)
                    end
                    if part.Size ~= newSize then
                        part.Size = newSize
                        part.CanCollide = false
                    end
                end
            end
        end
        uiElements.checkpointLabel.Text = "Checkpoints: " .. checkpointCount
    end)
    if not success then
        uiElements.statusLabel.Text = "Status: Error - " .. err
        warn("Resize error: " .. err)
    end
end

local function debounceUpdate()
    if isRunning then return end
    isRunning = true
    task.wait(0.5)
    updateUI()
    isRunning = false
end

local function clearBeams()
    for _, beamData in ipairs(beams) do
        beamData.beam:Destroy()
        beamData.att1:Destroy()
        beamData.att2:Destroy()
    end
    beams = {}
end

uiElements.enableButton.MouseButton1Click:Connect(function()
    isEnabled = not isEnabled
    uiElements.enableButton.Text = isEnabled and "Enable" or "Disable"
    uiElements.enableButton.BackgroundColor3 = isEnabled and Color3.fromRGB(0, 150, 200) or Color3.fromRGB(80, 60, 90)
    updateUI()
end)

uiElements.beamToggle.MouseButton1Click:Connect(function()
    showBeams = not showBeams
    uiElements.beamToggle.Text = "Beams: " .. (showBeams and "ON" or "OFF")
    uiElements.beamToggle.BackgroundColor3 = showBeams and Color3.fromRGB(0, 100, 180) or Color3.fromRGB(80, 60, 90)
    uiElements.toggleKnob.Position = showBeams and UDim2.new(0, 20, 0, 0) or UDim2.new(0, 0, 0, 0)
    uiElements.toggleSwitch.BackgroundColor3 = showBeams and Color3.fromRGB(0, 150, 200) or Color3.fromRGB(50, 30, 60)
    updateUI()
end)

LocalPlayer.CharacterAdded:Connect(function(newCharacter)
    Character = newCharacter
    Humanoid = Character:WaitForChild("Humanoid")
    clearBeams()
    updateUI()
end)

Workspace.DescendantAdded:Connect(debounceUpdate)
RunService.Heartbeat:Connect(updateUI)
updateUI()
