package.path = "./moonstore/?.lua;" .. package.path
local table = require("table")
local filestore = require("moonstore.filestore")
local utils = require("moonstore.utils")

local pathToList = function(path) return utils.splitString(path, "/") end

local Tree = {
  new = function(childTrees, childBlobs)
    return {trees=childTrees or {}, blobs=childBlobs or {}, parents={}}
  end,
  setChildTree = function(self, key, childTree) self.trees[key] = childTree end,
  childTree = function(self, key) return self.trees[key] end,
  setChildBlob = function(self, key, childBlob) self.blobs[key] = childBlob end,
  childBlob = function(self, key) return self.blobs[key] end,
  childBlobs = function(self) return self.blobs end,
  childTrees = function(self) return self.trees end,
  serialize = function(self) return utils.serializeToString(self) end,
  deserialize = function(string) return utils.deserializeString(string) end
}

local backendWrapper = function(directory)
  local backend = filestore(directory)
  local obj = {}
  obj.readBlob = function(hash)
    return backend.readBlob(hash)
  end
  obj.writeBlob = function(data)
    local hash = utils.hash(data)
    backend.writeBlob(hash, data)
    return hash
  end
  obj.readTree = function(hash)
    return Tree.deserialize(backend.readTree(hash))
  end
  obj.writeTree = function(aTree)
    local serialized = Tree.serialize(aTree)
    local hash = utils.hash(serialized)
    backend.writeTree(hash, serialized)
    return hash
  end
  obj.delete = backend.delete
  return obj
end

local newMoonstore = function(directory)
  local moonstore = {}
  local backend = backendWrapper(directory)
  local writeChangedTree
  writeChangedTree = function(oldTreeHash, changedTree)
    local oldTree
    if (oldTreeHash) then oldTree = backend.readTree(oldTreeHash)
    else oldTree = Tree.new() end
    local newTree = utils.tableCopy(oldTree)
    newTree.parents = {oldTreeHash}
    for key, child in pairs(changedTree) do
      if (type(child) == "table") then
        local oldChildTree
        local oldChildTreeHash = Tree.childTree(oldTree, key)
        Tree.setChildTree(newTree, key, writeChangedTree(oldChildTreeHash, child))
      else
        if (child == false) then
          Tree.setChildBlob(newTree, key, nil)
        else
          Tree.setChildBlob(newTree, key, backend.writeBlob(child))
        end
      end
    end
    return backend.writeTree(newTree)
  end

  moonstore.commit = function(parentTreeHash, data)
    local dataList = utils.pathTableToList(data)
    local changedTree = utils.listToTree(dataList)
    return writeChangedTree(parentTreeHash, changedTree)
  end

  local read
  read = function(treeHash, path)
    local tree = backend.readTree(treeHash)
    local childTreeHash = Tree.childTree(tree, path.first)
    if (childTreeHash) then
      if(path.rest) then return read(childTreeHash, path.rest)
      else return childTreeHash end
    else
      if(path.rest) then return nil
      else return Tree.childBlob(tree, path.first) end
    end
  end
  moonstore.read = function(treeHash, path)
    local pathList = pathToList(path)
    return read(treeHash, pathList)
  end

  moonstore.blob = backend.readBlob

  moonstore.readBlob = function(treeHash, path)
    local hash = moonstore.read(treeHash, path)
    return backend.readBlob(hash)
  end

  moonstore.paths = function(commit)

  end

  moonstore.merge = function(commit1, commit2)

  end

  moonstore.metaDiff = function(fromCommit, toCommit)

  end

  moonstore.diff = function(fromCommit, toCommit)

  end

  moonstore.applyDiff = function(commit, diff)

  end

  moonstore.delete = function()
    backend.delete()
  end

  return moonstore
end

return newMoonstore