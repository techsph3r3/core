<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%
 if ( iw_isset(devIndex) == 0 )
 {
  devIndex = 0;
 }

 if ( iw_isset(vapIndex) == 0 )
 {
  vapIndex = 0;
 }
%>
<html>
<head>
 <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
    <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate" />
    <meta http-equiv="Pragma" content="no-cache" />
    <meta http-equiv="Expires" content="0" />
 <link href="nport2g.css" rel=stylesheet type=text/css>
 <title><% iw_webSysDescHandler("WirelessStatusTree", "", "Wireless Status"); %></title>
 <% iw_webJSList_get(); %>
 <script type="text/javascript">
 <!--
  function do_referesh()
  {
   if(document.getElementById("ref5").checked)
    document.location.reload();
  }

  function check_referesh()
  {
   if(document.getElementById("ref5").checked)
    window.setTimeout("do_referesh()", 10000);
  }

   var trBgColor = ["beige", "azure"];

  var picindex = new Array("Signal_0.gif","Signal_1.gif","Signal_2.gif","Signal_3.gif","Signal_4.gif", "Signal_5.gif");
  var BoardOPMode = new String( "<% iw_webCfgValueMainHandler( "board", "operationMode", "WIRELESS_REDUNDANCY" ); %>" );
  var WlanSsidList = <% iw_webGetRfIndexSSIDarray(1); %>;
  var ssidNum = WlanSsidList.length;
  var Wlans = <% iw_webGetWirelessStatusArray(devIndex, vapIndex); %>;
  var iface_signal_strength = [ <% iw_webGetWlanIfaceSiganlStrength(devIndex, vapIndex); %>];
  var chanWidth = "<% iw_webGetChanWidth(devIndex); %>";



  function iw_onLoad()
  {
   var rfindexElement = document.getElementById('devIndex');
   var i, newItem;

   for( i = 0; i < ssidNum; i++ )
   {
    newItem = document.createElement("option");
    newItem.value = WlanSsidList[i].devIndex + '_' + WlanSsidList[i].vapIndex;




    newItem.text = 'WLAN (SSID: ' + WlanSsidList[i].ssid + ')';


    rfindexElement.options.add(newItem);
   }

   iw_selectSet( rfindexElement, '<% write(devIndex); %>_<% write(vapIndex); %>' );
  }

 -->
 </script>
</head>

<body onLoad = "iw_onLoad();">
 <h2><% iw_webSysDescHandler("WirelessStatusTree", "", "Wireless Status"); %></h2>
 <script type="text/javascript">
  if(window.setTimeout)
  {
   document.write("<input type='checkbox' id='ref5' checked onclick='check_referesh()' /><label for='ref5'>Auto Update<\/label>");
   check_referesh();
  }
 </script>

 <table width="100%">
 <tr>
  <td width="30%" class="column_title">Show&nbsp;status&nbsp;of&nbsp;
   <select id="devIndex" name="devIndex" size="1" onChange="document.location.href='wireless_status.asp?devIndex='+this.options[this.selectedIndex].value.split('_')[0]+'&vapIndex='+this.options[this.selectedIndex].value.split('_')[1];">
   </select>
  </td>
 </tr>
 </table>

 <script type="text/javascript">
 <!--
 var bgColorIndex = 0;
 document.write('<table width="100%">');

 document.write('<tr><td colspan="2" class="block_title"><% iw_webSysDescHandler("Overview80211Info", "", "802.11 info"); %><\/td><\/tr>');

//#if defined (AWK5222) || defined (AWK6222) || defined (AWK5232) || defined (AWK6232)
 document.write('<tr bgcolor="' + trBgColor[bgColorIndex] + '"><td width="30%" class="column_title_no_bg"><% iw_webCfgDescHandler("board", "operationMode", "Operation mode"); %><\/td>');
 document.write('<td class="column_text_no_bg">'+ iwStrMap(Wlans[0].opmode) );
 if( Wlans[0].vapIndex == 0 )
  document.write('<\/td>');
 else
  document.write(' - &nbsp;(Sub&nbsp;AP&nbsp;' + (Wlans[0].vapIndex) + ')<\/td>');


 document.write('<\/tr>');
 bgColorIndex = 1 - bgColorIndex;

 document.write('<tr bgcolor="' + trBgColor[bgColorIndex] + '"><td class="column_title_no_bg"><% iw_webCfgDescHandler("wlanDevWIFI0", "channel_g", "Channel"); %><\/td>');

 if( (iwStrMap(Wlans[0].opmode) == 'Client' || iwStrMap(Wlans[0].opmode) == 'Slave' || iwStrMap(Wlans[0].opmode) == 'Redundant client')
  && Wlans[0].channel == 'N/A' )
 {
  Wlans[0].channel = 'Not connected';
 }
 document.write('<td class="column_text_no_bg">'+ Wlans[0].channel +'<\/td>');
 document.write('<\/tr>');
 bgColorIndex = 1 - bgColorIndex;

 document.write('<tr bgcolor="' + trBgColor[bgColorIndex] + '"><td class="column_title_no_bg"><% iw_webCfgDescHandler("wlanDevWIFI0", "channelWidth", "Channel width"); %><\/td>');
    document.write('<td class="column_text_no_bg">'+ chanWidth +'<\/td>');
    document.write('<\/tr>');
    bgColorIndex = 1 - bgColorIndex;

 document.write('<tr bgcolor="' + trBgColor[bgColorIndex] + '"><td class="column_title_no_bg"><% iw_webCfgDescHandler("wlanDevWIFI0", "rfType", "RF type"); %><\/td>');
 document.write('<td class="column_text_no_bg">'+ iwStrMap(Wlans[0].rftype) +'<\/td>');
 document.write('<\/tr>');
 bgColorIndex = 1 - bgColorIndex;

 document.write('<tr bgcolor="' + trBgColor[bgColorIndex] + '"><td class="column_title_no_bg"><% iw_webCfgDescHandler("wlanVap1", "ssid", "SSID"); %><\/td>');
 document.write('<td class="column_text_no_bg">'+ Wlans[0].ssid +'<\/td>');
 document.write('<\/tr>');
 bgColorIndex = 1 - bgColorIndex;

 document.write('<tr bgcolor="' + trBgColor[bgColorIndex] + '"><td class="column_title_no_bg">MAC<\/td>');
 document.write('<td class="column_text_no_bg">'+ Wlans[0].mac +'<\/td>');
 document.write('<\/tr>');
 bgColorIndex = 1 - bgColorIndex;

 document.write('<tr bgcolor="' + trBgColor[bgColorIndex] + '"><td class="column_title_no_bg"><% iw_webCfgDescHandler("wlanVap1", "authType", "Security mode"); %><\/td>');
 document.write('<td class="column_text_no_bg">'+ Wlans[0].authtype +'<\/td>');
 document.write('<\/tr>');
 bgColorIndex = 1 - bgColorIndex;

 document.write('<tr bgcolor="' + trBgColor[bgColorIndex] + '"><td class="column_title_no_bg"><% iw_webCfgDescHandler("wlanVap1", "bssidClient", "BSSID"); %><\/td>');
 document.write('<td class="column_text_no_bg">'+ Wlans[0].bssid +'<\/td>');
 document.write('<\/tr>');
 bgColorIndex = 1 - bgColorIndex;

 if(iwStrMap(Wlans[0].opmode) != 'AP')
    {
        document.write('<tr bgcolor="' + trBgColor[bgColorIndex] + '"><td class="column_title_no_bg">AP IP address<\/td>');
        document.write('<td class="column_text_no_bg">'+ Wlans[0].ApIp +'<\/td>');
        document.write('<\/tr>');
        bgColorIndex = 1 - bgColorIndex;
    }

 document.write('<tr bgcolor="' + trBgColor[bgColorIndex] + '"><td class="column_title_no_bg"><% iw_webCfgDescHandler("board", "rssi", "Signal strength"); %><\/td>');
 document.write('<td class="column_text_no_bg">');
 if( typeof(picindex[Wlans[0].signalPicIndex]) == 'undefined' )
  document.write(Wlans[0].signalPicIndex);
 else
  document.write('<img src="' + picindex[Wlans[0].signalPicIndex] + '"<\/img>&nbsp;');
 document.write('<\/td>');
 document.write('<\/tr>');
 bgColorIndex = 1 - bgColorIndex;

document.write('<tr bgcolor="' + trBgColor[bgColorIndex] + '"><td class="column_title_no_bg">Signal strength<\/td>');
        document.write('<td class="column_text_no_bg">'+ iface_signal_strength[0] + ' dBm<\/td>');
        document.write('<\/tr>');
        bgColorIndex = 1 - bgColorIndex;

        document.write('<tr bgcolor="' + trBgColor[bgColorIndex] + '"><td class="column_title_no_bg">Noise floor<\/td>');
        document.write('<td class="column_text_no_bg">'+ iface_signal_strength[1] + ' dBm<\/td>');
        document.write('<\/tr>');
        bgColorIndex = 1 - bgColorIndex;

                document.write('<tr bgcolor="' + trBgColor[bgColorIndex] + '"><td class="column_title_no_bg">SNR<\/td>');
                if((Wlans[0].channel == 'Not connected') || (iwStrMap(Wlans[0].opmode) == 'AP') || (iwStrMap(Wlans[0].opmode) == 'Master'))
                        iface_signal_strength[2] = 'N/A'
                document.write('<td class="column_text_no_bg">'+ iface_signal_strength[2] + '<\/td>');
                document.write('<\/tr>');
                bgColorIndex = 1 - bgColorIndex;
 document.write('<tr><td colspan="2" class="block_title"><% iw_webSysDescHandler("TxInfo", "", "Transmission Information"); %><\/td><\/tr>');
 document.write('<tr bgcolor="' + trBgColor[bgColorIndex] + '"><td class="column_title_no_bg">Rate<\/td>');
 document.write('<td class="column_text_no_bg">'+ Wlans[0].txrate +'<\/td>');
 document.write('<\/tr>');
 bgColorIndex = 1 - bgColorIndex;

 document.write('<tr bgcolor="' + trBgColor[bgColorIndex] + '"><td class="column_title_no_bg">Power<\/td>');

 document.write('<td class="column_text_no_bg">' + Wlans[0].txpower + '&nbsp;dBm<\/td>');



 document.write('<\/tr>');
 bgColorIndex = 1 - bgColorIndex;
 document.write('<tr><td colspan="2" class="block_title">Outgoing Packets<\/td><\/tr>');
 bgColorIndex = 0;
 document.write('<tr bgcolor="' + trBgColor[bgColorIndex] + '"><td class="column_title_no_bg">Total sent<\/td>');
 document.write('<td class="column_text_no_bg">'+ Wlans[0].txpacket +'<\/td>');
 document.write('<\/tr>');
 bgColorIndex = 1 - bgColorIndex;
 document.write('<tr bgcolor="' + trBgColor[bgColorIndex] + '"><td class="column_title_no_bg">Packets with errors<\/td>');
 document.write('<td class="column_text_no_bg">'+ Wlans[0].txerror +'<\/td>');
 document.write('<\/tr>');
 bgColorIndex = 1 - bgColorIndex;
 document.write('<tr bgcolor="' + trBgColor[bgColorIndex] + '"><td class="column_title_no_bg">Packets dropped<\/td>');
 document.write('<td class="column_text_no_bg">'+ Wlans[0].txdrop +'<\/td>');
 document.write('<\/tr>');
 bgColorIndex = 1 - bgColorIndex;

 document.write('<tr><td colspan="2" class="block_title">Incoming Packets<\/td><\/tr>');
 bgColorIndex = 0;
 document.write('<tr bgcolor="' + trBgColor[bgColorIndex] + '"><td class="column_title_no_bg">Total received<\/td>');
 document.write('<td class="column_text_no_bg">'+ Wlans[0].rxpacket +'<\/td>');
 document.write('<\/tr>');
 bgColorIndex = 1 - bgColorIndex;
 document.write('<tr bgcolor="' + trBgColor[bgColorIndex] + '"><td class="column_title_no_bg">Packets with errors<\/td>');
 document.write('<td class="column_text_no_bg">'+ Wlans[0].rxerror +'<\/td>');
 document.write('<\/tr>');
 bgColorIndex = 1 - bgColorIndex;
 document.write('<tr bgcolor="' + trBgColor[bgColorIndex] + '"><td class="column_title_no_bg">Packets dropped<\/td>');
 document.write('<td class="column_text_no_bg">'+ Wlans[0].rxdrop +'<\/td>');
 document.write('<\/tr>');
 bgColorIndex = 1 - bgColorIndex;

 document.write('<\/table>');
 -->
 </script>
</body>

</html>
