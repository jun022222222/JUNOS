client = nil
cPcall = nil
Pcall = nil
Routine = nil
service = nil
gTable = nil

--// All global vars will be wiped/replaced except script
--// All guis are autonamed client.Variables.CodeName..gui.Name

return function(data, env)
	if env then
		setfenv(1, env)
	end
	local gui = script.Parent.Parent
	local bar = gui.TextLabel
	local playergui = service.PlayerGui

	--[[
	local TopbarMatchAdmin = client.GetReturn("Setting","TopbarMatchAdmin")
	local TopbarColor = client.GetReturn("Setting","TopbarColor")
	local TopbarTransparency = client.GetReturn("Setting","TopbarTransparency")
	local TopbarText = client.GetReturn("Setting","TopbarText")

	if not TopbarMatchAdmin then
		local text=TopbarText
		if text=="%TIME" then
			cPcall(function()
				repeat
					local t4=GetTime()
					local nt4
					local hour=t4:match("%d+")
					if tonumber(hour)>12 or tonumber(hour)<1 then
						nt4=`{math.abs(tonumber(hour)-12)}{t4:match(":%d+")} PM`
					else
						nt4=`{t4} AM`
					end
					bar.Text=`{t4} / {nt4}`
				until not wait(1)
			end)
		else
			bar.Text=TopbarText
		end
		bar.BackgroundColor3=TopbarColor
		bar.BorderSizePixel=0
		bar.BackgroundTransparency=TopbarTransparency
	end
	--]]

	bar.Position=UDim2.new(0,0,0,-40)
	gTable:Ready()
end