-- 
-- 定义游戏的规则
-- 
local Mode = {}

-- 阵营相关
Mode.CAMP_SELF = 1
Mode.Camp_OPPO = 2

Mode.CAMP_INFO = {
  [Mode.CAMP_SELF] = "玩家",
  [Mode.Camp_OPPO] = "对手"
}

Mode.ACTION_TYPE_INFO = {
  [0] = "行动",
  [1] = "额外行动",
  [2] = "特殊行动"
}

Mode.DAMAGE_TYPE_INFO = {
  [0] = "", -- 一般
  [1] = "暴击",
  [2] = "闪避",
  [3] = "减伤"
}

-- (damage/buff)op相关
Mode.OP_PLUS = 1
Mode.OP_MINUS = 2

Mode.DAMAGE_OP_INFO = {
  [Mode.OP_PLUS] = "增加",
  [Mode.OP_MINUS] = "减少"
}

Mode.BUFF_OP_INFO = {
  [Mode.OP_PLUS] = "添加",
  [Mode.OP_MINUS] = "移除"
}

Mode.ATTR_HP = 1
Mode.ATTR_HP_MAX = 2
Mode.ATTR_ENERGY = 3

-- 属性映射
Mode.ATTR_INFO = {
  [Mode.ATTR_HP] = 'hp',
  [Mode.ATTR_HP_MAX] = 'hp_max',
  [Mode.ATTR_ENERGY] = 'energy'
}

Mode.MEMBER_TYPE_HERO = 1
-- ...

-- FAKE_NAME
Mode.HERO_NAMES = {
  [1000] = '初心者',
  [1001] = '战士',
  [1002] = '魔法师',
  [1003] = '弓箭手',
  [1004] = '刺客',
  [1005] = '海盗'
}

Mode.BATTLE_TYPE_INFO = {
  [1] = 'PVE',
  [2] = 'PVP',
  -- ...
}

-- 函数类

function Mode.winner(is_win)
  if is_win then
    return '玩家胜利'
  else
    return '对手胜利'
  end
end

function Mode.help_text()
  local str = {}

  table.insert(str, '*Hero血量表示[血量/最大血量]')
  table.insert(str, '*Hero属性变化[增加/扣除:属性][表现值|实际值(->当前值)]')
  -- hp table.insert(str, '*Hero属性变化[增加/扣除:hp][表现值|实际值(->(hp/max_hp)%)]')

  return table.concat(str, '\n')
end

return Mode