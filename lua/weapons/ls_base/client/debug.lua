local debugCol = Color(0, 255, 0, 200)
local ironFade = ironFade or 0
local GetConVar = GetConVar
local LocalPlayer = LocalPlayer

local black = Color(0, 0, 0, 255)

function SWEP:DrawAttachmentHUD(attID, hdr)
	local ft = RealFrameTime()

    local data = self.Attachments[attID]
    if not data then return end

	if data.Scope then
		self:DrawVMAttachmentScope(attID)
	end

	if data.NeedsHDR and not hdr and self:GetIronsights() then
		draw.SimpleText("WARNING!", "ChatFont", ScrW() * 0.5, ScrH() * 0.5, nil, TEXT_ALIGN_CENTER)
		draw.SimpleText("To see this scope, you must enable HDR in your settings.", "ChatFont", ScrW() * 0.5, (ScrH() * 0.5) + 20, nil, TEXT_ALIGN_CENTER)
		draw.SimpleText("Press ESC > Settings > Video > Advanced Settings > High Dynamic Range to FULL", "ChatFont", ScrW() * 0.5 , (ScrH() * 0.5) + 40, nil, TEXT_ALIGN_CENTER)
		draw.SimpleText("You will then have to rejoin.", "ChatFont", ScrW() * 0.5 , (ScrH() * 0.5) + 60, nil, TEXT_ALIGN_CENTER)
		return
	end

    local w, h = ScrW(), ScrH()
    local cw, ch = w / 2, h / 2

	if data.Behaviour != "sniperscope" then return end
    if not self:GetIronsights() then return end

    local tex = data.ScopeTexture
    local col = data.ScopeColor or color_white
    local bgCol = data.ScopeBGColor or black

    local sw, sh = w / 1.2, h / 1.2
    local bw, bh = w - sw, h - sh

    surface.SetDrawColor(bgCol)
    surface.DrawRect(0, 0, w, h)

    surface.SetDrawColor(col)
    surface.SetMaterial(tex)
    surface.DrawTexturedRect(cw - sw / 2, ch - sh / 2, sw, sh)
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

function SWEP:DrawHUD()
	self.EquippedAttachments = self.EquippedAttachments or {}
	for attID, _ in pairs(self.EquippedAttachments) do
		local attData = self.Attachments[attID]
		if attData.Scope then
			self:DrawVMAttachmentScope(attID)
		end
	end
	local debugMode = GetConVar("longsword_debug")

	if (impulse_DevHud or debugMode:GetBool()) then
		local scrW = ScrW()
		local scrH = ScrH()
		local dev = GetConVar("developer"):GetInt()

		if dev == 0 then
			print("[longsword] Enabling 'developer 1'")
			LocalPlayer():ConCommand("developer 1")
		end

		surface.SetFont("lsDebug")
		surface.SetTextColor(debugCol)

		surface.SetTextPos(0, 0)
		surface.DrawText("[LONGSWORD DEBUG MODE ENABLED]")

		surface.SetTextPos((scrW / 2) + 30, (scrH / 2) - 20)
		surface.DrawText((self.PrintName or "PrintName ERROR").." [BDMG: "..(self.Primary.Damage or "?")..", RPM: "..(60 / (self.Primary.Delay or 0))..", SHOTS: "..(self.Primary.NumShots or "?").."]")

		surface.SetTextPos((scrW / 2) + 30, (scrH / 2))
		surface.DrawText("Recoil: "..self:GetRecoil())

		surface.SetTextPos((scrW / 2) + 30, (scrH / 2) + 20)
		surface.DrawText("Ironsights Recoil: "..self:GetIronsightsRecoil())

		surface.SetTextPos((scrW / 2) + 30, (scrH / 2) + 40)
		surface.DrawText("Last Spread: "..(self.LastSpread or "[SHOOT WEAPON]"))


		if self.LastSpread then
			local perc = (self.LastSpread / self.Primary.Cone)
			surface.SetTextPos((scrW / 2) + 30, (scrH / 2) + 60)
			surface.SetTextColor(Color(255 * perc, 255 * (1 - perc), 0, 200))
			surface.DrawText((perc * 100).."% of Base Cone")
			surface.SetTextColor(debugCol)
		end

		surface.SetTextPos((scrW / 2) + 30, (scrH / 2) + 90)
		surface.DrawText("Is Ironsights: "..tostring(self:GetIronsights()))

		surface.SetTextPos((scrW / 2) + 30, (scrH / 2) + 110)
		surface.DrawText("Is Bursting: "..tostring(self:GetBursting()))

		surface.SetTextPos((scrW / 2) + 30, (scrH / 2) + 130)
		surface.DrawText("Is Reloading: "..tostring(self:GetReloading()))

		local ns = (self:GetNextPrimaryFire() or 0) - CurTime()
		surface.SetTextPos((scrW / 2) + 30, (scrH / 2) + 150)
		surface.DrawText("Next Shot: "..(ns > 0 and ns or "CLEAR"))

		local attach = self:GetCurAttachment()

		if attach and attach != "" then
			surface.SetTextPos((scrW / 2) + 30, (scrH / 2) + 180)
			surface.DrawText("Attachment: "..self:GetCurAttachment())
		end
	end

	local hdr = (GetConVar("mat_hdr_level"):GetInt() or 0) != 0

	for attachment, _ in pairs(self.EquippedAttachments or {}) do
		self:DrawAttachmentHUD(attachment, hdr)
	end
end
