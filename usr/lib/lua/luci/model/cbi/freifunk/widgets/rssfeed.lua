--[[
LuCI - Lua Configuration Interface

Copyright 2012 Manuel Munz <freifunk at somakoma dot de>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

	http://www.apache.org/licenses/LICENSE-2.0

]]--

local map, section = ...
local utl = require "luci.util"

local form, ferr = loadfile(utl.libpath() .. "/model/cbi/freifunk/widgets/heightwidth.lua")
if form then
	setfenv(form, getfenv(1))(m, wdg)
end

local url = wdg:option(Value, "url", translate("URL"))
url.default = "http://global.freifunk.net/rss/all/rss.xml"

local max = wdg:option(Value, "max", translate("Maximal entries to show"))
max.rmempty = true
max.default = "10"
max.datatype = "integer"

local cache = wdg:option(Value, "cache", translate("Cache Time"), translate("Cache downloaded feed for that many seconds."))
cache.rmempty = true
cache.default = "3600"
cache.datatype = "integer"


