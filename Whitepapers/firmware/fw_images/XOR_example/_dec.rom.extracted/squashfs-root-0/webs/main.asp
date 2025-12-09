<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
 <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
 <link href="nport2g.css" rel=stylesheet type=text/css>
 <title><% iw_webSysDescHandler("Overview", "", ""); %></title>
 <% iw_webJSList_get(); %>
 <script type="text/javascript">
 <!--
  var i, j;
   var trBgColor = ["beige", "azure"];

  var picindex = new Array("Signal_0.gif","Signal_1.gif","Signal_2.gif","Signal_3.gif","Signal_4.gif", "Signal_5.gif");

  var Wlans = <% iw_webGetWirelessStatusArray(); %>;
  var chanWidth = "<% iw_webGetChanWidth(devIndex, vapIndex); %>";
  var BoardOPMode = new String( '<% iw_webCfgValueMainHandler( "board", "operationMode", "WIRELESS_REDUNDANCY" ); %>' );


  var mem_state = <% iw_websMemoryChange(); %>;

  function iw_onload_content()
  {
   if( <% iw_webQuickSetup_exit(); %> )
    top.contents.location.reload();

   if( <% iw_webQuickSetup_occupied(); %>
    || <% iw_websCheckPermission(); %> )
   {
    $('#qs_option').removeAttr('href');
    $('#qs_option').css('color', '#848484')
     .css('background-color', '#F2F2F2')
     .css('border', '3px double  #F2F2F2');
   }
  }


  function iw_ChangeOnLoad()
  {
   top.toplogo.location.reload();


   iw_onload_content();

  }

 -->
 </script>
</head>
<body onLoad="iw_ChangeOnLoad();">
 <H2>
  <% iw_webSysDescHandler("Overview", "", ""); %>

  <% iw_webAlertPassword(); %>

 </H2>

<table width="100%">
 <tr>
 <td width="100%" class="column_title_no_bg">This screen displays current active settings</td>
 </tr>
</table>

 <script type="text/javascript">
 <!--
 var bgColorIndex = 0;
 var devNum = 0;

 for( i = 0; i < Wlans.length; i++ )
 {
  if( Wlans[i].devIndex > devNum )
   devNum = Wlans[i].devIndex;
 }

 devNum++;

 document.write('<table width="100%">');
 document.write('<tr>');
 document.write('<td width="30%" colspan="' + (devNum + 1) + '" class="block_title"><% iw_webSysDescHandler("OverviewSystemInfoHeader", "", "System Info"); %><\/td>');
 document.write('<\/tr>');

 document.write('<tr bgcolor="' + trBgColor[bgColorIndex] + '">');
 document.write('<td width="30%" class="column_title_no_bg"><% iw_webCfgDescHandler("board", "modelName","Model"); %><\/td>');
 document.write('<td width="70%" colspan="' + devNum + '" class="column_text_no_bg"><% iw_webCfgValueMainHandler("board", "modelName",""); %><\/td>');
 document.write('<\/tr>');
 bgColorIndex = 1 - bgColorIndex;

 document.write('<tr bgcolor="' + trBgColor[bgColorIndex] + '">');
 document.write('<td width="30%" class="column_title_no_bg"><% iw_webCfgDescHandler("board", "deviceName","Device name"); %><\/td>');
 document.write('<td width="70%" colspan="' + devNum + '" class="column_text_no_bg"><% iw_webCfgValueMainHandler("board", "deviceName",""); %><\/td>');
 document.write('<\/tr>');
 bgColorIndex = 1 - bgColorIndex;

 document.write('<tr bgcolor="' + trBgColor[bgColorIndex] + '">');
 document.write('<td width="30%" class="column_title_no_bg"><% iw_webCfgDescHandler("board", "serialNO", "Serial number"); %><\/td>');
 document.write('<td width="70%" colspan="' + devNum + '" class="column_text_no_bg"><% iw_webCfgValueMainHandler("board", "serialNO", "Serial No."); %><\/td>');
 document.write('<\/tr>');
 bgColorIndex = 1 - bgColorIndex;

 document.write('<tr bgcolor="' + trBgColor[bgColorIndex] + '">');
 document.write('<td width="30%" class="column_title_no_bg"><% iw_webCfgDescHandler("board", "systemUptime", "System uptime"); %><\/td>');
 document.write('<td width="70%" colspan="' + devNum + '" class="column_text_no_bg"><% iw_webSysValueHandler("uptime", "", ""); %><\/td>');
 document.write('<\/tr>');
 bgColorIndex = 1 - bgColorIndex;

 document.write('<tr bgcolor="' + trBgColor[bgColorIndex] + '">');
 document.write('<td width="30%" class="column_title_no_bg"><% iw_webCfgDescHandler("board", "firmwareVersion", "Firmware version"); %><\/td>');
 document.write('<td width="70%" colspan="' + devNum + '" class="column_text_no_bg"><% iw_webCfgValueMainHandler("board", "firmwareVersion", "0"); %><\/td>');
 document.write('<\/tr>');
 bgColorIndex = 1 - bgColorIndex;

 document.write('<tr>');
 document.write('<td width="30%" colspan="' + (devNum+1) + '" class="block_title"><% iw_webSysDescHandler("OverviewDeviceInfoHeader", "", "Device Info"); %><\/td>');
 document.write('<\/tr>');
 bgColorIndex = 0;

 document.write('<tr bgcolor="' + trBgColor[bgColorIndex] + '">');
 document.write('<td width="30%" class="column_title_no_bg"><% iw_webCfgDescHandler("board", "deviceMACAddr", "MAC"); %><\/td>');
 document.write('<td width="70%" colspan="' + devNum + '" class="column_text_no_bg"><% iw_webCfgValueMainHandler("board", "deviceMACAddr", "MAC"); %><\/td>');
 document.write('<\/tr>');
 bgColorIndex = 1 - bgColorIndex;


 if( iwStrMap(Wlans[0].opmode) == 'Client-Router' )
 {
  document.write('<tr width="100%">');
  document.write('<td colspan="' + (devNum+1) + '" class="column_text_no_bg">');
  document.write('<table width="100%">');

  document.write('<tr bgcolor="' + trBgColor[bgColorIndex] + '">');
  document.write('<td width="30%" class="column_title_no_bg">Interface<\/td>');
  document.write('<td width="35%" class="column_text_no_bg">WLAN<\/td>');
  document.write('<td width="35%" class="column_text_no_bg">LAN<\/td>');
  document.write('<\/tr>');
  bgColorIndex = 1 - bgColorIndex;

  document.write('<tr bgcolor="' + trBgColor[bgColorIndex] + '">');
  document.write('<td width="30%" class="column_title_no_bg"><% iw_webCfgDescHandler("netDev1", "ipv4Addr", "IP address"); %><\/td>');
  document.write('<td width="35%" class="column_text_no_bg"><% iw_webCfgValueMainHandler("netDevWlan", "ipv4Addr", ""); %><\/td>');
  document.write('<td width="35%" class="column_text_no_bg"><% iw_webCfgValueMainHandler("netDevLan", "ipv4Addr", ""); %><\/td>');
  document.write('<\/tr>');
  bgColorIndex = 1 - bgColorIndex;

  document.write('<tr bgcolor="' + trBgColor[bgColorIndex] + '">');
  document.write('<td width="30%" class="column_title_no_bg"><% iw_webCfgDescHandler("netDev1", "ipv4Mask", "Netmask"); %><\/td>');
  document.write('<td width="35%" class="column_text_no_bg"><% iw_webCfgValueMainHandler("netDevWlan", "ipv4Mask", ""); %><\/td>');
  document.write('<td width="35%" class="column_text_no_bg"><% iw_webCfgValueMainHandler("netDevLan", "ipv4Mask", ""); %><\/td>');
  document.write('<\/tr>');
  bgColorIndex = 1 - bgColorIndex;

  document.write('<tr bgcolor="' + trBgColor[bgColorIndex] + '">');
  document.write('<td width="30%" class="column_title_no_bg"><% iw_webCfgDescHandler("netDev1", "ipv4GateWay", "Gateway"); %><\/td>');
  document.write('<td width="35%" class="column_text_no_bg"><% iw_webCfgValueMainHandler("netDevWlan", "ipv4GateWay", ""); %><\/td>');
  document.write('<td width="35%" class="column_text_no_bg">N/A<\/td>');
  document.write('<\/tr>');
  bgColorIndex = 1 - bgColorIndex;

  document.write('<\/table><\/td><\/tr>');
 } else

 {
  document.write('<tr bgcolor="' + trBgColor[bgColorIndex] + '">');
  document.write('<td width="30%" class="column_title_no_bg"><% iw_webCfgDescHandler("netDev1", "ipv4Addr", "IP address"); %><\/td>');
  document.write('<td width="70%" colspan="' + devNum + '" class="column_text_no_bg"><% iw_webCfgValueMainHandler("netDev1", "ipv4Addr", ""); %><\/td>');
  document.write('<\/tr>');
  bgColorIndex = 1 - bgColorIndex;

  document.write('<tr bgcolor="' + trBgColor[bgColorIndex] + '">');
  document.write('<td width="30%" class="column_title_no_bg"><% iw_webCfgDescHandler("netDev1", "ipv4Mask", "Netmask"); %><\/td>');
  document.write('<td width="70%" colspan="' + devNum + '"\ class="column_text_no_bg"><% iw_webCfgValueMainHandler("netDev1", "ipv4Mask", ""); %><\/td>');
  document.write('<\/tr>');
  bgColorIndex = 1 - bgColorIndex;


  document.write('<tr bgcolor="' + trBgColor[bgColorIndex] + '">');
  document.write('<td width="30%" class="column_title_no_bg"><% iw_webCfgDescHandler("netDev1", "ipv4GateWay", "Gateway"); %><\/td>');
  document.write('<td width="70%" colspan="' + devNum + '" class="column_text_no_bg"><% iw_webCfgValueMainHandler("netDev1", "ipv4GateWay", ""); %><\/td>');
  document.write('<\/tr>');
  bgColorIndex = 1 - bgColorIndex;

 }


 document.write('<tr><td colspan="'+ devNum+1 +'" class="block_title"><% iw_webSysDescHandler("Overview80211Info", "", "802.11 Info"); %><\/td><\/tr>');
 bgColorIndex = 0;

 document.write('<tr bgcolor="' + trBgColor[bgColorIndex] + '">');
 document.write('<td width="30%" class="column_title_no_bg"><% iw_webCfgDescHandler("wlanDevWIFI0", "countryCode", "Country code"); %><\/td>');
 document.write('<td width="70%" colspan="' + devNum + '" class="column_text_no_bg"><% iw_webCfgValueMainHandler("wlanDevWIFI0", "countryCode", ""); %><\/td>');
 document.write('<\/tr>');
 bgColorIndex = 1 - bgColorIndex;
 document.write('<tr bgcolor="' + trBgColor[bgColorIndex] + '"><td width="30%" class="column_title_no_bg"><% iw_webCfgDescHandler("board", "operationMode", "Operation mode"); %><\/td>');
 document.write('<td colspan="'+ devNum +'" class="column_text_no_bg">' + iwStrMap(Wlans[0].opmode) + '<\/td><\/tr>');
 document.write('<\/tr>');
 bgColorIndex = 1 - bgColorIndex;


 document.write('<tr bgcolor="' + trBgColor[bgColorIndex] + '"><td class="column_title_no_bg"><% iw_webCfgDescHandler("wlanDevWIFI0", "channel_g", "Channel"); %><\/td>');
 for( i = 0; i < devNum; i++ )
 {
  for( j = 0; j < Wlans.length; j++ )
  {
   if( Wlans[j].devIndex == i && Wlans[j].vapIndex == 0 )
   {
    if( iwStrMap(Wlans[j].opmode) == 'Client' || iwStrMap(Wlans[j].opmode) == 'Slave' || iwStrMap(Wlans[j].opmode) == 'Redundant client' || iwStrMap(Wlans[j].opmode) == 'Client-Router' )
    {
     if( Wlans[j].channel == 'N/A' )
      Wlans[j].channel = 'Not connected';
     else
      Wlans[j].channel = Wlans[j].channel;
    }


    document.write('<td class="column_text_no_bg">'+ Wlans[j].channel +'<\/td>');
   }
  }
 }
 document.write('<\/tr>');
 bgColorIndex = 1 - bgColorIndex;

 document.write('<tr bgcolor="' + trBgColor[bgColorIndex] + '"><td class="column_title_no_bg"><% iw_webCfgDescHandler("wlanDevWIFI0", "rfType", "RF type"); %><\/td>');
 for( i = 0; i < devNum; i++ )
 {
  for( j = 0; j < Wlans.length; j++ )
  {
   if( Wlans[j].devIndex == i && Wlans[j].vapIndex == 0 )
   {
    document.write('<td class="column_text_no_bg">'+ iwStrMap(Wlans[j].rftype) +'<\/td>');
   }
  }
 }
 document.write('<\/tr>');
 bgColorIndex = 1 - bgColorIndex;

document.write('<tr bgcolor="' + trBgColor[bgColorIndex] + '"><td class="column_title_no_bg"><% iw_webCfgDescHandler("wlanDevWIFI0", "channelWidth", "Channel width"); %><\/td>');
            for( i = 0; i < devNum; i++ )
        {
                for( j = 0; j < Wlans.length; j++ )
                {
                        if( Wlans[j].devIndex == i && Wlans[j].vapIndex == 0 )
                        {
                                document.write('<td class="column_text_no_bg">'+ chanWidth +'<\/td>');
                        }
                }
        }
        document.write('<\/tr>');
        bgColorIndex = 1 - bgColorIndex;

 document.write('<tr bgcolor="' + trBgColor[bgColorIndex] + '"><td class="column_title_no_bg"><% iw_webCfgDescHandler("wlanVap1", "ssid", "SSID"); %><\/td>');
 for( i = 0; i < devNum; i++ )
 {
  document.write('<td class="column_text_no_bg">');
  for( j = 0; j < Wlans.length; j++ )
  {
   if( Wlans[j].devIndex == i )
   {
    document.write( '<a href="wireless_status.asp?devIndex=' + i + '&vapIndex=' + Wlans[j].vapIndex + '">' + Wlans[j].ssid +'<\/a><br \/>');
   }
  }
  document.write('<\/td>');
 }
 document.write('<\/tr>');
 bgColorIndex = 1 - bgColorIndex;



 document.write('<\/table>');
 -->
 </script>
</body>
</html>
