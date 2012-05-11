
local store = {}
local io = require("io")
local lfs = require("lfs")

store.new = function(directory)
  if not lfs.attributes(directory) then
  	lfs.mkdir(directory)
  end
  return {directory = directory}
end

store.pull = function(targetStore, targetRef, sourceStore, sourceRef)
	
end

store.pullFromPeer = function(store, storeRef, peer, peerRef)

end

store.write = function(store, path, data)
  local file = io.open(store.directory.."/"..path..".txt", "w")
  file:write(data)
  file:close()
end

store.read = function(store, path)

end

return store