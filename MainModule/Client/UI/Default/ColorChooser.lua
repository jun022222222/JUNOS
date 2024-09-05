client, service = nil, nil

return function(data, env)
	if env then
		setfenv(1, env)
	end
	
	local doSearch
	local genList
	local returnColor
	local gTable
	
	local window = client.UI.Make("Window", {
		Name  = "ColorChooser";
		Title = data.Title or "Color Chooser";
		Icon = client.MatIcons.Create;
		Size  = {250,350};
		MinSize = {200, 250};
		OnClose = function()
			--[[if not returnColor then
				returnColor = "Dark stone grey"
			end]]
		end
	})
	
	local brickColorNames = {}
	for i = 1, 127 do
		table.insert(brickColorNames, BrickColor.palette(i).Name)
	end
	table.sort(brickColorNames)
	
	function doSearch(text)
		local found = {}
		text = string.lower(tostring(text)):gsub("%%", "%%%%"):gsub("%[", "%%["):gsub("%]", "%%]")
		for _, v in ipairs(brickColorNames) do
			if text == "" or (type(v) == "string" and string.find(string.lower(v),text)) or (type(v) == "table" and ((v.Text and string.find(string.lower(tostring(v.Text)), text)) or (v.Filter and string.find(string.lower(v.Filter),text)))) then
				table.insert(found, v)
			end
		end

		return found
	end
	
	local search = window:Add("TextBox", {
		Size = UDim2.new(1, -10, 0, 20);
		Position = UDim2.new(0, 5, 0, 5);
		Text = "";
		PlaceholderText = "Search";
	})
	
	search:GetPropertyChangedSignal("Text"):Connect(function()
		genList()
	end)
	
	local Selected = window:Add("TextButton", {
		Text = "Select";
		Size = UDim2.new(1, -10, 0, 30);
		Position = UDim2.new(0, 5, 1, -35);
		Events = {
			MouseButton1Down = function()
				window:Close()
			end
		}
	})
	
	local List = window:Add("ScrollingFrame", {
		Size = UDim2.new(1, -10, 1, -70);
		Position = UDim2.new(0, 5, 0, 30);
	})
	
	function genList()
		List:ClearAllChildren()
		
		local tab = brickColorNames
		
		if search.Text:gsub(" ", "") ~= "" then
			tab = doSearch(search.Text)
		end
		
		for i, color in next, tab do
			List:Add("TextButton", {
				Size = UDim2.new(1, -10, 0, 30);
				Position = UDim2.new(0, 5, 0, (i-1)*35);
				Text = "";
				BackgroundColor3 = BrickColor.new(color).Color;
				ToolTip = `Name: {color} | Num:{BrickColor.new(color).Number}`;
				Events = {
					MouseButton1Click = function()
						Selected.Text = `Select ({color})`
						
						returnColor = color
					end
				}
			})
		end
		
		List:ResizeCanvas(false, true)
	end
	
	genList()
	gTable = window.gTable
	window:Ready()
	
	repeat
		task.wait()
	until not gTable.Active
	
	return returnColor
end
