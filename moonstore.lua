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

  local commonBase
  local commonBase = function(tree1Hash, tree2Hash)
    if(tree1Hash == tree2Hash) then return tree1Hash end
    local tree1 = readTree(tree1Hash)
    local tree2 = readTree(tree2Hash)
    local tree1Parents = {}
    local tree2Parents = {}
    while (table.getn(tree1.parents) or table.getn(tree2.parents)) do

    end
  end

  local baseMerge = function(tree1Hash, tree2Hash, commonBase)

  end

  local merge
  merge = function(tree1Hash, tree2Hash, path)
    if path then
      local tree1
      if tree1Hash then tree1 = readTree(tree1Hash) else tree1 = Tree.new() end
      tree1.parents = {tree1Hash}
      local childTreeHash = Tree.childTree(tree1, path.first)
      Tree.setChildTree(tree1, path.first, merge(childTreeHash, tree2Hash, path.first))
      return backend.writeTree(tree1)
    else
      if tree1Hash then
        return baseMerge(tree1Hash, tree2Hash, commonBase(tree1Hash, tree2Hash))
      else
        return tree2Hash
      end
    end
  end
  moonstore.merge = function(tree1, tree2, path)
    local pathList
    if (path) then pathList = pathToList(path) end
    return merge(tree1, tree2, path)
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