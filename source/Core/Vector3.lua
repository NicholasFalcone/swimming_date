class('Vector3').extends()

function Vector3:init(x, y, z)
    self.x = x or 0
    self.y = y or 0
    self.z = z or 0
end

function Vector3:add(v)
    return Vector3(self.x + v.x, self.y + v.y, self.z + v.z)
end

function Vector3:sub(v)
    return Vector3(self.x - v.x, self.y - v.y, self.z - v.z)
end

function Vector3:mul(s)
    return Vector3(self.x * s, self.y * s, self.z * s)
end

function Vector3:div(s)
    return Vector3(self.x / s, self.y / s, self.z / s)
end

function Vector3:dot(v)
    return self.x * v.x + self.y * v.y + self.z * v.z
end

function Vector3:cross(v)
    return Vector3(
        self.y * v.z - self.z * v.y,
        self.z * v.x - self.x * v.z,
        self.x * v.y - self.y * v.x
    )
end

function Vector3:magnitude()
    return math.sqrt(self.x * self.x + self.y * self.y + self.z * self.z)
end

function Vector3:normalize()
    local m = self:magnitude()
    if m > 0 then
        return self:div(m)
    else
        return Vector3(0, 0, 0)
    end
end

function Vector3:rotateX(angle)
    local c = math.cos(angle)
    local s = math.sin(angle)
    return Vector3(
        self.x,
        self.y * c - self.z * s,
        self.y * s + self.z * c
    )
end

function Vector3:rotateY(angle)
    local c = math.cos(angle)
    local s = math.sin(angle)
    return Vector3(
        self.x * c + self.z * s,
        self.y,
        -self.x * s + self.z * c
    )
end

function Vector3:rotateZ(angle)
    local c = math.cos(angle)
    local s = math.sin(angle)
    return Vector3(
        self.x * c - self.y * s,
        self.x * s + self.y * c,
        self.z
    )
end

function Vector3:__tostring()
    return string.format("Vector3(%.2f, %.2f, %.2f)", self.x, self.y, self.z)
end
