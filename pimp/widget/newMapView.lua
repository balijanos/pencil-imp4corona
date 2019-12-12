local newMapView = function(opt)
  
  if system.getInfo("environment") ~= "simulator" then
    opt.center = opt.center or {0,0}
    -- native.textfield
    local mapView = native.newMapView(
      opt.x, 
      opt.y,
      opt.width, 
      opt.height
    )
    mapView.id = opt.id
    mapView.mapType = opt.mapType or "standard"
    mapView.isLocationVisible = opt.isLocationVisible or false
    mapView.isScrollEnabled = opt.isScrollEnabled or false
    mapView.isZoomEnabled = opt.isZoomEnabled or false
    mapView:setCenter( unpack(opt.center or mapView:getUserLocation()) )
    return mapView
  else
    return display.newRect(opt.x, opt.y, opt.width, opt.height)
  end
end

return newMapView