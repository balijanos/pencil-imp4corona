local newTextField = function(opt)
  
  -- input field background
  if opt.hasRect then 
    _=[[
    local inputBackground = display.newRect(  
      opt.x, 
      opt.y,
      opt.width, 
      opt.height
    )
    inputBackground.id = opt.id
    inputBackground:setFillColor( unpack(opt.fillColor) )
    inputBackground:setStrokeColor( unpack(opt.strokeColor) )
    inputBackground.strokeWidth = opt.strokeWidth
    ]]
  end
  
  -- native.textfield
  local textField = native.newTextField(
    opt.x, 
    opt.y,
    opt.width, 
    opt.height
  )
  textField.id = opt.id
  textField.text = opt.text
  textField.align = opt.align
  textField.isSecure = opt.isSecure or false
  textField.hasBackground = false
  textField.inputType = opt.inputType or "default"
  textField:setReturnKey( "done" )
  textField.font = native.newFont( native.systemFont, opt.fontSize )
  
  textField:setTextColor(unpack(opt.textColor))
  
  return textField, inputBackground
end

return newTextField