package = "moonstore"
version = "0.0.1-1"
source = {
   url = "http://..." -- We don't have one yet
}
dependencies = {
  "luacrypto >= 0.3",
  "luafilesystem >= 1.5"
}
build = {
  type = "builtin",
  modules = {
    moonstore = "moonstore.lua",
    ["moonstore.store"] = "moonstore/store.lua",
    ["moonstore.utils"] = "moonstore/utils.lua"
  }
}