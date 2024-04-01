y3.游戏:事件("玩家-发送消息", function(trg, data)
    if data.str1 == "1" then
        -- 创建一个单位，令其向右直线运动1000距离
        local unit = y3.玩家(1):创建单位(134274912, y3.点(0, 0), 0)
        unit:mover_line {
            speed = 1000,
            angle = 90,
            distance = 1000,
            on_remove = function()
                unit:杀死_单位(unit)
            end
        }
    end
    if data.str1 == "2" then
        -- 创建一个单位，然后在其右侧1000距离创建一个投射物，令投射物追踪单位
        -- 投射物追踪到单位后会杀死单位
        local unit = y3.玩家(1):创建单位(134274912, y3.点(0, 0), 0)
        local dummy = y3.投射物.创建 {
            key    = 134267518,
            target = unit:获取当前所在点():移动(1000, 0),
            height = 100,
        }
        dummy:mover_target {
            target_distance = 100,
            speed = 100,
            target = unit,
            on_remove = function()
                dummy:移除()
            end,
            on_finish = function()
                unit:杀死_单位(unit)
            end
        }
    end
end)
