package.path = "../moonstore/?.lua;" .. "../?.lua;" .. package.path
local ms = require("moonstore")
local os = require("os")
local utils = require("utils")
list = utils.list
local filestore = require("filestore")

local function testFilestore(directory)
  local mystore = filestore(directory)
  local path = "test"
  local data = "abcd"
  mystore.write(path, data)
  local retrievedData = mystore.read(path)
  assert(data == retrievedData, "read/write data to store")
  mystore.writeBlob(path, data)
  local retrievedData1 = mystore.readBlob(path)
  assert(data == retrievedData1, "read/write blob to store")
  mystore.delete()
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
    local a,b,c = utils.listValues(splitted)
    assert(a == "a" and b == "bc" and c == "d")
  end
  local testListToTree = function()
    local data = {
      ["a/b"] = "value1",
      ["a/c"] = "value2",
      ["d"] = "value3",
      ["a/e/f"] = "value4"
    }
    local dataList = utils.pathTableToList(data)
    local tree = utils.listToTree(dataList)
    assert(tree.a.b == "value1" and tree.a.c == "value2" and tree.d == "value3" and tree.a.e.f == "value4")
  end
  local testSerialize = function()
    local data = {a = 1, b = "hello", c = {1,2}}
    local string = utils.serializeToString(data)
    local deserialized = utils.deserializeString(string)
    assert(deserialized.a == data.a and deserialized.b == data.b)
    assert(deserialized.c[1] == data.c[1] and deserialized.c[2] == data.c[2])
  end
  testHash()
  testList()
  testListReverse()
  testSplitString()
  testListToTree()
  testSerialize()
end

local function testMoonStore(directory)
  local store = ms.new(directory)
  local data1 = {
    ["a/b"] = "value1",
    ["a/c/g"] = "value2",
    ["a/c/h"] = "value5",
    ["d"] = "value3",
    ["a/e/f"] = "value4"
  }
  local data2 = {
    ["a/b"] = "value1_changed",
    ["d"] = false,
    ["a/e/g"] = "new_value"
  }
  local commit1 = ms.commit(store, nil, data1)
  local commit2 = ms.commit(store, commit1, data2)
  assert(commit1 == "505ee8872573da12e488b6bf9fd3aafca6e84b9d")
  assert(commit2 == "34f9267379d5da5f31cdfd5b951c0b27a752b633")

  ms.delete(store)
end

testFilestore("teststore")
testUtils()
testMoonStore("testmoon")
