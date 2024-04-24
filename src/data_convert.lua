-- 
-- data_convert, 将游戏dump的战斗数据, 按规则解析所须使用的结构
-- 
local domain = require( 'domain' )
local tools = require( "tools" )

-- 使用func将params解析成data所需的数据并返回
-- @param: params number or table
-- @param: data 数据结果
-- @param: func callback_function
local function parsing(params, data, func)
  -- assert(type(func) == 'function', 'request function, but find ' .. type(func))
  tools.assert(func, 'function', 'request function')
  if tools.debug then 
    tools.dump(params, 'Parsing Params') 
    tools.dump(data, 'Domain Data') 
  end
  if params then
    local function processValue(_params)
      local value = tools.clone(data)
      func(params, value)
      return value
    end
    if type(params) == 'table' then
      if #params ~= 0 then
        local values = {}
        for i = 1, #params do
          local value = tools.clone(data)
          func(params[i], value)
          table.insert(values, value)
        end
        return values
      end
      if not tools.is_empty(params) then
        return processValue()
      end
    else
      return processValue()
    end
  end
end

-- BattleMemberLocator
local function extract_locator_info(data, locator)
  -- unit.camp = data.camp
  -- unit.type = data.type
  -- unit.id = data.id
  -- unit.pos = data.pos
end

------------------------------
-- 
------------------------------
local function parse_member_locator(params)
  return parsing(params, domain.BattleMemberLocator, extract_locator_info)
end

local function parse_members(params)
  return parsing(params, domain.BattleMember, function(data, member)
    -- member.camp = 
    -- member.pos = 
    -- member.type =  
    -- member.id = 
    -- member.hp = 
    -- member.max_hp = -- member.hp
    -- member.energy = 
    -- member.alive = true
    -- member.terminated = false
  end)
end

local function parse_members_update(params)
  return parsing(params, domain.BattleMemberUpdate, function(data, update) 
    -- update.op = data. -- 0, 1, 2...
    -- update.target = parse_member_locator(data.)
    -- update.new_memebers = parse_members(data.)
  end)
end

local function parse_damage_types(params)
  return parsing(params, domain.BattleDamageType, function(data, info) 
    -- info.type = 
    -- info.value = 
  end)
end

local function parse_damage_infos(params)
  return parsing(params, domain.BattleDamageInfo, function(data, info) 
    -- info.target = parse_member_locator(data.)
    -- info.id = 
    -- info.op = 
    -- info.value = 
    -- info.actual_value = 
    -- info.damage_types = parse_damage_types(data.)
    -- info.effect = 
  end)
end

local function parse_buffs(params)
  return parsing(params, domain.BattleBuff, function(data, buff)
    -- -- buff.id = 
    -- buff.buff = 
    -- buff.skill = 
    -- buff.op = 
    -- buff.layers = 
    -- buff.duration = 
  end)
end

local function parse_effects(params)
  return parsing(params, domain.BattleEffect, function(data, effect)
    -- effect.skill = 
    -- effect.buff = 
    -- effect.effect_infos = parse_damage_infos(data.)
  end)
end

local function parse_takes_effects(params) 
  return parsing(params, domain.BattleTakesEffect, function(data, apply_effect)
    -- apply_effect.target = parse_member_locator(data.)
    -- apply_effect.effects = parse_effects(data.)
    -- apply_effect.buffs = parse_buffs(data.)
  end)
end

local function parse_actions(params) 
  return parsing(params, domain.BattleAAction, function(data, action) 
    -- action.action_index = 0,
    -- action.actor =  
    -- action.type = 
    -- action.skill = 
    -- action.before_effects = parse_takes_effects(data.) 
    -- action.action_infos = parse_damage_infos(data.)
    -- action.action_effects = parse_takes_effects(data.) 
    -- action.after_effects = parse_takes_effects(data.) 
    -- action.end_rounds = parse_takes_effects(data.) 
    -- action.members_update = parse_members_update(data.)
  end)
end

local function parse_rounds(params)
  return parsing(params, domain.BattleARound, function(data, round) 
    -- round.round_index = 
    -- round.before_rounds = parse_takes_effects(data.)
    -- round.actions = parse_actions(data.)
    -- round.max_actions = 
  end)
end

-- 当存在原始数据没有的情况, 需要使用 or 0 | or {}进行填充
local function parse_waves(params)
  return parsing(params, domain.BattleAWave, function(data, wave)
    -- wave.wave_index = 
    -- wave.init_effects = 
    -- wave.rounds = parse_rounds(data.)
    -- wave.max_rounds 
    -- wave.is_win = 
    -- wave.first = 
    -- wave.members = parse_members(data.)
    -- wave.final_members = parse_members(data.)
  end)
end

local function extract_player_info(raw_data, aside)
  local info = tools.clone(domain.BattlePlayerInfo)
  -- player.name = 
  -- is_robot?
  -- ...
  return info
end

-- 传入从游戏中dump出的数据, 并将其映射成domain中的结构
return function(raw_data) 
  local replay = tools.clone(domain.BattleReplay)
  -- replay.self_info = extract_player_info(raw_data, aside)
  -- replay.oppo_info = extract_player_info(raw_data,)
  -- replay.type = 
  -- replay.waves = parse_waves(raw_data.waves)
  -- ...
  return replay
end