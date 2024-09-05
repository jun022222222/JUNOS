client = nil
cPcall = nil
Pcall = nil
Routine = nil
service = nil
gTable = nil

--// All global vars will be wiped/replaced except script
--// All guis are autonamed codeName..gui.Name

return function(data, env)
	if env then
		setfenv(1, env)
	end

	local UI = client.UI
	local Remote = client.Remote
	local Variables = client.Variables

	local gui = script.Parent.Parent

	gTable.Name = "Console"
	gTable.CanKeepAlive = true

	local frame = gui.Frame
	local text = frame.TextBox
	local scroll = frame.ScrollingFrame
	local players = frame.PlayerList
	local entry = gui.Entry

	local Settings = Remote.Get("Setting", {"SplitKey", "ConsoleKeyCode", "BatchKey", "Prefix"})
	local splitKey = Settings.SplitKey
	local consoleKey = Settings.ConsoleKeyCode
	local batchKey = Settings.BatchKey
	local prefix = Settings.Prefix
	local commands = Remote.Get("FormattedCommands") or {}

	local opened = false
	local scrolling = false
	local scrollOpen = false
	local debounce = false
	local varifocus = false

	local tweenInfo = TweenInfo.new(0.15)----service.SafeTweenSize(frame,UDim2.new(1,0,0,40), nil, nil,0.3, nil,function() if scrollOpen then frame.Size = UDim2.new(1,0,0,140) end end)
	local scrollOpenTween = service.TweenService:Create(frame, tweenInfo, {
		Size = UDim2.new(1, 0, 0, 140);
	})
	local scrollCloseTween = service.TweenService:Create(frame, tweenInfo, {
		Size = UDim2.new(1, 0, 0, 40);
	})
	local consoleOpenTween = service.TweenService:Create(frame, tweenInfo, {
		Position = UDim2.new(0, 0, 0, 0);
	})
	local consoleCloseTween = service.TweenService:Create(frame, tweenInfo, {
		Position = UDim2.new(0, 0, 0, -200);
	})

	local function showGuis()
		if UI.Get("Notif") then
			UI.Get("Notif", nil, true).Object.LABEL.Visible = true
		end
		do
			local scr = UI.Get("Chat", nil, true)
			if scr then scr.Object.Drag.Visible = true end
		end
		do
			local scr = UI.Get("PlayerList", nil, true)
			if scr then scr.Object.Drag.Visible = true end
		end
		do
			local scr = UI.Get("HintHolder", nil, true)
			if scr then scr.Object.Frame.Visible = true end
		end
	end

	local function hideGuis()
		if UI.Get("Notif") then
			UI.Get("Notif", nil, true).Object.LABEL.Visible = false
		end
		do
			local scr = UI.Get("Chat", nil, true)
			if scr then scr.Object.Drag.Visible = false end
		end
		do
			local scr = UI.Get("PlayerList", nil, true)
			if scr then scr.Object.Drag.Visible = false end
		end
		do
			local scr = UI.Get("HintHolder", nil, true)
			if scr then scr.Object.Frame.Visible = false end
		end
	end

	frame.Position = UDim2.fromOffset(0, -200)
	frame.Visible = false
	frame.Size = UDim2.new(1, 0, 0, 40)
	scroll.Visible = false

	if Variables.ConsoleOpen then
		if Variables.ChatEnabled then
			service.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, true)
		end

		if Variables.PlayerListEnabled then
			service.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, true)
		end

		showGuis()
	end

	Variables.ChatEnabled = service.StarterGui:GetCoreGuiEnabled("Chat")
	Variables.PlayerListEnabled = service.StarterGui:GetCoreGuiEnabled("PlayerList")

	local function closeConsole()
		if gui:IsDescendantOf(game) and not debounce then
			debounce = true
			scroll:ClearAllChildren()
			scroll.CanvasSize = UDim2.new(0,0,0,0)
			scroll.ScrollingEnabled = false
			frame.Size = UDim2.new(1,0,0,40)
			scroll.Visible = false
			players.Visible = false
			scrollOpen = false

			if Variables.ChatEnabled then
				service.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, true)
			end

			if Variables.PlayerListEnabled then
				service.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, true)
			end

			showGuis()

			consoleCloseTween:Play()
			--service.SafeTweenPos(frame,UDim2.new(0,0,0,-200), "Out", "Linear",0.2, true)
			--frame:TweenPosition(UDim2.new(0,0,0,-200), "Out", "Linear",0.2, true)
			debounce = false
			opened = false
		end
	end

	local function openConsole()
		if not gui:IsDescendantOf(game) or debounce then
			return
		end
		debounce = true
		Variables.ChatEnabled = service.StarterGui:GetCoreGuiEnabled("Chat")
		Variables.PlayerListEnabled = service.StarterGui:GetCoreGuiEnabled("PlayerList")

		service.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, false)
		service.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)

		scroll.ScrollingEnabled = true
		players.ScrollingEnabled = true

		hideGuis()

		consoleOpenTween:Play()

		frame.Size = UDim2.new(1, 0, 0, 40)
		scroll.Visible = false
		players.Visible = false
		scrollOpen = false
		text.Text = ""
		frame.Visible = true
		frame.Position = UDim2.new()
		text:CaptureFocus()
		text.Text = ""
		wait()
		text.Text = ""
		debounce = false
		opened = true
	end

	text.FocusLost:Connect(function(enterPressed)
		task.wait()
		if varifocus then
			varifocus = false
		else
			if enterPressed then
				if string.len(text.Text) > 1 then
					Remote.Send("ProcessCommand", text.Text)
				end
			end
			
			closeConsole()
		end
	end)

	text:GetPropertyChangedSignal("Text"):Connect(function()
		if text.Text ~= "" and openConsole then
			if string.sub(text.Text, string.len(text.Text)) == "	" then
				if players:FindFirstChild("Entry 0") then
					text.Text = `{string.sub(text.Text, 1, (string.len(text.Text) - 1))}{players["Entry 0"].Text} `
				elseif scroll:FindFirstChild("Entry 0") then
					text.Text = string.split(scroll["Entry 0"].Text, "<")[1]
				else
					text.Text = text.Text..prefix
				end
				text.CursorPosition = string.len(text.Text) + 1
				text.Text = string.gsub(text.Text, "	", "")
			end
			scroll:ClearAllChildren()
			players:ClearAllChildren()

			local nText = text.Text
			if string.match(nText, `.*{batchKey}([^']+)`) then
				nText = string.match(nText, `.*{batchKey}([^']+)`)
				nText = string.match(nText, "^%s*(.-)%s*$")
			end

			local pNum = 0
			local pMatch = string.match(nText, `.+{splitKey}(.*)$`)
			for _, v in service.Players:GetPlayers() do
				if (pMatch and string.sub(string.lower(tostring(v)),1,#pMatch) == string.lower(pMatch)) or string.match(nText,`{splitKey}$`) then
					local new = entry:Clone()
					new.Text = tostring(v)
					new.Name = `Entry {pNum}`
					new.TextXAlignment = "Right"
					new.Visible = true
					new.Parent = players
					new.Position = UDim2.new(0,0,0,20*pNum)
					new.MouseButton1Down:Connect(function()
						varifocus = true
						text.Text = text.Text..tostring(v)
						text:CaptureFocus()
					end)
					pNum += 1
				end
			end

			players.CanvasSize = UDim2.new(0,0,0,pNum*20)

			local num = 0
			for _, v in commands do
				if string.sub(string.lower(v),1,#nText) == string.lower(nText) or string.find(string.lower(v), string.match(string.lower(nText), `^(.-){splitKey}`) or string.lower(nText), 1, true) then
					if not scrollOpen then
						scrollOpenTween:Play()
						--frame.Size = UDim2.new(1,0,0,140)
						scroll.Visible = true
						players.Visible = true
						scrollOpen = true
					end
					local b = entry:Clone()
					b.Visible = true
					b.Parent = scroll
					b.Text = v
					b.Name = `Entry {num}`
					b.Position = UDim2.fromOffset(0, 20*num)
					b.MouseButton1Down:Connect(function()
						varifocus = true
						text.Text = string.match(v, `^(.-){splitKey}`)
						text:CaptureFocus()
					end)
					num += 1
				end
			end
			frame.Size = UDim2.new(1, 0, 0, math.clamp((num*20)+40, 40, 140))
			scroll.CanvasSize = UDim2.fromOffset(0, num*20)
		elseif text.Text == "" and opened then
			scrollCloseTween:Play()
			--service.SafeTweenSize(frame,UDim2.new(1,0,0,40), nil, nil,0.3, nil,function() if scrollOpen then frame.Size = UDim2.new(1,0,0,140) end end)
			scroll.Visible = false
			players.Visible = false
			scrollOpen = false
			scroll:ClearAllChildren()
			scroll.CanvasSize = UDim2.new()
		end
	end)

	service.HookEvent("ToggleConsole", function()
		if opened then
			closeConsole()
		else
			openConsole()
		end
		Variables.ConsoleOpen = opened
	end)

	gTable.BindEvent(service.UserInputService.InputBegan, function(inputObject: InputObject)
		local textbox = service.UserInputService:GetFocusedTextBox()
		if not textbox and rawequal(inputObject.UserInputType, Enum.UserInputType.Keyboard) and inputObject.KeyCode.Name == (Variables.CustomConsoleKey or consoleKey) then
			service.Events.ToggleConsole:Fire()
		end
	end)

	gTable:Ready()
end
