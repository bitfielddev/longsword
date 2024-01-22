local debugCol = Color(0, 255, 0, 200)
local ironFade = ironFade or 0
local GetConVar = GetConVar
local LocalPlayer = LocalPlayer

local black = Color(0, 0, 0, 255)


surface.CreateFont("Longsword.Title", {
	font = "Roboto Bold",
	size = 43,
	weight = 300,
	antialias = true
})

surface.CreateFont("Longsword.Version", {
	font = "Roboto Light",
	size = 22,
	weight = 200,
	antialias = true
})

surface.CreateFont("Longsword.Info", {
	font = "Cascadia Code",
	size = 20,
	weight = 200,
	antialias = true
})

function SWEP:DrawAttachmentHUD(attID, hdr)
	local ft = RealFrameTime()

    local data = self.Attachments[attID]
    if not data or data.Behaviour != "sniperscope" then return end

	if data.Scope then
		self:DrawVMAttachmentScope(attID)
		return
	end

	if not self:GetIronsights() then
		ironFade = 0
		return
	end

	local scrw = ScrW()
	local scrh = ScrH()
	local ft = FrameTime()
	local scoped = self:ScopedIn()

	if ironFade != 1 and not scoped then
		ironFade = math.Clamp(ironFade + (ft * 2.6), 0, 1)

		surface.SetDrawColor(ColorAlpha(color_black, ironFade * 255))
		surface.DrawRect(0, 0, scrw, scrh)

		return
	end

	if scoped and ironFade != 0 then
		ironFade = math.Clamp(ironFade - (ft * 1), 0, 1)

		surface.SetDrawColor(ColorAlpha(color_black, ironFade * 255))
		surface.DrawRect(0, 0, scrw, scrh)
	end

	local scopeh = scrh * 1
	local scopew = scopeh * 1.8
	local hw = (scrw * 0.5) - (scopew / 2)
	local hh = (scrh * 0.5) - (scopeh / 2)

	surface.SetDrawColor(color_black)
	surface.DrawRect(0, 0, scrw, hh)
	surface.DrawRect(0, 0, scrw - scopew, scrh)
	surface.DrawRect(scrw - hw, 0, scrw - scopew, scrh)
	surface.DrawRect(0, hh + scopeh, scrw, scrh)

	surface.SetDrawColor(data.ScopeColour or color_white)
	surface.SetMaterial(data.ScopeTexture)
	surface.DrawTexturedRect(hw, hh, scopew, scopeh)

	if data.NeedsHDR then
		local hasHDR = GetConVar("mat_hdr_level"):GetInt() or 0

		if hasHDR == 0 then
			draw.SimpleText("WARNING!", "ChatFont", ScrW() * 0.5, ScrH() * 0.5, nil, TEXT_ALIGN_CENTER)
			draw.SimpleText("To see this scope, you must enable HDR in your settings.", "ChatFont", ScrW() * 0.5, (ScrH() * 0.5) + 20, nil, TEXT_ALIGN_CENTER)
			draw.SimpleText("Press ESC > Settings > Video > Advanced Settings > High Dynamic Range to FULL", "ChatFont", ScrW() * 0.5 , (ScrH() * 0.5) + 40, nil, TEXT_ALIGN_CENTER)
			draw.SimpleText("You will then have to rejoin.", "ChatFont", ScrW() * 0.5 , (ScrH() * 0.5) + 60, nil, TEXT_ALIGN_CENTER)
		end
	end

	if data.ScopePaint then
		data.ScopePaint(self)
	end
end

function SWEP:ScopedIn()
	if not self:GetIronsights() then return false end

	for attID, _ in pairs(self.EquippedAttachments or {}) do
		local data = self.Attachments[attID]
		if not data then continue end

		if data.Behaviour == "sniperscope" then
			return true
		end
	end
end

local yInc = 20

function SWEP:DrawDebugHUD()
	-- Title
	surface.SetFont("Longsword.Title")
	surface.SetTextColor(debugCol)
	surface.SetTextPos(60, 60)
	surface.DrawText("LONGSWORD")

	surface.SetFont("Longsword.Version")
	surface.SetTextColor(200, 200, 200, 255)
	surface.SetTextPos(60, 94)
	surface.DrawText("v" .. longsword.version)

	-- Info

	local y = 120

	surface.SetFont("Longsword.Info")
	surface.SetTextColor(255, 255, 255, 255)
	surface.SetTextPos(60, y)
	surface.DrawText("BDMG: " .. self.Primary.Damage)

	y = y + yInc

	surface.SetFont("Longsword.Info")
	surface.SetTextColor(255, 255, 255, 255)
	surface.SetTextPos(60, y)
	surface.DrawText("Ironsights: " .. math.SnapTo(self.IronsightsFrac or 0, 0.005))

	y = y + yInc

	surface.SetFont("Longsword.Info")
	surface.SetTextColor(255, 255, 255, 255)
	surface.SetTextPos(60, y)
	surface.DrawText("Crouch: " .. math.SnapTo(self.VMCrouchLerp or 0, 0.005))

	y = y + yInc

	surface.SetFont("Longsword.Info")
	surface.SetTextColor(255, 255, 255, 255)
	surface.SetTextPos(60, y)
	surface.DrawText("Last Spread: " .. (self.LastSpread or 0))
end

function SWEP:DrawHUD()
	self.EquippedAttachments = self.EquippedAttachments or {}
	for attID, _ in pairs(self.EquippedAttachments) do
		local attData = self.Attachments[attID]
		if attData.Scope then
			self:DrawVMAttachmentScope(attID)
		end
	end

	local isDebug = GetConVar("longsword_debug")

	if isDebug:GetBool() then
		self:DrawDebugHUD()
	end

	local hdr = (GetConVar("mat_hdr_level"):GetInt() or 0) != 0

	for attachment, _ in pairs(self.EquippedAttachments or {}) do
		self:DrawAttachmentHUD(attachment, hdr)
	end
end

function SWEP:RenderScreenspaceEffects()
	local cv = GetConVar("longsword_shootblur")
	if not cv or not cv:GetBool() then return end

	local fx = self.BlurFraction or 0

	self.BlurFraction = Lerp(RealFrameTime() * 1, fx, 0)

	DrawToyTown(fx * 2, ScrH() / 2)
end