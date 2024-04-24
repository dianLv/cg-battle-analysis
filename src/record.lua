local Record = {
  name = nil,
  data = {}
}

function Record:new(o)
  local o = o or {}
  self.__index = self
  return setmetatable(o, self)
end

function Record:set_name(name)
  self.name = name
end

function Record:buffer(...)
  local msg = string.format(...)
  table.insert(self.data, msg)
end

function Record:store()
  local content = table.concat(self.data, '\n')
  local file = io.open(self.name, 'w')
  assert(file, 'IOException: Open ' .. self.name .. ' fail!')
  file:write(content)
  io.close(file)
end

-- function Record:close()
-- end

return Record