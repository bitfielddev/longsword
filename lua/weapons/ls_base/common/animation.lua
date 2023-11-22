function SWEP:PlayAnim(act)
	local vmodel = self.Owner:GetViewModel()
	local seq = isstring(act) and self:LookupSequence(act) or vmodel:SelectWeightedSequence(act)

	vmodel:SendViewModelMatchingSequence(seq)

	return vmodel:SequenceDuration(seq)
end

function SWEP:PlayAnimWorld(act)
	local wmodel = self
	local seq = wmodel:SelectWeightedSequence(act)

	self:ResetSequence(seq)
end

function SWEP:QueueIdle()
	self:SetNextIdle( CurTime() + self.Owner:GetViewModel():SequenceDuration() + 0.1 )
end