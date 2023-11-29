concommand.Add("longsword_debug_attachments", function()
    local vm = LocalPlayer():GetViewModel()

    PrintTable(vm:GetAttachments())
end)

concommand.Add("longsword_debug_bones", function()
    local vm = LocalPlayer():GetViewModel()

    for i = 1, vm:GetBoneCount() do
        print(vm:GetBoneName(i), i)
    end
end)
