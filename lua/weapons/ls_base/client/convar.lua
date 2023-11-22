if not ConVarExists("longsword_debug") then
	CreateClientConVar("longsword_debug", "0", false, false)

	surface.CreateFont("lsDebug", {
		font = "Consolas",
		size = 18,
		weight = 1000,
		antialias = true,
		shadow = true
	})
end