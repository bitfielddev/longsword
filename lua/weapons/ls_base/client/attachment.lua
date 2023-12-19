local wepMeta = FindMetaTable("Weapon")

-- https://github.com/Lexicality/stencil-tutorial/blob/master/lua/stencil_tutorial/09_advanced_masks.lua
-- this prevents everything except the specified entity to draw (i think idfk)
function maskEntity(ent)
	render.SetStencilReferenceValue(0)
    render.SetStencilPassOperation(STENCIL_KEEP)
    render.SetStencilZFailOperation(STENCIL_KEEP)
    render.ClearStencil()

    render.SetStencilEnable(true)
    render.SetStencilWriteMask(0xF0)
    render.ClearStencilBufferRectangle(0, 0, ScrW(), ScrH(), 0x0F)
    render.SetStencilCompareFunction(STENCIL_NEVER)
    render.SetStencilTestMask(0x00)
    render.SetStencilFailOperation(STENCIL_INCR)

    ent:DrawModel()

    render.SetStencilTestMask(0xFF)
    render.SetStencilReferenceValue(0x1F)
	render.SetStencilCompareFunction( STENCIL_INCRSAT )
end

function unmaskEntity(ent)
	render.SetStencilEnable(false)
end

function wepMeta:GiveAttachment(attID)
	if not self.IsLongsword or not self.Attachments then return end

	local attData = self.Attachments[attID]
	if not attData then return end

	self.EquippedAttachments = self.EquippedAttachments or {}
	self.EquippedAttachments[attID] = true

	self:ProcessAttachmentAdd(attID)
end

function wepMeta:TakeAttachment(attID)
	if not self.IsLongsword or not self.Attachments then return end

	local attData = self.Attachments[attID]
	if not attData then return end

	self.EquippedAttachments = self.EquippedAttachments or {}
	self.EquippedAttachments[attID] = nil
	self:ProcessAttachmentRemove(attID)

	if attData._CSModel then
		attData._CSModel:Remove()
	end


end

local reticule = Material("models/weapons/insurgency_sandstorm/ins2_sandstorm/kobra_reticle") 
function SWEP:DrawVMAttachmentCrosshair(attID)
	local attData = self.Attachments[attID]
	local mdl = attData._CSModel

	if not IsValid(mdl) then return end

	local p, a = mdl:GetPos(), mdl:GetAngles()
	a:RotateAroundAxis(a:Up(), -90)
	local retData = attData.Reticule or {}

	if retData.Pos then
		p = p + a:Forward() * retData.Pos.x
		p = p + a:Right() * retData.Pos.y
		p = p + a:Up() * retData.Pos.z
	end


	local ret = retData.Material or reticule
	local col = retData.Color or color_white

	render.SetMaterial(ret)
	render.DrawQuadEasy(p, a:Forward(), retData.Size or 32, retData.Size or 32, col, a.r - 180)
end

function SWEP:DrawVMAttachmentScope(attID)
	local attData = self.Attachments[attID]
	if not attData then return end

	local scope = attData.Scope
	local ply = self:GetOwner()
	local vm = ply:GetViewModel()

	local att = attData._CSModel
	if not IsValid(att) then return end

	local c = {}
		c.origin = vm:GetPos()
		c.angles = EyeAngles()
		c.fov = scope.FOV or 14
		c.x, c.y = 0, 0
		c.w, c.h = ScrW(), ScrH()

		c.drawviewmodel = false
		c.drawhud = false 
		c.aspect = 1

	if scope.RTOffset then
		c.drawviewmodel = true

		local attPos = self.LastVMPos or vm:GetPos()
		local attAng = self.LastVMAng or vm:GetAngles()

		attPos, attAng = longsword.math.translate(attPos, attAng, scope.RTOffset, scope.RTOffsetAng or Angle())

		c.origin = attPos
		c.angles = attAng
	end

	render.PushRenderTarget(longsword.rt)
	render.OverrideAlphaWriteEnable(true, true)

	cam.Start2D()
	render.Clear(255, 255, 255, 0)
	render.RenderView(c)
	cam.End2D()

	draw.NoTexture()
	render.PopRenderTarget()
	render.OverrideAlphaWriteEnable(false, false)


	if attData.Scope.SubMaterial then
		att:SetSubMaterial(attData.Scope.SubMaterial, "!ls_rendertargetmaterial")
	end
end

function SWEP:DrawVMAttachment(attID)
	local vm = self:GetOwner():GetViewModel()

	local attData = self.Attachments[attID]
	if not attData then return end

	if attData.PlayerParent then
		vm = self:GetOwner()
	end

	if not IsValid(attData._CSModel) then
		attData._CSModel = ClientsideModel(attData.Cosmetic.Model, RENDER_GROUP_VIEW_MODEL_OPAQUE)
		attData._CSModel:SetParent(vm)
		attData._CSModel:SetNoDraw(true)

		if attData.Cosmetic.Scale then
			attData._CSModel:SetModelScale(attData.Cosmetic.Scale)
		end
	end


	local att = attData._CSModel
	local c = attData.Cosmetic
	
	local pos, ang
	if c.Bone then
		local bone = vm:LookupBone(c.Bone)
	
		if not bone then
			return
		end

		local m = vm:GetBoneMatrix(bone)
		if not m then return end

		pos, ang = m:GetTranslation(), m:GetAngles()

	elseif c.Attachment then
		local attc = vm:LookupAttachment(c.Attachment)
		if not attc then return end

		local data = vm:GetAttachment(attc)
		if not data then return end

		pos, ang = data.Pos, data.Ang
	else
		pos, ang = vm:GetPos(), vm:GetAngles()
	end

	
	att:SetPos(pos + ang:Forward() * c.Pos.x + ang:Right() * c.Pos.y + ang:Up() * c.Pos.z)
	ang:RotateAroundAxis(ang:Up(), c.Ang.y)
	ang:RotateAroundAxis(ang:Right(), c.Ang.p)
	ang:RotateAroundAxis(ang:Forward(), c.Ang.r)
	att:SetAngles(ang)
	att:DrawModel()
	if attData.Reticule and not attData.Reticule.NoMask then
		maskEntity(att)
		self:DrawVMAttachmentCrosshair(attID)
		unmaskEntity()
	elseif attData.Reticule then
		self:DrawVMAttachmentCrosshair(attID)
	end


end

function SWEP:DrawVMElement(data)
	local vm = self:GetOwner():GetViewModel()
	if not IsValid(vm) then
		return
	end

	if not IsValid(data._CSModel) then
        local cs = ClientsideModel(data.Model)
        data._CSModel = cs

        cs:SetParent(vm)
        cs:SetNoDraw(true)

		if data.BoneMerge then
			cs:AddEffects(EF_BONEMERGE)
		end

		if data.Scale then
			cs:SetModelScale(data.Scale)
		end
    end

	if data.ShouldDraw and not data.ShouldDraw(self) then return end
	
    local cs = data._CSModel

    local bone = vm:LookupBone(data.Bone)
	local pos, ang
	if bone then
		local m = vm:GetBoneMatrix(bone)
		if m then
			pos, ang = m:GetTranslation(), m:GetAngles()
		else
			pos, ang = vm:GetPos(), vm:GetAngles()
		end
	else
		pos, ang = vm:GetPos(), vm:GetAngles()
	end

	cs:SetPos(pos + ang:Forward() * data.Pos.x + ang:Right() * data.Pos.y + ang:Up() * data.Pos.z)
	ang:RotateAroundAxis(ang:Up(), data.Ang.y)
	ang:RotateAroundAxis(ang:Right(), data.Ang.p)
	ang:RotateAroundAxis(ang:Forward(), data.Ang.r)
	cs:SetAngles(ang)
    cs:DrawModel()
end


-- seems pointless rn tbh

-- function SWEP:DrawWorldModel()
-- 	if self.ExtraDrawWorldModel then
-- 		self.ExtraDrawWorldModel(self)
-- 	else
-- 		self:DrawModel()
-- 	end

-- 	local attachment = self:GetCurAttachment()

-- 	if not self.Attachments or not self.Attachments[attachment] or not self.Attachments[attachment].Cosmetic then
-- 		return
-- 	end

-- 	local attData = self.Attachments[attachment]

-- 	if not IsValid(self.worldAttachment) then
-- 		self.worldAttachment = ClientsideModel(attData.Cosmetic.Model, RENDERGROUP_TRANSLUCENT)
-- 		self.worldAttachment:SetParent(self)
-- 		self.worldAttachment:SetNoDraw(true)

-- 		if attData.Cosmetic.Scale then
-- 			self.worldAttachment:SetModelScale(attData.Cosmetic.Scale)
-- 		end
-- 	end

-- 	local vm = self

-- 	if attData.Cosmetic.PlayerParent then
-- 		vm = self.Owner
-- 	end

-- 	local att = self.worldAttachment
-- 	local c = attData.Cosmetic
-- 	local w = c.World

-- 	if not w then
-- 		return
-- 	end

-- 	local bone = w.Bone and vm:LookupBone(w.Bone) or self:LookupBone("ValveBiped.Bip01_R_Hand")
-- 	local m = vm:GetBoneMatrix(bone)

-- 	local pos, ang = m:GetTranslation(), m:GetAngles()
	
-- 	att:SetPos(pos + ang:Forward() * w.Pos.x + ang:Right() * w.Pos.y + ang:Up() * w.Pos.z)
-- 	ang:RotateAroundAxis(ang:Up(), w.Ang.y)
-- 	ang:RotateAroundAxis(ang:Right(), w.Ang.p)
-- 	ang:RotateAroundAxis(ang:Forward(), w.Ang.r)
-- 	att:SetAngles(ang)
-- 	--att:DrawModel()
-- end