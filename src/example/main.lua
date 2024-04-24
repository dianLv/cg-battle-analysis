local output_name = arg[1] or 'example_battle_report.txt'
local tools = require('tools')

local record = require('record')
local _record = record:new({
  name = output_name
})

-- 本地输出的目录
local function main()
  -- 原始数据
  local raw_data = {} -- require('battle_data => export LuaModule')
  local raw_data = require('example.raw_data')
  -- local convert = require('data_convert')
  local convert = require('example.data_convert')
  -- Domain.BattleReplay 
  local battle_replay = convert(raw_data)
  -- 提供一个battle_stage
  local stage = require('example.stage')
  stage(battle_replay, _record)
  _record:store()
end

local function error_handle(err)
  -- 尝试将已有内容输出
  _record:store()
  -- 输出错误信息
  print("Error caught:" .. err)
  print(debug.traceback())
  -- tools.dump(err, 'ERROR!!!')
end

xpcall(main, error_handle)