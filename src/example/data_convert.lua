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
  locator.camp = data.camp
  locator.type = data.type
  -- unit.id = data.id
  locator.pos = data.pos
end

------------------------------
-- 
------------------------------
local function parse_member_locator(params)
  return parsing(params, domain.BattleMemberLocator, extract_locator_info)
end

local function parse_members(params)
  return parsing(params, domain.BattleMember, function(data, member)
    member.camp = data.camp
    member.type = data.member_type
    member.pos = data.pos
    member.id = data.id
    member.hp = data.hp
    member.max_hp = data.max_hp
    member.energy = data.energy
    member.alive = data.alive
    -- member.terminated = false
  end)
end

local function parse_members_update(params)
  return parsing(params, domain.BattleMemberUpdate, function(data, update) 
    update.op = data.type -- 0, 1, 2...
    update.target = parse_member_locator(data.target)
    update.new_memebers = parse_members(data.new_memebers)
  end)
end

local function parse_damage_types(params)
  return parsing(params, domain.BattleDamageType, function(data, info) 
    info.type = data.type
    info.value = data.value
  end)
end

local function parse_damage_infos(params)
  return parsing(params, domain.BattleDamageInfo, function(data, info) 
    info.target = parse_member_locator(data.target)
    info.id = data.id
    info.op = data.op
    info.value = data.value
    info.actual_value = data.actual_value
    info.damage_types = parse_damage_types(data.action_types)
    info.effect = data.effect_id
  end)
end

local function parse_buffs(params)
  return parsing(params, domain.BattleBuff, function(data, buff)
    -- -- buff.id = 
    buff.buff = data.buff_id
    buff.skill = data.skill_id
    buff.op = data.op
    buff.duration = data.round
    buff.layers = data.num
  end)
end

local function parse_effects(params)
  return parsing(params, domain.BattleEffect, function(data, effect)
    effect.skill = data.skill_id
    effect.buff = data.buff_id
    effect.effect_infos = parse_damage_infos(data.effect_infos)
  end)
end

local function parse_takes_effects(params) 
  return parsing(params, domain.BattleTakesEffect, function(data, apply_effect)
    apply_effect.target = parse_member_locator(data.target)
    apply_effect.effects = parse_effects(data.effects)
    apply_effect.buffs = parse_buffs(data.buffs)
  end)
end

local function parse_actions(params) 
  return parsing(params, domain.BattleAAction, function(data, action) 
    action.action_index = data.action_index
    action.actor = parse_member_locator(data.actor_info)
    action.type = data.action_type
    action.skill = data.skill_id
    action.before_effects = parse_takes_effects(data.before_effects) 
    action.action_infos = parse_damage_infos(data.action_infos)
    action.action_effects = parse_takes_effects(data.action_effects) 
    action.after_effects = parse_takes_effects(data.after_effects) 
    action.end_rounds = parse_takes_effects(data.end_rounds) 
    action.members_update = parse_members_update(data.members_update)
  end)
end

local function parse_rounds(params)
  return parsing(params, domain.BattleARound, function(data, round) 
    round.round_index = data.round_index
    round.before_rounds = parse_takes_effects(data.before_effects)
    round.actions = parse_actions(data.actions)
    round.max_actions = #round.actions
  end)
end

local function parse_waves(params)
  return parsing(params, domain.BattleAWave, function(data, wave)
    wave.wave_index = data.wave_index
    wave.init_effects = parse_takes_effects(data.init_effects)
    wave.rounds = parse_rounds(data.rounds)
    wave.max_rounds = wave.max_rounds or #wave.rounds
    wave.is_win = data.is_win
    wave.first = data.first
    wave.members = parse_members(data.members)
    wave.final_members = parse_members(data.members_final)
  end)
end

local function extract_player_info(raw_data, aside)
  local player_info = tools.clone(domain.BattlePlayerInfo)
  player_info.name = raw_data[aside .. '_name']
  -- is_robot?
  -- ...
  return player_info
end

-- 传入从游戏中dump出的数据, 并将其映射成domain中的结构
return function(raw_data) 
  local replay = tools.clone(domain.BattleReplay)
  replay.self_info = extract_player_info(raw_data, 'self')
  replay.oppo_info = extract_player_info(raw_data, 'oppo')
  replay.type = raw_data.type
  replay.is_win = raw_data.is_win
  replay.version = raw_data.version
  replay.waves = parse_waves(raw_data.waves)
  -- ...
  return replay
end