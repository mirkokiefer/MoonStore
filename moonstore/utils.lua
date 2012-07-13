
local crypto = require("crypto")

local utils = {}

utils.hash = function(data)
  return crypto.digest("sha1", data)
end

utils.deleteDirectory = function(directory)
  for file in lfs.dir(directory) do
    os.remove(directory.."/"..file)
  end
  os.remove(directory)
end

return utils