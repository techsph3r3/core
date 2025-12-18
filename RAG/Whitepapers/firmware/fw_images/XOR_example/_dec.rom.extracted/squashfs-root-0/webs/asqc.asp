<HTML>
<HEAD>
 <META http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
    <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate" />
    <meta http-equiv="Pragma" content="no-cache" />
    <meta http-equiv="Expires" content="0" />
 <LINK href="nport2g.css" rel=stylesheet type=text/css>
 <TITLE><% iw_webSysDescHandler("Overview", "", ""); %></TITLE>
 <% iw_webJSList_get(); %>
 <SCRIPT>
 <!--

  var opmode_state = new String("<% iw_webCfgValueHandler("board", "operationMode", "AP"); %>");
  var Wlans = <% iw_webGetWirelessStatusArray(); %>;
  var rf_status = new String("<% iw_webCfgValueHandler("wlanDevWIFI0", "rfType", "G-MODE"); %>");



         var channel_statea = new String("<% iw_webCfgValueHandler("wlanDevWIFI0", "channel_a", "32"); %>");
        var channel_stateb = new String("<% iw_webCfgValueHandler("wlanDevWIFI0", "channel_b", "6"); %>");
        var channel_stateg = new String("<% iw_webCfgValueHandler("wlanDevWIFI0", "channel_g", "1"); %>");
         var rate_statea = new String("<% iw_webCfgValueHandler("wlanDevWIFI0", "txRateA", "auto"); %>");
         var rate_stateb = new String("<% iw_webCfgValueHandler("wlanDevWIFI0", "txRateB", "auto"); %>");
         var rate_stateg = new String("<% iw_webCfgValueHandler("wlanDevWIFI0", "txRateG", "auto"); %>");


  function check()
  {
   if (document.bios_upload.filename.value != "")
   {
    document.bios_upload.Submit.disabled = true;
    return true;
   }
   else
   {
    window.alert("Error! Please specify a file.");
    return false;
   }
  }
    -->
    </Script>
</HEAD>
<BODY>
 <H2><% iw_webSysDescHandler("Overview", "", ""); %></H2>
<TABLE width="100%">
 <TR>
  <TD width="100%" colspan="2" class="block_title"><% iw_webSysDescHandler("OverviewSystemInfoHeader", "", "System Info"); %></TD>
 </TR>
  <TR bgcolor="beige">
    <TD width="30%" class="column_title_no_bg"><% iw_webCfgDescHandler("board", "modelName","Model"); %></TD>
    <TD width="70%" class="column_text_no_bg"><% iw_webGetModelNameEOT(); %></TD>
  </TR>
  <TR bgcolor="azure">
    <TD width="30%" class="column_title_no_bg"><% iw_webCfgDescHandler("board", "deviceName","Device name"); %></TD>
    <TD width="70%" class="column_text_no_bg"><% iw_webCfgValueHandler("board", "deviceName",""); %></TD>
  </TR>
  <TR bgcolor="beige">
    <TD width="30%" class="column_title_no_bg"><% iw_webCfgDescHandler("board", "serialNO", "Serial No."); %></TD>
    <TD width="70%" class="column_text_no_bg"><% iw_webCfgValueHandler("board", "serialNO", "Serial No."); %></TD>
  </TR>
  <TR bgcolor="azure">
    <TD width="30%" class="column_title_no_bg"><% iw_webCfgDescHandler("board", "systemUptime", "Up time"); %></TD>
    <TD width="70%" class="column_text_no_bg"><% iw_webSysValueHandler("uptime", "", ""); %></TD>
  </TR>
  <TR bgcolor="beige">
    <TD width="30%" class="column_title_no_bg"><% iw_webCfgDescHandler("board", "firmwareVersion", "Firmware version"); %></TD>
    <TD width="70%" class="column_text_no_bg"><% iw_webCfgValueHandler("board", "firmwareVersion", "0"); %></TD>
  </TR>
  <TR bgcolor="azure">
    <TD width="30%" class="column_title_no_bg"><% iw_webCfgDescHandler("board", "biosVersion", "Bios version"); %></TD>
    <TD width="70%" class="column_text_no_bg"><% iw_webCfgValueHandler("board", "biosVersion", "0"); %></TD>
  </TR>
  <TR>
  <TD width="100%" colspan="2" class="block_title"><% iw_webSysDescHandler("OverviewDeviceInfoHeader", "", "Device Info"); %></TD>
 </TR>
  <TR bgcolor="beige">
    <TD width="30%" class="column_title_no_bg"><% iw_webCfgDescHandler("board", "deviceMACAddr", "MAC"); %></TD>
    <TD width="70%" class="column_text_no_bg"><% iw_webCfgValueHandler("board", "deviceMACAddr", "MAC"); %></TD>
  </TR>
  <TR bgcolor="azure">
    <TD width="30%" class="column_title_no_bg"><% iw_webCfgDescHandler("netDev1", "ipv4Addr", "IP address"); %></TD>
    <TD width="70%" class="column_text_no_bg"><% iw_webCfgValueHandler("netDev1", "ipv4Addr", ""); %></TD>
  </TR>
  <TR bgcolor="beige">
    <TD width="30%" class="column_title_no_bg"><% iw_webCfgDescHandler("netDev1", "ipv4Mask", "Netmask"); %></TD>
    <TD width="70%" class="column_text_no_bg"><% iw_webCfgValueHandler("netDev1", "ipv4Mask", ""); %></TD>
  </TR>

  <TR bgcolor="azure">
    <TD width="30%" class="column_title_no_bg"><% iw_webCfgDescHandler("netDev1", "ipv4GateWay", "Gateway"); %></TD>
    <TD width="70%" class="column_text_no_bg"><% iw_webCfgValueHandler("netDev1", "ipv4GateWay", ""); %></TD>
  </TR>


  <TR>
  <TD width="100%" colspan="2" class="block_title"><% iw_webSysDescHandler("OverviewBoardFlagInfo", "", "Board Flag Info"); %></TD>
  </TR>
  <TR bgcolor="azure">
    <TD width="30%" class="column_title_no_bg">flag_eth_phy</TD>
    <TD width="70%" class="column_text_no_bg"><% iw_webGetBtloaderFlag("flag_eth_phy"); %></TD>
  </TR>
  <TR bgcolor="azure">
    <TD width="30%" class="column_title_no_bg">flag_eth_type</TD>
    <TD width="70%" class="column_text_no_bg"><% iw_webGetBtloaderFlag("flag_eth_type"); %></TD>
  </TR>
  <TR bgcolor="azure">
    <TD width="30%" class="column_title_no_bg">flag_wifi_module</TD>
    <TD width="70%" class="column_text_no_bg"><% iw_webGetBtloaderFlag("flag_wifi_module"); %></TD>
  </TR>
  <TR bgcolor="azure">
    <TD width="30%" class="column_title_no_bg">flag_art</TD>
    <TD width="70%" class="column_text_no_bg"><% iw_webGetBtloaderFlag("flag_art"); %></TD>
  </TR>
  <TR bgcolor="beige">
    <TD width="30%" class="column_title_no_bg">flag_mp</TD>
    <TD width="70%" class="column_text_no_bg"><% iw_webGetBtloaderFlag("flag_mp"); %></TD>
  </TR>
  <TR bgcolor="beige">
    <TD width="30%" class="column_title_no_bg">flag_idgen</TD>
    <TD width="70%" class="column_text_no_bg"><% iw_webGetBtloaderFlag("flag_idgen"); %></TD>
  </TR>
  <TR bgcolor="azure">
    <TD width="30%" class="column_title_no_bg">flag_macgen</TD>
    <TD width="70%" class="column_text_no_bg"><% iw_webGetBtloaderFlag("flag_macgen"); %></TD>
  </TR>
  <TR bgcolor="azure">
    <TD width="30%" class="column_title_no_bg">flag_burn</TD>
    <TD width="70%" class="column_text_no_bg"><% iw_webGetBtloaderFlag("flag_burn"); %></TD>
  </TR>
  <TR bgcolor="beige">
    <TD width="30%" class="column_title_no_bg">flag_cmu</TD>
    <TD width="70%" class="column_text_no_bg"><% iw_webGetBtloaderFlag("flag_cmu"); %></TD>
  </TR>
  <TR bgcolor="azure">
    <TD width="30%" class="column_title_no_bg">flag_gps</TD>
    <TD width="70%" class="column_text_no_bg"><% iw_webGetBtloaderFlag("flag_gps"); %></TD>
  </TR>
  <TR bgcolor="beige">
    <TD width="30%" class="column_title_no_bg">flag_txrx</TD>
    <TD width="70%" class="column_text_no_bg"><% iw_webGetBtloaderFlag("flag_txrx"); %></TD>
  </TR>
  <TR bgcolor="azure">
    <TD width="30%" class="column_title_no_bg">flag_eot</TD>
    <TD width="70%" class="column_text_no_bg"><% iw_webGetBtloaderFlag("flag_eot"); %></TD>
  </TR>
  <TR bgcolor="beige">
    <TD width="30%" class="column_title_no_bg">flag_poe</TD>
    <TD width="70%" class="column_text_no_bg"><% iw_webGetBtloaderFlag("flag_poe"); %></TD>
  </TR>
  <TR bgcolor="beige">
    <TD width="30%" class="column_title_no_bg">flag_pse</TD>
    <TD width="70%" class="column_text_no_bg"><% iw_webGetBtloaderFlag("flag_pse"); %></TD>
  </TR>

  <TR bgcolor="beige">
    <TD width="30%" class="column_title_no_bg">flag_asqc</TD>
    <TD width="70%" class="column_text_no_bg"><% iw_webGetBtloaderFlag("flag_asqc"); %></TD>
  </TR>


  <TR>
  <TD width="100%" colspan="2" class="block_title"><% iw_webSysDescHandler("Overview80211Info", "", "802.11 Info"); %></TD>
 </TR>
    <TR bgcolor="beige">
    <TD width="30%" class="column_title_no_bg"><% iw_webCfgDescHandler("board", "operationMode", "Operation mode"); %></TD>
    <TD width="70%" class="column_text_no_bg">
 <script type="text/javascript">
  if( opmode_state == "AP-CLIENT")
    document.write("CLIENT");
  else
  document.write(opmode_state);
 </SCRIPT></TD>
  </TR>
      <TR bgcolor="azure">
    <TD width="30%" class="column_title_no_bg"><% iw_webCfgDescHandler("wlanDevWIFI0", "channel_g", "Channel"); %></TD>
    <TD width="70%" class="column_text_no_bg">
 <script type="text/javascript">
// 2016-07-06 by Ted Hsu, use runtime channel to instead channel of config
// TBD: multiple Wi-Fi Module
  if (Wlans != null && Wlans[0].channel != 'N/A') {
      document.write(Wlans[0].channel);
  } else
// end, 2016-07-06 by Ted Hsu
  {
   if (rf_status.match("A-MODE") != null)
   {
    document.write(channel_statea);
   } else if (rf_status.match("B-MODE") != null)
   {
    document.write(channel_stateb);
   } else
   {
    document.write(channel_stateg);
   }
  }
 </SCRIPT></TD>
  </TR>
    <TR bgcolor="beige">
    <TD width="30%" class="column_title_no_bg"><% iw_webCfgDescHandler("wlanVap1", "ssid", "SSID"); %></TD>
    <TD width="70%" class="column_text_no_bg"><% iw_webCfgValueHandler("wlanVap1", "ssid", "MOXA"); %></TD>
  </TR>
    <TR bgcolor="azure">
    <TD width="30%" class="column_title_no_bg"><% iw_webCfgDescHandler("wlanVap1", "authType", "Wireless security"); %></TD>
    <TD width="70%" class="column_text_no_bg"><% iw_webCfgValueHandler("wlanVap1", "authType", "OPEN"); %></TD>
  </TR>
    <TR bgcolor="beige">
    <TD width="30%" class="column_title_no_bg"><% iw_webCfgDescHandler("wlanDevWIFI0", "rfType", "RF type"); %></TD>
    <TD width="70%" class="column_text_no_bg">
 <script type="text/javascript">
   document.write(iwStrMap(Wlans[0].rftype));
 </SCRIPT></TD>
  </TR>
    <TR bgcolor="azure">
    <TD width="30%" class="column_title_no_bg"><% iw_webCfgDescHandler("wlanDevWIFI0", "txRateA", "Transmission Rate"); %></TD>
    <TD width="70%" class="column_text_no_bg">
  <script type="text/javascript">
  if (rf_status.match("A-MODE") != null)
  {
   if (rate_statea.match("auto") != null)
    document.write("Auto");
   else
    document.write(rate_statea);
  }
  else if (rf_status.match("B-MODE") != null)
  {
   if (rate_stateb.match("auto") != null)
    document.write("Auto");
   else
    document.write(rate_stateb);
  }
  else
  {
   if (rate_stateg.match("auto") != null)
    document.write("Auto");
   else
    document.write(rate_stateg);
  }
 </SCRIPT></TD>
  </TR>
  <TR bgcolor="beige">
    <TD width="30%" class="column_title_no_bg"><% iw_webCfgDescHandler("wlanDevWIFI0", "countryCode", "Country Code"); %></TD>
    <TD width="70%" class="column_text_no_bg"><% iw_webCfgValueHandler("wlanDevWIFI0", "countryCode", "FCC"); %></TD>
  </TR>

</TABLE>
</BODY>
</HTML>
