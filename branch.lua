
local branch = {}
branch.new = function(store, head)
  return {store = store, head = head}
end

branch.fork = function(branch, head)

end

branch.head = function(branch)
  return branch.head
end

branch.commit = function(branch, entries)

end

branch.get = function(branch, paths)

end

branch.merge = function(branch, newCommit, conflictFun)

end

return branch