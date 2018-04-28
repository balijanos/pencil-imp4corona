-- main.lua
--
-- ====================================================================
-- Pencil importer example
-- ====================================================================
--
-- (c) 2018, IT-Gears.hu
-- 
-- Author: Janos Bali
--

local importFile = "epz/DesignTest.epz"
local exportDir = "export" 
display.setDefault( "background", 1,1,1,1 )	
--------------------------------------
local pimp = require "pimp.pimp"
local pimpCore = require "pimp.pimpCore"
local composer = require "composer"

local function pimpDone(prjName, startPage)
  print(prjName, startPage)
  pimpCore.setDir(exportDir)
  composer.gotoScene(exportDir.."."..startPage)
end

pimp.import(importFile, exportDir, pimpDone)
