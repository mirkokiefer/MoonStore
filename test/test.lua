package.path = "../moonstore/?.lua;" .. "../?.lua;" .. package.path
local ms = require("moonstore")
local lfs = require("lfs")
local os = require("os")
local utils = require("utils")
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

  store.delete(mystore)
end

local function testHash()
  local data = "abc"
  local knownHash = "a9993e364706816aba3e25717850c26c9cd0d89d"
  assert(utils.hash(data) == knownHash, "test hash")
end




local testFolder = "teststore"

testStore(testFolder)
testHash()