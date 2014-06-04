rootfs = os.getenv("meshr") or ''
if #rootfs > 0 then
  if string.match(... or "", "--splash") then
    smode = '/controller2/'
  end
  hostos = 'win32'
  package.path= rootfs .. '/usr/lib/lua/?.lua;' .. rootfs .. '/usr/lib/lua/?/init.lua;;'
  package.cpath= rootfs .. '/usr/lib/lua/?.so;;'
end  
dofile (rootfs .. "/setup.lua")
require "luci.lucid".start()
