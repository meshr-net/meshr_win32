# Meshr.Net

   Meshr is a free open source software for creating and popularization
   of mesh networks. The main goals of Meshr are to make Internet
   available to as much number of people as possible all over the world,
   to make communication between people free and depend only on mesh
   network members and to make free and accurate Wi-Fi positioning. To
   reach these goals it makes available easy to use zero-configuration
   cross-platform software versions of Freifunk Openwrt firmwares (no
   need to reflash your firmware) for international community. Meshr is
   an open and independent project. Everyone is welcome to contribute.
   
   Software versions for different platforms including Windows are
   available now. They allow to connect to Freifunk networks and
   meshr.net free Internet gateways anonymized by TOR.

   Use the links below to download and install Meshr on Windows
   https://github.com/meshr-net/meshr_win32/releases/download/latest/meshr_win32.exe

### Installation requirements
 
   Meshr requires PC with Windows XP sp3 or later. Tested Windows
   versions are:
     * Windows XP sp3
     * Windows 7 sp1
     * Windows 8.1
       
  Notes
  
     * Wireless network adapter should be turned on.
     * Windows 8: Wireless devices should be turned on (Click "Logo
       key"+C : Settings -> Change PC Settings -> Wireless -> turn on)
       
   Security reminder: Meshr requires Administrator privileges to install.
   

### Installation guide

     * Download and run meshr_win32.exe to start installation.
     * Run meshr_win32.exe /S for silent installation.
     * You need to confirm TUN/TAP adapter installation. It is required
       to provide you anonymized Internet access.
     * Run Uninstall.exe from installation folder to uninstall meshr (or
       run it from Start -> Run %meshr%\Uninstall.exe).
       

### Configuration

   Navigate to http://127.0.0.1:8084 in your browser to configure meshr
   thru Web interface.
   
   Notes:
     *  %meshr% Windows environment variable added. It contains software
       install path. Default value is C:/opt/meshr
     * Windows related configuration files added to /etc folder:
          + %meshr%/etc/wlan/ folder contains *.xml files for Windows
            wireless profile configuration settings and *.txt files for
            ip configuration settings.
          + %meshr%/etc/wifi.txt file contains settings for default
            wireless adapter.
       

### Meshr feature list

     * Free Internet. Meshr shares and anonymizes your internet
       connection. It provides you free Internet access thru other nodes.
     * P2P distribution. Meshr doesn't require Internet for operation. It
       distributes required software thru its users home pages
       (splashscreens).
     * Auto-connection. Meshr uses wifi profiles to setup/restore wifi
       adapter settings. It connects to meshr.net automatically if you
       wifi adapter is idle.
     * Mesh-network compatibility. Meshr is compatible with the other
       Freifunk mesh networks. It runs automatic configuration when it is
       connected to know mesh-networks.
     * Wide device compatibility. Meshr uses olsr routing protocol, which
       has wide compatibility: BSD, i386, Android, iPhone, Linux, Mac
       OSX, Win32. Meshr can be installed on local PC and remote router
       from the same installation file. No reflashing firmware required
       for routers when possible.
     * Multilanguage support.
     * Unified webinterface for all devices. Background working process.
     * Minimum system requirements. Meshr software for routers can be
       installed on network drive (nfs or samba) or even to RAM (/tmp).
       No flashdrive requirements.
     * Zero-configuration. Meshr runs automatic configuration script
       during installation (it is ./defaults.bat script file in the
       installation folder). It does automatic geo-location during
       configuration..
     * Automatic updates. Meshr does checks for updates every 24 hours
       (it is ./update.bat script file). It checks release branch in git
       and downloads modified files if there are new ones. You can also
       run ./lib/update-master.bat batch file manually to update to the
       most recent version from master (pre-release) branch. It also
       updates ipkg software list.

### How it works?
       
Before first use

   Meshr generates default configuration after installation to create new
   meshr node (it is here ./default.bat)
    1. Meshr tries to determine your current geo-location to fill basic
       settings for you (it is here
       http://127.0.0.1:8084/luci/admin/freifunk/basics/, or replace
       127.0.0.1 with your router IP if you installed meshr into it).
    2. You get IP-address in 10.177.0.0/16 range from meshr.net while
       installation. IP is generated automatically in
       10.177.128.1-10.177.253.255 range if there is no Internet access.
    3. Meshr is looking for known mesh networks that are available in the
       air. If it finds any it configures meshr settings to create new
       node of this network. If there is no known networks then it
       configures meshr settings to create new node of meshr.net network.
       
   Note: Additional setup is needed for Freifunk olsr mesh networks other
   than meshr (any help for integration with other mesh networks is
   welcome).
    1. Make sure correct community is selected on "Administration ->
       Freifunk -> Basic Settings" page
       http://127.0.0.1:8084/luci/admin/freifunk/basics/, or replace
       127.0.0.1 with your router IP if you installed meshr there.
    2. Go to "Administration -> Freifunk -> Mesh Wizard" page. Select
       Interface where "Mesh IP address" is enabled and input your
       community ip address there. Press "Save & Apply" button to apply
       new settings (i.e. network and olsrd settings).
       
Everyday use

   Meshr is monitoring status of your wireless adapter (in
   ./lib/watchdog.bat)
    1. If your computer has Internet access and your wireless adapter is
       unused then meshr creates ad-hoc network and waits for users to
       connect
         1. If there is a new user connection then meshr launches on your
            computer (under linux it happens even without new user
            connection):
              1. TOR - it is socks proxy server for tunneling all new
                 user's connections to Internet through it (it is here
                 127.0.0.1:9150).
              2. meshr-splash - it is a webserver with welcome page for
                 new users (it used tcp socket like 10.177.X.X:80). It is
                 necessary to provide meshr software download link to new
                 users to enable them access to mesh networks, including
                 TOR proxy servers for anonymous Internet access.
              3. DualServer or dnsmasq (under linux) - it is DHCP and DNS
                 server in one (DualServer web interface is
                 http://127.0.0.1:6789 ). It provides IP address, default
                 gateway and DNS server for new users. This settings are
                 necessary to direct new user to your welcome page with
                 meshr software download link.
              4. olsrd - it is routing software that provides
                 connectivity between mesh nodes even if there is no
                 direct connection between them. It also advertised TOR
                 proxy servers for Internet access.
         2. If all users disconnect from your node then meshr stops TOR,
            DualServer/dnsmasq and meshr-splash services and restores
            your old IP settings (it happens only under Windows) .
    2. If your computer has no Internet access and you are connecting to
       meshr node (wireless network with meshr.net name) then
         1. If you haven't installed meshr software then you will get
            meshr welcome page instead of any Internet page. You need to
            download and install meshr software in this case.
         2. If you have installed meshr software then you get IP-address
            from it, then meshr launches on your computer olsrd routing
            service and looks for available TOR proxy servers. Once it
            finds working one it launches (in ./lib/tor-tun.bat):
              1. badvpn-tun2socks It connects your TAP adapter with a TOR
                 proxy server from mesh network. As a result new local
                 internet gateway is created: 10.177.254.2
              2. dns2socks It creates local dns server 10.177.254.1 for
                 resolving Internet domains thru TOR socks server.
              3. Default gateway is set to 10.177.254.2 and dns is set to
                 10.177.254.1 to enable Internet access
       

### Author ###

* Yury Popov ( meshr.net[at]googlemail.com )

This file is generated automatically from http://meshr.net wiki pages