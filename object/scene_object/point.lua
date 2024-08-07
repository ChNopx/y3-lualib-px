---@alias Point.HandleType py.FPoint

--点
---@class Point
---@field handle Point.HandleType
---@field res_id? integer
---@overload fun(py_point: Point.HandleType): self
---@overload fun(x: number, y: number, z?: number): self
local M = Class "Point"

M.type = "point"

---@private
function M:__tostring()
    return string.format("{Point|%.3f,%.3f,%.3f}"
    , self:获取x()
    , self:获取y()
    , self:获取z()
    )
end

---@private
---@param py_point Point.HandleType
---@return self
function M:__init(py_point)
    self.handle = py_point
    return self
end

---@private
---@param x number
---@param y number
---@param z? number
---@return Point
function M:__alloc(x, y, z)
    return M.创建自坐标(x, y, z)
end

---@private
M.map = {}

---@param res_id integer
---@return Point
function M.从场景id获取(res_id)
    if not M.map[res_id] then
        local py_point = GameAPI.get_point_by_res_id(res_id)
        local point = M.从handle获取(py_point)
        point.res_id = res_id
        M.map[res_id] = point
    end
    return M.map[res_id]
end

---根据py对象创建点
---@param py_point Point.HandleType
---@return Point
function M.从handle获取(py_point)
    local point = New "Point" (py_point)
    return point
end

y3.py_converter.register_type_alias("py.Point", "Point")
y3.py_converter.register_py_to_lua("py.Point", M.从handle获取)
y3.py_converter.register_lua_to_py("py.Point", function(lua_value)
    return lua_value.handle
end)
y3.py_converter.register_py_to_lua('py.Vector3', M.从handle获取)
y3.py_converter.register_lua_to_py('py.Vector3', function(lua_value)
    return lua_value.handle
end)

---点的x坐标
---@return number
function M:获取x()
    if not self.x then
        self.x = GlobalAPI.get_fixed_coord_index(self.handle, 0):float()
    end
    return self.x
end

---点的y坐标
---@return number
function M:获取y()
    if not self.y then
        self.y = GlobalAPI.get_fixed_coord_index(self.handle, 2):float()
    end
    return self.y
end

---点的z坐标
---@return number
function M:获取z()
    if not self.z then
        self.z = GlobalAPI.get_fixed_coord_index(self.handle, 1):float()
    end
    return self.z
end

---@return Point
function M:get_point()
    return self
end

-- 移动点
---@param x number?
---@param y number?
---@param z number?
---@return Point
function M:移动(x, y, z)
    local nx = self:获取x() + (x or 0)
    local ny = self:获取y() + (y or 0)
    local nz = self:获取z() + (z or 0)
    return M.创建自坐标(nx, ny, nz)
end

---坐标转化为点
---@param x number 点X坐标
---@param y number 点Y坐标
---@param z? number 点Z坐标
---@return Point
function M.创建自坐标(x, y, z)
    local py_point = GlobalAPI.coord_to_point(Fix32(x), Fix32(y), Fix32(z or 0))
    -- TODO 见问题2
    ---@diagnostic disable-next-line: param-type-mismatch
    local p = M.从handle获取(py_point)
    p.x = x
    p.y = y
    p.z = z or 0
    return p
end


---点向方向偏移
---@param point Point 点
---@param direction number 偏移方向点
---@param offset number 偏移量
---@return Point
function M.向方向偏移(point, direction, offset)
    local py_point = GlobalAPI.get_point_offset_vector(point.handle, Fix32(direction), Fix32(offset))
    -- TODO 见问题2
    ---@diagnostic disable-next-line: param-type-mismatch
    return M.从handle获取(py_point)
end

---路径中的点
---@param path table 目标路径
---@param index integer 索引
---@return Point
function M.获取路径中的点(path, index)
    local py_point = GlobalAPI.get_point_in_route(path.handle, index)
    return M.从handle获取(py_point)
end

-- 获取与另一个点的方向
---@param other Point
---@return number
function M:获取与点的方向(other)
    -- TODO 见问题2
    ---@diagnostic disable-next-line: param-type-mismatch
    return GameAPI.get_points_angle(self.handle, other.handle):float()
end

-- 获取与另一个点的距离
---@param other Point
---@return number
function M:获取与点的距离(other)
    -- TODO 见问题2
    ---@diagnostic disable-next-line: param-type-mismatch
    return GameAPI.get_points_dis(self.handle, other.handle):float()
end

--获取圆形范围内的随机点
function M:get_random_point(radius)
    local p = GameAPI.get_random_point_in_circular(self.handle, Fix32(radius))
    ---@diagnostic disable-next-line: param-type-mismatch
    return M.从handle获取(p)
end

---@param tostring文本 string
---@return self
function M.创建自字符串(tostring文本)
    local 坐标数组 = 字符串.分割(字符串.取右边文本(tostring文本, "|"), ",")
    return M.创建自坐标(到数值(坐标数组[1]), 到数值(坐标数组[2]), 到数值(坐标数组[3]))
end

return M
