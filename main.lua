local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local movementModule = require(
	ReplicatedStorage
		:WaitForChild("Objects")
		:WaitForChild("Game")
		:WaitForChild("Character")
		:WaitForChild("Client")
		:WaitForChild("Movement")
)

local enabled = false
local overrideApplied = false

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "EmoteSpeedToggle"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local button = Instance.new("TextButton")
button.Name = "Toggle"
button.AnchorPoint = Vector2.new(0, 0)
button.Position = UDim2.fromOffset(24, 180)
button.Size = UDim2.fromOffset(104, 36)
button.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
button.BorderSizePixel = 0
button.Font = Enum.Font.GothamSemibold
button.Text = "Emote: OFF"
button.TextColor3 = Color3.fromRGB(255, 255, 255)
button.TextSize = 13
button.AutoButtonColor = true
button.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = button

local function updateButton()
	button.Text = enabled and "Emote: ON" or "Emote: OFF"
	button.BackgroundColor3 = enabled
		and Color3.fromRGB(40, 145, 85)
		or Color3.fromRGB(55, 55, 55)
end

local dragging = false
local dragged = false
local dragInput
local dragStart
local startPosition

button.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch
	then
		dragging = true
		dragged = false
		dragStart = input.Position
		startPosition = button.Position

		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

button.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement
		or input.UserInputType == Enum.UserInputType.Touch
	then
		dragInput = input
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if dragging and input == dragInput then
		local delta = input.Position - dragStart
		if delta.Magnitude > 6 then
			dragged = true
		end
		button.Position = UDim2.new(
			startPosition.X.Scale,
			startPosition.X.Offset + delta.X,
			startPosition.Y.Scale,
			startPosition.Y.Offset + delta.Y
		)
	end
end)

button.Activated:Connect(function()
	if dragged then
		return
	end
	enabled = not enabled
	updateButton()
end)

RunService.Heartbeat:Connect(function()
	local registry = movementModule.DataRegistry
	local emoteId = registry and registry:Get("Emote")
	local shouldApplyOverride = enabled and emoteId ~= nil

	if shouldApplyOverride ~= overrideApplied then
		movementModule:SpeedChange("Emote", shouldApplyOverride and 50 or nil)
		overrideApplied = shouldApplyOverride
	end
end)
