-- 
-- generated by pimp v1.1
-- 
-- (c) 2018, IT-Gears.hu
-- 
-- Author: Janos Bali
--
--
local pimpCore = require "pimp.pimpCore"
local m={}
local objectOptions = {}
function m.getObjectOptions()
  return objectOptions
end
function m.getSceneObjects(event,sceneGroup)
  local opt, obj
  local sceneObjects = {}
  
	objectOptions["designRect3"] = {
	id = "designRect3",
	isVisible = true,
	x = 0,
	y = 48,
	width = 720,
	height = 80,
	cornerRadius = 0,
	strokeWidth = 0,
	fillColor = {1,1,0.8,0.47843137254902},
	strokeColor = {0,0,0,0},
	sceneGroup = sceneGroup,
	reference = nil,
	}
	obj = pimpCore.newRect (objectOptions["designRect3"])
	sceneObjects["designRect3"] = obj
	obj.isVisible = true

	objectOptions["My_MaterialIcon3"] = {
	id = "My_MaterialIcon3",
	isVisible = true,
	text = mIcon.get("info_outline"),
	x = 23,
	y = 64,
	width = 48,
	height = 48,
	font = mFont,
	fontSize = 48,
	fillColor = {0.34509803921569,0.50196078431373,0.8,0.47843137254902},
	sceneGroup = sceneGroup,
	reference = nil,
	}
	obj = pimpCore.newMaterialIcon (objectOptions["My_MaterialIcon3"])
	sceneObjects["My_MaterialIcon3"] = obj
	obj.isVisible = true

	objectOptions["My_MaterialIcon4"] = {
	id = "My_MaterialIcon4",
	isVisible = true,
	text = mIcon.get("arrow_back"),
	x = 650,
	y = 64,
	width = 48,
	height = 48,
	font = mFont,
	fontSize = 48,
	fillColor = {0.34509803921569,0.50196078431373,0.8,0.47843137254902},
	sceneGroup = sceneGroup,
	reference = "Page01",
	}
	obj = pimpCore.newMaterialIcon (objectOptions["My_MaterialIcon4"])
	sceneObjects["My_MaterialIcon4"] = obj
	obj.isVisible = true

	objectOptions["My_Text4"] = {
	id = "My_Text4",
	isVisible = true,
	text = "Application Title",
	x = 251,
	y = 70,
	font = native.systemFont,
	fontSize = 36,
	fillColor = {0.34509803921569,0.50196078431373,0.8,0.47843137254902},
	width = 262,
	height = 40,
	align= "center",
	sceneGroup = sceneGroup,
	reference = nil,
	}
	obj = pimpCore.newText (objectOptions["My_Text4"])
	sceneObjects["My_Text4"] = obj
	obj.isVisible = true

	objectOptions["My_Text5"] = {
	id = "My_Text5",
	isVisible = true,
	text = "Back",
	x = 0,
	y = 107,
	font = native.systemFont,
	fontSize = 24,
	fillColor = {1,0.54901960784314,0.23137254901961,0.92941176470588},
	width = 702,
	height = 27,
	align= "right",
	sceneGroup = sceneGroup,
	reference = nil,
	}
	obj = pimpCore.newText (objectOptions["My_Text5"])
	sceneObjects["My_Text5"] = obj
	obj.isVisible = true

	objectOptions["email_Page02"] = {
	id = "email_Page02",
	isVisible = true,
	text = "Thank you!",
	x = 0,
	y = 180,
	font = native.systemFontBold,
	fontSize = 28,
	fillColor = {0.8,0.2,0.8,0.92941176470588},
	width = 720,
	height = 31,
	align= "center",
	sceneGroup = sceneGroup,
	reference = nil,
	}
	obj = pimpCore.newText (objectOptions["email_Page02"])
	sceneObjects["email_Page02"] = obj
	obj.isVisible = true

	objectOptions["My_Image"] = {
	id = "My_Image",
	isVisible = true,
	image = "refs/4eba44a9c5714b7bbfc87fc89a931fcb.jpg",
	width = 468,
	height = 336,
	x = 132,
	y = 216,
	sceneGroup = sceneGroup,
	reference = nil,
	}
	obj = pimpCore.newImageRect (objectOptions["My_Image"])
	sceneObjects["My_Image"] = obj
	obj.isVisible = true

	objectOptions["My_WebView"] = {
	id = "My_WebView",
	isVisible = true,
	genericType = "newWebView",
	hasText = false,
	hasRect = false,
	hasOverColors = false,
	x = 0,
	y = 585,
	width = 720,
	height = 695.7031250000001,
	urlRequest="https://coronalabs.com/blog",
canGoForward = true,
canGoBack = true,
	sceneGroup = sceneGroup,
	reference = nil,
	}
	obj = pimpCore.newGenericObject (objectOptions["My_WebView"])
	sceneObjects["My_WebView"] = obj
	obj.isVisible = true

  return sceneObjects
end
return m
