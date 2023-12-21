SWEP.CrosshairAlpha = 1
SWEP.CrosshairSpread = 0

local function drawCirc(x, y, radius, seg)
	local cir = {}

	table.insert( cir, { x = x, y = y, u = 0.5, v = 0.5 } )
	for i = 0, seg do
		local a = math.rad( ( i / seg ) * -360 )
		table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )
	end

	local a = math.rad( 0 ) -- This is needed for non absolute segment counts
	table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )

	surface.DrawPoly( cir )
end

function SWEP:CanDrawCrosshair()
	if self.NoCrosshair then
		return false
	end
	
	if self:ScopedIn() then
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
    local base = 7 * (self.Primary.Cone * 128)

	base = base * (self:IsSprinting() and (self.Spread.SprintMod or 2) * 4 or 1)
    base = base * (self:GetIronsights() and (self.Spread.IronsightsMod or 0.7) or 1)
	
    return base
end

function SWEP:DoDrawCrosshair(x, y)
	local cv = GetConVar("longsword_dyncrosshair")
	if not cv:GetBool() then
		return false
	end


	local length = 8
	local candraw = self:CanDrawCrosshair()

    local newGap = self:GetCrosshairGap()
    local gap = Lerp(RealFrameTime() * 8, self.HUDCrosshairGap or newGap, newGap)
    self.HUDCrosshairGap = gap

	local newAlpha = candraw and 255 or 0
	local alpha = Lerp(RealFrameTime() * 20, self.HUDCrosshairAlpha or newAlpha, newAlpha)
	self.HUDCrosshairAlpha = alpha

	surface.SetDrawColor(ColorAlpha(color_white, alpha))

    surface.DrawLine(x + gap, y, x + gap + length, y)
    surface.DrawLine(x - gap, y, x - gap - length, y)

    surface.DrawLine(x, y + gap, x, y + gap + length)
    surface.DrawLine(x, y - gap, x, y - gap - length)

	surface.DrawRect(x - 1, y - 1, 2, 2)

	return true
end