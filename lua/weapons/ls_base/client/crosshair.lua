SWEP.CrosshairAlpha = 1
SWEP.CrosshairSpread = 0

function SWEP:CanDrawCrosshair()
	if self.NoCrosshair then
		return false
	end
	
	if hook.Run("ShouldDrawLocalPlayer", self.Owner) then
		return true	
	end

	if self:GetReloading() or (self:IsSprinting() and self.LoweredPos) then
		return false
	end

	if (self:GetIronsights() and not self.IronsightsCrosshair) then
		return false
	end

	return true
end

function SWEP:GetCrosshairGap()
    local ply = self:GetOwner()
    local base = 5 * (self.Primary.Cone * 128)

	base = base * (self:IsSprinting() and (self.Spread.SprintMod or 2) * 4 or 1)
    base = base * (self:GetIronsights() and (self.Spread.IronsightsMod or 0.7) or 1)

    return base
end

function SWEP:DoDrawCrosshair(x, y)
	local length = 8
	local candraw = self:CanDrawCrosshair()

    local newGap = self:GetCrosshairGap()
    local gap = Lerp(RealFrameTime() * 20, self.HUDCrosshairGap or newGap, newGap)
    self.HUDCrosshairGap = gap

	local newAlpha = candraw and 255 or 0
	local alpha = Lerp(RealFrameTime() * 10, self.HUDCrosshairAlpha or newAlpha, newAlpha)
	self.HUDCrosshairAlpha = alpha

	surface.SetDrawColor(ColorAlpha(color_white, alpha))
    surface.DrawLine(x + gap, y, x + gap + length, y)
    surface.DrawLine(x - gap, y, x - gap - length, y)

    surface.DrawLine(x, y + gap, x, y + gap + length)
    surface.DrawLine(x, y - gap, x, y - gap - length)
end