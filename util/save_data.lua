--存档
---@class SaveData
local M = {}

---@private
M.table_cache = setmetatable({}, { __mode = 'k' })

-- 获取玩家的存档数据（布尔）
---@param player Player
---@param slot integer
---@return boolean
function M.读取布尔值(player, slot)
    return player.handle:get_save_data_bool_value(slot) or false
end

-- 保存玩家的存档数据（布尔）
---@param player Player
---@param slot integer
---@param value boolean
function M.保存布尔值(player, slot, value)
    player.handle:set_save_data_bool_value(slot, value)
end

-- 获取玩家的存档数据（整数）
---@param player Player
---@param slot integer
---@return integer
function M.读取整数值(player, slot)
    return player.handle:get_save_data_int_value(slot) or 0
end

-- 保存玩家的存档数据（整数）
---@param player Player
---@param slot integer
---@param value integer
function M.保存整数值(player, slot, value)
    player.handle:set_save_data_int_value(slot, value)
end

-- 获取玩家的存档数据（实数）
---@param player Player
---@param slot integer
---@return number
function M.读取实数值(player, slot)
    return player.handle:get_save_data_fixed_value(slot):float()
end

-- 保存玩家的存档数据（实数）
---@param player Player
---@param slot integer
---@param value number
function M.保存实数值(player, slot, value)
    player.handle:set_save_data_fixed_value(slot, Fix32(value))
end

-- 获取玩家的存档数据（字符串）
---@param player Player
---@param slot integer
---@return string
function M.读取字符串(player, slot)
    return player.handle:get_save_data_str_value(slot) or ''
end

-- 保存玩家的存档数据（字符串）
---@param player Player
---@param slot integer
---@param value string
function M.保存字符串(player, slot, value)
    player.handle:set_save_data_str_value(slot, value)
end

-- 获取玩家的存档数据（表）
---@param player Player
---@param slot integer
---@param disable_cover boolean # 是否禁用覆盖，必须和存档设置中的一致
---@return table
function M.读取玩家表格数据(player, slot, disable_cover)
    if disable_cover then
        return M.load_table_with_cover_disable(player, slot)
    else
        return M.load_table_with_cover_enable(player, slot)
    end
end

-- 保存玩家的存档数据（表），存档设置中必须使用允许覆盖模式
---@param player Player
---@param slot integer
---@param t table
function M.保存玩家表格数据(player, slot, t)
    assert(type(t) == 'table', '数据类型必须是表！')
    t = y3.proxy.raw(t) or t
    player.handle:set_save_data_table_value(slot, t)
    M.upload_save_data(player)
end

---@private
---@type table<Player, LocalTimer>
M.timer_map = {}

---@private
---@param player Player
function M.upload_save_data(player)
    local timer = M.timer_map[player]
    if timer then
        return
    end
    M.timer_map[player] = y3.l计时器.wait(0.1, function()
        M.timer_map[player] = nil
        player.handle:upload_save_data()
        -- log.info('自动保存存档：', player)
    end)
end

---@private
---@param player Player
---@param slot integer
---@return table
function M.load_table_with_cover_enable(player, slot)
    local save_data = player.handle:get_save_data_table_value(slot) or {}
    local create_proxy

    ---@type Proxy.Config
    local proxy_config = {
        anySetter = function(self, raw, key, value, config, custom)
            if custom >= 3 and type(value) == 'table' then
                error('存档表最多只支持3层嵌套')
            end
            if type(key) ~= 'string'
                and math.type(key) ~= 'integer' then
                error('存档的key必须是字符串或者整数')
            end
            local vtype = type(value)
            if vtype ~= 'nil'
                and vtype ~= 'string'
                and vtype ~= 'boolean'
                and vtype ~= 'number'
                and vtype ~= 'table' then
                error('存档的值只能是基础类型或表')
            end
            if vtype == 'table' and y3.proxy.raw(value) then
                value = y3.proxy.raw(value)
            end
            raw[key] = value

            M.保存玩家表格数据(player, slot, save_data)
        end,
        anyGetter = function(self, raw, key, config, custom)
            local value = raw[key]
            if type(value) == 'table' then
                return create_proxy(value, custom + 1)
            end
            return value
        end,
    }

    function create_proxy(raw, level)
        if M.table_cache[raw] then
            return M.table_cache[raw]
        end
        local v = y3.proxy.new(raw, proxy_config, level)
        M.table_cache[raw] = v
        return v
    end

    local proxy_save_data = create_proxy(save_data, 0)

    return proxy_save_data
end

---@private
---@param player Player
---@param slot integer
---@return table
function M.load_table_with_cover_disable(player, slot)
    local save_data = player.handle:get_save_data_table_value(slot)
    local create_proxy
    local update_delay = 0.1
    local update_timer

    local function update_save_data()
        if update_timer then
            return
        end
        update_timer = y3.l计时器.wait(update_delay, function()
            update_timer = nil
            player.handle:upload_save_data()
            log.info('自动保存存档：', player, slot)
        end)
    end

    local function unpack_path(key, path)
        local key1 = path and path[1]
        if not key1 then
            key1 = key
            key = ''
        end
        local key2 = path and path[2]
        if not key2 then
            key2 = key
            key = ''
        end
        local key3 = path and path[3] or key
        return key1, key2, key3
    end

    local function set_value(key, value, path)
        local key1, key2, key3 = unpack_path(key, path)
        player.handle:set_save_table_key_value(slot
            , key1
            , value
            , key2
            , key3
            , ''
        )
        update_save_data()
    end

    local function get_value(key, path)
        local key1, key2, key3 = unpack_path(key, path)
        return player.handle:get_save_table_key_value(slot
            , key1
            , key2
            , key3
            ---@diagnostic disable-next-line: param-type-mismatch
            , nil
            , ''
        )
    end

    ---@type Proxy.Config
    local proxy_config = {
        anySetter = function (self, raw, key, value, config, path)
            if type(key) ~= 'string'
                and math.type(key) ~= 'integer' then
                error('表的key必须是字符串或者整数')
            end
            local vtype = type(value)
            if vtype == 'table' then
                if next(value) ~= nil then
                    error('禁止覆盖模式下非空表不能作为存档的值')
                end
                if path and #path >= 3 then
                    error('存档表最多只支持3层嵌套')
                end
                if y3.proxy.raw(value) then
                    value = y3.proxy.raw(value)
                end
            elseif vtype ~= 'nil'
            and    vtype ~= 'string'
            and    vtype ~= 'boolean'
            and    vtype ~= 'number' then
                error('存档的值只能是基础类型')
            end

            set_value(key, value, path)
        end,
        anyGetter = function (self, raw, key, config, path)
            local value = get_value(key, path)
            if type(value) == 'table' then
                local new_path = path and { table.unpack(path) } or {}
                new_path[#new_path+1] = key
                return create_proxy(value, new_path)
            end

            return value
        end,
    }

    function create_proxy(raw, path)
        if M.table_cache[raw] then
            return M.table_cache[raw]
        end
        local v = y3.proxy.new(raw, proxy_config, path)
        M.table_cache[raw] = v
        return v
    end

    local proxy_save_data = create_proxy(save_data)

    return proxy_save_data
end

return M
