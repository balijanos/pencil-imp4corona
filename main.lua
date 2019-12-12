-- main.lua
--
-- ====================================================================
-- Pencil importer example
-- ====================================================================
--
-- (c) 2018-19, IT-Gears.hu
-- 
-- Author: Janos Bali
--

local importFile = "epz/DesignTest.epz"
local exportDir = "testapp"
local prefix = "testapp"
display.setDefault( "background", 1,1,1,1 )	
--------------------------------------
local pimp = require "pimp.pimp"
local pimpCore = require "pimp.core"
local composer = require "composer"

local function pimpDone(prjName, startPage)
  print(prjName, startPage)
  pimpCore.setDir(exportDir)
  pimpCore.setPrefix(prefix)
  composer.gotoScene(exportDir.."."..startPage)
end

pimp.import(importFile, exportDir, prefix, pimpDone)
