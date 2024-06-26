--玩家组
---@class PlayerGroup
---@field handle py.RoleGroup
---@field private _removed? boolean
---@overload fun(py_player_group?: py.RoleGroup): self
local M = Class 'PlayerGroup'

M.type = 'player_group'

---@private
function M:__tostring()
    return string.format('{PlayerGroup|%s}'
    , self.handle
    )
end

---@private
---@param py_player_group py.RoleGroup
---@return self
function M:__init(py_player_group)
    self.handle = py_player_group
    return self
end

function M:__len()
    return self:获取玩家数量()
end

---@param py_role_group py.RoleGroup
---@return PlayerGroup
function M.从句柄获取(py_role_group)
    local player_group = New 'PlayerGroup' (py_role_group)
    return player_group
end

y3.py_converter.register_type_alias('py.RoleGroup', 'PlayerGroup')
y3.py_converter.register_py_to_lua('py.RoleGroup', M.从句柄获取)
y3.py_converter.register_lua_to_py('py.RoleGroup', function(lua_value)
    return lua_value.handle
end)

--创建空玩家组
---@return PlayerGroup
function M.创建空玩家组()
    return M.从句柄获取(GameAPI.create_role_group())
end

--获取玩家组中玩家数量
---@return integer
function M:获取玩家数量()
    return python_len(self.handle)
end

--将玩家组转换为Lua的玩家数组
---@return Player[]
function M:到数组()
    local lua_table = {}
    for i = 1, python_len(self.handle) do
        local iter_player = python_index(self.handle, i - 1)
        table.insert(lua_table, y3.玩家.从id获取(iter_player))
    end
    return lua_table
end

--添加玩家
---@param player Player 玩家
function M:添加玩家(player)
    GameAPI.add_role_to_group(player.handle, self.handle)
end

--移除玩家
---@param player Player 玩家
function M:移除玩家(player)
    GameAPI.rem_role_from_group(player.handle, self.handle)
end

--清空玩家组
---@return self
function M:清空()
    GlobalAPI.clear_group(self.handle)
    return self
end

---@private
M.ALL_PLAYERS = M.从句柄获取(GameAPI.get_all_role_ids())

---获取所有玩家
---@return PlayerGroup player_group
function M.获取所有玩家()
    return M.ALL_PLAYERS
end

---阵营內所有玩家
---@param camp py.Camp 阵营
---@return PlayerGroup player_group
function M.获取阵营内所有玩家(camp)
    local py_player_group = GameAPI.get_role_ids_by_camp(camp)
    return M.从句柄获取(py_player_group)
end

---玩家的所有敌对玩家
---@param player Player 玩家
---@return PlayerGroup player_group
function M.获取所有敌对玩家(player)
    local py_player_group = GameAPI.get_enemy_ids_by_role(player.handle)
    return M.从句柄获取(py_player_group)
end

---玩家的所有同盟玩家
---@param player Player 玩家
---@return PlayerGroup player_group
function M.获取所有同盟玩家(player)
    local py_player_group = GameAPI.get_ally_ids_by_role(player.handle)
    return M.从句柄获取(py_player_group)
end

---获取所有胜利的玩家
---@return PlayerGroup player_group
function M.获取所有胜利玩家()
    local py_player_group = GameAPI.get_victorious_role_ids()
    return M.从句柄获取(py_player_group)
end

---获取所有失败的玩家
---@return PlayerGroup player_group
function M.获取所有失败玩家()
    local py_player_group = GameAPI.get_defeated_role_ids()
    return M.从句柄获取(py_player_group)
end

---所有非中立玩家
---@return PlayerGroup player_group
function M.获取所有非中立玩家()
    local py_player_group = GameAPI.get_role_ids_by_type(1)
    return M.从句柄获取(py_player_group)
end

---@return PlayerGroup player_group
function M.获取所有_非中立_在线玩家()
    local 玩家组 = M.获取所有非中立玩家()
    玩家组:遍历(function(索引, 遍历到的玩家)
        if 遍历到的玩家:获取_游戏_状态() ~= y3.const.玩家游戏状态.游戏中 then
            玩家组:移除玩家(遍历到的玩家)
        end
    end)
    return 玩家组
end

---@param 回调 fun(索引:integer,遍历到的玩家:Player)
function M:遍历(回调)
    for index, value in ipairs(self:到数组()) do
        回调(index, value)
    end
end

---@param 控件handle string
---@param 文本 string
function M:设置控件文本(控件handle, 文本)
    self:遍历(function(索引, 遍历到的玩家)
        y3.控件.获取于HD(遍历到的玩家, 控件handle):设置文本(文本)
    end)
end

---@param 控件handle string
---@param 是否可见 boolean
function M:设置控件是否可见(控件handle, 是否可见)
    self:遍历(function(索引, 遍历到的玩家)
        y3.控件.获取于HD(遍历到的玩家, 控件handle):设置是否可见(是否可见)
    end)
end

return M
