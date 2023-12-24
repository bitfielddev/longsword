longsword.math = longsword.math or {}

--- Lerps between two points
-- @float p1 The first point
-- @float p2 The second point
-- @float t The fraction, from 0-1
-- @treturn float The result
-- @realm shared
function longsword.math.lerp(p1, p2, t)
    return p1 + (p2 - p1) * t
end

--- Lerps between two points using a vector
-- @vec p1 The first point
-- @vec p2 The second point
-- @float t The fraction, from 0-1
-- @treturn vec The result
-- @realm shared
function longsword.math.lerpVec(p1, p2, t)
    local x = longsword.math.lerp(p1.x, p2.x, t)
    local y = longsword.math.lerp(p1.y, p2.y, t)
    local z = longsword.math.lerp(p1.z, p2.z, t)

    return Vector(x, y, z)
end

--- Lerps between two points using an angle
-- @ang p1 The first point
-- @ang p2 The second point
-- @float t The fraction, from 0-1
-- @treturn vec The result
-- @realm shared
function longsword.math.lerpAng(p1, p2, t)
    local p = longsword.math.lerp(p1.p, p2.p, t)
    local y = longsword.math.lerp(p1.y, p2.y, t)
    local r = longsword.math.lerp(p1.r, p2.r, t)

    return Angle(p, y, r)
end

--- Creates a bezier curve between three points
-- @float p1 The first point
-- @float p2 The second point
-- @float p3 The third point
-- @float t The fraction, from 0-1
-- @treturn float The resulting bezier curve
-- @realm shared
function longsword.math.quadBezierLerp(p1, p2, p3, t)
    return math.QuadraticBezier(t, p1, p2, p3)
end

--- Creates a bezier curve between three vector points in 3D space
-- @vec p1 The first point
-- @vec p2 The second point
-- @vec p3 The third point
-- @float t The fraction, from 0-1
-- @treturn vec The resulting vector
-- @realm shared
function longsword.math.vecQuadBezier(p1, p2, p3, t)
    local x = longsword.math.quadBezierLerp(p1.x, p2.x, p3.x, t)
    local y = longsword.math.quadBezierLerp(p1.y, p2.y, p3.y, t)
    local z = longsword.math.quadBezierLerp(p1.z, p2.z, p3.z, t)
    return Vector(x, y, z)
end

--- Creates a bezier curve between three angle points in 3D space
-- @ang p1 The first point
-- @ang p2 The second point
-- @ang p3 The third point
-- @float t The fraction, from 0-1
-- @treturn ang The resulting angle
-- @realm shared
function longsword.math.angQuadBezier(p1, p2, p3, t)
    local p = longsword.math.quadBezierLerp(p1.p, p2.p, p3.p, t)
    local y = longsword.math.quadBezierLerp(p1.y, p2.y, p3.y, t)
    local r = longsword.math.quadBezierLerp(p1.r, p2.r, p3.r, t)
    return Angle(p, y, r)
end

--- Translates a vector/angle by the given vector/angle. This is mainly used as a helper function.
-- @vec pos The original angle
-- @ang ang The original position
-- @vec nPos The angle to translate oA with
-- @ang nAng The position to translate oP with
-- @float[opt=1] mul The value to multiply it by
-- @treturn vec The new position
-- @treturn ang The new angles
function longsword.math.translate(originalVec, originalAng, newVec, newAng, mul)
    mul = mul or 1
    originalAng:RotateAroundAxis(originalAng:Right(), newAng.p * mul)
    originalAng:RotateAroundAxis(originalAng:Up(), newAng.y * mul)
    originalAng:RotateAroundAxis(originalAng:Forward(), newAng.r * mul)

    originalVec = originalVec + newVec.x * originalAng:Right() * mul
    originalVec = originalVec + newVec.y * originalAng:Forward() * mul
    originalVec = originalVec + newVec.z * originalAng:Up() * mul

    return originalVec, originalAng
end

--- Rotates a vector/angle around a vector.
-- @vec pos The original angle
-- @ang ang The original position
-- @vec vec The vector to rotate around with
-- @ang rot The amount to rotate it by
-- @treturn vec The new position
-- @treturn ang The new angles
function longsword.math.rotateAround(pos, ang, vec, rot)
    local mat = Matrix()
    mat:SetTranslation(pos)
    mat:SetAngles(ang)
    mat:Translate(vec)
    mat:Rotate(-rot)
    mat:Translate(-vec)
    return mat:GetTranslation(), mat:GetAngles()
end

--- Reflects a vector
-- @vec vector The vector origin
-- @vec normal The normal of the surface
-- @treturn vec The reflected result
-- @realm shared
function longsword.math.reflect(vector, normal)
    local dir = vector:Dot(normal) * 2

    return vector - (normal * dir)
end