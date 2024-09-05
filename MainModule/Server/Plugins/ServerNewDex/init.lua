return function(Vargs)
	local Server = Vargs.Server;
	local Service = Vargs.Service;

	local Variables = Server.Variables;
	local Commands = Server.Commands;

	local Settings = Server.Settings;
	local Anti = Server.Anti;
	local Functions = Server.Functions;
	local Logs = Server.Logs;
	local Remote = Server.Remote;

	local HttpService = Service.HttpService
	local Success, APIDump, Reflection = nil
	local ServerNewDex = {}
	
	local newDex_main = script:WaitForChild("Dex_Client", 120)
	local Event = ServerNewDex.Event;
	
	if not newDex_main then
		warn("New Dex unable to be located?")
	else
		newDex_main = newDex_main:Clone()
		for _, BaseScript in ipairs(newDex_main:GetDescendants()) do
			if BaseScript.ClassName == "LocalScript" then
				BaseScript.Disabled = false
			end
		end
	end
	
	if HttpService.HttpEnabled then
		while true do
			Success, APIDump = pcall(function() return HttpService:GetAsync("https://github.com/MaximumADHD/Roblox-Client-Tracker/raw/roblox/API-Dump.json") end)
			if Success and APIDump then
				break
			end
			task.wait(1)
		end

		while true do
			Success,Reflection = pcall(function() return HttpService:GetAsync("https://raw.githubusercontent.com/MaximumADHD/Roblox-Client-Tracker/roblox/ReflectionMetadata.xml") end)
			if Success and Reflection then
				break
			end
			task.wait(1)
		end
		
	else
		warn('Access to HttpService is not enabled! Dex api dump could not be fetched!')
	end
	
	ServerNewDex.newDex_main = newDex_main
	ServerNewDex.Event = nil;
	ServerNewDex.Authorized = {}; --// Users who have been given Dex and are authorized to use the remote event

	local Actions = {
		destroy = function(p: Player, args)
			args[1]:Destroy();
			return true;
		end,
		clearclipboard = function(Player: Player, args)
			Player.Clipboard = {};
			return true;
		end,
		duplicate = function(Player: Player, args)
			local obj = args[1];
			local par = args[2];

			local new = obj:Clone()
			new.Parent = par;

			return new;
		end,
		copy = function(Player: Player, args)
			local obj = args[1];
			local new = obj:Clone();
			table.insert(Player.Clipboard, new)

			return new; -- It seems like this returns nil to the client, if the parent is nil.
		end,
		paste = function(Player: Player, args)
			local parent = args[1];
			local pastedObjects = {}

			for _,v in pairs(Player.Clipboard) do
				local cloned = v:Clone()
				cloned.Parent = parent;
				table.insert(pastedObjects, cloned)
			end

			return pastedObjects;
		end,
		setproperty = function(Player: Player, args)
			local obj = args[1];
			local prop = args[2];
			local value = args[3];

			if value ~= nil then
				obj[prop] = value;
				return true;
			end
		end,
		setpropertyattribute = function(Player:Player, args)
			local obj = args[1];
			local attributeName = args[2];
			local value = args[3];

			if (value ~= nil) then
				obj:SetAttribute(attributeName, value);
				return true;
			end
		end,
		instancenew = function(Player:Player, args)
			return Service.New(args[1], args[2]);
		end, 
		callfunction = function(Player:Player, args)
			local rets = {pcall(function() return (args[1][args[2]](args[1])) end)}
			table.remove(rets,1)
			return rets
		end, 
		callremote = function(Player:Player, args)
			if args[1]:IsA("RemoteFunction") then
				return args[1]:InvokeClient(table.unpack(args[2]))
			elseif args[1]:IsA("RemoteEvent") then
				args[1]:FireClient(table.unpack(args[2]))
			elseif args[1]:IsA("BindableFunction") then
				return args[1]:Invoke(table.unpack(args[2]))
			elseif args[1]:IsA("BindableEvent") then
				args[1]:Fire(table.unpack(args[2]))
			end
		end,
		fetchapi = function(Player:Player)
			return APIDump or false
		end,
		fetchrmd = function(Player:Player)
			return Reflection or false
		end, 
	}
	
	function ServerNewDex.MakeEvent()
		if not Event then
			Event = Service.New("RemoteFunction", {
				Name = "NewDex_Event";
				Parent = game:GetService("ReplicatedStorage");
			}, true, true)

			Event.OnServerInvoke = (function(Plr: Player, Action, ...)
				local pData = ServerNewDex.Authorized[Plr];

				if not pData then
					return	Anti.Detected(Plr, "kick", "Unauthorized to use the dex event");
				end

				local args = {...};
				local Suppliments = args[1];

				local Action = string.lower(assert(Action, "Method argument missing!"))
				local MethodFunction = assert(Actions[Action], `{Plr.Name} attempted to use an action that wasn't defined: {Action}`)

				return MethodFunction(pData, args);
			end)
		end

	end

	function ServerNewDex.MakeLocalDexForPlayer(ply, dexGui, destination)
		if (ply) then
			if (dexGui and destination) then
				dexGui.Parent = destination
			end
		end
	end


	-- Function used to give Dex to a player.
	function ServerNewDex.GiveDexToPlayer(ply)
		if (ply) then
			ServerNewDex.Authorized[ply] = {
				Clipboard = {};
			}; --// double as per-player explorer-related data

			if not ServerNewDex.Event then  ServerNewDex.MakeEvent(); end
			ServerNewDex.MakeLocalDexForPlayer(ply, ServerNewDex.newDex_main:Clone(), ply:FindFirstChild("PlayerGui"))
		end
	end
	
	
	Commands.DexExplorerNew = {
		Prefix = Settings.Prefix;
		Commands = {"dexnew";"dexnewexplorer";"newdex";"dex";"dexexplorer"};
		Args = {};	--// kept for backwards compatibility
		Description = "Lets you explore the game using new Dex [Credits to LorekeeperZinnia]";
		AdminLevel = 300;
		Function = function(plr, args)
			ServerNewDex.Authorized[plr] = {
				Clipboard = {};
			}; --// double as per-player explorer-related data

			if not ServerNewDex.Event then  ServerNewDex.MakeEvent(); end
			Remote.MakeLocal(plr, newDex_main:Clone(), "PlayerGui")
		end
	};
end