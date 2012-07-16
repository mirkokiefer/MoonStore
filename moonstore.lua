package.path = "./moonstore/?.lua;" .. package.path
local table = require("table")
local filestore = require("moonstore.filestore")
local utils = require("moonstore.utils")

local readBlob = function(store, hash)
  return store.storeModule.readBlob(store.storeObj, hash)
end
local writeBlob = function(store, data)
  local hash = utils.hash(data)
  store.storeModule.writeBlob(store.storeObj, hash, data)
  return hash
end
local readCommit = function(store, hash)
  return utils.deserializeString(store.storeModule.readCommit(store.storeObj, hash))
end
local writeCommit = function(store, parentCommits, tree)
  local commit = {parents = parentCommits, tree = tree}
  local commitSerialized = utils.serializeToString(commit)
  local commitHash = utils.hash(commitSerialized)
  store.storeModule.writeCommit(store.storeObj, commitHash, commitSerialized)
  return commitHash
end
local readTree = function(store, hash)
  return utils.deserializeString(store.storeModule.readTree(store.storeObj, hash))
end
local writeTree = function(store, tree)
  local serialized = utils.serializeToString(tree)
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
      local oldChildTree = {trees={}, blobs={}}
      if(oldTree.trees[key]) then oldChildTree = readTree(store, oldTree.trees[key]) end
      newTree.trees[key] = writeChangedTree(store, oldChildTree, child)
    else
      if (child == false) then
        newTree.blobs[key] = nil
      else
        newTree.blobs[key] = writeBlob(store, child)
      end
    end
  end
  return writeTree(store, newTree)
end

moonstore.commit = function(store, parentCommit, data)
  local dataList = utils.pathTableToList(data)
  local changedTree = utils.listToTree(dataList)
  local parentCommitTree = {trees={}, blobs={}}
  if (parentCommit) then
    local parentCommitObj = readCommit(store, parentCommit)
    parentCommitTree = readTree(store, parentCommitObj.tree)
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
  return readTree(store, obj.tree)
end

moonstore.childSegments = function(store, segmentHash)
  return readTree(store, segmentHash)
end

moonstore.parentCommits = function(store, commit)
  local obj = readCommit(store, commit)
  return obj.parents
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