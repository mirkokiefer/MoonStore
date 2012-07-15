package.path = "../moonstore/?.lua;" .. "../?.lua;" .. package.path
local ms = require("moonstore")
local lfs = require("lfs")
local os = require("os")
local utils = require("utils")
local filestore = require("filestore")

local function testFilestore(directory)
  local mystore = filestore.new(directory)
  local path = "test"
  local data = "abcd"
  filestore.write(mystore, path, data)
  local retrievedData = filestore.read(mystore, path)
  assert(data == retrievedData, "read/write data to store")

  filestore.delete(mystore)
end

local function testUtils()
  local testHash = function ()
    local data = "abc"
    local knownHash = "a9993e364706816aba3e25717850c26c9cd0d89d"
    assert(utils.hash(data) == knownHash, "test hash")
  end
  local testList = function()
    list = utils.list(1,2,3)
    assert(list.first==1 and list.rest.first==2 and list.rest.rest.first ==3)
  end
  local testListReverse = function()
    list = utils.list(1,2,3)
    reversed = utils.listReverse(list)
    a,b,c = utils.listValues(reversed)
    assert(a==3 and b==2 and c==1)
  end
  local testSplitString = function()
    local aString = "a/bc/d"
    local splitted = utils.splitString(aString, "/")
    a,b,c = utils.listValues(splitted)
    assert(a == "a" and b == "bc" and c == "d")
  end
  testHash()
  testList()
  testListReverse()
  testSplitString()
end

local function testMoonStore(directory)
  store = ms.create(directory)
  data1 = {
    ["a/b"] = "value1",
    ["a/c"] = "value2",
    ["d"] = "value3",
    ["a/e/f"] = "value4"
  }
  data2 = {
    ["a/b"] = "value1_changed",
    ["d"] = nil,
    ["a/e/g"] = "new_value"
  }
  commit1 = ms.commit(store, nil, data1)
  commit2 = ms.commit(store, commit1, data2)

end

local testFolder = "teststore"

testFilestore(testFolder)
testUtils()