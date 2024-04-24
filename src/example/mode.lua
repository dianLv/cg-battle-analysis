-- 
-- 定义游戏的规则
-- 
local Mode = {}

-- 属性解释

-- 如 CAMP
-- 如 Damage_TYPES
-- act_type
Mode.CAMP = {
  [1] = "玩家",
  [2] = "对手"
}

Mode.PLAYER = {
  ["self"] = 1,
  ["oppo"] = 2
}

Mode.ACTION_TYPES = {
  [0] = "行动",
  [1] = "额外行动",
  [2] = "特殊行动"
}

Mode.DAMAGE_TYPES = {
  [0] = "", -- 一般
  [1] = "暴击",
  [2] = "闪避",
  [3] = "减伤"
}

Mode.DAMAGE_OP = {
  [1] = "增加",
  [2] = "减少"
}

-- Mode.BUFF_OP = {
--   [1] = "添加",
--   [2] = "移除"
-- }

-- Mode.OP = {
--   ['add'] = 1,
--   ['remove'] = 2,
--   ['set'] = 3
-- }

-- 属性映射
Mode.ATTRS = {
  [1] = 'hp',
  [2] = 'hp_max',
  [3] = 'energy'
}

Mode.MEMBER_TYPES = {
  [1] = 'hero',
  -- ...
}

-- FAKE_NAME
Mode.HERO_NAMES = {
  [1000] = '初心者',
  [1001] = '战士',
  [1002] = '魔法师',
  [1003] = '弓箭手',
  [1004] = '刺客',
  [1005] = '海盗'
}

Mode.BATTLE_TYPES = {
  [1] = 'PVE',
  [2] = 'PVP',
  -- ...
}

-- 函数类
function Mode.is_hero(id)
  local type = Mode.MEMBER_TYPES[id]
  return type == 'hero'
end

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

  return table.concat(str, '\n')
end

return Mode