
local store = {}
local io = require("io")
local utils = require("utils")

storePaths = {
  Blob = "blobs/",
  Commit = "commits/",
  Tree = "trees/"
}

store.new = function(directory)
  utils.mkdir(directory)
  for k, subFolder in pairs(storePaths) do
    utils.mkdir(directory.."/"..subFolder)
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

for key, pathPrefix in pairs(storePaths) do
  store["write"..key] = function(aStore, path, data)
    store.write(aStore, pathPrefix..path, data)
  end
  store["read"..key] = function(aStore, path)
    return store.read(aStore, pathPrefix..path)
  end
end

return store