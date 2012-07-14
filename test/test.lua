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

local function testHash()
  local data = "abc"
  local knownHash = "a9993e364706816aba3e25717850c26c9cd0d89d"
  assert(utils.hash(data) == knownHash, "test hash")
end

local function testSplitString()
  local aString = "a/bc/d"
  local splitted = utils.splitString(aString, "/")
  assert(splitted[1] == "a")
  assert(splitted[2] == "bc")
  assert(splitted[3] == "d")
end

local testFolder = "teststore"

testFilestore(testFolder)
testHash()
testSplitString()