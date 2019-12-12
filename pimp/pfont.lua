local fonts = {
  ["MaterialIcons"] = "fonts/MaterialIcons-Regular.ttf",
} 

local m = {}

function m.get(fontName)
  if fonts[fontName] then
    return native.newFont( fonts[fontName], 16 )
  else
    return native.systemFont
  end
end

return m