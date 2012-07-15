package = "moonstore"
version = "0.0.1-1"
source = {
   url = "http://..." -- We don't have one yet
}
dependencies = {
  "lua >= 5.1",
  "luacrypto >= 0.3"
}
build = {
  type = "builtin",
  modules = {
    moonstore = "moonstore.lua",
    ["moonstore.filestore"] = "moonstore/filestore.lua",
    ["moonstore.utils"] = "moonstore/utils.lua"
  }
}