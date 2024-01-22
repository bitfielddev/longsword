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

if not ConVarExists("longsword_shootblur") then
	CreateClientConVar("longsword_shootblur", "1", true, false, "If the top/bottom of the screen should be blurred when shooting.", 0, 1)
end

if not ConVarExists("longsword_shootfov") then
	CreateClientConVar("longsword_shootfov", "1", true, false, "If the FOV should be increased when shooting.", 0, 1)
end

if not ConVarExists("longsword_vmfov") then
	CreateClientConVar("longsword_vmfov", "1", true, false, "FOV multiplier for ViewModel", -10, 10)
end

if not ConVarExists("longsword_lefthand") then
	CreateClientConVar("longsword_lefthand", "0", true, false, "If left handed viewmodel should be enabled.", 0, 1)
end