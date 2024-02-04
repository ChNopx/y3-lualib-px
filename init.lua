pcall(function()
    LDBG = require "y3.debugger":start "127.0.0.1:12399"
end)



-- 全局方法类，提供各种全局方法
---@class Y3
y3 = {}

y3.proxy = require "y3.tools.proxy"
y3.class = require "y3.tools.class"
y3.util = require "y3.tools.utility"
y3.json = require "y3.tools.json"

pcall(function()
    y3.doctor = require "y3.tools.doctor"
end)

---@enum classType
ClassType = {}

Class     = y3.class.declare
New       = y3.class.new
---@deprecated
---@diagnostic disable-next-line: deprecated
Super     = y3.class.super
Extends   = y3.class.extends
Delete    = y3.class.delete
IsValid   = y3.class.isValid

require "y3.util.log"
y3.重载 = require "y3.tools.reload"

---@diagnostic disable-next-line: lowercase-global
include = y3.重载.include

require "y3.tools.linked_table"
y3.随机池 = require "y3.tools.pool"
require "y3.tools.gc"

require "y3.util.eca_function"
require "y3.util.trigger"
require "y3.util.event"
require "y3.util.event_manager"
require "y3.util.custom_event"
require "y3.util.ref"
require "y3.util.storage"

print = log.debug

y3.const = require "y3.game.const"
y3.math = require "y3.game.math"
y3.游戏 = require "y3.game.game"
y3.py_converter = require "y3.game.py_converter"
y3.py_event_sub = require "y3.game.py_event_subscribe"
y3.helper = require "y3.game.helper"
y3.ground = require "y3.game.ground"
y3.config = require "y3.game.config"
y3.kv = require "y3.game.kv"

y3.单位 = require "y3.object.editable_object.unit"
y3.单位组 = require "y3.object.runtime_object.unit_group"

y3.玩家 = require "y3.object.runtime_object.player"
y3.玩家组 = require "y3.object.runtime_object.player_group"

y3.场景 = require "y3.object.scene_object.scene_ui"
y3.控件 = require "y3.object.scene_object.ui"
y3.元件 = require "y3.object.scene_object.ui_prefab"

y3.技能 = require "y3.object.editable_object.ability"
y3.destructible = require "y3.object.editable_object.destructible"
y3.物品 = require "y3.object.editable_object.item"
y3.buff = require "y3.object.editable_object.buff"
y3.projectile = require "y3.object.editable_object.projectile"
y3.technology = require "y3.object.editable_object.technology"

y3.beam = require "y3.object.runtime_object.beam"
y3.item_group = require "y3.object.runtime_object.item_group"
y3.mover = require "y3.object.runtime_object.mover"
y3.particle = require "y3.object.runtime_object.particle"

y3.计时器 = require "y3.object.runtime_object.timer"
y3.projectile_group = require "y3.object.runtime_object.projectile_group"
y3.selector = require "y3.object.runtime_object.selector"
y3.cast = require "y3.object.runtime_object.cast"
y3.damage_instance = require "y3.object.runtime_object.damage_instance"
y3.heal_instance = require "y3.object.runtime_object.heal_instance"
y3.sound = require "y3.object.runtime_object.sound"

require "y3.object.runtime_object.local_player"

y3.area = require "y3.object.scene_object.area"
y3.镜头 = require "y3.object.scene_object.camera"
y3.light = require "y3.object.scene_object.light"
y3.路径 = require "y3.object.scene_object.road"
y3.点 = require "y3.object.scene_object.point"

y3.shape = require "y3.object.scene_object.shape"

y3.物编 = require "y3.util.object"
y3.ltimer = require "y3.util.local_timer"
y3.存档 = require "y3.util.save_data"
y3.dump = require "y3.util.dump"

y3.develop = {}
y3.develop.command = include "y3.develop.command"

include "y3.px.常量枚举"
include "y3.px.基础.表"
include "y3.px.基础.字符串"
include "y3.px.基础.数学"
include "y3.px.基础.工具"
require "y3.px.重载扩展"


-- TODO 给目前的Lua垃圾回收过慢的问题打个临时补丁
local function fixGC()
    local mem = collectgarbage "count"
    y3.ltimer.loop_frame(10, function()
        local new_mem = collectgarbage "count"
        local delta = new_mem - mem
        mem = new_mem
        if delta > 0 then
            collectgarbage "restart"
            collectgarbage("step", math.ceil(delta))
        end
    end)
end

fixGC()
