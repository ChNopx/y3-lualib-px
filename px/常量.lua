---@enum 键盘按类型
键盘按类型 = {
    NONE = 0x00,
    ESC = 0x01,
    数字_1 = 0x02,
    数字_2 = 0x03,
    数字_3 = 0x04,
    数字_4 = 0x05,
    数字_5 = 0x06,
    数字_6 = 0x07,
    数字_7 = 0x08,
    数字_8 = 0x09,
    数字_9 = 0x0A,
    数字_0 = 0x0B,
    减号 = 0x0C,
    等号 = 0x0D,
    Backspace = 0x0E,
    Tab = 0x0F,
    Q = 0x10,
    W = 0x11,
    E = 0x12,
    R = 0x13,
    T = 0x14,
    Y = 0x15,
    U = 0x16,
    I = 0x17,
    O = 0x18,
    P = 0x19,
    左_中括号 = 0x1A,
    右_中括号 = 0x1B,
    Enter = 0x1C,
    左_Ctrl = 0x1D,
    A = 0x1E,
    S = 0x1F,
    D = 0x20,
    F = 0x21,
    G = 0x22,
    H = 0x23,
    J = 0x24,
    K = 0x25,
    L = 0x26,
    分号 = 0x27, --;
    单引号 = 0x28,
    重音符 = 0x29, --`
    左_Shift = 0x2A,
    右_斜杠 = 0x2B,
    Z = 0x2C,
    X = 0x2D,
    C = 0x2E,
    V = 0x2F,
    B = 0x30,
    N = 0x31,
    M = 0x32,
    逗号 = 0x33,
    点 = 0x34,
    左_斜杠 = 0x35,
    右_Shift = 0x36,
    小键盘_星号 = 0x37,
    左_Alt = 0x38,
    Space = 0x39,
    CAPSLOCK = 0x3A,
    F1 = 0x3B,
    F2 = 0x3C,
    F3 = 0x3D,
    F4 = 0x3E,
    F5 = 0x3F,
    F6 = 0x40,
    F7 = 0x41,
    F8 = 0x42,
    F9 = 0x43,
    F10 = 0x44,
    Pause = 0x45,
    Scroll_Lock = 0x46,
    小键盘7 = 0x47,
    小键盘8 = 0x48,
    小键盘9 = 0x49,
    小键盘 = 0x4A,
    小键盘4 = 0x4B,
    小键盘5 = 0x4C,
    小键盘6 = 0x4D,
    小键盘_加号 = 0x4E,
    小键盘1 = 0x4F,
    小键盘2 = 0x50,
    小键盘3 = 0x51,
    小键盘0 = 0x52,
    小键盘_点 = 0x53,
    F11 = 0x57,
    F12 = 0x58,
    小键盘Enter = 0x9C,
    右Ctrl = 0x9D,
    小键盘_逗号 = 0xB3,
    小键盘_左斜杠 = 0xB5,
    系统重启 = 0xB7,
    右_Alt = 0xB8,
    NumLock = 0xC5,
    Home = 0xC7,
    方向键_上 = 0xC8,
    PageUp = 0xC9,
    方向键_左 = 0xCB,
    方向键_右 = 0xCD,
    End = 0xCF,
    方向键_下 = 0xD0,
    PageDown = 0xD1,
    Insert = 0xD2,
    Delete = 0xD3,
    左Win = 0xDB,
    右Win = 0xDC,
    应用 = 0xDD,
}

---@enum 控件界面属性
控件属性 = {
    文本 = "text_bind",
    最大值 = "max_value_bind",
    当前值 = "current_value_bind",
}
---@enum 控件类型
控件类型 = {
    物品 = "物品",
    按钮 = "按钮",
    富文本 = "富文本",
    文本 = "文本",
    图片 = "图片",
    进度条 = "进度条",
    模型 = "模型",
    空节点 = "空节点",
    标签页 = "标签页",
    设置 = "设置",
    列表 = "列表",
    滑动条 = "滑动条",
    聊天 = "聊天",
    轮播图 = "轮播图",
    语音开关 = "语音开关",
    输入框 = "输入框",
    地图 = "地图",
    技能按钮 = "技能按钮",
    魔法效果 = "魔法效果",
    序列帧 = "序列帧",
}

---@enum 镜头移动类型
镜头移动类型 = {
    匀速 = 0,
    匀加速 = 1,
    匀减速 = 2
}

---@enum 镜头角度类型
镜头角度类型 = {
    俯视角 = 1,
    滚角 = 2,
    导航角 = 3
}
