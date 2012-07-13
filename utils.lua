
local crypto = require("crypto")

local utils = {}

utils.hash = function(data)
  return crypto.digest("sha1", data)
end

return utils