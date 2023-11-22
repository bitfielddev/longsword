function longsword.echo(weapon, ply)
    local lp = LocalPlayer()
    local echoSound = weapon.Primary.Sound

    if weapon.Echo then
        echoSound = weapon.Echo.Sounds and weapon.Echo.Sounds[math.random(1, #weapon.Echo.Sounds)] or weapon.Echo.Sound
    end

    local muffled = (ply:GetPos() - lp:GetPos()):LengthSqr() > (500 ^ 2)

    local dsp = muffled and 31 or nil

    ply:EmitSound(echoSound, 180, 100, 1, CHAN_STATIC, nil, dsp)
end