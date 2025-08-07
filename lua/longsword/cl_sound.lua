longsword.sound = longsword.sound or {}
local meta = FindMetaTable("Entity")

local function combineTables(useKeys, ...)
    if useKeys == nil then
        useKeys = true
    end
    local res = {}

    for _, tbl in pairs({ ... }) do
        for k, v in pairs(tbl) do
            if useKeys and res[k] != v then
                res[k] = v
            elseif not useKeys and not table.HasValue(v) then
                table.insert(res, v)
            end
        end
    end

    return res
end

function longsword.sound.quickTrace(start, direction)
    local tr = {}
        tr.start = start
        tr.endpos = start + direction * 32768
        tr.filter = LocalPlayer()
        tr.mask = bit.bor(MASK_SOLID, MASK_SHOT)

    local res = util.TraceLine(tr)
    debugoverlay.Line(tr.start, res.HitPos, 10, Color(math.random(0, 255), math.random(0, 255), math.random(0, 255)), true)

    return res
end

local penetratableMaterials = {
    [MAT_DIRT] = true,
    [MAT_WOOD] = true,
    [MAT_GLASS] = true,
    [MAT_VENT] = true,
    [MAT_FOLIAGE] = true,
    [MAT_GRASS] = true,
    [MAT_GRATE] = true
}

function longsword.sound.traceBounce(origin, startNormal, maxBounces)
    maxBounces = maxBounces or 8

    local lastTrace
    local traces = {}

    local energy = maxBounces * 2

    for i = 1, maxBounces do
        if energy < 1 then break end

        local trace
        if not lastTrace then
            trace = longsword.sound.quickTrace(origin, startNormal)
        else
            trace = longsword.sound.quickTrace(lastTrace.HitPos, longsword.math.reflect(lastTrace.HitPos, lastTrace.HitNormal))
        end

        local mat = trace.MatType
        if mat and penetratableMaterials[mat] then
            energy = energy - 2

            trace = longsword.sound.quickTrace(trace.HitPos + trace.Normal * 16, trace.Normal)
        end

        energy = energy - 1
        lastTrace = trace

        table.insert(traces, trace)
    end

    return traces
end

function longsword.sound.getDelay(pos)
    return (EyePos():Distance(pos) * 0.01) / 343
end

function longsword.sound.playDynSound(path, origin, pitch, level, volume)
    local eye = EyePos()
    local radius = level ^ 2

    local diff = (origin - eye)
    local dist = diff:LengthSqr()
    if dist < radius or noMuffle then
        sound.Play(path, origin, level, pitch, volume)
        return
    end

    local cv = GetConVar("longsword_dynsound_maxbounces")
    local maxBounces = cv and cv:GetInt() or 8

    local hitCount = 0

    radius = (level * 2) ^ 2

    local resolution = 16
    local dir = diff:GetNormalized():Angle()

    for dirIndex = 1, resolution do
        if hitCount >= 10 then break end
        local ang = 60 - (dirIndex / resolution) * 180

        local traceDir = Angle(dir.p, ang + dir.y, dir.r)
        traceDir:Normalize()
        local traces = longsword.sound.traceBounce(eye, traceDir:Forward(), maxBounces)

        
        for _, trace in ipairs(traces) do
            local diff = (trace.HitPos - origin)
            local length = diff:LengthSqr()
            debugoverlay.Text(trace.HitPos, tostring(length), 10)
            if length > radius then continue end
            
            hitCount = hitCount + 1
            if hitCount >= 10 then break end
        end
    end

    
    impulse.Notify("What ", hitCount)

    local dsp = 0

    if hitCount < 10 then
        dsp = 14
    end

    if hitCount < 2 then
        dsp = 16
    end

    sound.Play(path, origin, level, pitch, volume, dsp)


end

function meta:EmitDynSound(path, pitch, level, volume, noMuffle)
    pitch = pitch or 100
    level = level or 100
    volume = volume or 1
    if noMuffle then
        self:EmitSound(path, level, pitch, volume)
        return
    end

    longsword.sound.playDynSound(path, self:GetPos(), pitch, level, volume)
end
