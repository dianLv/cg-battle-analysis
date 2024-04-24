local tools = require('tools')
local data_tables = require('data_tables')
local mode = require('mode')

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
local function display_hero(hero)
  return string.format('%s%d号位的%s(%d)', hero.camp, hero.pos, hero.name, hero.id)
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

  -- 根据规则获取self/oppo
function Stage:get_player(camp)
  -- if camp == [camp_index] then
  --   return self.self_player
  -- else
  --   return self.oppo_player
  -- end
end

function Stage:get_player_heroes(camp)
  return self:get_player(camp).heroes
end

function Stage:set_hero(camp, pos, hero)
  self:get_player(camp).heroes[pos] = hero
end

function Stage:get_hero(camp, pos)
  return self:get_player(camp).heroes[pos]
end

function Stage:init_hero(member)
  tools.assert(member, 'table', 'member must be table')
  -- 根据hero的结构从member中提取
  local hero = tools.clone(member)
  -- 一般是利用data_tables对hero进行一些补充, 如name, attr, buffs...等信息
  -- hero.name = data_tables.lookup_table('hero', 'name', hero.id)
  -- return hero
  self:set_hero(member.camp, member.pos, hero)
end

function Stage:init_members(members)
  iterator(members, function(member) 
    -- if member.type == [type_index:hero] then
    --   self:init_hero(member)
    -- end
    -- ...
  end)
end

--------- ↓↓↓ display ↓↓↓ ---------
function Stage:display_player_info(camp)
  return ''
end

-- unit display
function Stage:display_member_info(locator)
  return ''
end

-- 额外的伤害类信息
function Stage:display_damage_types(dts)
  local str = {}
  if not tools.is_empty(dts) then
    iterator(dts, function(dt)
      if dt.value ~= 0 then
        table.insert(str, string.format('%s[%d]', name, dt.value))
      else
        table.insert(str, string.format('%s', name))
      end
    end)
  else
    return ''
  end

  -- if #str == 0 then return '' end

  return table.concat(str, '|')
end

--------- ↓↓↓ process ↓↓↓ ---------
-- 完成战斗场景的入场工作
function Stage:enter(report)
  -- 入场信息
  self.record:buffer("Enter Battle.")
  -- 完成数据绑定
  bind_player(self.self_player, report.self_info)
  bind_player(self.oppo_player, report.oppo_info)
  -- 显示本场战斗的一些信息, 如玩家, 先后手, 胜负, 战斗规则, 版本等信息
  -- 完成本场战斗的分析
  self:process_awaves(report.waves)
end

-- 处理每一波的战斗情况
function Stage:process_awaves(waves)
  iterator(waves, function(wave) 
    -- 重置当前Stage
    self:reset()
    -- 胜负
    -- 完成成员初始化
    self:init_members(wave.members)
    -- battle start
    self:process_takes_effects(wave.init_effects, 'Battle Start Phase')
    self:process_arounds(wave.rounds)
    -- flag: battle end
    self.record:buffer('A Wave End!')
  end)
end

function Stage:process_arounds(rounds)
  if not tools.is_empty(rounds) then
    self.record:buffer( "Enter Battle(Total Rounds: %d)", #rounds )
    iterator(rounds, function(round) 
      local index = round.index
      local actions = round.actions
      self.record:buffer("No. %d Round(Total Action: %d)", index ,#actions)
      -- 当回合开始时, 执行的效果
      self:process_takes_effects(round.before_effects, 'Round Start Phase')
      -- 进入行动阶段
      self:process_aactions(actions)
      -- flag: round end
      self.record:buffer('A Round End!')
      -- display_current_player_hero_info
    end)
  end
end

function Stage:process_aactions(actions)
  if not tools.is_empty(actions) then
    iterator(actions, function(action, i)
      self.record:buffer("No. %d Action", i)
      -- actor
      local locator = action.actor
      -- 行动信息
      local actor_info = self:display_member_info(locator)
      -- 获取技能名称
      local skill = action.skill_id
      local type = action.type
      -- 行动开始前
      self:process_takes_effects(action.before_effects, 'Before Action')
      -- => 谁行动, 行动原因是什么[普通/特殊...], 使用什么技能[=>技能名称(skill_id)]
      -- 如果改html, 可以嵌入技能引用信息, 做tooltips
      self:process_damage_infos(action.action_infos, 'Action')
      -- 在行动期间
      self:process_takes_effects(action.action_effects, 'During Action')
      -- 行动结束
      self:process_takes_effects(action.after_effects, 'After Action')
      self:process_takes_effects(action.after_round_effects, 'Round End Phase')
      -- 最后, 更新成员信息
      self:process_members_update(action.members_update)
    end)
  end
end

function Stage:process_members_update(update_infos)
  if not tools.is_empty(update_infos) then
    self.record:buffer('update members status')
    iterator(update_infos, function(info)
      -- ...
    end)
  end
end

function Stage:process_takes_effects(use_effects, timed)
  if not tools.is_empty(use_effects) then
    self.record:buffer("%s Take Effect", timed)
    iterator(use_effects, function(use_effect)
      -- 效果作用的目标
      -- target => hero
      -- buff, 已buff_mgr
      self:process_buffs(use_effect.buffs, use_effect.target)
      -- local hero = self:get_hero(use_effect.target)
      self:process_effects(use_effect.effects)
    end)
  end
end

-- 由skill/buff产生的的效果
function Stage:process_effects(effects)
  if not tools.is_empty(effects) then
    iterator(effects, function(effect) 
      -- skill_id/buff_id, 效果来源, 有技能产生还是来自buff结算
      -- 可以将相关信息塞到process_damage_infos的remark中
      self:process_damage_infos(effect.effect_infos, 'Effect')
    end)
  end
end

-- 涉及target身上的buff的变化情况
function Stage:process_buffs(buffs, target)
  if not tools.is_empty(buffs) then
    iterator(buffs, function(buff) 
      -- ...
    end)
  end
end

-- 大概由伤害来源, 目标, 类型, 影响属性, 额外信息(暴击/闪避...), 具体数值等信息组成
-- 并同步stage.player.[type].[attr]
function Stage:process_damage_infos(infos, remark)
  if not tools.is_empty(infos) then
    -- remark, 可以表示伤害来源, 或其他信息
    iterator(infos, function(info)
      local display = display_player_hero(info.target)
      local op = info.op
      local value = info.value
			local actual_value = info.actual_value
    end)
  end
end

return function(report, record)
  local stage = Stage:new()
  stage:set_record(record)
  stage:enter(report)
end