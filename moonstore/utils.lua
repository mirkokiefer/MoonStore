
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

return utils