
local ms = require("moonstore")
local lfs = require("lfs")
local os = require("os")
local store = ms.store
local branch = ms.branch
local peer = ms.peer

local function testStore(directory)
  local mystore = ms.store.new(directory)
  local path = "test"
  local data = "abcd"
  store.write(mystore, path, data)
  local retrievedData = store.read(mystore, path)
  assert(data == retrievedData, "read/write data to store")
end

local function deleteDirectory(directory)
  for file in lfs.dir(directory) do
    os.remove(directory.."/"..file)
  end
  os.remove(directory)
end

local testFolder = "teststore"
testStore(testFolder)
deleteDirectory(testFolder)
