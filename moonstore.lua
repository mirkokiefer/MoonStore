package.path = "./moonstore/?.lua;" .. package.path
local table = require("table")
local filestore = require("moonstore.filestore")
local utils = require("moonstore.utils")
local url = require("url")

local Tree = {
  new = function(childTrees, childBlobs)
    return {trees=childTrees or {}, blobs=childBlobs or {}}
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

local Commit = {
  new = function(parentCommits, tree) return {parents = parentCommits, tree = tree} end,
  tree = function(self) return self.tree end,
  parents = function(self) return self.parents end,
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
  obj.readCommit = function(hash)
    return Commit.deserialize(backend.readCommit(hash))
  end
  obj.writeCommit = function(commit)
    local commitSerialized = Commit.serialize(commit)
    local commitHash = utils.hash(commitSerialized)
    backend.writeCommit(commitHash, commitSerialized)
    return commitHash
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
  writeChangedTree = function(oldTree, changedTree)
    local newTree = utils.tableCopy(oldTree)
    for key, child in pairs(changedTree) do
      if (type(child) == "table") then
        local oldChildTree
        local oldChildTreeHash = Tree.childTree(oldTree, key)
        if(oldChildTreeHash) then oldChildTree = backend.readTree(oldChildTreeHash)
        else oldChildTree = Tree.new() end
        Tree.setChildTree(newTree, key, writeChangedTree(oldChildTree, child))
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

  moonstore.commit = function(parentCommit, data)
    local dataList = utils.pathTableToList(data)
    local changedTree = utils.listToTree(dataList)
    local parentCommitTree = Tree.new()
    if (parentCommit) then
      local parentCommitObj = backend.readCommit(parentCommit)
      parentCommitTree = backend.readTree(Commit.tree(parentCommitObj))
    end
    local treeHash = writeChangedTree(parentCommitTree, changedTree)
    return backend.writeCommit(Commit.new({parentCommit}, treeHash))
  end

  moonstore.read = function(commit, path)

  end

  moonstore.paths = function(commit)

  end

  moonstore.rootSegments = function(commit)
    local obj = backend.readCommit(commit)
    return backend.readTree(Commit.tree(obj))
  end

  moonstore.childSegments = function(segmentHash)
    return backend.readTree(segmentHash)
  end

  moonstore.parentCommits = function(commit)
    local obj = backend.readCommit(commit)
    return Commit.parents(obj)
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