

local filestore = require("moonstore.filestore")

moonstore = {}
moonstore.create = function(directory)
  storeBackend = filestore.create(directory)
  return {store = storeBackend}
end

moonstore.commit = function(store, oldCommit, data)

end

moonstore.read = function(store, commit, path)

end

moonstore.paths = function(store, commit)

end

moonstore.parentCommits = function(store, commit)

end

moonstore.metaDiff = function(store, fromCommit, toCommit)

end

moonstore.diff = function(store, fromCommit, toCommit)

end

moonstore.applyDiff = function(store, commit, diff)

end

return moonstore