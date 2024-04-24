-- 
-- 一个战斗的参考模型
-- 
local Domain  = {}

Domain.BattleReplay = {
  self_info = {},    -- 我方信息, @BattlePlayerInfo
  oppo_info = {},  -- 对手信息
  waves = {}, -- @BattleAWave
  max_waves = 0,  -- 最大波次信息
  type = '',      -- 战斗模式, pvp(...), pve(...)
  is_win = false, -- 胜负信息
  version = ''    -- mapper battle_engine version
}

-- player_info
Domain.BattlePlayerInfo = {
  name = '',
  -- ...
}

Domain.BattleAWave = {
  wave_index = 0,     -- 当前战斗索引
  init_effects = {},  -- 战斗开始阶段 @BattleTakesEffect
  rounds = {}, -- 当前战斗所有的回合信息, @BattleARound
  max_rounds = 0, -- 当前一波打了多少回合
  is_win = false, -- 攻击方获胜?
  first = false, -- 攻击方先手?
  members = {},   -- 默认的双方参战成员, @BattleMember
  final_members = {} -- 该波战斗结束时, 依旧存活的member(hero), @BattleMember
}

--在某些游戏中round
Domain.BattleARound = {
  round_index = 0, -- 当前回合的索引
  before_rounds = {}, -- 当前回合开始时, 有时候也会放到BattleAction中
  actions = {}, -- 当前回合中的行动序列
  max_actions = 0 -- 当前回合发生了多少次行动
  -- after_rounds = {}, -- 所有人都行动结束后, 一般不确定, 放BattleAction中
}

Domain.BattleAAction = {
  action_index = 0, -- 当前行动的所用, 可能还保护round,wave的index
  type = {}, -- 行动类型, 普通行动, 特殊行动, 额外行动等
  actor = {}, -- 行动者, 通过@BattleMemberLocator
  skill = 0, -- skill_id, 表示使用的技能
  before_effects = {}, -- 行动开始前, @BattleTakesEffect
  action_infos = {},  -- 行动时产生的伤害,治疗等, @BattleDamageInfo
  action_effects = {}, -- 由行动产生的效果, 表现上与action_infos同时
  after_effects = {},  -- 完成行动后，如宝可梦中的毒
  end_rounds = {}, -- 当前回合结束时(正常的行动者及其衍生行动结束)
  members_update = {},  -- 更新场上成员(状态)信息, @BattleMemberUpdate
  -- 其他
}

-- 行动或效果引发的伤害/治疗信息
-- attack_damage_info, effect_damage_info其实是2种不同的东西
Domain.BattleDamageInfo = {
  target = {}, -- @BattleMemberLocator
  id = 0, -- 用来表示atrr type, 如hp, hp_max, energy...
  op = 0, -- 加减
  value = 0, -- 用来表现用的数值
  actual_value = 0, -- 实际数值, 改变属性的数值
  damage_types = {}, -- @BattleDamageType 
  effect, -- 效果表现
  -- 目标的状态变化
  -- alive = false,
}

-- DamageType, 暴击, 闪避, 减伤 ...
Domain.BattleDamageType = {
  type = 0,
  value = 0
}

-- 产生效果
Domain.BattleTakesEffect = {
  target = {}, -- 作用目标, @BattleMemberLocator
  buffs = {}, -- 具体buff的变化，@BattleBuff
  effects = {} -- 具体的效果, @BattleEffect
}

-- 对应游戏效果的执行情况(TakeEffect)
Domain.BattleEffect = {
  skill = 0, -- skill_id, 表示由skill产生
  buff = 0, -- buff_id, 表示由buff产生
  effect_infos = {} -- @ref BattleDamageInfo
}

-- append/delete
Domain.BattleBuff = {
  -- id = 0, -- 对应gl_buff_mgr中的唯一id
  buff = 0,  -- 对应buff_id
  skill = 0, -- 对应skill_id
  op = 0, -- 添加/删除
  layers = 0, -- 堆叠
  duration = 0, -- 持续时间 
  -- caster = 0 -- 表示添加buff的来源
}

-- 用来表示一个基础的战斗单元
Domain.BattleMember = {
  -- 基础信息(起区分和定位作用) ...
  camp = 0, 
  type = 0,
  pos = 0, 
  id = 0,
  -- 属性信息 ...
  hp = 0,
  max_hp = 0,
  energy = 0,
  name = 0, -- 从对应的table中获取
  -- 状态信息 ...
  alive = true, -- 是否存活
  terminated = false -- 是否销毁(alive = false)
}

-- 这里用来定位与查找member
Domain.BattleMemberLocator = {
  camp = 0, -- 归属, self/enemy
  type = 0, -- hero/pet/summon, ...
  pos = 0, -- 在battle_scene位置
  id = 0, -- type -> id, 有时也忽略
}

Domain.BattleMemberUpdate = {
  type = 0, -- 更新内容: alive, terminated, create(summon, relive, ...)
  target = {},  -- 需要更新的目标
  new_member = {}, -- 用于复活或召唤这种额外登场member
}

return Domain