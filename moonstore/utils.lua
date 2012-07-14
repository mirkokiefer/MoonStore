
local crypto = require("crypto")
local string = require("string")
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

utils.splitString = function(aString, sep)
  local sep, fields = sep or ":", {}
  local pattern = string.format("([^%s]+)", sep)
  string.gsub(aString, pattern, function(c) fields[#fields+1] = c end)
  return fields
end

return utils