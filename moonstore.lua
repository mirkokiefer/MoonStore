

local store = {}
store.new = function()

end

store.pull = function(targetStore, targetRef, sourceStore, sourceRef)
	
end

store.pullFromPeer = function(store, storeRef, peer, peerRef)

end

local branch = {}
branch.new = function(store, commit)

end

branch.fork = function(branch, commit)

end

branch.head = function(branch)

end

branch.commit = function(branch, entries)

end

branch.get = function(branch, paths)

end

branch.merge = function(branch, newCommit, conflictFun)

end

local peer = {}
peer.new = function(url)

end

return {
	store = store,
	branch = branch,
	peer = peer
}