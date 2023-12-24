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

if not ConVarExists("longsword_invertsway") then
	CreateClientConVar("longsword_invertsway", "0", true, false, "If the sway should be inverted on ALL weapons.", 0, 1)
end

if not ConVarExists("longsword_centered") then
	CreateClientConVar("longsword_centered", "0", true, false, "If the viewmodel should be centered.", 0, 1)
end

if not ConVarExists("longsword_dyncrosshair") then
	CreateClientConVar("longsword_dyncrosshair", "1", true, false, "If the custom crosshair should be used.", 0, 1)
end

if not ConVarExists("longsword_dynsound_maxbounces") then
	CreateClientConVar("longsword_dynsound_maxbounces", "8", true, false, "Max bounces to use for Longsword-DynSound. The amount of traces made is MaxBounces * 6", 4, 128)
end