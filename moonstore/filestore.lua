
local store = {}
local io = require("io")
local utils = require("utils")

storePaths = {
  Blob = "blobs/",
  Tree = "trees/"
}

local new = function(directory)
  local store = {}
  store.delete = function() utils.deleteDirectory(directory) end
  store.write = function(path, data)
    local file = assert(io.open(directory.."/"..path..".txt", "w"))
    file:write(data)
    file:close()
  end
  store.read = function(path)
    local file = assert(io.open(directory.."/"..path..".txt", "r"))
    local data = file:read("*a")
    file:close()
    return data
  end

  local init = function()
    utils.mkdir(directory)
    for k, subFolder in pairs(storePaths) do
      utils.mkdir(directory.."/"..subFolder)
    end
    for key, pathPrefix in pairs(storePaths) do
      store["write"..key] = function(path, data)
        store.write(pathPrefix..path, data)
      end
      store["read"..key] = function(path)
        return store.read(pathPrefix..path)
      end
    end
    return store
  end
  return init()
end

return new