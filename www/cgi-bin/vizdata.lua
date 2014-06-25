local rootfs = rootfs or ''
local hostos = hostos or ''

if hostos:sub(1,3) == 'win' then
  require "os".execute("Quiet " .. rootfs .. "/www/cgi-bin/vizdata.bat")
  return require "luci.model.ipkg".file_exists("/tmp/vizdata.tmp") and require "nixio.fs".readfile(rootfs .. "/tmp/vizdata.tmp") or ''
else
  return require "io".popen(rootfs .. "/www/cgi-bin/vizdata.sh"):read("*a")
end