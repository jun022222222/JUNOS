client = nil
service = nil

return function(data, env)
	if env then
		setfenv(1, env)
	end
	-- Some pre-defined "global" variables

	local gTable
	local tLimit = data.Time
	local sImg
	local visualiserModule = nil
	local visualiser = nil
	local isMuted = false
	local activeSongList = nil
	local availableSongLists = {}
	local selected = nil
	local shuffle = false
	local soundInstanceEndedEvent = nil

	-- Sound that's used for every song

	local soundInstance = service.New('Sound')
	soundInstance.Volume = 0.25
	soundInstance.Looped = false
	--soundInstance.SoundId = 'http://www.roblox.com/asset/?id=4881542521' -- Used to play a sound on window open.


	-- The audio visulaiser at the top of the menu.

	local visualiserModule = require(script:FindFirstChild("Visualizer"))

	-- Function to run when we close the window

	local function doOnClose()
		if visualiser then
			visualiser:UnlinkFromSound()
			visualiser:Destroy()
			visualiser = nil
		end
		if visualiserModule then
			visualiserModule = nil
		end
		if soundInstance then
			soundInstance:Stop()
			soundInstance:Destroy()
		end
	end

	-- The when the who the when the window

	local window = client.UI.Make("Window", {
		Name = "Audio Player";
		Title = "Audio Player";
		Size = {410, 400};
		MinSize = {410, 245};
		icon = "http://www.roblox.com/asset/?id=7032721624";
		Position = UDim2.new(0, 10, 1, -410);
		OnClose = function()
			doOnClose()
		end
	})

	-- Make the window ready before completing any code - Used to allow for delays in loading caused by MarketplaceService.

	gTable = window.gTable
	gTable:Ready()

	-- Mute button

	local muteButton = window:AddTitleButton({
		Text = "";
		OnClick = function()
			if isMuted then
				soundInstance.Volume = 0.25
				sImg.Image = "rbxassetid://7463478056"
				isMuted = false
			else
				soundInstance.Volume = 0
				sImg.Image = "rbxassetid://7463462018";
				isMuted = true
			end
		end
	})

	sImg = muteButton:Add("ImageLabel", {
		Size = UDim2.new(1, 0 ,0.85, 0);
		AnchorPoint = Vector2.new(0.5,0.5);
		Position = UDim2.new(0.5, 0 ,0.536, 0);
		ScaleType = Enum.ScaleType.Fit;
		Image = "rbxassetid://7463478056";
		BackgroundTransparency = 1;
	})

	-- Song title and Audio Visaliser Frame.

	local heading = window:Add("TextLabel", {
		Text = "Audio Player";
		Size = UDim2.new(1,0,0,20);
		BackgroundTransparency = 1;
		TextScaled = true;
		ToolTip = "Audio Player";
	})

	local visualiserFrame = window:Add("Frame", {
		Size = UDim2.new(1,0,0,50);
		Position = UDim2.new(0, 0, 0, 30);
		BackgroundTransparency = 1;
		TextScaled = true;
	})

	-- Function that makes the song list.

	local function getSongs(tab, list)
		local num = 0
		selected = nil
		if availableSongLists and availableSongLists[tab.Name] then availableSongLists[tab.Name] = nil end
		if soundInstanceEndedEvent then soundInstanceEndedEvent:Disconnect() end

		tab:ClearAllChildren();

		local frame = tab:Add("ScrollingFrame", {
			Size = UDim2.new(1, 0, 1, 1);
			Position = UDim2.new(0, 0, 0, 0);
			BackgroundColor3 = Color3.new(0.235294, 0.235294, 0.235294);
			BackgroundTransparency = 1;
		})

		local loading = frame:Add("TextLabel", {
			Text = "Loading nothing yet!";
			ToolTip = "Never gonna give you up, Never gonna let you down...";
			BackgroundTransparency = 0;
			Size = UDim2.new(1,0,1,0);
			Position = UDim2.new(0,0,0,0);
			ZIndex = 69420
			--TextXAlignment = "Left";
		})

		availableSongLists[tab.Name] = {}

		for i,v in next,(list  or {}) do
			if type(v) == "table" then
				loading.Text = `Loading tracks ({i}/{#list})`;
				local success, product_info = pcall(function()
					return service.MarketplaceService:GetProductInfo(v.ID, Enum.InfoType.Asset)
				end)
				if product_info.AssetTypeId == 3 then
					table.insert(availableSongLists[tab.Name], v)
					frame:Add("TextButton", {
						Text = `  {num + 1}) {success and product_info.Name or `[ERROR] {v.Name}`}`;
						ToolTip = `Name: {v.Name} | ID: {v.ID}`;
						Size = UDim2.new(1, 0, 0, 25);
						Position = UDim2.new(0, 0, 0, num*25);
						BackgroundTransparency = (num%2 == 0 and 0) or 0.2;
						TextXAlignment = "Left";
						OnClicked = function(button)
							if selected and selected.Button then
								selected.Button.BackgroundTransparency = 0
							end
							button.BackgroundTransparency = 0.5

							soundInstance:Stop()
							soundInstance.SoundId = `http://www.roblox.com/asset/?id={v.ID}`;
							soundInstance:Play()

							heading.Text = success and product_info.Name or v.Name
							selected = {
								ID = v.ID,
								Name = v.Name,
								Button = button,
								Index = i
							}
						end
					})
				end
			end
			num = num + 1
		end
		soundInstanceEndedEvent = soundInstance.Ended:Connect(function()
			if activeSongList and selected then
				if shuffle then
					local rnum
					repeat rnum = math.random(#activeSongList) until (rnum ~= selected.Index or #activeSongList <= 1)
					local toPlay = activeSongList[(rnum)]
					if toPlay then
						soundInstance:Stop()
						soundInstance.SoundId = `http://www.roblox.com/asset/?id={toPlay.ID}`;
						soundInstance:Play()
						local success, product_info = pcall(function()
							return service.MarketplaceService:GetProductInfo(toPlay.ID, Enum.InfoType.Asset)
						end)
						heading.Text = success and product_info.Name or `[ERROR] {toPlay.Name}`
						selected = {
							ID = toPlay.ID,
							Name = toPlay.Name,
							Button = nil,
							Index = rnum
						}
					end
				else
					local toPlay = activeSongList[(selected.Index +1)]
					if toPlay then
						soundInstance:Stop()
						soundInstance.SoundId = `http://www.roblox.com/asset/?id={toPlay.ID}`;
						soundInstance:Play()
						local success, product_info = pcall(function()
							return service.MarketplaceService:GetProductInfo(toPlay.ID, Enum.InfoType.Asset)
						end)
						heading.Text = success and product_info.Name or `[ERROR] {toPlay.Name}`
						selected = {
							ID = toPlay.ID,
							Name = toPlay.Name,
							Button = nil,
							Index = selected.Index +1
						}
					end
			end
		end
		end)
		loading:Destroy()
		frame:ResizeCanvas(false, true)
	end

	-- Tabs for different playlists

	local tabFrame = window:Add("TabFrame",{
		Size = UDim2.new(1, 0, 1, -165);
		Position = UDim2.new(0, 0, 0, 90);
	})

	local personalTab = tabFrame:NewTab("Personal",{
		Text = "Personal";
		OnFocus = function()
			activeSongList = availableSongLists["Personal"] or {}
		end;
	})
	local gameTab = tabFrame:NewTab("Game",{
		Text = "Game";
		OnFocus = function()
			activeSongList = availableSongLists["Game"] or {}
		end;
	})
	local adonisTab = tabFrame:NewTab("Adonis", {
		Text = "Adonis";
		OnFocus = function()
			activeSongList = availableSongLists["Adonis"] or {}
		end;
	})
	local customTab = tabFrame:NewTab("Custom", {
		Text = "Custom";
		OnFocus = function()
			activeSongList = availableSongLists["Custom"] or {}
		end;
	})


	--  The Custom Playlists editor window

	local binderBox; binderBox = tabFrame:Add("Frame", {
		Visible = false;
		Size = UDim2.new(1,0,1,0);
		Position = UDim2.new(0,0,0,0);
		BackgroundTransparency = 0;
		ZIndex = 10000;
		Children = {
			{
				Class = "TextLabel";
				Text = "New Custom Playlist string:";
				Position = UDim2.new(0, 5, 0, 5);
				Size = UDim2.new(1, -10, 0, 30);
				BackgroundTransparency = 0;
				ZIndex = 10001;
			};
			{
				Class = "TextButton";
				Text = "Add";
				Position = UDim2.new(0.5, 5, 1, -35);
				Size = UDim2.new(0.5, -10, 0, 30);
				BackgroundTransparency = 0;
				ZIndex = 10002;
				OnClicked = function()
				end
			};
			{
				Class = "TextButton";
				Text = "Cancel";
				Position = UDim2.new(0, 5, 1, -35);
				Size = UDim2.new(0.5, -5, 0, 30);
				BackgroundTransparency = 0;
				ZIndex = 10003;
				OnClicked = function()
					binderBox.Visible = false
				end
			};
		}
	})

	local PlaylistBox = binderBox:Add("TextBox", {
		Position = UDim2.new(0, 5, 0, 40);
		Size = UDim2.new(1, -10, 1, -80);
		TextWrapped = true;
		--TextXAlignment = "Left";
		--TextYAlignment = "Top";
		ClearTextOnFocus = false;
		PlaceholderText = "NAME:ID, SECOND:12398801, HeavyIsDead:4881542521";
		ZIndex = 10004;
		TextChanged = function(newText, enter, box)
			client.Variables.Playlist = {Playlist = {}}
			for v in pairs(client.Variables.Playlist.Playlist) do
				client.Variables.Playlist.Playlist[v] = nil
			end
			for i,v in next,(string.split(string.gsub(newText, " ", ""), ",")) do
				local split = string.split(v, ":")
				table.insert(client.Variables.Playlist.Playlist, (#client.Variables.Playlist.Playlist + 1), {
					Name = tostring(split[1]),
					ID = tonumber(split[2])
				})
			end
			binderBox.Visible = false
			getSongs(customTab, (client.Variables.Playlist.Playlist or {}))
			activeSongList = availableSongLists["Custom"] or {}
		end
	})

	PlaylistBox.BackgroundColor3 = PlaylistBox.BackgroundColor3:lerp(Color3.new(1, 1, 1), 0.1)
	binderBox.BackgroundColor3 = binderBox.BackgroundColor3:lerp(Color3.new(1, 1, 1), 0.05)

	--

	-- The controls frame at the bottom of the window

	local controls = window:Add("Frame", {
		Size = UDim2.new(1, 0, 0, 75);
		Position = UDim2.new(0, 0, 1, -75);
		BackgroundColor3 = Color3.new(0.235294, 0.235294, 0.235294);
		BackgroundTransparency = 0;
	})

	-- Top control buttons (Save and load custom playlist)

	-- Load custom playlist

	local playlistLoad = controls:Add("TextButton", {
		Text = "Load playlist";
		ToolTip = "Create a new custom playlist from a string.";
		BackgroundTransparency = 0;
		Size = UDim2.new(0, 100, 0, 30);
		Position = UDim2.new(0, 5, 1, -70);
		--TextXAlignment = "Left";
		OnClicked = function()
			PlaylistBox.Text = ""
			binderBox.Visible = true
			customTab:FocusTab();
			activeSongList = availableSongLists["Custom"] or {}
		end
	})

	-- Save cutom playlist

	local playlistLoad = controls:Add("TextButton", {
		Text = "Save playlist";
		ToolTip = "Save your custom playlist to the games datastore.";
		BackgroundTransparency = 0;
		Size = UDim2.new(0, 100, 0, 30);
		Position = UDim2.new(1, -105, 1, -70);
		--TextXAlignment = "Right";
		OnClicked = function()
			personalTab:FocusTab();
			if (client.Variables.Playlist.Playlist ~= nil) and (client.Variables.Playlist.Playlist ~= {}) then
				client.Functions.UpdatePlaylist(client.Variables.Playlist)
				getSongs(personalTab, ((client.Functions.Playlist()).Playlist or {}))
			else
				print("[ERROR] Cannot update empty Playlist")
			end
			activeSongList = availableSongLists["Personal"] or {}
		end
	})




	-- Bottom control buttons

	-- Custom Sound ID

	local controlID = controls:Add("TextLabel", {
		Text = "  ID: ";
		ToolTip = "ID: The Sound ID from the roblox catalogue.";
		BackgroundTransparency = 0;
		Size = UDim2.new(0, 120, 0, 30);
		Position = UDim2.new(0, 5, 1, -35);
		TextXAlignment = "Left";
		Children = {
			TextBox = {
				Text = "";
				PlaceholderText = "4881542521";
				Size = UDim2.new(0, 80, 1, 0);
				Position = UDim2.new(1, -90, 0, 0);
				BackgroundTransparency = 1;
				TextXAlignment = "Right";
				TextChanged = function(text, enter, new)
					if enter then
						soundInstance:Stop()
						soundInstance.SoundId = `http://www.roblox.com/asset/?id={text}`;
						soundInstance:Play()
					end
				end
			}
		}
	})

	-- Volume
	local controlVolume = controls:Add("TextLabel", {
		Text = "  Vol: ";
		ToolTip = "Volume: How loud the audio will play (0 to 10).";
		BackgroundTransparency = 0;
		Size = UDim2.new(0, 60, 0, 30);
		Position = UDim2.new(0, 130, 1, -35);
		TextXAlignment = "Left";
		Children = {
			TextBox = {
				Text = "";
				PlaceholderText = "1";
				Size = UDim2.new(0, 40, 1, 0);
				Position = UDim2.new(1, -50, 0, 0);
				BackgroundTransparency = 1;
				TextXAlignment = "Right";
				TextChanged = function(text, enter, new)
					if enter then
						soundInstance.Volume = text;
					end
				end
			}
		}
	})

	-- Position
	local controlPosition = controls:Add("TextLabel", {
		Text = "  Pos: ";
		ToolTip = "Position: Set the audio's position (In seconds).";
		BackgroundTransparency = 0;
		Size = UDim2.new(0, 60, 0, 30);
		Position = UDim2.new(1, -205, 1, -35);
		TextXAlignment = "Left";
		Children = {
			TextBox = {
				Text = "";
				PlaceholderText = "0";
				Size = UDim2.new(0, 40, 1, 0);
				Position = UDim2.new(1, -50, 0, 0);
				BackgroundTransparency = 1;
				TextXAlignment = "Right";
				TextChanged = function(text, enter, new)
					if enter then
						soundInstance:Stop()
						soundInstance.TimePosition = text;
						soundInstance:Play()
					end
				end
			}
		}
	})

	-- Back button
	local controlBack = controls:Add("TextButton", {
		Text = "◀️";
		TextSize = 15;
		ToolTip = "Back: Go back to the last played track.";
		BackgroundTransparency = 0;
		Size = UDim2.new(0, 30, 0, 30);
		Position = UDim2.new(1, -140, 1, -35);
		TextXAlignment = "Center";
		OnClick = function()
			if activeSongList and selected then
				if shuffle then
					local rnum
					repeat rnum = math.random(#activeSongList) until (rnum ~= selected.Index or #activeSongList <= 1)
					local toPlay = activeSongList[(rnum)]
					if toPlay then
						soundInstance:Stop()
						soundInstance.SoundId = `http://www.roblox.com/asset/?id={toPlay.ID}`;
						soundInstance:Play()
						local success, product_info = pcall(function()
							return service.MarketplaceService:GetProductInfo(toPlay.ID, Enum.InfoType.Asset)
						end)
						heading.Text = success and product_info.Name or `[ERROR] {toPlay.Name}`
						selected = {
							ID = toPlay.ID,
							Name = toPlay.Name,
							Button = nil,
							Index = rnum
						}
					end
				else
					local toPlay = activeSongList[(selected.Index -1)]
					if toPlay then
						soundInstance:Stop()
						soundInstance.SoundId = `http://www.roblox.com/asset/?id={toPlay.ID}`;
						soundInstance:Play()
						local success, product_info = pcall(function()
							return service.MarketplaceService:GetProductInfo(toPlay.ID, Enum.InfoType.Asset)
						end)
						heading.Text = success and product_info.Name or `[ERROR] {toPlay.Name}`
						selected = {
							ID = toPlay.ID,
							Name = toPlay.Name,
							Button = nil,
							Index = selected.Index -1
						}
					end
				end
			end
		end
	})

	-- Pause/Play button
	local controlPausePlay = controls:Add("TextButton", {
		Text = "⏯️";
		TextSize = 15;
		ToolTip = "Pause/Play: Control the tracks playing state.";
		BackgroundTransparency = 0;
		Size = UDim2.new(0, 30, 0, 30);
		Position = UDim2.new(1, -105, 1, -35);
		TextXAlignment = "Center";
		OnClick = function()
			if soundInstance.Playing then
				soundInstance:Pause()
			else
				soundInstance:Resume()
			end
		end
	})

	-- Forward button
	local controlForward = controls:Add("TextButton", {
		Text = "▶️";
		TextSize = 15;
		ToolTip = "Forward: Skip to the next track.";
		BackgroundTransparency = 0;
		Size = UDim2.new(0, 30, 0, 30);
		Position = UDim2.new(1, -70, 1, -35);
		TextXAlignment = "Center";
		OnClick = function()
			if activeSongList and selected then
				if shuffle then
					local rnum
					repeat rnum = math.random(#activeSongList) until (rnum ~= selected.Index or #activeSongList <= 1)
					local toPlay = activeSongList[(rnum)]
					if toPlay then
						soundInstance:Stop()
						soundInstance.SoundId = `http://www.roblox.com/asset/?id={toPlay.ID}`;
						soundInstance:Play()
						local success, product_info = pcall(function()
							return service.MarketplaceService:GetProductInfo(toPlay.ID, Enum.InfoType.Asset)
						end)
						heading.Text = success and product_info.Name or `[ERROR] {toPlay.Name}`
						selected = {
							ID = toPlay.ID,
							Name = toPlay.Name,
							Button = nil,
							Index = rnum
						}
					end
				else
					local toPlay = activeSongList[(selected.Index +1)]
					if toPlay then
						soundInstance:Stop()
						soundInstance.SoundId = `http://www.roblox.com/asset/?id={toPlay.ID}`;
						soundInstance:Play()
						local success, product_info = pcall(function()
							return service.MarketplaceService:GetProductInfo(toPlay.ID, Enum.InfoType.Asset)
						end)
						heading.Text = success and product_info.Name or `[ERROR] {toPlay.Name}`
						selected = {
							ID = toPlay.ID,
							Name = toPlay.Name,
							Button = nil,
							Index = selected.Index +1
						}
					end
				end
			end
		end
	})

	local controlShuffle = nil
	local controlShuffleBackgroundColor3 = nil

	local function changeShuffleColor()
		if shuffle then
			controlShuffle.BackgroundColor3 = Color3.new(0, 1, 0.6)
		else
			controlShuffle.BackgroundColor3 = controlShuffleBackgroundColor3
		end
	end

	-- Forward button
	controlShuffle = controls:Add("TextButton", {
		Text = "🔀";
		TextSize = 15;
		ToolTip = "Shuffle: Randomly pick between.";
		BackgroundTransparency = 0;
		Size = UDim2.new(0, 30, 0, 30);
		Position = UDim2.new(1, -35, 1, -35);
		TextXAlignment = "Center";
		OnClick = function()
			shuffle = not shuffle
			changeShuffleColor()
		end
	})

	controlShuffleBackgroundColor3 = controlShuffle.BackgroundColor3


	-- Create audio vislualiser

	soundInstance.Parent = visualiserFrame
	local visualiser = visualiserModule.new(visualiserFrame, 400)
	visualiser:LinkToSound(soundInstance)
	--soundInstance:Play() -- Play a sound immediately after opening

	-- Create OnClose event after everything has been initialised

	-- Load in track lists

	local loadingMessage = function(tab)
		tab:Add("TextLabel", {
			Text = "Waiting in queue to load tracks...";
			ToolTip = "Never gonna give you up, Never gonna let you down...";
			BackgroundTransparency = 0;
			Size = UDim2.new(1,0,1,0);
			Position = UDim2.new(0,0,0,0);
			ZIndex = 69420
			--TextXAlignment = "Left";
		})
	end

	loadingMessage(personalTab)
	loadingMessage(gameTab)
	loadingMessage(adonisTab)
	getSongs(personalTab, ((client.Functions.Playlist()).Playlist or {}))
	getSongs(gameTab, (client.Remote.Get("Variable", "MusicList") or {}))
	getSongs(adonisTab, (client.Remote.Get("Variable", "MusicList") or {}))
	activeSongList = availableSongLists["Personal"] or {}
end