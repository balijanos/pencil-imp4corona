local newWebView = function(opt)
  
  -- native.textfield
  local webView = native.newWebView(
    opt.x, 
    opt.y,
    opt.width, 
    opt.height
  )
  webView.id = opt.id
  webView.hasBackground = opt.hasBackground or false
  webView.canGoBack = opt.canGoBack or false
  webView.canGoForward = opt.canGoForward or false
  
  webView:request(opt.urlRequest, opt.localDirectory)
  
  return webView
end

return newWebView