client = nil
cPcall = nil
Pcall = nil
Routine = nil
service = nil
gTable = nil

--// All global vars will be wiped/replaced except script

return function(data, env)
	if env then
		setfenv(1, env)
	end

	local playergui = service.PlayerGui
	local gui = client.UI.Prepare(script.Parent.Parent)
	local label = gui.LABEL
	local str = data.Message

	client.UI.Remove("Notif",script.Parent.Parent)

	if str and type(str)=="string" then
		label.Text = str
		gTable:Ready()
	else
		gui:Destroy()
	end
end