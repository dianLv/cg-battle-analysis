local tools = require('tools')
local data_tables = require('data_tables')
local mode = require('example.mode')

-- BattlePlayer prototype --
local Player = {
  name = '',
  heroes = {
    -- [1:pos] = hero:table
    -- ...
  },
  -- other members...
}

-- 关联player
local function bind_player(player, data)
  player.name = data.name
  -- ...
end

-- hero的信息显示
local function display_simple(hero)
  return string.format('[%s%d号位的%s(%d)]', mode.CAMP_INFO[hero.camp], hero.pos, hero.name, hero.id)
end

local function display_hero(hero)
  return string.format('[%d号位][%s(%d)][hp:%d/%d][energy:%d][alive:%s]', hero.pos, hero.name, hero.id, hero.hp, hero.max_hp, hero.energy, hero.alive)
end

-- 用于修改hero的属性
local function modify_attr(hero, attr, value)
  hero[attr] = hero[attr] + value
  -- 防止数值为负
  -- 或加assert(hero[attr] >= 0, '')
  if hero[attr] < 0 then
    hero[attr] = 0
  end
end

--
-- 统一处理params是{1 = {}, 2 = {}, 3 = {}}/mapper时的func调用状况,
-- 
local function iterator(params, func)
  if params then
    tools.assert(params, 'table', 'require table')
    if #params ~= 0 then
      for k, v in ipairs(params) do
        func(v, k)
      end
    else
      func(params)
    end
  end 
end

----- 英雄也有适合英雄的舞台 -----
local Stage = {
  self_player = tools.clone(Player),
  oppo_player = tools.clone(Player),
  record = nil,
  -- common: 一些公共内容
  is_win = false,
  type = 0,
  version = ''
}

---------- ↓↓↓ Basic ↓↓↓ ----------
function Stage:new(o)
  o = o or {}
  self.__index = self
  return setmetatable(o, self)
end

function Stage:reset()
  self.self_player.heroes = {}
  self.oppo_player.heroes = {}
  -- ...
end

function Stage:set_record(record)
  self.record = record
end

function Stage:get_player(camp)
  -- 根据规则获取self/oppo
  if camp == mode.CAMP_SELF then
    return self.self_player
  else
    return self.oppo_player
  end
end

function Stage:get_player_heroes(camp)
  return self:get_player(camp).heroes
end

function Stage:set_hero(hero)
  self:get_player(hero.camp).heroes[hero.pos] = hero
end

-- function Stage:get_hero(camp, pos)
--   return self:get_player(camp).heroes[pos]
-- end

function Stage:get_hero(locator)
  -- assert(locator.type == 'hero', '')
  return self:get_player(locator.camp).heroes[locator.pos]
end

function Stage:init_hero(member)
  tools.assert(member, 'table', 'member must be table')
  local hero = member
  -- 补充raw中没有的数据
  hero.name = mode.HERO_NAMES[hero.id]
  self:set_hero(hero)
end

function Stage:init_members(members)
  iterator(members, function(member) 
    if member.type == mode.MEMBER_TYPE_HERO then
      self:init_hero(member)
    end
    -- ...
  end)
end

--------- ↓↓↓ display ↓↓↓ ---------
function Stage:display_player_info()
  for i = 1, #mode.CAMP_INFO do
    local player = self:get_player(i)
    self.record:buffer(mode.CAMP_INFO[i] .. '[' .. player.name .. ']信息:')
    local heroes = player.heroes
    for j = 1, #heroes do
      self.record:buffer(display_hero(heroes[j]))
    end
  end
  self.record:buffer('')
end

-- unit display
function Stage:display_member_info(locator)
  -- 假设1是hero
  if locator.type == 1 then
    local hero = self:get_hero(locator)
    return display_simple(hero)
  -- elseif unit.type == 2 ...
  end
end

-- 额外的伤害类信息
function Stage:display_damage_types(infos)
  local str = {}
  if not tools.is_empty(infos) then
    iterator(infos, function(info)
      if info.value ~= 0 then
        table.insert(str, string.format('%s[%d]', mode.DAMAGE_TYPE_INFO[info.type], info.value))
      else
        table.insert(str, string.format('%s', mode.DAMAGE_TYPE_INFO[info.type]))
      end
    end)
  else
    return ''
  end
  -- 一般来说, 效果产生的伤害是直接作用到目标上的, 不需要额外说明
  if #str == 0 then return '' end
  return '造成[' .. table.concat(str, '|') .. ']'
end

-- 显示帮助信息
function Stage:display_help_text()
  self.record:buffer('[帮助信息]')
  self.record:buffer(mode.help_text())
  self.record:buffer('')
end

function Stage:display_stage_info()
  self.record:buffer('[场景信息]')
  self.record:buffer('玩家信息: ' .. self.self_player.name)
  self.record:buffer('对手信息: ' .. self.oppo_player.name)
  self.record:buffer('--------------')
  self.record:buffer('模式: ' .. mode.BATTLE_TYPE_INFO[self.type])
  self.record:buffer('胜负: ' .. mode.winner(self.is_win))
  self.record:buffer('')
end

--------- ↓↓↓ process ↓↓↓ ---------
-- 完成战斗场景的入场工作
function Stage:enter(report)
  self:display_help_text()

  bind_player(self.self_player, report.self_info)
  bind_player(self.oppo_player, report.oppo_info)
  self.is_win = report.is_win
  self.version = ''
  self.type = report.type
  self:display_stage_info()
  
  -- 解析战斗
  self:process_awaves(report.waves)
end

-- 处理每一波的战斗情况
function Stage:process_awaves(waves)
  self.record:buffer('[战斗信息]')
  iterator(waves, function(wave)
    local wave_index = wave.wave_index
    self.record:buffer('Battle Start Wave %d', wave_index)
    -- 重置当前Stage
    self:reset()
    -- 胜负
    -- 完成成员初始化
    self:init_members(wave.members)
    -- 执行战斗开始前的效果
    self:process_takes_effects(wave.init_effects, '战斗开始阶段')
    self.record:buffer('--------------')
    -- desplayer
    self:display_player_info()
    -- battle start
    self:process_arounds(wave.rounds)
    -- flag: battle end
    self.record:buffer('Wave %d Battle End', wave_index)
  end)
end

function Stage:process_arounds(rounds)
  if not tools.is_empty(rounds) then
    self.record:buffer("Start Battle(Total Rounds: %d)", #rounds)
    iterator(rounds, function(round)
      local index = round.round_index
      local actions = round.actions
      self.record:buffer("Round %d(Total Action: %d)", index ,#actions)
      -- 当回合开始时, 执行的效果
      self:process_takes_effects(round.before_effects, '回合开始阶段')
      -- 进入行动阶段
      self:process_aactions(actions)
      -- flag: round end
      self.record:buffer('-当前回合结束-')
      -- display_current_player_hero_info
      self:display_player_info()
    end)
  end
end

function Stage:process_aactions(actions)
  if not tools.is_empty(actions) then
    iterator(actions, function(action, i)
      self.record:buffer("No.%d Action", i)
      -- 行动开始前
      self:process_takes_effects(action.before_effects, '行动开始前')
      -- 行动信息
      local actor_info = self:display_member_info(action.actor)
      -- 获取技能名称
      local skill = action.skill
      local type = action.type
      -- => 谁行动, 行动原因是什么[普通/特殊...], 使用什么技能[=>技能名称(skill_id)]
      -- 如果改html, 可以嵌入技能引用信息, 做tooltips
      self.record:buffer('由%s%s, 使用skill:%d', actor_info, mode.ACTION_TYPE_INFO[type], skill)
      -- 行动时
      self:process_damage_infos(action.action_infos, '行动')
      -- 在行动期间
      self:process_takes_effects(action.action_effects, '行动期间')
      -- 行动结束
      self:process_takes_effects(action.after_effects, '行动结束时')
      self:process_takes_effects(action.after_round_effects, '回合结束阶段')
      -- 最后, 更新成员信息
      self:process_members_update(action.members_update)
    end)
  end
end

function Stage:process_members_update(update_infos)
  if not tools.is_empty(update_infos) then
    self.record:buffer('update members status')
    iterator(update_infos, function(info)
      -- create/relive/, exit, remove...
      -- if info.op == create/relive then
      --   self:init_hero(info.new_member)
      -- elseif info.op == remove then
      --   local heroes self:get_player_heroes()
      --   heroes[info.target.pos] = nil  | hero.terminated = true
      -- elseif info.op == 3 then
      -- end
    end)
  end
end

function Stage:process_takes_effects(use_effects, timed)
  if not tools.is_empty(use_effects) then
    self.record:buffer("*[%s]产生", timed)
    iterator(use_effects, function(use_effect)
      -- 效果作用的目标
      -- target => hero
      local hero = self:get_hero(use_effect.target)
      self.record:buffer(display_simple(hero) .. '执行效果')
      -- buff, 已buff_mgr
      self:process_buffs(use_effect.buffs, use_effect.target)
      self:process_effects(use_effect.effects)
    end)
  end
end

function Stage:process_effects(effects)
  if not tools.is_empty(effects) then
    iterator(effects, function(effect) 
      -- skill_id/buff_id, 效果来源, 有技能产生还是来自buff结算
      if effect.skill and effect.skill ~= 0 then
        self.record:buffer('[skill:%d]产生效果', effect.skill)
      else
        self.record:buffer('[buff:%d]产生效果', effect.buff)
      end
      -- 可以将相关信息塞到 process_damage_infos 的 remark 中
      self:process_damage_infos(effect.effect_infos, '效果')
    end)
  end
end

function Stage:process_buffs(buffs, target)
  if not tools.is_empty(buffs) then
    iterator(buffs, function(buff) 
      if buff.op == 1 then -- 添加
        if buff.skill ~= 0 then
          self.record:buffer('由[skill:%d]添加%d层[buff:%d], 持续%d回合', buff.skill, buff.layers, buff.buff, buff.duration)
        else
          self.record:buffer('添加%d层[buff:%d], 持续%d回合', buff.layers, buff.buff, buff.duration)
        end
      elseif buff.op == 2 then
        if buff.skill ~= 0 then -- 移除buff
        else
        end
      end
    end)
  end
end

function Stage:process_damage_infos(infos, remark)
  if not tools.is_empty(infos) then
    -- remark
    if remark then self.record:buffer('*[%s]结算', remark) end
    iterator(infos, function(info)
      -- 目标信息
      local hero = self:get_hero(info.target)
      local op = info.op
      local id = info.id
      local attr = mode.ATTR_INFO[id]
      local value = info.value
			local actual_value = info.actual_value
      if id == mode.ATTR_ENERGY then
        if op == 1 then
          modify_attr(hero, 'energy', actual_value)
        elseif op == 2 then
          modify_attr(hero, 'energy', -actual_value)
        end
        self.record:buffer('->给%s[%s:energy][%d|%d(->%d)]', display_simple(hero), mode.DAMAGE_OP_INFO[op], value, actual_value, hero.energy)
      elseif id == mode.ATTR_HP then
        -- 当存在特殊的血量规则时, 需要额外处理
        if op == 1 then
          modify_attr(hero, 'hp', actual_value)
        elseif op == 2 then
          modify_attr(hero, 'hp', -actual_value)
        end
        -- 生成伤害类型信息
        local damage_types = self:display_damage_types(info.damage_types)
        self.record:buffer('->给%s%s, [%s:hp][%d|%d(->%d)]', display_simple(hero), damage_types, mode.DAMAGE_OP_INFO[op], value, actual_value, hero.hp, damage_types)
      else
      end
    end)
  end
end

return function(report, record)
  local stage = Stage:new()
  stage:set_record(record)
  stage:enter(report)
end