add_luci_conffiles()
{
	local filelist="$1"

	# save ssl certs
	if [ -d $meshr/etc/nixio ]; then
		find $meshr/etc/nixio -type f >> $filelist
	fi

	# save uhttpd certs
	[ -f "$meshr/etc/uhttpd.key" ] && echo $meshr/etc/uhttpd.key >> $filelist
	[ -f "$meshr/etc/uhttpd.crt" ] && echo $meshr/etc/uhttpd.crt >> $filelist
}

sysupgrade_init_conffiles="$sysupgrade_init_conffiles add_luci_conffiles"

