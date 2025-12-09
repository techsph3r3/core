<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
 <title>Content Menu</title>
 <meta content="text/html; charset=iso-8859-1" http-equiv="Content-Type">
    <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate" />
    <meta http-equiv="Pragma" content="no-cache" />
    <meta http-equiv="Expires" content="0" />
 <% iw_webJSList_get(); %>
 <script type="text/javascript">
 <!--

 function redirect()
 {
  top.main.location="/setup_option.asp";
 }



 $(function()
 {
  if( <% iw_webContentShow(); %> == 1 )
   $("#area_home_link").show();
  else
   $("#area_home_link").hide();
 });


 -->
 </script>
 <style type="text/css">
  A:link { color:#0000FF; text-decoration: none;}
  A:visited { color:#0000FF; text-decoration: none; }
  A:hover { color:#FF0000; text-decoration: none; }
 </style>
</head>



<body style="margin-left:1px;margin-top:1px;font-family: Verdana; font-size: 10pt" bgcolor="#ccf4de">


 <div id="area_home_link">
  &nbsp;<a href="javascript:redirect()">Home</a>
 </div>

 <script type="text/javascript">
  foldersTree =gFld("<% iw_webSysDescHandler("MainMenuTree", "", "Main Menu"); %>");
   insDoc(foldersTree, gLnk(0, "<% iw_webSysDescHandler("OverviewTree", "", "Overview"); %>", "main.asp"));

   aux1 = insFld(foldersTree, gFld("<% iw_webSysDescHandler("BasicSettingsTree", "", "Basic Settings"); %>"));
     insDoc(aux1, gLnk(0, "<% iw_webSysDescHandler("SysInfoSettingsTree", "", "System Info Settings"); %>", "sysinfo.asp"));
     insDoc(aux1, gLnk(0, "<% iw_webSysDescHandler("InterfaceOnOffTree", "", "Interface On/Off"); %>", "interfaceOnOff.asp"));
     insDoc(aux1, gLnk(0, "<% iw_webSysDescHandler("NetworkSettingsTree", "", "Network Settings"); %>", "network_basic.asp"));
     insDoc(aux1, gLnk(0, "<% iw_webSysDescHandler("TimeSettingsTree", "", "Time Settings"); %>", "time_set.asp"));
   aux1 = insFld(foldersTree, gFld("<% iw_webSysDescHandler("WirelessSettingsTree", "", "Wireless Settings"); %>"));

     insDoc(aux1, gLnk(0, "AeroMag", "aeroMag.asp"));

     insDoc(aux1, gLnk(0, "Operation Mode", "wireless_opmode.asp"));
     aux2 = insFld(aux1, gFld("WLAN"));
      insDoc(aux2, gLnk(0, "<% iw_webSysDescHandler("BasicWirelessSettingsTree", "", "Basic Wireless Settings"); %>", "ap_selection.asp?set=basic&devIndex=1"));
      insDoc(aux2, gLnk(0, "<% iw_webSysDescHandler("SecuritySettingsTree", "", "Security Settings"); %>", "ap_selection.asp?set=security&devIndex=1"));
      insDoc(aux2, gLnk(0, "<% iw_webSysDescHandler("AdvancedWirelessSettingsTree", "", "Advanced Wireless Settings"); %>", "wireless_advan.asp?index=1"));
      insDoc(aux2, gLnk(0, "<% iw_webSysDescHandler("WLANCertificateSettingsTree", "", "WLAN Certificate Settings"); %>", "wireless_cert.asp?index=1"));
   aux1 = insFld(foldersTree, gFld("<% iw_webSysDescHandler("AdvancedSettings", "", "Advanced Settings"); %>"));

     insDoc(aux1, gLnk(0, "<% iw_webSysDescHandler("VLANSettingsTree", "", "VLAN Settings"); %>", "vlan_set.asp"));


     insDoc(aux1, gLnk(0, "<% iw_webSysDescHandler("DHCPServerTree", "", "DHCP Server"); %>", "dhcp_srv.asp"));




     aux2 = insFld(aux1, gFld("<% iw_webSysDescHandler("PacketFiltersTree", "", "Packet Filters"); %>"));
      insDoc(aux2, gLnk(0, "<% iw_webSysDescHandler("PacketFiltersMacTree", "", "MAC Filters"); %>", "FilterMac.asp"));
      insDoc(aux2, gLnk(0, "<% iw_webSysDescHandler("PacketFiltersIppTree", "", "IP Protocol Filters"); %>", "FilterIpp.asp"));
      insDoc(aux2, gLnk(0, "<% iw_webSysDescHandler("PacketFiltersPortTree", "", "TCP/UCP Port Filters"); %>", "FilterPort.asp"));

     insDoc(aux1, gLnk(0, "<% iw_webSysDescHandler("RstpSettingTree", "", "RSTP Settings"); %>", "rstp.asp"));


     insDoc(aux1, gLnk(0, "<% iw_webSysDescHandler("StaticRouteTree", "", "Static Route"); %>", "static_route.asp"));


     insDoc(aux1, gLnk(0, "<% iw_webSysDescHandler("NATSettingTree", "", "NAT Settings"); %>", "nat_settings.asp"));

     insDoc(aux1, gLnk(0, "<% iw_webSysDescHandler("SNMPAgentTree", "", "SNMP Agent"); %>", "SNMPAgent.asp"));







     insDoc(aux1, gLnk(0, "<% iw_webSysDescHandler("lfpTree", "", "Link Fault Pass-Through"); %>", "LFP.asp"));
   aux1 = insFld(foldersTree, gFld("<% iw_webSysDescHandler("AutoWarningSettingsTree", "", "Auto Warning Settings"); %>"));
     aux2 = insFld(aux1, gFld("<% iw_webSysDescHandler("SystemLogTree", "", "System log"); %>"));
      insDoc(aux2, gLnk(0, "<% iw_webSysDescHandler("SystemLogEventTree", "", "System Log Event Types"); %>", "system_event.asp"));
     aux2 = insFld(aux1, gFld("<% iw_webSysDescHandler("SysLogTree", "", "Syslog"); %>"));
      insDoc(aux2, gLnk(0, "<% iw_webSysDescHandler("SysLogEventTree", "", "Syslog Event Types"); %>", "syslog_event.asp"));
      insDoc(aux2, gLnk(0, "<% iw_webSysDescHandler("SysLogServerTree", "", "Syslog Server Settings"); %>", "syslog_server.asp"));
     aux2 = insFld(aux1, gFld("<% iw_webSysDescHandler("EmailTree", "", "E-mail"); %>"));
      insDoc(aux2, gLnk(0, "<% iw_webSysDescHandler("EmailEventTree", "", "E-mail Event Types"); %>", "email_event.asp"));
      insDoc(aux2, gLnk(0, "<% iw_webSysDescHandler("EmailServerTree", "", "E-mail Server Settings"); %>", "email_server.asp"));

     aux2 = insFld(aux1, gFld("<% iw_webSysDescHandler("RelayTree", "", "Relay"); %>"));
      insDoc(aux2, gLnk(0, "<% iw_webSysDescHandler("RelayEventTree", "", "Relay Event Types"); %>", "relay_event.asp"));

     aux2 = insFld(aux1, gFld("<% iw_webSysDescHandler("TrapTree", "", "Trap"); %>"));
      insDoc(aux2, gLnk(0, "<% iw_webSysDescHandler("TrapEventTree", "", "Trap Event Types"); %>", "trap_event.asp"));
      insDoc(aux2, gLnk(0, "<% iw_webSysDescHandler("TrapSetingsTree", "", "SNMP Trap Receiver Settings"); %>", "trap_server.asp"));






   aux1 = insFld(foldersTree, gFld("<% iw_webSysDescHandler("StatusTree", "", "Status"); %>"));

     insDoc(aux1, gLnk(0, "<% iw_webSysDescHandler("WirelessStatusTree", "", "Wireless Status"); %>", "wireless_status.asp"));
     insDoc(aux1, gLnk(0, "<% iw_webSysDescHandler("AssociatedClientListTree", "", "Associated Client List"); %>", "client_list.asp"));


     insDoc(aux1, gLnk(0, "<% iw_webSysDescHandler("DHCPClientListTree", "", "DHCP Client List"); %>", "dhcp_list.asp"));

     insDoc(aux1, gLnk(0, "<% iw_webSysDescHandler("SystemLogTree", "", "System Log"); %>", "system_log.asp"));

     insDoc(aux1, gLnk(0, "<% iw_webSysDescHandler("DoutStatusTree", "", "Relay Status"); %>", "relay_state.asp"));


     insDoc(aux1, gLnk(0, "<% iw_webSysDescHandler("DinPowerStatusTree", "", "DI and Power Status"); %>", "DinPwrStatus.asp"));


     insDoc(aux1, gLnk(0, "<% iw_webSysDescHandler("LinkProtectionStatusTree", "", "Link-protection Status"); %>", "LinkProtectionStatus.asp"));


     insDoc(aux1, gLnk(0, "<% iw_webSysDescHandler("SystemStatusTree", "", "System Status"); %>", "system_status.asp"));


     aux2 = insFld(aux1, gFld("<% iw_webSysDescHandler("NetworkStatusTree", "", "Network Status"); %>"));



     insDoc(aux2, gLnk(0, "<% iw_webSysDescHandler("NetworkStatusArpTableHeader", "", "ARP Table"); %>", "arp.asp"));

     insDoc(aux2, gLnk(0, "<% iw_webSysDescHandler("NetworkStatusBridgeStatusTree", "", "Bridge Status"); %>", "bridge_status.asp"));

     insDoc(aux2, gLnk(0, "<% iw_webSysDescHandler("NetworkStatusLLDPHeader", "", "LLDP Status"); %>", "lldp.asp"));

     insDoc(aux2, gLnk(0, "<% iw_webSysDescHandler("NetworkStatusRoutingTableHeader", "", "Routing Table"); %>", "routing.asp"));



     insDoc(aux2, gLnk(0, "<% iw_webSysDescHandler("RstpStatusTree", "", "RSTP Status"); %>", "rstp_status.asp"));

   aux1 = insFld(foldersTree, gFld("<% iw_webSysDescHandler("MaintenanceTree", "", "Maintenance"); %>"));

     insDoc(aux1, gLnk(0, "<% iw_webSysDescHandler("ConsoleSettingTree", "", "Console Settings"); %>", "console_set_v2.asp"));



     insDoc(aux1, gLnk(0, "<% iw_webSysDescHandler("PingTracerouteTree", "", "Ping"); %>", "ping_trace.asp"));
     insDoc(aux1, gLnk(0, "<% iw_webSysDescHandler("FirmwareUpgradeTree", "", "Firmware Upgrade"); %>", "ConfirmUpgrade.asp"));
     insDoc(aux1, gLnk(0, "<% iw_webSysDescHandler("ConfigurationImExportTree", "", "Configuration Import Export"); %>", "ConfirmConfImp.asp"));
     insDoc(aux1, gLnk(0, "<% iw_webSysDescHandler("LoadFactoryDefaultTree", "", "Load Factory Default"); %>", "ConfirmLoadDef.asp"));

     insDoc(aux1, gLnk(0, "<% iw_webSysDescHandler("AccountSetting", "", "Account Settings"); %>", "account_status.asp"));

     insDoc(aux1, gLnk(0, "<% iw_webSysDescHandler("ChangePasswordTree", "", "Change Password"); %>", "Password.asp"));
     insDoc(aux1, gLnk(0, "<% iw_webSysDescHandler("MiscSettingTree", "", "Miscellaneous Settings"); %>", "misc_set.asp"));

     insDoc(aux1, gLnk(0, "<% iw_webSysDescHandler("TroubleshootingTree", "", "Troubleshooting"); %>", "Troubleshooting.asp"));
   insDoc(foldersTree, gLnk(0, "<% iw_webSysDescHandler("SaveConfigTree", "", "Save Configuration"); %>", "ConfirmSaveConf.asp"));
   insDoc(foldersTree, gLnk(0, "<% iw_webSysDescHandler("RestartTree", "", "Restart"); %>", "ConfirmRestart.asp"));
   insDoc(foldersTree, gLnk(0, "<% iw_webSysDescHandler("LogoutTree", "", "Logout"); %>", "Logout.asp"));

  initializeDocument( <% iw_webContentShow(); %>);
 </script>
 <h2></h2>
</body>
</html>
