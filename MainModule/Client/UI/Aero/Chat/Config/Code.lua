
client, cPcall, Pcall, Routine, service, gTable
	= nil, nil, nil, nil, nil, nil

--// All global vars will be wiped/replaced except script
--// All guis are autonamed client.Variables.CodeName..gui.Name
--// Be sure to update the console gui's code if you change stuff

return function(data, env)
	if env then
		setfenv(1, env)
	end

	local client, cPcall, Pcall, Routine, service, gTable =
		client, cPcall, Pcall, Routine, service, gTable

	local gui = script.Parent.Parent

	local localplayer = service.Player
	local mouse = localplayer:GetMouse()
	local playergui = service.PlayerGui

	local storedChats = client.Variables.StoredChats
	local desc = gui.Desc
	local nohide = data.KeepChat

	local function Expand(ent, point)
		ent.MouseLeave:Connect(function(x, y)
			point.Visible = false
		end)

		ent.MouseMoved:Connect(function(x, y)
			point.Text = ent.Desc.Value
			point.Size = UDim2.new(0, 10000, 0, 10000)
			local bounds = point.TextBounds.X
			local rows = math.floor(bounds / 500)
			rows = rows + 1
			if rows < 1 then
				rows = 1
			end
			local newx = 500
			if bounds < 500 then
				newx = bounds
			end
			point.Visible = true
			point.Size = UDim2.new(0, newx + 10, 0, rows * 20)
			point.Position = UDim2.new(0, x, 0, y - 40 - (rows * 20))
		end)
	end

	local function UpdateChat()
		if gui then
			local globalTab = gui.Drag.Frame.Frame.Global
			local teamTab = gui.Drag.Frame.Frame.Team
			local localTab = gui.Drag.Frame.Frame.Local
			local adminsTab = gui.Drag.Frame.Frame.Admins
			local crossTab = gui.Drag.Frame.Frame.Cross

			local entry = gui.Entry
			local tester = gui.BoundTest

			globalTab:ClearAllChildren()
			teamTab:ClearAllChildren()
			localTab:ClearAllChildren()
			adminsTab:ClearAllChildren()
			crossTab:ClearAllChildren()

			local globalNum = 0
			local teamNum = 0
			local localNum = 0
			local adminsNum = 0
			local crossNum = 0
			for i, v in storedChats do
				local clone = entry:Clone()
				clone.Message.Text = service.MaxLen(v.Message, 100)
				clone.Desc.Value = v.Message
				Expand(clone, desc)
				if not string.match(v.Player, "%S") then
					clone.Nameb.Text = v.Player
				else
					clone.Nameb.Text = `[{v.Player}]: `
				end
				clone.Visible = true
				clone.Nameb.Font = "SourceSansBold"

				local color = v.Color or BrickColor.White()
				clone.Nameb.TextColor3 = color.Color


				tester.Text = `[{v.Player}]: `
				local naml = tester.TextBounds.X + 5
				if naml > 100 then
					naml = 100
				end

				tester.Text = v.Message
				local mesl = tester.TextBounds.X

				clone.Message.Position = UDim2.new(0, naml, 0, 0)
				clone.Message.Size = UDim2.new(1, -(naml + 10), 1, 0)
				clone.Nameb.Size = UDim2.new(0, naml, 0, 20)

				clone.Visible = false
				clone.Parent = globalTab

				local rows = math.floor((mesl + naml) / clone.AbsoluteSize.X)
				rows = rows + 1
				if rows < 1 then
					rows = 1
				end
				if rows > 3 then
					rows = 3
				end
				--rows = rows+1

				clone.Parent = nil
				clone.Visible = true

				clone.Size = UDim2.new(1, 0, 0, rows * 20)

				if v.Private then
					clone.Nameb.TextColor3 = Color3.new(0.58823529411765, 0.22352941176471, 0.69019607843137)
				end

				if v.Mode == "Global" then
					clone.Position = UDim2.new(0, 0, 0, globalNum * 20)
					globalNum = globalNum + 1
					if rows > 1 then
						globalNum = globalNum + rows - 1
					end
					clone.Parent = globalTab
				elseif v.Mode == "Team" then
					clone.Position = UDim2.new(0, 0, 0, teamNum * 20)
					teamNum = teamNum + 1
					if rows > 1 then
						teamNum = teamNum + rows - 1
					end
					clone.Parent = teamTab
				elseif v.Mode == "Local" then
					clone.Position = UDim2.new(0, 0, 0, localNum * 20)
					localNum = localNum + 1
					if rows > 1 then
						localNum = localNum + rows - 1
					end
					clone.Parent = localTab
				elseif v.Mode == "Admins" then
					clone.Position = UDim2.new(0, 0, 0, adminsNum * 20)
					adminsNum = adminsNum + 1
					if rows > 1 then
						adminsNum = adminsNum + rows - 1
					end
					clone.Parent = adminsTab
				elseif v.Mode == "Cross" then
					clone.Position = UDim2.new(0, 0, 0, crossNum * 20)
					crossNum = crossNum + 1
					if rows > 1 then
						crossNum = crossNum + rows - 1
					end
					clone.Parent = crossTab
				end
			end

			globalTab.CanvasSize = UDim2.new(0, 0, 0, ((globalNum) * 20))
			teamTab.CanvasSize = UDim2.new(0, 0, 0, ((teamNum) * 20))
			localTab.CanvasSize = UDim2.new(0, 0, 0, ((localNum) * 20))
			adminsTab.CanvasSize = UDim2.new(0, 0, 0, ((adminsNum) * 20))
			crossTab.CanvasSize = UDim2.new(0, 0, 0, ((crossNum) * 20))

			local glob = (((globalNum) * 20) - globalTab.AbsoluteWindowSize.Y)
			local tea = (((teamNum) * 20) - teamTab.AbsoluteWindowSize.Y)
			local loc = (((localNum) * 20) - localTab.AbsoluteWindowSize.Y)
			local adm = (((adminsNum) * 20) - adminsTab.AbsoluteWindowSize.Y)
			local cro = (((crossNum) * 20) - crossTab.AbsoluteWindowSize.Y)

			if glob < 0 then
				glob = 0
			end
			if tea < 0 then
				tea = 0
			end
			if loc < 0 then
				loc = 0
			end
			if adm < 0 then
				adm = 0
			end
			if cro < 0 then
				cro = 0
			end

			globalTab.CanvasPosition = Vector2.new(0, glob)
			teamTab.CanvasPosition = Vector2.new(0, tea)
			localTab.CanvasPosition = Vector2.new(0, loc)
			adminsTab.CanvasPosition = Vector2.new(0, adm)
			crossTab.CanvasPosition = Vector2.new(0, cro)
		end
	end

	if not storedChats then
		client.Variables.StoredChats = {}
		storedChats = client.Variables.StoredChats
	end

	gTable:Ready()

	local bubble = gui.Bubble
	local toggle = gui.Toggle
	local drag = gui.Drag
	local frame = gui.Drag.Frame
	local frame2 = gui.Drag.Frame.Frame
	local box = gui.Drag.Frame.Chat

	local globalTab = gui.Drag.Frame.Frame.Global
	local teamTab = gui.Drag.Frame.Frame.Team
	local localTab = gui.Drag.Frame.Frame.Local
	local adminsTab = gui.Drag.Frame.Frame.Admins
	local crossTab = gui.Drag.Frame.Frame.Cross

	local global = gui.Drag.Frame.Global
	local team = gui.Drag.Frame.Team
	local localb = gui.Drag.Frame.Local
	local admins = gui.Drag.Frame.Admins
	local cross = gui.Drag.Frame.Cross

	if not nohide then
		client.Variables.CustomChat = true
		client.Variables.ChatEnabled = false
		service.StarterGui:SetCoreGuiEnabled('Chat', false)
	else
		drag.Position = UDim2.new(0, 10, 1, -180)
	end

	local dragger = gui.Drag.Frame.Dragger
	local fakeDrag = gui.Drag.Frame.FakeDragger

	local boxFocused = false
	local mode = "Global"

	local lastChat = 0
	local lastClick = 0
	local isAdmin = client.Remote.Get("CheckAdmin")

	if not isAdmin then
		admins.BackgroundTransparency = 0.8
		admins.TextTransparency = 0.8
		cross.BackgroundTransparency = 0.8
		cross.TextTransparency = 0.8
	end

	if client.UI.Get("HelpButton") then
		toggle.Position = UDim2.new(1, -90, 1, -45)
	end

	local function openGlobal()
		globalTab.Visible = true
		teamTab.Visible = false
		localTab.Visible = false
		adminsTab.Visible = false
		crossTab.Visible = false

		global.Text = "Global"
		mode = "Global"

		global.BackgroundTransparency = 0
		team.BackgroundTransparency = 0.5
		localb.BackgroundTransparency = 0.5
		if isAdmin then
			admins.BackgroundTransparency = 0.5
			admins.TextTransparency = 0
			cross.BackgroundTransparency = 0.5
			cross.TextTransparency = 0
		else
			admins.BackgroundTransparency = 0.8
			admins.TextTransparency = 0.8
			cross.BackgroundTransparency = 0.8
			cross.TextTransparency = 0.8
		end
	end

	local function openTeam()
		globalTab.Visible = false
		teamTab.Visible = true
		localTab.Visible = false
		adminsTab.Visible = false
		crossTab.Visible = false

		team.Text = "Team"
		mode = "Team"

		global.BackgroundTransparency = 0.5
		team.BackgroundTransparency = 0
		localb.BackgroundTransparency = 0.5
		admins.BackgroundTransparency = 0.5
		if isAdmin then
			admins.BackgroundTransparency = 0.5
			admins.TextTransparency = 0
			cross.BackgroundTransparency = 0.5
			cross.TextTransparency = 0
		else
			admins.BackgroundTransparency = 0.8
			admins.TextTransparency = 0.8
			cross.BackgroundTransparency = 0.8
			cross.TextTransparency = 0.8
		end
	end

	local function openLocal()
		globalTab.Visible = false
		teamTab.Visible = false
		localTab.Visible = true
		adminsTab.Visible = false
		crossTab.Visible = false

		localb.Text = "Local"
		mode = "Local"

		global.BackgroundTransparency = 0.5
		team.BackgroundTransparency = 0.5
		localb.BackgroundTransparency = 0
		admins.BackgroundTransparency = 0.5
		if isAdmin then
			admins.BackgroundTransparency = 0.5
			admins.TextTransparency = 0
			cross.BackgroundTransparency = 0.5
			cross.TextTransparency = 0
		else
			admins.BackgroundTransparency = 0.8
			admins.TextTransparency = 0.8
			cross.BackgroundTransparency = 0.8
			cross.TextTransparency = 0.8
		end
	end

	local function openAdmins()
		globalTab.Visible = false
		teamTab.Visible = false
		localTab.Visible = false
		adminsTab.Visible = true
		crossTab.Visible = false

		admins.Text = "Admins"
		mode = "Admins"

		global.BackgroundTransparency = 0.5
		team.BackgroundTransparency = 0.5
		localb.BackgroundTransparency = 0.5
		if isAdmin then
			admins.BackgroundTransparency = 0
			admins.TextTransparency = 0
			cross.BackgroundTransparency = 0.5
			cross.TextTransparency = 0
		else
			admins.BackgroundTransparency = 0.8
			admins.TextTransparency = 0.8
			cross.BackgroundTransparency = 0.8
			cross.TextTransparency = 0.8
		end
	end

	local function openCross()
		globalTab.Visible = false
		teamTab.Visible = false
		localTab.Visible = false
		adminsTab.Visible = false
		crossTab.Visible = true

		cross.Text = "Cross"
		mode = "Cross"

		global.BackgroundTransparency = 0.5
		team.BackgroundTransparency = 0.5
		localb.BackgroundTransparency = 0.5
		if isAdmin then
			admins.BackgroundTransparency = 0.5
			admins.TextTransparency = 0
			cross.BackgroundTransparency = 0
			cross.TextTransparency = 0
		else
			admins.BackgroundTransparency = 0.8
			admins.TextTransparency = 0.8
			cross.BackgroundTransparency = 0.8
			cross.TextTransparency = 0.8
		end
	end

	local function fadeIn()
    --[[
    frame.BackgroundTransparency = 0.5
    frame2.BackgroundTransparency = 0.5
    box.BackgroundTransparency = 0.5
    for i=0.1,0.5,0.1 do
        --wait(0.1)
        frame.BackgroundTransparency = 0.5-i
        frame2.BackgroundTransparency = 0.5-i
        box.BackgroundTransparency = 0.5-i
    end-- Disabled ]]
		frame.BackgroundTransparency = 0
		frame2.BackgroundTransparency = 0
		box.BackgroundTransparency = 0
		fakeDrag.Visible = true
	end

	local function fadeOut()
    --[[
    frame.BackgroundTransparency = 0
    frame2.BackgroundTransparency = 0
    box.BackgroundTransparency = 0
    for i=0.1,0.5,0.1 do
        --wait(0.1)
        frame.BackgroundTransparency = i
        frame2.BackgroundTransparency = i
        box.BackgroundTransparency = i
    end-- Disabled ]]
		frame.BackgroundTransparency = 0.7
		frame2.BackgroundTransparency = 1
		box.BackgroundTransparency = 1
		fakeDrag.Visible = false
	end

	fadeOut()

	frame.MouseEnter:Connect(function()
		fadeIn()
	end)

	frame.MouseLeave:Connect(function()
		if not boxFocused then
			fadeOut()
		end
	end)

	toggle.MouseButton1Click:Connect(function()
		if drag.Visible then
			drag.Visible = false
			toggle.Image = "rbxassetid://417301749"--417285299"
		else
			drag.Visible = true
			toggle.Image = "rbxassetid://417301773"--417285351"
		end
	end)

	global.MouseButton1Click:Connect(function()
		openGlobal()
	end)

	team.MouseButton1Click:Connect(function()
		openTeam()
	end)

	localb.MouseButton1Click:Connect(function()
		openLocal()
	end)

	admins.MouseButton1Click:Connect(function()
		if isAdmin or tick() - lastClick > 5 then
			isAdmin = client.Remote.Get("CheckAdmin")
			if isAdmin then
				openAdmins()
			else
				admins.BackgroundTransparency = 0.8
				admins.TextTransparency = 0.8
			end
			lastClick = tick()
		end
	end)

	cross.MouseButton1Click:Connect(function()
		if isAdmin or tick() - lastClick > 5 then
			isAdmin = client.Remote.Get("CheckAdmin")
			if isAdmin then
				openCross()
			else
				cross.BackgroundTransparency = 0.8
				cross.TextTransparency = 0.8
			end
			lastClick = tick()
		end
	end)

	box.FocusLost:Connect(function(enterPressed)
		boxFocused = false
		if enterPressed and not client.Variables.Muted then
			if box.Text ~= '' and ((mode ~= "Cross" and tick() - lastChat >= 0.5) or (mode == "Cross" and tick() - lastChat >= 10)) then
				if not client.Variables.Muted then
					client.Remote.Send('ProcessCustomChat', box.Text, mode)
					lastChat = tick()
				end
			elseif not ((mode ~= "Cross" and tick() - lastChat >= 0.5) or (mode == "Cross" and tick() - lastChat >= 10)) then
				local tim
				if mode == "Cross" then
					tim = 10 - (tick() - lastChat)
				else
					tim = 0.5 - (tick() - lastChat)
				end
				tim = string.sub(tostring(tim), 1, 3)
				client.Handlers.ChatHandler("SpamBot", `Sending too fast! Please wait {tim} seconds.`, "System")
			end
			box.Text = "Click here or press the '/' key to chat"
			fadeOut()
			if mode ~= "Cross" then
				lastChat = tick()
			end
		end
	end)

	box.Focused:Connect(function()
		boxFocused = true
		if box.Text == "Click here or press the '/' key to chat" then
			box.Text = ''
		end
		fadeIn()
	end)

	if not nohide then
		service.UserInputService.InputBegan:Connect(function(InputObject)
			local textbox = service.UserInputService:GetFocusedTextBox()
			if not (textbox) and InputObject.UserInputType == Enum.UserInputType.Keyboard and InputObject.KeyCode == Enum.KeyCode.Slash then
				if box.Text == "Click here or press the '/' key to chat" then
					box.Text = ''
				end
				service.RunService.RenderStepped:Wait()
				box:CaptureFocus()
			end
		end)
	end

	local dragging = false

	local nx, ny = drag.AbsoluteSize.X, frame.AbsoluteSize.Y --450,200
	local defx, defy = nx, ny
	mouse.Move:Connect(function(x, y)
		if dragging then
			nx = math.clamp(defx + (dragger.Position.X.Offset + 20), 1, 260)
			ny = math.clamp(defy + (dragger.Position.Y.Offset + 20), 1, 100)

			frame.Size = UDim2.new(1, 0, 0, ny)
			drag.Size = UDim2.new(0, nx, 0, 30)
		end
	end)
	dragger.DragBegin:Connect(function(init)
		dragging = true
	end)
	dragger.DragStopped:Connect(function(x, y)
		dragging = false
		defx = nx
		defy = ny
		dragger.Position = UDim2.new(1, -20, 1, -20)
		UpdateChat()
	end)

	UpdateChat()

--[[
if not service.UserInputService.KeyboardEnabled then
    warn("User is on mobile :: CustomChat Disabled")
    chatenabled = true
    drag.Visible = false
    service.StarterGui:SetCoreGuiEnabled('Chat',true)
end
--]]

	client.Handlers.RemoveCustomChat = function()
		local chat = gui
		if chat then
			chat:Destroy()
			client.Variables.ChatEnabled = true
			service.StarterGui:SetCoreGuiEnabled('Chat', true)
		end
	end

	client.Handlers.ChatHandler = function(plr, message, mode)
		if not message then
			return
		end
		if string.sub(message, 1, 2) == '/e' then
			return
		end
		if gui then
			local player

			if plr and type(plr) == "userdata" then
				player = plr
			else
				player = {
					Name = tostring(plr or "System"),
					TeamColor = BrickColor.White()
				}
			end

			if #message > 150 then
				message = `{string.sub(message, 1, 150)}...`
			end

			if mode then
				if mode == "Private" or mode == "System" then
					table.insert(storedChats, {
						Color = player.TeamColor or BrickColor.White(),
						Player = player.Name,
						Message = message,
						Mode = "Global",
						Private = true
					})
					table.insert(storedChats, {
						Color = player.TeamColor or BrickColor.White(),
						Player = player.Name,
						Message = message,
						Mode = "Team",
						Private = true
					})
					table.insert(storedChats, {
						Color = player.TeamColor or BrickColor.White(),
						Player = player.Name,
						Message = message,
						Mode = "Local",
						Private = true
					})
					table.insert(storedChats, {
						Color = player.TeamColor or BrickColor.White(),
						Player = player.Name,
						Message = message,
						Mode = "Admins",
						Private = true
					})
					table.insert(storedChats, {
						Color = player.TeamColor or BrickColor.White(),
						Player = player.Name,
						Message = message,
						Mode = "Cross",
						Private = true
					})
				else
					local plr = player.Name
					table.insert(storedChats, {
						Color = player.TeamColor or BrickColor.White(),
						Player = plr,
						Message = message,
						Mode = mode
					})
				end
			else
				local plr = player.Name
				table.insert(storedChats, {
					Color = player.TeamColor or BrickColor.White(),
					Player = plr,
					Message = message,
					Mode = "Global"
				})
			end

			if mode == "Local" then
				if not localTab.Visible then
					localb.Text = "Local*"
				end
			elseif mode == "Team" then
				if not teamTab.Visible then
					team.Text = "Team*"
				end
			elseif mode == "Admins" then
				if not adminsTab.Visible then
					admins.Text = "Admins*"
				end
			elseif mode == "Cross" then
				if not crossTab.Visible then
					cross.Text = "Cross*"
				end
			else
				if not globalTab.Visible then
					global.Text = "Global*"
				end
			end

			if #storedChats >= 50 then
				table.remove(storedChats, 1)
			end

			UpdateChat()

			if not nohide then
				if player and type(player) == "userdata" then
					local char = player.Character
					local head = char:FindFirstChild("Head")

					if head then
						local cont = service.LocalContainer():FindFirstChild(`{player.Name}Bubbles`)
						if not cont then
							cont = Instance.new("BillboardGui", service.LocalContainer())
							cont.Name = `{player.Name}Bubbles`
							cont.StudsOffset = Vector3.new(0, 2, 0)
							cont.SizeOffset = Vector2.new(0, 0.5)
							cont.Size = UDim2.new(0, 200, 0, 150)
						end

						cont.Adornee = head

						local clone = bubble:Clone()
						clone.TextLabel.Text = message
						clone.Parent = cont

						local xsize = clone.TextLabel.TextBounds.X + 40
						if xsize > 400 then
							xsize = 400
						end
						clone.Size = UDim2.new(0, xsize, 0, 50)


						if #cont:GetChildren() > 3 then
							cont:GetChildren()[1]:Destroy()
						end

						for i, v in cont:GetChildren() do
							local xsize = v.TextLabel.TextBounds.X + 40
							if xsize > 400 then
								xsize = 400
							end
							v.Position = UDim2.new(0.5, -xsize / 2, 1, -(math.abs((i - 1) - #cont:GetChildren()) * 50))
						end

						local cam = workspace.CurrentCamera
						local char = player.Character
						local head = char:FindFirstChild("Head")

						Routine(function()
							repeat
								if not head then
									break
								end
								local dist = (head.Position - cam.CFrame.p).Magnitude
								if dist <= 50 then
									clone.Visible = true
								else
									clone.Visible = false
								end
								task.wait(0.1)
							until not clone.Parent or not clone or not head or not head.Parent or not char
						end)

						task.wait(10)

						if clone then
							clone:Destroy()
						end
					end
				end
			end
		end
	end

	local textbox = service.UserInputService:GetFocusedTextBox()
	if textbox then
		textbox:ReleaseFocus()
	end
end