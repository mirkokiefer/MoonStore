package.path = "./moonstore/?.lua;" .. package.path
local table = require("table")
local filestore = require("moonstore.filestore")
local utils = require("moonstore.utils")

local Tree = {
  new = function(childTrees, childBlobs)
    return {trees=childTrees or {}, blobs=childBlobs or {}}
  end,
  setChildTree = function(self, key, childTree) self.trees[key] = childTree end,
  childTree = function(self, key) return self.trees[key] end,
  setChildBlob = function(self, key, childBlob) self.blobs[key] = childBlob end,
  childBlob = function(self, key) return self.blobs[key] end,
  serialize = function(self) return utils.serializeToString(self) end,
  deserialize = function(string) return utils.deserializeString(string) end
}

local Commit = {
  new = function(parentCommits, tree) return {parents = parentCommits, tree = tree} end,
  tree = function(self) return self.tree end,
  parents = function(self) return self.parents end,
  serialize = function(self) return utils.serializeToString(self) end,
  deserialize = function(string) return utils.deserializeString(string) end
}

local readBlob = function(store, hash)
  return store.storeModule.readBlob(store.storeObj, hash)
end
local writeBlob = function(store, data)
  local hash = utils.hash(data)
  store.storeModule.writeBlob(store.storeObj, hash, data)
  return hash
end
local readCommit = function(store, hash)
  return Commit.deserialize(store.storeModule.readCommit(store.storeObj, hash))
end
local writeCommit = function(store, parentCommits, tree)
  local commit = Commit.new(parentCommits, tree)
  local commitSerialized = Commit.serialize(commit)
  local commitHash = utils.hash(commitSerialized)
  store.storeModule.writeCommit(store.storeObj, commitHash, commitSerialized)
  return commitHash
end
local readTree = function(store, hash)
  return Tree.deserialize(store.storeModule.readTree(store.storeObj, hash))
end
local writeTree = function(store, aTree)
  local serialized = Tree.serialize(aTree)
  local hash = utils.hash(serialized)
  store.storeModule.writeTree(store.storeObj, hash, serialized)
  return hash
end

moonstore = {}
moonstore.new = function(directory)
  local storeBackend = filestore.new(directory)
  return {storeObj = storeBackend, storeModule = filestore}
end

writeChangedTree = function(store, oldTree, changedTree)
  local newTree = utils.tableCopy(oldTree)
  for key, child in pairs(changedTree) do
    if (type(child) == "table") then
      local oldChildTree
      local oldChildTreeHash = Tree.childTree(oldTree, key)
      if(oldChildTreeHash) then oldChildTree = readTree(store, oldChildTreeHash)
      else oldChildTree = Tree.new() end
      Tree.setChildTree(newTree, key, writeChangedTree(store, oldChildTree, child))
    else
      if (child == false) then
        Tree.setChildBlob(newTree, key, nil)
      else
        Tree.setChildBlob(newTree, key, writeBlob(store, child))
      end
    end
  end
  return writeTree(store, newTree)
end

moonstore.commit = function(store, parentCommit, data)
  local dataList = utils.pathTableToList(data)
  local changedTree = utils.listToTree(dataList)
  local parentCommitTree = Tree.new()
  if (parentCommit) then
    local parentCommitObj = readCommit(store, parentCommit)
    parentCommitTree = readTree(store, Commit.tree(parentCommitObj))
  end
  local treeHash = writeChangedTree(store, parentCommitTree, changedTree)
  return writeCommit(store, {parentCommit}, treeHash)
end

moonstore.read = function(store, commit, path)

end

moonstore.paths = function(store, commit)

end

moonstore.rootSegments = function(store, commit)
  local obj = readCommit(store, commit)
  return readTree(store, Commit.tree(obj))
end

moonstore.childSegments = function(store, segmentHash)
  return readTree(store, segmentHash)
end

moonstore.parentCommits = function(store, commit)
  local obj = readCommit(store, commit)
  return Commit.parents(obj)
end

moonstore.metaDiff = function(store, fromCommit, toCommit)

end

moonstore.diff = function(store, fromCommit, toCommit)

end

moonstore.applyDiff = function(store, commit, diff)

end

moonstore.delete = function(store)
  store.storeModule.delete(store.storeObj)
end

return moonstore