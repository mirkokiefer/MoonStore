
local crypto = require("crypto")
local string = require("string")
local table = require("table")
local utils = {}

utils.hash = function(data)
  return crypto.digest("sha1", data)
end

utils.deleteDirectory = function(directory)
  for file in lfs.dir(directory) do
    os.remove(directory.."/"..file)
  end
  os.remove(directory)
end

utils.splitString = function(aString, sep)
  local sep = sep or ":"
  local tokens = nil
  local pattern = string.format("([^%s]+)", sep)
  string.gsub(aString, pattern, function(c) tokens = utils.listAdd(tokens, c) end)
  return utils.listReverse(tokens)
end

utils.tableCopy = function(aTable)
  local t2 = {}
  for k,v in pairs(t) do
    t2[k] = v
  end
  return t2
end

utils.list = function(first, ...)
  if first == nil then return nil end
  return {first = first, rest = utils.list(...)}
end

utils.listAdd = function(list, value)
  return {first = value, rest = list}
end

utils.listAt = function(list, index)
  if index == 1 then return list.first end
  return listAt(list.rest, index-1)
end

utils.listReverse = function(list)
  reversed = nil
  while(list) do
    reversed = utils.listAdd(reversed, list.first)
    list = list.rest
  end
  return reversed
end

utils.listValues = function(list, maxValues)
  array = {}
  index = 1
  while(list) do
    array[index] = list.first
    if maxValues and i >= maxValues then break end
    list = list.rest
    index = index + 1
  end
  return unpack(array)
end

utils.pathTableToList = function(table)
  local list = nil
  for path, value in pairs(table) do
    list = utils.listAdd(list, {path=utils.splitString(path, "/"), value=value})
  end
  return list
end

utils.listToTree = function(pathValues)
  local tree = {}
  while(pathValues) do
    local current = pathValues.first
    local path = current.path
    if (path.rest) then
      tree[path.first] = utils.listAdd(tree[path.first], {path = path.rest, value = current.value})
    else
      child = current.value
      tree[path.first] = current.value
    end
    pathValues = pathValues.rest
  end
  for key, childPathValues in pairs(tree) do
    if childPathValues.first then
      tree[key] = utils.listToTree(childPathValues)
    end
  end
  return tree
end

utils.print = function(data)
  require 'pl.pretty'.dump(data)
end

utils.memoryFile = function()
  local data = ""
  local file = {
    write = function(newData)
      data = data .. newData
    end,
    close = function() end,
    data = function() return data end
  }
  return file
end

utils.deserializeString = function(string)
  string = "data = " .. string
  local table = {}
  local f = assert(loadstring(string))
  setfenv(f, table)
  f()
  return table.data
end

utils.serializeToString = function(data)
  local file = utils.memoryFile()
  utils.serialize(file, data)
  return file.data()
end

utils.deserialize = function(file)
  local data = file:read("*a")
  file:close()
  return utils.deserializeString(data)
end

utils.serialize = function(file, o)
  if type(o) == "number" then
    file.write(o)
  elseif type(o) == "string" then
    file.write(string.format("%q", o))
  elseif type(o) == "table" then
    file.write("{\n")
    for k,v in pairs(o) do
      file.write("  ["); utils.serialize(file, k); file.write("] = ")
      utils.serialize(file, v)
      file.write(",\n")
    end
    file.write("}\n")
  else
    error("cannot serialize a " .. type(o))
  end
end

return utils