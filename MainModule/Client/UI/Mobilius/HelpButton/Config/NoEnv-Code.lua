client = nil
cPcall = nil
Pcall = nil
Routine = nil
service = nil

--// All global vars will be wiped/replaced except script

return function(data, env)
	if env then
		setfenv(1, env)
	end

	local playergui = service.PlayerGui
	local localplayer = service.Player
	local toggle = script.Parent.Parent.Toggle

	if client.Core.Get("Chat") then
		toggle.Position = UDim2.new(1, -(45+40),1, -45)
	end

	toggle.MouseButton1Down:Connect(function()
		local found = client.Core.Get("UserPanel",nil,true)
		if found then
			found.Object:Destroy()
		else
			client.Core.Make("UserPanel",{})
		end
	end)

	script.Parent.Parent.Parent = playergui
end