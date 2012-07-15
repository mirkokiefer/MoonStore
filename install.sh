mkdir deps
git clone https://github.com/keplerproject/luafilesystem.git ./deps/lfs

cd deps/lfs
luarocks make --local rockspecs/luafilesystem-1.5.0-1.rockspec
