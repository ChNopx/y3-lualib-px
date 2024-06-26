--施法实例
--
--会在施法相关的事件中传递
---@class Cast
---@field package ability Ability
---@field package cast_id integer
---@overload fun(ability: Ability, cast_id: integer): self
local M = Class 'Cast'

---@class Cast: GCHost
Extends('Cast', 'GCHost')
---@class Cast: Storage
Extends('Cast', 'Storage')

---@param ability Ability
---@param cast_id integer
---@return self
function M:__init(ability, cast_id)
    self.ability = ability
    self.cast_id = cast_id
    return self
end

function M:__tostring()
    return string.format('{cast|%d} @ %s'
    , self.cast_id
    , self.ability
    )
end

---@class Ability
---@field package _castRef? Ref

---@param ability Ability
---@param cast_id integer
---@return Cast
function M.get(ability, cast_id)
    if not ability._castRef then
        ability._castRef = New 'Ref' ('Cast', function(id)
            return New 'Cast' (ability, id)
        end)
    end
    return ability._castRef:get(cast_id)
end

y3.游戏:事件('施法-结束', function(trg, data)
    local id = data.cast.cast_id
    local ability = data.cast.ability
    local castRef = ability._castRef
    if not castRef then
        return
    end
    castRef:remove(id)
end)

-- 获取技能
---@return Ability
function M:获取技能()
    return self.ability
end

-- 获取施法方向
---@return number
function M:获取方向()
    local angle = self.ability.handle:api_get_release_direction(self.cast_id)
    if not angle then
        return 0.0
    end
    return angle:float()
end

-- 获取施法目标物品
---@return Item?
function M:获取目标物品()
    local py_item = GameAPI.get_target_item_in_ability(self.ability.handle, self.cast_id)
    if not py_item then
        return nil
    end
    return y3.物品.获取于hd(py_item)
end

-- 获取施法目标单位
---@return Unit?
function M:获取目标单位()
    local py_unit = GameAPI.get_target_unit_in_ability(self.ability.handle, self.cast_id)
    if not py_unit then
        return nil
    end
    return y3.单位.从handle获取(py_unit)
end

-- 获取施法目标可破坏物
---@return Destructible?
function M:获取目标可破坏物()
    local py_destructible = GameAPI.get_target_dest_in_ability(self.ability.handle, self.cast_id)
    if not py_destructible then
        return nil
    end
    return y3.可破坏物.get_by_handle(py_destructible)
end

-- 获取施法目标点
---@return Point?
function M:获取目标点()
    local py_point = self.ability.handle:api_get_release_position(self.cast_id)
    if not py_point then
        return nil
    end
    return y3.点.从handle获取(py_point)
end

return M
