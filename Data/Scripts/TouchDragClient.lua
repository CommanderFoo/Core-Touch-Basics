local ICON_BUTTON = script:GetCustomProperty("IconButton")
local BAG = script:GetCustomProperty("Bag"):WaitForObject()
local GEMS_AMOUNT = script:GetCustomProperty("GemsAmount"):WaitForObject()
local CONTAINER = script:GetCustomProperty("Container"):WaitForObject()
local ICONS = require(script:GetCustomProperty("Icons"))
local AUDIO = script:GetCustomProperty("Audio"):WaitForObject()

local draggedIcon = nil
local lastPosition = nil
local amount = 0
local task = nil

local function OnPressed(button)
	draggedIcon = button
	button.isHittable = false
end

local function OnReleased(button, points)
	draggedIcon = nil

	local control = UI.FindControlAtPosition(lastPosition)

	if control == BAG then
		amount = amount + points
		GEMS_AMOUNT.text = string.format("Gems: %s", amount)
		button:Destroy()

		AUDIO.pitch = math.random(-100, 600)
		AUDIO:Play()
	else
		button.isHittable = true
	end
end

local function SpawnIcon()
	if draggedIcon ~= nil then
		return
	end

	local icon = World.SpawnAsset(ICON_BUTTON, { parent = CONTAINER })
	local row = ICONS[math.random(#ICONS)]

	icon:SetImage(row.icon)

	icon.x = math.random(-800, 800)
	icon.y = math.random(-400, 400)
	icon.rotationAngle = math.random(360)

	icon.pressedEvent:Connect(OnPressed)
	icon.releasedEvent:Connect(OnReleased, row.points)

	if task ~= nil then
		task.repeatInterval = math.random()
	end
end

function Tick()
	if Object.IsValid(draggedIcon) then
		lastPosition = Input.GetPointerPosition()

		if lastPosition ~= nil then
			if Input.GetCurrentInputType() == InputType.TOUCH then
				local safeArea = UI.GetSafeArea()
				local screenSize = UI.GetScreenSize()

				if safeArea.left > 0 then
					lastPosition.x = lastPosition.x + (safeArea.left / 2)
				elseif safeArea.right < screenSize.x then
					lastPosition.x = lastPosition.x + ((screenSize.x - safeArea.right) / 2)
				end 
			end

			draggedIcon:SetAbsolutePosition(lastPosition)
		end
	end
end

UI.SetCanCursorInteractWithUI(true)
UI.SetCursorVisible(true)

Input.DisableVirtualControls()

task = Task.Spawn(SpawnIcon)

task.repeatCount = -1
task.repeatInterval = .6