-- pimpCore.lua
--*********************************************************************************************
--
-- ====================================================================
-- Core functions for Pencil imported pages
-- ====================================================================
--
-- File: pimpCore.lua
--
-- (c) 2018, IT-Gears.hu
-- 
-- Author: Janos Bali
--
-- Version 1.1
--
--*********************************************************************************************
local widget = require "widget" 
local composer = require "composer"

mFont = "icon-font/MaterialIcons-Regular.ttf"
mIcon = require("icon-font.codepoints")

local cbPencilCore = {}

local pimpDir = ""

function cbPencilCore.setDir(dirName)
  pimpDir = dirName
end

function cbPencilCore.newRect(opt)
  local obj
  if opt.cornerRadius == 0 then
    obj = display.newRect(opt.x + opt.width/2, opt.y + opt.height/2, opt.width, opt.height)
  else
    obj = display.newRoundedRect(opt.x + opt.width/2, opt.y + opt.height/2, opt.width, opt.height, opt.cornerRadius)
  end
  obj.strokeWidth = opt.strokeWidth
  obj:setFillColor(unpack(opt.fillColor))
  obj:setStrokeColor(unpack(opt.strokeColor))
  if opt.sceneGroup then
    opt.sceneGroup:insert(obj)
  end
  return obj
end

function cbPencilCore.newCircle(opt)
  local obj
  obj = display.newCircle(opt.x + opt.radius, opt.y + opt.radius, opt.radius)
  obj.strokeWidth = opt.strokeWidth
  obj:setFillColor(unpack(opt.fillColor))
  obj:setStrokeColor(unpack(opt.strokeColor))
  if opt.sceneGroup then
    opt.sceneGroup:insert(obj)
  end
  return obj
end

function cbPencilCore.newText(opt)
  local obj
  obj = display.newText(opt)
  obj.x = obj.x + obj.width/2
  obj.y = obj.y + obj.height/2
  obj:setFillColor(unpack(opt.fillColor))
  if opt.sceneGroup then
    opt.sceneGroup:insert(obj)
  end
  return obj
end

function cbPencilCore.newMaterialIcon(opt)
  local obj
  obj = display.newText(opt)
  obj.x = obj.x + obj.width/2
  obj.y = obj.y + obj.height/2
  obj:setFillColor(unpack(opt.fillColor))
  if opt.sceneGroup then
    opt.sceneGroup:insert(obj)
  end
  if opt.reference then
    obj:addEventListener("touch",
      function(event)
        if event.phase=="ended" then
          composer.gotoScene(pimpDir.."."..opt.reference)
        end
        return true
      end
    )
  end
  return obj
end

function cbPencilCore.newButton(opt)
  local obj
  opt.x = opt.x + opt.width/2
  opt.y = opt.y + opt.height/2
  obj = widget.newButton(opt)
  if opt.sceneGroup then
    opt.sceneGroup:insert(obj)
  end
  if opt.reference then
    obj:addEventListener("touch",
      function(event)
        if event.phase=="ended" then
          composer.gotoScene( pimpDir.."."..opt.reference)
        end
        return true
      end
    )
  end
  return obj
end

function cbPencilCore.newSpinner(opt)
  local obj
  opt.x = opt.x + opt.width/2
  opt.y = opt.y + opt.height/2
  obj = widget.newSpinner(opt)
  if opt.sceneGroup then
    opt.sceneGroup:insert(obj)
  end
  return obj
end

function cbPencilCore.newImageRect(opt)
  local obj
  opt.image = pimpDir.."/"..opt.image
  obj = display.newImageRect(opt.image,system.ResourceDirectory,opt.width,opt.height)
  obj.x = opt.x + opt.width/2
  obj.y = opt.y + opt.height/2
  if opt.sceneGroup then
    opt.sceneGroup:insert(obj)
  end
  return obj
end

function cbPencilCore.newSwitch(opt)
  local obj
  opt.x = opt.x + opt.width/2
  opt.y = opt.y + opt.height/2
  obj = widget.newSwitch(opt)
  if opt.sceneGroup then
    opt.sceneGroup:insert(obj)
  end
  return obj
end

function cbPencilCore.newSlider(opt)
  local obj
  opt.x = opt.x + opt.width/2
  opt.y = opt.y + opt.height/2
  obj = widget.newSlider(opt)
  if opt.sceneGroup then
    opt.sceneGroup:insert(obj)
  end
  return obj
end

function cbPencilCore.newProgressView(opt)
  local obj
  opt.x = opt.x + opt.width/2
  opt.y = opt.y + opt.height/2
  obj = widget.newProgressView(opt)
  if opt.sceneGroup then
    opt.sceneGroup:insert(obj)
  end
  obj:setProgress( opt.progress )
  return obj
end

function cbPencilCore.newTabBar(opt)
  local obj
  opt.left = opt.left
  opt.top = opt.top
  obj = widget.newTabBar(opt)
  if opt.sceneGroup then
    opt.sceneGroup:insert(obj)
  end
  return obj
end

-- Generic widgets handlers
local genericWidgets = {
  ["newTextField"] = "widget.newTextField",
  ["newTextBox"] = "widget.newTextBox",
  ["newWebView"] = "widget.newWebView",
  ["newMapView"] = "widget.newMapView",
}

function cbPencilCore.newGenericObject(opt)
  opt.x = opt.x + opt.width/2
  opt.y = opt.y + opt.height/2
  if genericWidgets[opt.genericType] then
    local gw = require (genericWidgets[opt.genericType])
    local obj = gw(opt)
    if opt.sceneGroup then
      opt.sceneGroup:insert(obj)
    end
    return obj
  end
  return {}
end


return cbPencilCore