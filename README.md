# pimp-v1.0
Pencil UI design importer for Corona Sdk

## Installing Corona Sdk stencils for Evolus Pencil
Download latest version (3.0.4) for [Pencil](https://pencil.evolus.vn/)
Select "Tools/Manage Collections" from menu. Click on "Install from file" button and locate the stencil file CoronaSdk-Pencil-Stencils-v1.0.
Open sample design from "epz" folder. 

## Preparing Pimp for import
To change current configuration modify the `main.lua` file

main.lua:
```
local importFile = "epz/scene_test.epz"
local exportDir = "export" 
display.setDefault( "background", 1,1,1,1 )	
```
Pimp will export generated files to `exportDir`. After generation finshed the program executes the **first page** of the UI design pages.
```
local function pimpDone(prjName, startPage)
  pimpCore.setDir(exportDir)
  composer.gotoScene(exportDir.."."..startPage)
end
pimp.import(importFile, exportDir, pimpDone)
```
## Editing generated files
