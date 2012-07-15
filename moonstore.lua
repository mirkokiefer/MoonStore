package.path = "./moonstore/?.lua;" .. package.path
local table = require("table")
local filestore = require("moonstore.filestore")
local utils = require("moonstore.utils")

moonstore = {}
moonstore.new = function(directory)
  local storeBackend = filestore.new(directory)
  return {storeObj = storeBackend, storeModule = filestore}
end

local readObject = function(store, hash)
  local data = store.storeModule.read(store.storeObj, hash)
  return utils.deserializeString(data)
end

writeTree = function(store, oldTree, tree)
  local newTree = utils.tableCopy(oldTree)
  for key, child in pairs(tree) do
    if (type(child) == "table") then
      local oldChildTree = {}
      if(oldTree[key]) then oldChildTree = readObject(store, oldTree[key]) end
      newTree[key] = writeTree(store, oldChildTree, child)
    else
      if (child == false) then
        newTree[key] = nil
      else
        local hash = utils.hash(child)
        store.storeModule.write(store.storeObj, hash, child)
        newTree[key] = hash
      end
    end
  end
  local serialized = utils.serializeToString(newTree)
  local hash = utils.hash(serialized)
  store.storeModule.write(store.storeObj, hash, serialized)
  return hash
end

local writeCommit = function(store, parentCommits, tree)
  local commit = {parents = parentCommits, tree = tree}
  local commitSerialized = utils.serializeToString(commit)
  local commitHash = utils.hash(commitSerialized)
  store.storeModule.write(store.storeObj, commitHash, commitSerialized)
  return commitHash
end

moonstore.commit = function(store, parentCommit, data)
  local dataList = utils.pathTableToList(data)
  local changedTree = utils.listToTree(dataList)
  local parentCommitTree = {}
  if (parentCommit) then
    local parentCommitObj = readObject(store, parentCommit)
    parentCommitTree = readObject(store, parentCommitObj.tree)
  end
  local treeHash = writeTree(store, parentCommitTree, changedTree)
  return writeCommit(store, {parentCommit}, treeHash)
end

moonstore.read = function(store, commit, path)

end

moonstore.paths = function(store, commit)

end

moonstore.rootSegments = function(store, commit)
  local obj = readObject(store, commit)
  return readObject(store, obj.tree)
end

moonstore.childSegments = function(store, segmentHash)
  return readObject(store, segmentHash)
end

moonstore.parentCommits = function(store, commit)
  local obj = readObject(store, commit)
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