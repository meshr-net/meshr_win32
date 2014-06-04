# Meshr.Net

   Meshr is a free open source software for creating and popularization
   of mesh networks. The main goals of Meshr are to make Internet
   available to as much number of people as possible all over the world
   and to make communication between people free and depend only on mesh
   network participents. To reach this goal it makes available easy to
   use cross-platform versions of Freifunk Openwrt firmwares for
   international community. Meshr is an open and independent project.
   Everyone is welcome to contribute.
   
   Experimental software version for Windows is available now. It allows
   to connect to Freifunk networks and meshr.net free Internet gateways
   anonymized by TOR.
   
   Use the links below to explore the site contents. You'll find some
   content translated into other languages, but the primary documentation
   language is English.
   
   For general questions about Meshr see the communication page or ask at
   the support desk.

### What is Meshr? 
   
   Meshr.Net is:
     * feature-rich and extensible;
     * scalable and suitable for both small and large networks;
     * available in your language;
     * simple to install, working on most hardware/software combinations.

### Installation requirements
   
   Meshr 0.1 requires Windows XP sp3 or later.
   
   Tested Windows versions are:
     * Windows XP sp3
     * Windows 7 sp1
     * Windows 8.1
       
   Security reminder: Meshr requires Administrator privileges to install.
   

### Installation guide
   
     * You need to confirm TUN/TAP adapter installation. It is used to
       provide you anonymized Internet access.
       

### Configuration
       
   You should configure meshr thru Web interface here
   http://127.0.0.1:8084
   
  Configuration changes in 0.1
  
     *  %meshr% Windows environment variable added. It contains software
       install path. Default value is C:/opt/meshr
     * Windows related configuration files added to /etc folder:
          +  %meshr%/etc/wlan/ folder contains *.xml files for Windows
            wireless profile configuration settings and *.wmic files for
            ip configuration settings.
          +  %meshr%/etc/wifi file contains settings for default wireless
            adapter

### Meshr feature list

  Automatic configuration
  
   Meshr runs automatic configuration script during installation (it
   is %meshr%/defaults.bat). More info
   
  Automatic updates
  
   Meshr does checks for updates every 24 hours. It checks last version
   tag in git and downloads it if it is new. It also updates ipkg
   software list.

### How it works?
       
Before first use

   Meshr generates default config after installation to create new meshr
   node (in "%meshr%/default.bat")
    1. Meshr tries to determine your current geo-location to add your
       computer to meshr community.
    2. You get IP-address in 10.177.0.0/16 range from meshr.net while
       installation. IP is generated automatically in
       10.177.128.1-10.177.253.255 range if there is no Internet access.
    3. Meshr is looking for known mesh networks that are available. If it
       finds any it configures network settings to create new node of
       this network. If there is no known networks then it configures
       network settings to create new node of meshr network.
       
Everyday use

   Meshr is monitoring status of your wireless node (in
   "%meshr%/lib/watchdog.bat")
    1. If your computer has Internet access and your wireless adapter is
       unused then meshr creates ad-hoc network and waits for users to
       connect
         1. If there is a new user connection then meshr launches on your
            computer:
              1. TOR - it is socks proxy server for tunneling all new
                 user's connections to Internet through it (it is here
                 127.0.0.1:9150)
              2. meshr-splash - it is webserver with welcome page for new
                 users (it used tcp socket like 10.177.X.X:80). It is
                 necessary to provide meshr software download link to new
                 users to enable them access to mesh networks, including
                 TOR proxy servers for anonymous Internet access.
              3. DualServer - it is DHCP and DNS server in one. It
                 provides IP address, default gateway and DNS server for
                 new user. This settings are necessary to direct new user
                 to your welcome page with meshr software download link.
              4. olsrd - it is routing software that provides
                 connectivity between mesh nodes even if there is no
                 direct connection between them. It also advertised TOR
                 proxy servers for Internet access.
         2. If all users disconnect from your node then meshr stops TOR,
            DualServer and meshr-splash services
    2. If your computer has no Internet access and you are connecting to
       meshr node (wireless network with meshr.net name) then
         1. If you haven't installed meshr software then you will get
            meshr welcome page instead of any Internet page. You need to
            download and install meshr software in this case.
         2. If you have installed meshr software then you get IP-address
            from it, then meshr launches on your computer olsrd routing
            service and looks for available TOR proxy servers. Once it
            finds working one it launches (in "%meshr%/lib/tor-tun.bat"):
              1. badvpn-tun2socks It connects your TAP adapter with to
                 TOR proxy server. As a result new local internet gateway
                 is created: 10.177.254.2
              2. dns2socks It creates local dns server 10.177.254.1 for
                 resolving Internet domains thru TOR socks server.
              3. Default gateway is set to 10.177.254.2 and dns is set to
                 10.177.254.1 to enable Internet access
       

### Upgrading

   Run "meshr-update" link from start menu or update.bat from
   installation folder (default: C:\opt\meshr) to update manually. Meshr
   does automatic check and update every 24h.

### Author ###

* Yury Popov (<meshr.net[a]googlemail.com>)
