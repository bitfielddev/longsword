function SWEP:PlayAnim(act)
	if not IsValid(self:GetOwner()) or not IsValid(self:GetOwner():GetViewModel()) return
	
	local vmodel = self:GetOwner():GetViewModel()
	local seq = isstring(act) and self:LookupSequence(act) or vmodel:SelectWeightedSequence(act)

	if not seq or seq == -1 then
		return longsword.debugPrint("Attempting to play invalid sequence " .. act .. "!")
	end
	
	vmodel:ResetSequenceInfo()
	vmodel:SendViewModelMatchingSequence(seq)

	return vmodel:SequenceDuration(seq)
end

function SWEP:PlayAnimWorld(act)
	local wmodel = self
	local seq = wmodel:SelectWeightedSequence(act)

	self:ResetSequence(seq)
end

function SWEP:QueueIdle()
	self:SetNextIdle( CurTime() + self:GetOwner():GetViewModel():SequenceDuration() + 0.1 )
end