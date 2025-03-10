local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then
    warn("LocalPlayer not found, waiting for character...")
    LocalPlayer = Players.LocalPlayerAdded:Wait()
end
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

local originalSizes = {}
local isRunning = false
local beams = {}
local raceTypes = {"110 METER HURDLES", "200 METER DASH"}

local isEnabled = true
local showBeams = true
local isStreamerMode = false
local lastUpdate = 0
local UPDATE_INTERVAL = 0.1 -- Update every 0.1 seconds instead of every frame

local partsToModify = {}
local uiElements = nil

-- Function to create the main UI
local function createUI()
    print("Creating UI...")
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "TrackAndFieldUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 400, 0, 450)
    mainFrame.Position = UDim2.new(0.5, -200, 0.5, -225)
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

    local sliderFrame = Instance.new("Frame")
    sliderFrame.Size = UDim2.new(1, 0, 0, 50)
    sliderFrame.Position = UDim2.new(0, 0, 0, 300)
    sliderFrame.BackgroundColor3 = Color3.fromRGB(30, 20, 40)
    sliderFrame.BorderSizePixel = 0
    Instance.new("UICorner", sliderFrame).CornerRadius = UDim.new(0, 5)
    sliderFrame.Parent = contentFrame

    local sliderLabel = Instance.new("TextLabel")
    sliderLabel.Size = UDim2.new(0, 80, 0, 20)
    sliderLabel.Position = UDim2.new(0, 10, 0, 5)
    sliderLabel.BackgroundTransparency = 1
    sliderLabel.Text = "Studs: 100"
    sliderLabel.TextColor3 = Color3.fromRGB(150, 200, 210)
    sliderLabel.TextSize = 14
    sliderLabel.Font = Enum.Font.Gotham
    sliderLabel.Parent = sliderFrame

    local sliderTrack = Instance.new("Frame")
    sliderTrack.Size = UDim2.new(0, 260, 0, 10)
    sliderTrack.Position = UDim2.new(0, 100, 0, 20)
    sliderTrack.BackgroundColor3 = Color3.fromRGB(50, 30, 60)
    sliderTrack.BorderSizePixel = 0
    Instance.new("UICorner", sliderTrack).CornerRadius = UDim.new(0, 5)
    sliderTrack.Parent = sliderFrame

    local sliderKnob = Instance.new("Frame")
    sliderKnob.Size = UDim2.new(0, 20, 0, 20)
    sliderKnob.Position = UDim2.new(0, 120, 0, 15)
    sliderKnob.BackgroundColor3 = Color3.fromRGB(0, 150, 200)
    sliderKnob.BorderSizePixel = 0
    Instance.new("UICorner", sliderKnob).CornerRadius = UDim.new(0, 10)
    sliderKnob.Parent = sliderFrame

    -- Streamer Mode UI
    local streamerFrame = Instance.new("Frame")
    streamerFrame.Size = UDim2.new(1, 0, 0, 50)
    streamerFrame.Position = UDim2.new(0, 0, 0, 360)
    streamerFrame.BackgroundColor3 = Color3.fromRGB(30, 20, 40)
    streamerFrame.BorderSizePixel = 0
    Instance.new("UICorner", streamerFrame).CornerRadius = UDim.new(0, 5)
    streamerFrame.Parent = contentFrame

    local streamerToggle = Instance.new("TextButton")
    streamerToggle.Size = UDim2.new(0, 120, 0, 30)
    streamerToggle.Position = UDim2.new(0, 10, 0, 10)
    streamerToggle.BackgroundColor3 = Color3.fromRGB(0, 100, 180)
    streamerToggle.Text = "Streamer: OFF"
    streamerToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    streamerToggle.TextSize = 14
    streamerToggle.Font = Enum.Font.Gotham
    Instance.new("UICorner", streamerToggle).CornerRadius = UDim.new(0, 5)
    streamerToggle.Parent = streamerFrame

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
        checkpointLabel = checkpointLabel,
        sliderLabel = sliderLabel,
        sliderTrack = sliderTrack,
        sliderKnob = sliderKnob,
        streamerToggle = streamerToggle
    }
end

-- Function to make an object draggable
local function makeDraggable(draggable)
    print("Making " .. draggable.Name .. " draggable...")
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

-- Function to create a beam between two parts
local function createBeam(target)
    if not target or not target:IsA("BasePart") then
        print("Invalid target in createBeam")
        return
    end
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

-- Function to add highlight and beam to a part
local function addHighlightAndBeam(part)
    if not part or not part:IsA("Part") then
        print("Invalid part in addHighlightAndBeam")
        return
    end
    local selectionBox = Instance.new("SelectionBox")
    selectionBox.Parent = part
    selectionBox.Adornee = part
    selectionBox.LineThickness = 0.1
    selectionBox.Color3 = Color3.new(0, 0, 1)
    createBeam(part)
end

-- Function to populate the partsToModify list with existing parts
local function populatePartsList()
    print("Populating parts list...")
    for _, descendant in ipairs(Workspace:GetDescendants()) do
        if descendant:IsA("Part") and (descendant.Name == "EndPoint" or descendant.Name:match("^Checkpoint%d+$")) then
            table.insert(partsToModify, descendant)
            print("Added part: " .. descendant.Name)
        end
    end
end

-- Function to update button position based on UI visibility
local function updateButtonPosition()
    if uiElements then
        if uiElements.mainFrame.Visible then
            uiElements.menuButton.Position = UDim2.new(0, 10, 0, 10)
        else
            uiElements.menuButton.Position = UDim2.new(0.5, -30, 0.5, -30)
        end
    end
end

-- Function to clear existing beams
local function clearBeams()
    for _, beamData in ipairs(beams) do
        if beamData.beam and beamData.att1 and beamData.att2 then
            beamData.beam:Destroy()
            beamData.att1:Destroy()
            beamData.att2:Destroy()
        end
    end
    beams = {}
end

-- Function to update the UI state
local function updateUI()
    if not uiElements or not isEnabled then
        if uiElements then uiElements.statusLabel.Text = "Status: Disabled" end
        return
    end
    uiElements.statusLabel.Text = "Status: Active" .. (isStreamerMode and " (Streamer Mode)" or "")
    local success, err = pcall(function()
        -- Safely access the race title with checks
        local raceTitleText = "Unknown Race"
        if Workspace:FindFirstChild("Map") then
            local map = Workspace.Map
            if map:FindFirstChild("Timers") then
                local timers = map.Timers
                if timers:FindFirstChild("Timer") then
                    local timer = timers.Timer
                    if timer:FindFirstChild("Title") then
                        local title = timer.Title
                        if title:FindFirstChild("SurfaceGui") then
                            local surfaceGui = title.SurfaceGui
                            if surfaceGui:FindFirstChild("TitleText") then
                                raceTitleText = surfaceGui.TitleText.Text
                            else
                                print("TitleText not found in SurfaceGui")
                            end
                        else
                            print("SurfaceGui not found in Title")
                        end
                    else
                        print("Title not found in Timer")
                    end
                else
                    print("Timer not found in Timers")
                end
            else
                print("Timers not found in Map")
            end
        else
            print("Map not found in Workspace")
        end
        uiElements.raceLabel.Text = "Current Race: " .. raceTitleText

        local checkpointCount = 0
        local studsText = uiElements.sliderLabel.Text:match("%d+")
        local studs = studsText and tonumber(studsText) or 100

        print("Updating UI with " .. #partsToModify .. " parts")
        clearBeams()
        for i, part in ipairs(partsToModify) do
            if part and part:IsA("Part") and part.Parent and (part.Name == "EndPoint" or part.Name:match("^Checkpoint%d+$")) then
                checkpointCount = checkpointCount + 1
                if isStreamerMode then
                    if part:FindFirstChild("SelectionBox") then
                        part.SelectionBox:Destroy()
                    end
                    part.Transparency = 1
                elseif showBeams then
                    part.Transparency = 0.9
                    addHighlightAndBeam(part)
                end
                -- Safely store the original size
                if not originalSizes[part] then
                    local success, size = pcall(function()
                        return part.Size
                    end)
                    if success and size then
                        originalSizes[part] = size
                    else
                        print("Failed to get size for part: " .. (part.Name or "Unknown"))
                        continue
                    end
                end
                -- Safely resize the part
                local success, resizeErr = pcall(function()
                    if originalSizes[part] and originalSizes[part].X and originalSizes[part].Y then
                        local newSize = Vector3.new(originalSizes[part].X, originalSizes[part].Y, studs)
                        if part.Size ~= newSize then
                            part.Size = newSize
                            part.CanCollide = false
                        end
                    else
                        print("Invalid original size for part: " .. (part.Name or "Unknown"))
                    end
                end)
                if not success then
                    print("Failed to resize part: " .. (part.Name or "Unknown") .. " - " .. tostring(resizeErr))
                end
            else
                -- Part no longer matches the criteria, remove it from partsToModify
                table.remove(partsToModify, i)
                i = i - 1 -- Adjust index after removal
            end
        end
        uiElements.checkpointLabel.Text = "Checkpoints: " .. checkpointCount
    end)
    if not success then
        uiElements.statusLabel.Text = "Status: Error - " .. tostring(err)
        warn("Resize error: " .. tostring(err))
    end
end

-- Initialize the main UI
local function initializeMainUI()
    print("Initializing main UI...")
    uiElements = createUI()
    if not uiElements then
        warn("Failed to create UI elements!")
        return
    end
    makeDraggable(uiElements.mainFrame)
    makeDraggable(uiElements.menuButton)

    if UserInputService.TouchEnabled then
        uiElements.menuButton.Visible = true
    end

    uiElements.menuButton.MouseButton1Click:Connect(function()
        uiElements.mainFrame.Visible = not uiElements.mainFrame.Visible
        updateButtonPosition()
    end)

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

    uiElements.streamerToggle.MouseButton1Click:Connect(function()
        isStreamerMode = not isStreamerMode
        uiElements.streamerToggle.Text = "Streamer: " .. (isStreamerMode and "ON" or "OFF")
        uiElements.streamerToggle.BackgroundColor3 = isStreamerMode and Color3.fromRGB(0, 120, 200) or Color3.fromRGB(0, 100, 180)
        
        if isStreamerMode then
            uiElements.mainFrame.Visible = false
            uiElements.menuButton.Visible = false
        else
            uiElements.menuButton.Visible = UserInputService.TouchEnabled
            updateButtonPosition()
        end
        updateUI()
    end)

    local draggingSlider = false
    uiElements.sliderKnob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            draggingSlider = true
        end
    end)

    uiElements.sliderKnob.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            draggingSlider = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if draggingSlider and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local trackAbsPos = uiElements.sliderTrack.AbsolutePosition
            local trackAbsSize = uiElements.sliderTrack.AbsoluteSize
            local knobAbsSize = uiElements.sliderKnob.AbsoluteSize

            local newX = math.clamp(input.Position.X - trackAbsPos.X - knobAbsSize.X / 2, 0, trackAbsSize.X - knobAbsSize.X)
            uiElements.sliderKnob.Position = UDim2.new(0, newX + 100, 0, 15)

            local studs = math.floor((newX / (trackAbsSize.X - knobAbsSize.X)) * 500)
            uiElements.sliderLabel.Text = "Studs: " .. studs
            updateUI()
        end
    end)

    updateUI()
    print("Main UI initialized successfully.")
end

-- Initialize the main UI
initializeMainUI()

-- Manage partsToModify list with events
Workspace.DescendantAdded:Connect(function(child)
    if child:IsA("Part") and (child.Name == "EndPoint" or child.Name:match("^Checkpoint%d+$")) then
        table.insert(partsToModify, child)
        print("Added part to modify: " .. child.Name)
    end
end)

Workspace.DescendantRemoving:Connect(function(child)
    for i, part in ipairs(partsToModify) do
        if part == child then
            table.remove(partsToModify, i)
            print("Removed part from modify list: " .. child.Name)
            break
        end
    end
end)

-- Populate initial parts list
populatePartsList()

-- Handle character changes
LocalPlayer.CharacterAdded:Connect(function(newCharacter)
    Character = newCharacter
    Humanoid = Character:WaitForChild("Humanoid")
    clearBeams()
    updateUI()
    print("Character changed, UI updated.")
end)

-- Throttle the updateUI calls
RunService.Heartbeat:Connect(function()
    local currentTime = tick()
    if currentTime - lastUpdate >= UPDATE_INTERVAL then
        updateUI()
        lastUpdate = currentTime
    end
end)

print("Script started for " .. LocalPlayer.Name)