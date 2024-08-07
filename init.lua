pcall(function()
    LDBG = require 'y3.debugger':start '127.0.0.1:12399'
end)

-- 全局方法类，提供各种全局方法
---@class Y3
y3         = {}

y3.version = 240705

y3.proxy   = require 'y3.tools.proxy'
y3.class   = require 'y3.tools.class'
y3.util    = require 'y3.tools.utility'
y3.json    = require 'y3.tools.json'
y3.inspect = require 'y3.tools.inspect'
y3.await   = require 'y3.tools.await'
pcall(function()
    y3.doctor = require 'y3.tools.doctor'
end)

Class        = y3.class.declare
New          = y3.class.new
Extends      = y3.class.extends
Delete       = y3.class.delete
IsValid      = y3.class.isValid
IsInstanceOf = y3.class.isInstanceOf

require 'y3.util.log'
y3.reload = require 'y3.tools.reload'
y3.sandbox = require 'y3.tools.sandbox'
y3.hash    = require 'y3.tools.SDBMHash'

---@diagnostic disable-next-line: lowercase-global
include = y3.reload.include

require 'y3.tools.linked_table'
y3.随机池 = require 'y3.tools.pool'
require 'y3.tools.gc'
require 'y3.tools.synthesis'

require 'y3.util.eca_function'
require 'y3.util.trigger'
require 'y3.util.event'
require 'y3.util.event_manager'
require 'y3.util.custom_event'
require 'y3.util.ref'
require 'y3.util.storage'
require 'y3.util.gc_buffer'

y3.const = require 'y3.game.const'
y3.数学 = require 'y3.game.math'
y3.游戏 = require 'y3.game.game'
y3.py_converter = require 'y3.game.py_converter'
y3.py_event_sub = require 'y3.game.py_event_subscribe'
y3.helper = require 'y3.game.helper'
y3.地面 = require 'y3.game.ground'
y3.config = require 'y3.game.config'
y3.kv = require 'y3.game.kv'
y3.py_proxy = require 'y3.util.py_proxy'

y3.单位 = require 'y3.object.editable_object.unit'
y3.技能 = require 'y3.object.editable_object.ability'
y3.可破坏物 = require 'y3.object.editable_object.destructible'
y3.物品 = require 'y3.object.editable_object.item'
y3.魔法效果 = require 'y3.object.editable_object.buff'
y3.投射物 = require 'y3.object.editable_object.projectile'
y3.科技 = require 'y3.object.editable_object.technology'

y3.闪电特效 = require 'y3.object.runtime_object.beam'
y3.物品组 = require 'y3.object.runtime_object.item_group'
y3.运动器 = require 'y3.object.runtime_object.mover'
y3.粒子特效 = require 'y3.object.runtime_object.particle'
y3.玩家 = require 'y3.object.runtime_object.player'
y3.玩家组 = require 'y3.object.runtime_object.player_group'
y3.计时器 = require 'y3.object.runtime_object.timer'
y3.单位组 = require 'y3.object.runtime_object.unit_group'
y3.投射物组 = require 'y3.object.runtime_object.projectile_group'
y3.选择器 = require 'y3.object.runtime_object.selector'
y3.cast = require 'y3.object.runtime_object.cast'
y3.damage_instance = require 'y3.object.runtime_object.damage_instance'
y3.heal_instance = require 'y3.object.runtime_object.heal_instance'
y3.声音 = require 'y3.object.runtime_object.sound'

require 'y3.object.runtime_object.local_player'
require 'y3.object.runtime_object.current_select'

y3.区域 = require 'y3.object.scene_object.area'
y3.镜头 = require 'y3.object.scene_object.camera'
y3.光照 = require 'y3.object.scene_object.light'
y3.路径 = require 'y3.object.scene_object.road'
y3.点 = require 'y3.object.scene_object.point'
y3.场景 = require 'y3.object.scene_object.scene_ui'
y3.控件 = require 'y3.object.scene_object.ui'
y3.元件 = require 'y3.object.scene_object.ui_prefab'
y3.形状 = require 'y3.object.scene_object.shape'

y3.物编 = require 'y3.util.object'
y3.l计时器 = require 'y3.util.local_timer'
y3.ctimer = require 'y3.util.client_timer'
y3.存档 = require 'y3.util.save_data'
y3.dump = require 'y3.util.dump'
y3.sync = require 'y3.util.sync'
y3.network = require 'y3.util.network'
y3.eca = require 'y3.util.eca_helper'
y3.base64 = require 'y3.util.base64'
y3.aes = require 'y3.util.aes'
y3.local_ui = require 'y3.util.local_ui'

pcall(function()
    require 'y3-helper.meta'
end)

y3.develop         = {}
y3.develop.command = include 'y3.develop.command'
y3.develop.arg     = require 'y3.develop.arg'
y3.develop.console = include 'y3.develop.console'
y3.develop.helper  = require 'y3.develop.helper'

pcall(function()
    if LDBG and y3.develop.arg['lua_wait_debugger'] == 'true' then
        y3.develop.wait_debugger = true
        LDBG:event 'wait'
    end
end)

--使用分代垃圾回收
GlobalAPI.api_stop_luagc_control()
collectgarbage 'restart'
collectgarbage 'generational'

--对await进行一些配置
y3.await.setErrorHandler(log.error)
y3.await.setSleepWaker(y3.l计时器.wait)

log.info('LuaLib版本：', y3.version)

require 'y3.Y3-PxEx.init'

---@diagnostic disable-next-line: missing-parameter, param-type-mismatch
y3.游戏:发起事件C('$Y3-初始化')
