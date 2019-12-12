local newTextBox = function(opt)
  
  -- input field background
  if opt.hasRect then 
    _=[[
    local inputBackground = display.newRect(  
      opt.x, 
      opt.y,
      opt.width, 
      opt.height
    )
    inputBackground:setFillColor( unpack(opt.fillColor) )
    inputBackground:setStrokeColor( unpack(opt.strokeColor) )
    inputBackground.strokeWidth = opt.strokeWidth
    ]]
  end
  
  -- native.textfield
  local textBox = native.newTextBox(
    opt.x, 
    opt.y,
    opt.width, 
    opt.height
  )
  textBox.id = opt.id
  textBox.text = opt.text
  textBox.align = opt.align
  textBox.hasBackground = false
  textBox.isEditable = opt.isEditable or false
  textBox:setReturnKey( "done" )
  textBox.font = native.newFont( native.systemFont, opt.fontSize )
  
  textBox:setTextColor(unpack(opt.textColor))
  
  return textBox, inputBackground
end

return newTextBox