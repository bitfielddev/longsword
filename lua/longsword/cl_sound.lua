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
        tr.mask = CONTENTS_SOLID + CONTENTS_CURRENT_0

    local res = util.TraceLine(tr)
    debugoverlay.Line(tr.start, res.HitPos, 10, Color(math.random(0, 255), math.random(0, 255), math.random(0, 255)), true)

    return res
end

function longsword.sound.traceBounce(origin, startNormal, maxBounces)
    maxBounces = maxBounces or 8

    local lastTrace = longsword.sound.quickTrace(origin, startNormal)
    local traces = {}
    local entities = {}

    for i = 1, maxBounces do
        local trace = longsword.sound.quickTrace(lastTrace.HitPos, longsword.math.reflect(lastTrace.HitPos, lastTrace.Normal))
        lastTrace = trace

        if IsValid(trace.Entity) and not entities[trace.Entity:EntIndex()] then
            entities[trace.Entity:EntIndex()] = trace.Entity
        end

        table.insert(traces, trace)
    end


    return (lastTrace.HitPos - origin):Length(), entities, traces
end

function longsword.sound.getDelay(pos)
    return (EyePos():Distance(pos) * 0.01) / 343
end

local soundMats = {
    [MAT_CONCRETE] = true,
    [MAT_METAL] = true,
    [MAT_PLASTIC] = true
}
function meta:EmitDynSound(path, pitch, level, volume, noMuffle)
    pitch = pitch or 100
    level = level or 100
    volume = volume or 1

    if self == LocalPlayer() then
        self:EmitSound(path, level, pitch, volume)
        return
    end

    local me = LocalPlayer()
    local origin = self:GetPos()
    local eye = EyePos()
    local ang = Angle()

    local cv = GetConVar("longsword_dynsound_maxbounces")
    local maxBounces = cv and cv:GetInt() or 8

    local distLeft, entsLeft, tracesLeft = longsword.sound.traceBounce(eye, ang:Right(), maxBounces)
    local distRight, entsRight, tracesRight = longsword.sound.traceBounce(eye, -ang:Right(), maxBounces)
    local distUp, entsUp, tracesUp = longsword.sound.traceBounce(eye, ang:Up(), maxBounces)
    local distDown, entsDown, tracesDown = longsword.sound.traceBounce(eye, -ang:Up(), maxBounces)
    local distFwd, entsFwd, tracesFwd = longsword.sound.traceBounce(eye, ang:Forward(), maxBounces)
    local distBack, entsBack, tracesBack = longsword.sound.traceBounce(eye, -ang:Forward(), maxBounces)

    local entList = combineTables(true, entsLeft, entsRight, entsUp, entsDown, entsFwd, entsBack)
    local traceList = combineTables(false, tracesLeft, tracesRight, tracesUp, tracesDown, tracesFwd, tracesBack)

    local roomSize = (distLeft + distRight + distUp + distDown + distFwd + distBack) / 6
    debugoverlay.ScreenText(50, 50, roomSize, 6, Color(0, 255, 0))

    local dsp = 0
    -- self:EmitSound(path, level, pitch, volume, CHAN_STATIC)

    -- for i, trace in pairs(traceList) do
    --     if not soundMats[trace.MatType] or i % (maxBounces / 2) != 0 then continue end
    --     print(i)

    --     timer.Simple(longsword.sound.getDelay(trace.HitPos), function()
    --         EmitSound(path, trace.HitPos, 0, CHAN_AUTO, 0.6, 100, nil, pitch, nil, nil)
    --     end)
    -- end
    if roomSize <= 400 then
        dsp = 8
    end

    if roomSize > 400 and roomSize <= 500 then
        dsp = 24
    end

    if roomSize > 500 and roomSize <= 600 then
        dsp = 25
    end

    if roomSize > 600 and roomSize <= 800 then
        dsp = 21
    end

    if roomSize > 800 then
        dsp = 19
    end

    if not noMuffle then
        local dir = (self:GetPos() - eye):GetNormalized()
        local tr = longsword.sound.quickTrace(eye, dir)
        if tr.Entity != self then
            local tr2 = longsword.sound.quickTrace(tr.HitPos + (dir * 16), dir)

            dsp = (tr2.Entity != self) and 31 or 30
        end
    end
    self:EmitSound(path, level, pitch, volume, CHAN_AUTO, nil, nil)
    self:EmitSound(path, level, pitch, 0.4, CHAN_AUTO, nil, dsp)
end
