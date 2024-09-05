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

	local player = service.Players.LocalPlayer
	local playergui = player.PlayerGui
	local gui = script.Parent.Parent
	local frame = gui.Frame
	local text = gui.Frame.TextBox
	local scroll = gui.Frame.ScrollingFrame
	local players = gui.Frame.PlayerList
	local entry = gui.Entry
	local BindEvent = gTable.BindEvent

	local opened = false
	local scrolling = false
	local scrollOpen = false
	local debounce = false
	local settings = client.Remote.Get("Setting",{"SplitKey","ConsoleKeyCode","BatchKey","Prefix"})
	local splitKey = settings.SplitKey
	local consoleKey = settings.ConsoleKeyCode
	local batchKey = settings.BatchKey
	local prefix = settings.Prefix
	local commands = client.Remote.Get('FormattedCommands') or {}

	local tweenInfo = TweenInfo.new(0.15)----service.SafeTweenSize(frame,UDim2.new(1,0,0,40),nil,nil,0.3,nil,function() if scrollOpen then frame.Size = UDim2.new(1,0,0,140) end end)
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

	frame.Position = UDim2.new(0,0,0,-200)
	frame.Visible = false
	frame.Size = UDim2.new(1,0,0,40)
	scroll.Visible = false

	if client.Variables.ConsoleOpen then
		if client.Variables.ChatEnabled then
			service.StarterGui:SetCoreGuiEnabled("Chat",true)
		end

		if client.Variables.PlayerListEnabled then
			service.StarterGui:SetCoreGuiEnabled('PlayerList',true)
		end
		if client.UI.Get("Notif") then
			client.UI.Get("Notif",nil,true).Object.LABEL.Visible = true
		end

		local scr = client.UI.Get("Chat",nil,true)
		if scr then scr.Object.Drag.Visible = true end

		local scr = client.UI.Get("PlayerList",nil,true)
		if scr then scr.Object.Drag.Visible = true end

		local scr = client.UI.Get("HintHolder",nil,true)
		if scr then scr.Object.Frame.Visible = true end
	end

	client.Variables.ChatEnabled = service.StarterGui:GetCoreGuiEnabled("Chat")
	client.Variables.PlayerListEnabled = service.StarterGui:GetCoreGuiEnabled('PlayerList')

	local function close()
		if gui:IsDescendantOf(game) and not debounce then
			debounce = true
			scroll:ClearAllChildren()
			scroll.CanvasSize = UDim2.new(0,0,0,0)
			scroll.ScrollingEnabled = false
			frame.Size = UDim2.new(1,0,0,40)
			scroll.Visible = false
			players.Visible = false
			scrollOpen = false

			if client.Variables.ChatEnabled then
				service.StarterGui:SetCoreGuiEnabled("Chat",true)
			end

			if client.Variables.PlayerListEnabled then
				service.StarterGui:SetCoreGuiEnabled('PlayerList',true)
			end

			if client.UI.Get("Notif") then
				client.UI.Get("Notif",nil,true).Object.LABEL.Visible = true
			end

			local scr = client.UI.Get("Chat",nil,true)
			if scr then scr.Object.Drag.Visible = true end

			local scr = client.UI.Get("PlayerList",nil,true)
			if scr then scr.Object.Drag.Visible = true end

			local scr = client.UI.Get("HintHolder",nil,true)
			if scr then scr.Object.Frame.Visible = true end

			consoleCloseTween:Play();
			--service.SafeTweenPos(frame,UDim2.new(0,0,0,-200),'Out','Linear',0.2,true)
			--frame:TweenPosition(UDim2.new(0,0,0,-200),'Out','Linear',0.2,true)
			debounce = false
			opened = false
		end
	end

	local function open()
		if gui:IsDescendantOf(game) and not debounce then
			debounce = true
			client.Variables.ChatEnabled = service.StarterGui:GetCoreGuiEnabled("Chat")
			client.Variables.PlayerListEnabled = service.StarterGui:GetCoreGuiEnabled('PlayerList')

			service.StarterGui:SetCoreGuiEnabled("Chat",false)
			service.StarterGui:SetCoreGuiEnabled('PlayerList',false)

			scroll.ScrollingEnabled = true
			players.ScrollingEnabled = true

			if client.UI.Get("Notif") then
				client.UI.Get("Notif",nil,true).Object.LABEL.Visible = false
			end

			local scr = client.UI.Get("Chat",nil,true)
			if scr then scr.Object.Drag.Visible = false end

			local scr = client.UI.Get("PlayerList",nil,true)
			if scr then scr.Object.Drag.Visible = false end

			local scr = client.UI.Get("HintHolder",nil,true)
			if scr then scr.Object.Frame.Visible = false end

			consoleOpenTween:Play();

			frame.Size = UDim2.new(1,0,0,40)
			scroll.Visible = false
			players.Visible = false
			scrollOpen = false
			text.Text = ''
			frame.Visible = true
			frame.Position = UDim2.new(0,0,0,0)
			text:CaptureFocus()
			text.Text = ''
			task.wait()
			text.Text = ''
			debounce = false
			opened = true
		end
	end

	text.FocusLost:Connect(function(enterPressed)
		if enterPressed then
			if text.Text~='' and string.len(text.Text)>1 then
				task.spawn(function()
					local sound = Instance.new("Sound",service.LocalContainer())
					sound.SoundId = "rbxassetid://669596713"
					sound.Volume = 0.2
					sound:Play()
					task.wait(0.5)
					sound:Destroy()
				end)
				client.Remote.Send('ProcessCommand',text.Text)
			end
		end

		close()
	end)

	text.Changed:Connect(function(c)
		if c == 'Text' and text.Text ~= '' and open then
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
			if string.match(nText,`.*{batchKey}([^']+)`) then
				nText = string.match(nText,`.*{batchKey}([^']+)`)
				nText = string.match(nText,"^%s*(.-)%s*$")
			end

			local pNum = 0
			local pMatch = string.match(nText,`.+{splitKey}(.*)$`)
			for i,v in service.Players:GetPlayers() do
				if (pMatch and string.sub(string.lower(tostring(v)),1,#pMatch) == string.lower(pMatch)) or string.match(nText,`{splitKey}$`) then
					local new = entry:Clone()
					new.Text = tostring(v)
					new.Name = `Entry {pNum}`
					new.TextXAlignment = "Right"
					new.Visible = true
					new.Parent = players
					new.Position = UDim2.new(0,0,0,20*pNum)
					new.MouseButton1Down:Connect(function()
						text.Text = text.Text..tostring(v)
						text:CaptureFocus()
					end)
					pNum = pNum+1
				end
			end

			players.CanvasSize = UDim2.new(0,0,0,pNum*20)

			local num = 0
			for i,v in commands do
				if string.sub(string.lower(v),1,#nText) == string.lower(nText) or string.find(string.lower(v), string.match(string.lower(nText),`^(.-){splitKey}`) or string.lower(nText), 1, true) then
					if not scrollOpen then
						scrollOpenTween:Play();
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
					b.Position = UDim2.new(0,0,0,20*num)
					b.MouseButton1Down:Connect(function()
						text.Text = b.Text
						text:CaptureFocus()
					end)
					num = num+1
				end
			end
			frame.Size = UDim2.new(1, 0, 0, math.clamp((num*20)+40, 40, 140))
			scroll.CanvasSize = UDim2.new(0,0,0,num*20)
		elseif c == 'Text' and text.Text == '' and opened then
			scrollCloseTween:Play();
			--service.SafeTweenSize(frame,UDim2.new(1,0,0,40),nil,nil,0.3,nil,function() if scrollOpen then frame.Size = UDim2.new(1,0,0,140) end end)
			scroll.Visible = false
			players.Visible = false
			scrollOpen = false
			scroll:ClearAllChildren()
			scroll.CanvasSize = UDim2.new(0,0,0,0)
		end
	end)

	BindEvent(service.UserInputService.InputBegan, function(InputObject)
		local textbox = service.UserInputService:GetFocusedTextBox()
		if not (textbox) and rawequal(InputObject.UserInputType, Enum.UserInputType.Keyboard) and InputObject.KeyCode.Name == (client.Variables.CustomConsoleKey or consoleKey) then
			if opened then
				close()
			else
				open()
			end
			client.Variables.ConsoleOpen = opened
		end
	end)

	gTable:Ready()
end