--物品
---@class Item
---@field handle py.Item
---@field phandle py.Item
---@field id py.ItemID
---@field package _removed_by_py? boolean
---@overload fun(id: py.ItemID, py_item: py.Item): self
local M = Class 'Item'

M.type = 'item'

---@class Item: Storage
Extends('Item', 'Storage')
---@class Item: GCHost
Extends('Item', 'GCHost')
---@class Item: CustomEvent
Extends('Item', 'CustomEvent')
---@class Item: ObjectEvent
Extends('Item', 'ObjectEvent')
---@class Item: KV
Extends('Item', 'KV')

function M:__tostring()
    return string.format('{item|%s|%s}'
    , self:获取名称()
    , self.handle
    )
end

---@param id py.ItemID
---@param py_item py.Item # py层的道具实例
---@return Item # 返回在lua层初始化后的lua层道具实例
function M:__init(id, py_item)
    self.id      = id
    self.handle  = py_item
    self.phandle = y3.py_proxy.wrap(py_item)
    return self
end

function M:__del()
    M.ref_manager:remove(self.id)
    y3.py_proxy.kill(self.phandle)
    if self._removed_by_py then
        return
    end
    self.phandle:api_remove()
end

---@package
---@param id py.ItemID
---@return Item?
M.ref_manager = New 'Ref' ('Item', function(id)
    local py_item = GameAPI.get_item(id)
    if not py_item then
        return nil
    end
    return New 'Item' (id, py_item)
end)

---通过py层的技能实例获取lua层的道具实例
---@param  py_item py.Item py层的道具实例
---@return Item? # 返回在lua层初始化后的lua层道具实例
function M.获取于hd(py_item)
    if not py_item then
        return nil
    end
    local id = y3.py_proxy.wrap(py_item):api_get_id() or 0
    return M.获取于id(id)
end

y3.py_converter.register_py_to_lua('py.Item', M.获取于hd)
y3.py_converter.register_lua_to_py('py.Item', function(lua_value)
    return lua_value.handle
end)

-- 通过id获取lua层的道具实例
---@param id py.ItemID
---@return Item # 返回在lua层初始化后的lua层道具实例
function M.获取于id(id)
    local item = M.ref_manager:get(id)
    return item
end

y3.py_converter.register_py_to_lua('py.ItemID', M.获取于id)

y3.游戏:事件('物品-移除', function(trg, data)
    data.触发物品._removed_by_py = true
    data.触发物品:移除()
end)

---是否存在
---@return boolean is_exist 是否存在
function M:是否存在()
    return GameAPI.item_is_exist(self.handle)
end

-- 获取唯一ID
---@return integer
function M:获取ID()
    return self.id
end

---存在标签
---@param tag string 删除标签
---@return boolean is_has_tag 是否有标签
function M:是否存在标签(tag)
    return self.phandle:api_has_tag(tag) or false
end

---是否在场景中
---@return boolean is_in_scene 是否在场景中
function M:是否在场景中()
    if not self:是否存在() then
        return false
    end
    return self.phandle:api_is_in_scene() or false
end

---物品在物品栏
---@return boolean is_in_bar 是否在物品栏
function M:是否在物品栏()
    return self.phandle:api_is_in_bar() or false
end

---物品在背包栏
---@return boolean is_in_bag 是否在背包栏
function M:是否在背包栏()
    return self.phandle:api_is_in_pkg() or false
end

---遍历物品的单位属性
---@return string[] keys 属性key
function M:获取所有单位属性()
    -- 去掉首尾的方括号
    local tmp = tostring(GameAPI.iter_unit_attr_of_item(self.handle)):sub(2, -2)
    local result = {}
    for match in tmp:gmatch("'([^']+)'") do
        table.insert(result, match)
    end
    return result
end

---遍历物品类型的单位属性
---@param item_key py.ItemKey 物品类型
---@return string[] keys 属性key
function M.获取所有单位属性_从类型(item_key)
    -- 去掉首尾的方括号
    local tmp = tostring(GameAPI.iter_unit_attr_of_item_name(item_key)):sub(2, -2)
    local result = {}
    for match in tmp:gmatch("'([^']+)'") do
        table.insert(result, match)
    end
    return result
end

---删除物品
function M:移除()
    Delete(self)
end

---丢弃物品到点
---@param point Point 目标点
---@param count integer 丢弃数量
function M:丢弃到点(point, count)
    self.phandle:api_drop_self(point.handle, count)
end

---移动到点
---@param point Point 点
function M:移动到点(point)
    -- TODO 见问题2
    ---@diagnostic disable-next-line: param-type-mismatch
    self.phandle:api_transmit(point.handle)
end

---设置物品的名称
---@param name string 名字
function M:设置名称(name)
    self.phandle:set_name(name)
end

---设置物品的描述
---@param description string 描述
function M:设置描述(description)
    self.phandle:api_set_desc(description)
end

---设置物品的图标
---@param picture_id py.Texture 图片id
function M:设置图标(picture_id)
    self.phandle:api_set_item_icon(picture_id)
end

---获取物品的图标
---@return py.Texture
function M:获取图标()
    return self.phandle:api_get_item_icon() or 0
end

---设置所属玩家
---@param player Player 所属玩家
function M:设置所属玩家(player)
    self.phandle:api_set_creator(player.handle)
end

---设置等级
---@param level integer 等级
function M:设置等级(level)
    self.phandle:api_set_level(level)
end

---设置充能数
---@param charge integer 充能数
function M:设置充能数(charge)
    self.phandle:api_set_charge_cnt(charge)
end

---增加充能数
---@param charge integer 充能数
function M:增加充能数(charge)
    self.phandle:api_add_charge(charge)
end

---设置最大充能数
---@param charge integer 最大充能数
function M:设置最大充能数(charge)
    self.phandle:api_set_max_charge(charge)
end

---设置堆叠数
---@param stack integer 堆叠数
function M:设置堆叠数(stack)
    self.phandle:api_set_stack_cnt(stack)
end

---增加堆叠数
---@param stack integer 堆叠数
function M:增加堆叠数(stack)
    self.phandle:api_add_stack(stack)
end

---设置属性
---@param attr_name string 属性名
---@param value number 属性值
---@param attr_type string 属性类型
function M:设置_单位属性(attr_name, value, attr_type)
    self.phandle:api_set_attr(attr_type, attr_name, value)
end

---设置基础属性
---@param key string 属性key
---@param value number 属性值
function M:设置基础属性(key, value)
    self.phandle:api_set_attr('ATTR_BASE', key, value)
end

---增加基础属性
---@param key string 属性key
---@param value number 属性值
function M:增加基础属性(key, value)
    self.phandle:api_change_attr('ATTR_BASE', key, value)
end

---获取物品的基础属性
---@param key string 属性key
---@return number
function M:获取基础属性(key)
    return self.phandle:api_get_attr('ATTR_BASE', key):float()
end

---设置增益属性
---@param key string 属性key
---@param value number 属性值
function M:设置增益属性(key, value)
    self.phandle:api_set_attr('ATTR_BONUS', key, value)
end

---增加增益属性
---@param key string 属性key
---@param value number 属性值
function M:增加增益属性(key, value)
    self.phandle:api_change_attr('ATTR_BONUS', key, value)
end

---获取物品的增益属性
---@param key string 属性key
---@return number
function M:获取增益属性(key)
    return self.phandle:api_get_attr('ATTR_BONUS', key):float()
end
---设置生命值
---@param value number 生命值
function M:设置生命值(value)
    self.phandle:api_set_hp(value)
end

---给物品添加被动技能
---@param ability_id py.AbilityKey 技能id
---@param level integer 等级
function M:添加被动技能(ability_id, level)
    self.phandle:api_item_add_passive_ability(ability_id, level)
end

---设置丢弃状态
---@param dropable boolean 状态
function M:设置是否可丢弃(dropable)
    self.phandle:api_set_droppable(dropable)
end

---添加标签
---@param tag string 标签
function M:添加标签(tag)
    self.phandle:api_add_tag(tag)
end

---@param tag string 标签
function M:移除标签(tag)
    self.phandle:api_remove_tag(tag)
end

---设置物品可否出售
---@param state boolean 是否可出售
function M:设置是否可出售(state)
    self.phandle:api_set_sale_state(state)
end

---设置物品缩放
---@param scale number 缩放
function M:设置缩放(scale)
    self.phandle:api_set_scale(scale)
end

--设置物品可见性
---@param is_visible boolean # 是否可见
function M:设置是否可见(is_visible)
    self.phandle:api_set_item_visible(is_visible)
end

---设置物品朝向
---@param facing number 朝向
function M:设置朝向(facing)
    self.phandle:api_set_face_angle(facing)
end

---获取物品类型id
---@return py.ItemKey key 类型
function M:获取物编ID()
    return self.phandle:api_get_key() or 0
end

---设置物品商品售价
---@param id py.ItemKey 物品id
---@param player_attr_name py.RoleResKey 玩家属性
---@param price number 价格
function M.设置出售价格(id, player_attr_name, price)
    GameAPI.set_item_buy_price(id, player_attr_name, price)
end

---物品持有者
---@return Unit? owner 持有者
function M:获取拥有者_单位()
    if not IsValid(self) then
        return nil
    end
    local py_owner = self.phandle:api_get_owner()
    if not py_owner then
        return nil
    end
    return y3.单位.从handle获取(py_owner)
end

---物品所在点
---@return Point position 物品所在点
function M:获取所在点()
    local py_point = self.phandle:api_get_position()
    -- TODO 见问题2
    ---@diagnostic disable-next-line: param-type-mismatch
    return y3.点.从handle获取(py_point)
end

---物品堆叠数
---@return integer stacks 堆叠数
function M:获取堆叠数()
    return self.phandle:api_get_stack_cnt() or 0
end

---物品充能数
---@return integer charges 充能数
function M:获取充能数()
    return self.phandle:api_get_charge_cnt() or 0
end

---获取最大充能数
---@return integer max_charge 最大充能数
function M:获取最大充能数()
    return self.phandle:api_get_max_charge() or 0
end

---获取物品等级
---@return integer level 物品等级
function M:获取等级()
    return self.phandle:api_get_level() or 0
end

---获取物品的生命值
---@return number hp 物品的生命值
function M:获取生命值()
    return self.phandle:api_get_hp():float()
end

---获取物品名
---@return string name 物品名字
function M:获取名称()
    return self.phandle:get_name() or ''
end

---获取物品描述
---@return string description 物品描述
function M:获取描述()
    return self.phandle:api_get_desc() or ''
end

---获取物品缩放
---@return number scale 物品缩放
function M:获取缩放()
    return self.phandle:api_get_scale():float()
end

---获取物品的朝向
---@return number angel 朝向
function M:获取朝向()
    return self.phandle:api_get_face_angle():float()
end

---获取物品的主动技能
---@return Ability? ability 主动技能
function M:获取主动技能()
    local py_ability = self.phandle:api_get_positive_ability()
    if not py_ability then
        return nil
    end
    return y3.技能.获取于HD(py_ability)
end

---获取物品的被动技能
---@param index integer
---@return Ability? ability 被动技能
function M:获取被动技能(index)
    local py_ability = self.phandle:api_get_passive_ability(index)
    if not py_ability then
        return nil
    end
    return y3.技能.获取于HD(py_ability)
end

---获取物品在单位身上的格子位置
---@return integer index 格子位置
function M:获取槽位索引()
    if not self.phandle:api_get_owner() then
        return -1
    end
    return self.phandle:api_get_item_slot_idx() or -1
end

---获取物品的拥有玩家
---@return Player? player 玩家
function M:获取拥有者_玩家()
    if not IsValid(self) then
        return nil
    end
    local py_player = self.phandle:api_get_creator()
    if not py_player then
        return nil
    end
    return y3.玩家.从句柄获取(py_player)
end

---获取物品在单位身上的背包槽类型
---@return py.SlotType 背包槽类型
function M:获取槽位类型()
    if not self.phandle:api_get_owner() then
        return -1
    end
    return self.phandle:api_get_item_slot_type() or -1
end

--------------------------------------------------------类的方法--------------------------------------------------------

---检查物品类型前置条件
---@param player Player 玩家
---@param item_key py.ItemKey 物品类型ID
---@return boolean
function M.判断是否符合前置条件(player, item_key)
    return GameAPI.check_item_key_precondition(player.handle, item_key)
end

---创建物品到点
---@param point Point 点
---@param item_key py.ItemKey 道具类型
---@param player? Player 玩家
---@return Item
function M.创建到点(point, item_key, player)
    if not player then
        player = y3.玩家(31)
    end
    local py_item = GameAPI.create_item_by_id(point.handle, item_key, player.handle)
    return M.获取于hd(py_item) --[[@as Item]]
end

---获取物品购买售价
---@param item_key py.ItemKey 类型
---@param key y3.Const.PlayerAttr | string # 玩家属性
---@return number price 价格
function M.获取购买价格(item_key, key)
    key = y3.const.PlayerAttr[key] or key
    ---@cast key py.RoleResKey
    return GameAPI.get_item_buy_price(item_key, key):float()
end

---获取物品出售售价
---@param item_key py.ItemKey 类型
---@param key y3.Const.PlayerAttr | string # 玩家属性
---@return number price 价格
function M.获取出售价格(item_key, key)
    key = y3.const.PlayerAttr[key] or key
    ---@cast key py.RoleResKey
    return GameAPI.get_item_sell_price(item_key, key):float()
end

---获得区域内所有物品
---@param area Area 区域
---@return ItemGroup
function M.获取区域内所有物品(area)
    local py_item_group = GameAPI.get_item_group_in_area(area.handle)
    return y3.物品组.create_lua_item_group_from_py(py_item_group)
end

---获取物品类型名
---@param item_key py.ItemKey 物品类型
---@return string
function M.获取类型的名称(item_key)
    return GameAPI.get_item_conf_name(item_key)
end

---获取物品类型的icon的图片id
---@param item_key py.ItemKey 物品类型
---@return integer
function M.类型获取图片(item_key)
    return GameAPI.get_icon_id_by_item_type(item_key)
end

---获取物品类型的描述
---@param item_key py.ItemKey 物品类型
---@return string
function M.类型获取描述(item_key)
    return GameAPI.get_item_desc_by_type(item_key)
end

---获取物品模型
---@return py.ModelKey model_key 模型类型
function M:获取模型()
    return self.phandle:api_get_item_model() or 0
end

---获取物品类型的模型
---@param item_key py.ItemKey 物品类型
---@return py.ModelKey model_key 模型类型
function M.类型获取模型(item_key)
    return GameAPI.api_get_item_type_model(item_key)
end

--物品类型合成所需的物品类型数量
---@param item_key py.ItemKey
---@param comp_item_key py.ItemKey
---@return integer
function M.类型获取合成所需类型的数量(item_key, comp_item_key)
    return GameAPI.api_get_value_of_item_name_comp_mat(item_key, comp_item_key)
end

--物品类型合成所需的玩家属性数量
---@param item_key py.ItemKey
---@param role_res_key py.RoleResKey
---@return number
function M.类型获取合成所需玩家属性数量(item_key, role_res_key)
    return GameAPI.api_get_value_of_item_name_comp_res(item_key, role_res_key)
end

---获取物品类型的基础属性
---@param key string 属性key
---@param item_key py.ItemKey 物品类型
---@return number
function M.类型获取基础属性(item_key, key)
    ---@diagnostic disable-next-line: return-type-mismatch
    return GameAPI.api_get_attr_of_item_key(item_key, 'ATTR_BASE', key)
end

---物品类型是否存在标签
---@param tag string 标签
---@param item_key py.ItemKey 物品类型
---@return boolean is_has_tag 是否有标签
function M.类型是否存在标签(tag, item_key)
    return GameAPI.item_key_has_tag(item_key, tag)
end

--获取物品的所有标签
---@param item_key py.ItemKey
---@return string[]
function M.get_tags_by_key(item_key)
    local utags = y3.物编.item[item_key].data.tags
    local tags = y3.helper.unpack_list(utags)
    return tags
end

return M
