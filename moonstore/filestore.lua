
local store = {}
local io = require("io")
local lfs = require("lfs")
local utils = require("utils")

store.new = function(directory)
  if not lfs.attributes(directory) then
  	lfs.mkdir(directory)
  end
  return {directory = directory}
end

store.delete = function(store)
  utils.deleteDirectory(store.directory)
end

store.write = function(store, path, data)
  local file = assert(io.open(store.directory.."/"..path..".txt", "w"))
  file:write(data)
  file:close()
end

store.read = function(store, path)
  local file = assert(io.open(store.directory.."/"..path..".txt", "r"))
  local data = file:read("*a")
  file:close()
  return data
end

return store