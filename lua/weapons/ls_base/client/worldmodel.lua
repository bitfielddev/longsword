function SWEP:DrawWorldModel( f )
	if not self.WMOffset then
		return self:DrawModel( f )
	end

	if not IsValid(self.WorldModel) then
		self.WorldModel = ClientsideModel(self.WorldModel)
		self.WorldModel:SetNoDraw(true)
	end


	local _Owner = self:GetOwner()

	if (IsValid(_Owner)) then
		local WorldModel = self.WorldModel
		-- Specify a good position
		local offsetVec = self.WMOffset.Position
		local offsetAng = self.WMOffset.Angle or angle_zero

		local boneid = _Owner:LookupBone( "ValveBiped.Bip01_R_Hand" ) -- Right Hand
		if !boneid then return end

		local matrix = _Owner:GetBoneMatrix(boneid)
		if !matrix then return end

		local newPos, newAng = LocalToWorld(offsetVec, offsetAng, matrix:GetTranslation(), matrix:GetAngles())

		WorldModel:SetPos(newPos)
		WorldModel:SetAngles(newAng)

		WorldModel:SetupBones()
	else
		WorldModel:SetPos(self:GetPos())
		WorldModel:SetAngles(self:GetAngles())
	end

	self.WorldModel:DrawModel()
end