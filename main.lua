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

-- local importFile = "epz/corona_v1.epz"
local importFile = "epz/scene_test.epz"
--------------------------------------
local pimp = require "pimp.pimp"
local pimpCore = require "pimp.pimpCore"
local composer = require "composer"
local exportDir = "export" 

local function pimpDone(prjName, startPage)
  pimpCore.setDir(exportDir)
  composer.gotoScene(exportDir.."."..startPage)
end

display.setStatusBar( display.DefaultStatusBar )
display.setDefault( "background", 1,1,1,1 )	
pimp.import(importFile, exportDir, pimpDone)