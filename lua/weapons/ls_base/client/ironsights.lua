function SWEP:AdjustMouseSensitivity()
	if self:GetIronsights() then return self.IronsightsSensitivity end
end

local appr = math.Approach

local zero = Vector()
local zeroAng = Angle()

SWEP.IronsightsInMidAng = Angle(0, -6, 0)
SWEP.IronsightsInMid = Vector(-4, 0, -2.5)

SWEP.IronsightsOutMidAng = Angle(0, 0, 0)
SWEP.IronsightsOutMid = Vector(-2, 0, -2)
function SWEP:GetRecoilMultiplier()
	return (self.Recoil and self.Recoil.VisualMultiplier or self.IronsightsRecoilVisualMultiplier) or 1
end

function SWEP:CustomRecoilOffset(eyePos, eyeAng)
	local ft = RealFrameTime()
	local ct = RealTime()

	local recoilPos = Vector()
	local recoilAng = Angle()
	local recoilInfo = self.Recoil or {}

	-- Lerp
	local value = self.RecoilValue or 0
	local target = self.RecoilTarget or 0

	if target == 1 and value >= 0.999 then
		self.RecoilTarget = 0
		self.RecoilSpeed = 2
		target = 0
	end

	if value != target then
		value = Lerp((self.RecoilSpeed or 4) * RealFrameTime(), value, target)
		self.RecoilValue = value
	end

	local rollRand = self.RecoilRollRandom or 0
	if rollRand != 0 then
		self.RecoilRollRandom = Lerp(ft * 7, rollRand, 0)
	end
	rollRand = rollRand * (recoilInfo.RollMultiplier or 1)
	
	-- Positions
	value = target == 1 and math.ease.OutQuad(value) or math.ease.InQuad(value)

	local pitch = value * 2 * (recoilInfo.PitchMultiplier or 1)

	recoilPos.y = -value * 2 * (recoilInfo.BackMultiplier or 1)
	recoilPos.z = -pitch * 0.2 * (recoilInfo.PitchCompMultiplier or 1)

	recoilAng.p = pitch
	recoilAng.r = rollRand * 4
	eyePos = eyePos + eyeAng:Right() * recoilPos.x
	eyePos = eyePos + eyeAng:Forward() * recoilPos.y
	eyePos = eyePos + eyeAng:Up() * recoilPos.z
	
	eyeAng:RotateAroundAxis(eyeAng:Right(), recoilAng.x)
    eyeAng:RotateAroundAxis(eyeAng:Up(), recoilAng.y)
    eyeAng:RotateAroundAxis(eyeAng:Forward(), recoilAng.z)

	return eyePos, eyeAng
end

function SWEP:GetIronsightsMid()
	if self:GetIronsights() then
		return self.IronsightsInMid, self.IronsightsInMidAng
	else
		return self.IronsightsOutMid, self.IronsightsOutMidAng
	end

end


function SWEP:IronsightsOffset(oPos, oAng)
	local ct = CurTime()
	local ft = RealFrameTime()
	local is = self:GetIronsights()

	local mid, midang = self:GetIronsightsMid()
	local dir = is and 1 or 0
	self.IronsightsFrac = Lerp(ft * (is and 4.5 or 3.1) * (self.IronsightsSpeed or 1), self.IronsightsFrac or 0, dir)

	local frac = self.IronsightsFrac
	local vec = longsword.math.vecQuadBezier(zero, mid or zero, self.IronsightsPos, frac)
	local ang = longsword.math.angQuadBezier(zeroAng, midang or zeroAng, self.IronsightsAng, frac )

	return vec, ang
end