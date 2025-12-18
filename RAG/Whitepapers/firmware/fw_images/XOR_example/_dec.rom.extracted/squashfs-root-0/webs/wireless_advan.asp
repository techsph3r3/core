
<%
 var wifiSection, vapSection, roamingSection;
    if ( iw_isset(index) == 0 ) {
        index = 1;
    }
    if ( iw_isset(vapIndex) == 0 ) {
        vapIndex = 0;
    }

    if (index==1 )
    {
        wifiSection = "wlanDevWIFI0";
        vapSection = "wlanVap1";
        roamingSection = "turboRoaming";
        devIndex = 1;
    }else
    {
        wifiSection = "wlanDevWIFI1";
        vapSection = "wlanVap2";
        roamingSection = "turboRoaming1";
        index = 2;
        devIndex = index;
    }
%>
<html>
<head>
 <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
    <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate" />
    <meta http-equiv="Pragma" content="no-cache" />
    <meta http-equiv="Expires" content="0" />
 <link href="nport2g.css" rel=stylesheet type=text/css>
 <% iw_webJSList_get(); %>
 <title>




<% iw_webSysDescHandler("AdvancedWirelessSettingsTree", "", "Advanced Wireless Settings"); %></title>
 <script type="text/javascript">
 <!--
  // Platform-independent part
   var mem_state = <% iw_websMemoryChange(); %>;

   // Platform-dependent part

  var VAPopMode = new String("<% iw_webCfgValueHandler(	"wlanDevWIFI0", "operationMode",	"AP"); %>");






  var turboRoamingChs;
        var turboRoamingEnable = "<% iw_webCfgValueHandler(roamingSection, "enable", "DISABLE"); %>";
        var isAPMode = false;

        var wlanChannels;

 // 10 is initial value, meaningless.
 var antenna_orig = 10;



  var isNonly = false;
  var hasNmode = false;




  var n_400nsGIs = new Array(<% iw_webGet11nTxRate2JSArr("n_400nsGIs"); %>);
  var n_20MHzBwShortGI = new Array(<% iw_webGet11nTxRate2JSArr("n_20MHzBwShortGI"); %>);
  var n_value_arr = new Array(<% iw_webGet11nTxRate2JSArr("n_value_arr"); %>);
  var channelWidth = "<% iw_webCfgValueHandler(wifiSection, "channelWidth", "20MHz"); %>";

  function full_11a_change_tx_enhancement_check()
  {
   return true;
  }
  function iw_onSubmit()
  {
   var form = document.wireless_advan;






 var formItem;
   formItem = document.wireless_advan;


   if( !isValidNumber(form.iw_beaconInterval, 40, 1000, "<% iw_webCfgDescHandler(wifiSection, "beaconInterval", "Beacon interval"); %>") )
   {
    form.iw_beaconInterval.focus();
    return false;
   }
   if( !isValidNumber(form.iw_dtimInterval, 1, 15, "<% iw_webCfgDescHandler(wifiSection, "dtimInterval", "DTIM interval"); %>") )
   {
    form.iw_dtimInterval.focus();
    return false;
   }

            if( !isValidNumber(form.iw_inactiveTimeout, 1, 240, "<% iw_webCfgDescHandler(wifiSection, "inactiveTimeout", ""); %>") )
            {
                form.iw_inactiveTimeout.focus();
                return false;
            }


   if( !isValidNumber(form.iw_fragThresh, 256, 2346, "<% iw_webCfgDescHandler(wifiSection, "fragThresh", "Fragmentation threshold"); %>") )
   {
    form.iw_fragThresh.focus();
    return false;
   }


   var rfType = new String("<% iw_webCfgValueHandler( wifiSection,	"rfType",			"G-MODE" ); %>");
   if( rfType == "GNMixed" || rfType == "BGNMixed" || rfType == "ANMixed" || rfType == "N-MODE-24G" || rfType == "N-MODE-5G")
   {
    if (form.iw_fragThresh.value != 2346){
     alert('Can not enable "fragmentation threshold" to fragment packet. When wireless settings RF type in wireless N mode.');
     form.iw_fragThresh.focus();
     return false;
    }
   }

   if( !isValidNumber(form.iw_rtsThreshold, 32, 2346, "<% iw_webCfgDescHandler(wifiSection, "rtsThreshold", "RTS threshold"); %>") )
   {
    form.iw_rtsThreshold.focus();
    return false;
   }

  if( rfType == "B-MODE"){
                if( !isValidNumber(form.iw_txRateMin, 0, 11, "<% iw_webCfgDescHandler(wifiSection, "txRateMin", "Minimum transmission rate"); %>") ){
                    form.iw_txRateMin.focus();
                    return false;
                }
            }else if( rfType == "BGMixed" || rfType == "G-MODE" || rfType == "A-MODE" ){
                if( !isValidNumber(form.iw_txRateMin, 0, 54, "<% iw_webCfgDescHandler(wifiSection, "txRateMin", "Minimum transmission rate"); %>") ){
                    form.iw_txRateMin.focus();
                    return false;
                }
            }else if( !isValidNumber(form.iw_txRateMin, 0, 64, "<% iw_webCfgDescHandler(wifiSection, "txRateMin", "Minimum transmission rate"); %>") ){
                    form.iw_txRateMin.focus();
                    return false;
                }



   document.wireless_advan.iw_beaconInterval.disabled = false;
   document.wireless_advan.iw_dtimInterval.disabled = false;

            document.wireless_advan.iw_inactiveTimeout.disabled = false;




   if( !isValidNumber(form.iw_txrange, 500, 11000, "<% iw_webCfgDescHandler(wifiSection, "txrange", "Transmission Distance"); %>") )
   {
    form.iw_wlanDevWIFI0_txrange.focus();
    return false;
   }


   if( form.iw_txrange.value > 500 && form.iw_txantenna.options[ form.iw_txantenna.selectedIndex ].value == "diversity-antenna")
        alert( 'To obtain better performance in long distance transmission, we suggest that:\n- Enlarge "Transmission power\n- Select A or B from "Antenna".');
  if( ("ENABLE" == $('#iw_turboRoaming_enable').val()) ) {
   var dfs_chan_list = [ <% iw_dfs_channel_list(devIndex, vapIndex); %> ];
   if(jQuery.inArray(parseInt($('#iw_turboRoaming_channel_0').val()), dfs_chan_list) != -1){
    alert("Your selected scanning channel " + $('#iw_turboRoaming_channel_0').val() + " is a DFS channels. Please note that access points using DFS channels may have their channels changed automatically if radar signals are detected. As a result, those access points may no longer be in your scanning list.");
   }
   if(jQuery.inArray(parseInt($('#iw_turboRoaming_channel_1').val()), dfs_chan_list) != -1){
    alert("Your selected scanning channel " + $('#iw_turboRoaming_channel_1').val() + " is a DFS channels. Please note that access points using DFS channels may have their channels changed automatically if radar signals are detected. As a result, those access points may no longer be in your scanning list.");
   }
   if(jQuery.inArray(parseInt($('#iw_turboRoaming_channel_2').val()), dfs_chan_list) != -1){
    alert("Your selected scanning channel " + $('#iw_turboRoaming_channel_2').val() + " is a DFS channels. Please note that access points using DFS channels may have their channels changed automatically if radar signals are detected. As a result, those access points may no longer be in your scanning list.");
   }
  }







   if( ("ENABLE" == $('#iw_turboRoaming_enable').val())



    && ("ENABLE" == $('#iw_virtualType').val()) )

            {
             //alert( 'To avoid the AeroLink Protection triggered by disconnection of Turbo Roaming, do not enable "AeroLink Protection" and "Turbo Roaming" at the same time.\n');
   }
   form.submit();

  }

  function cat_tb_ch_option(ch, current)
  {
   var new_ch = ch;
   var buf;

   for ( var x = 0; x < new_ch.length; x++ ) {
    selected = (new_ch[x] == current) ? 'selected' : '';
    if ( new_ch[x] == -1 ) {
     buf += '<option value="-1" ' + selected + '>Not Scanning</option>';
    } else {
     buf += '<option value="' + new_ch[x] + '" ' + selected + '>' + new_ch[x] + '</option>';
    }
   }

   return buf;
  }

  function draw_tbroaming_option()
  {
            var buf = "";
            var ch2g = [<% iw_webGetWirelessChan2G(devIndex, vapIndex, 0); %>];
            var ch5g = [<% iw_webGetWirelessChan5G(devIndex, vapIndex, 0); %>];







            var bandwidth = "FULL";

            var rfType = "<% iw_webCfgValueHandler( wifiSection, "rfType", "G-MODE" ); %>";
            var ch;
            var turbo_ch = [<% iw_webGetWirelessTurboRoamingChs(index); %>];

            if(iw_is5GHz(rfType))
            {
                if( "FULL" == bandwidth )
                    ch = ch5g;






            }
            else
            {
                if( "FULL" == bandwidth )
                    ch = ch2g;






            }
   ch.unshift (-1); // not scanning

   if( $.inArray(turbo_ch[0], turbo_ch) != 0 )
            {
    buf = cat_tb_ch_option(ch, -1);
   }
            else
            {
                buf = cat_tb_ch_option(ch, turbo_ch[0]);
            }
   $('#iw_turboRoaming_channel_0').append(buf);

   if( $.inArray(turbo_ch[1], turbo_ch) != 1 )
            {
    buf = cat_tb_ch_option(ch, -1);
   }
            else
            {
                buf = cat_tb_ch_option(ch, turbo_ch[1]);
            }
   $('#iw_turboRoaming_channel_1').append(buf);

   if( $.inArray(turbo_ch[2], turbo_ch) != 2 )
            {
    buf = cat_tb_ch_option(ch, -1);
   }
            else
            {
                buf = cat_tb_ch_option(ch, turbo_ch[2]);
            }
            $('#iw_turboRoaming_channel_2').append(buf);
  }

  function iw_virtual_initial()
  {

   $('#iw_virtualType_Settings').hide();
  }


  function editPermission()
  {
   var form = document.wireless_advan, i, j = <% iw_websCheckPermission(); %>;
   if(j)
   {
    for(i = 0; i < form.length; i++)
     form.elements[i].disabled = true;
   }
  }


  function iw_onLoad()
  {
   var formItem, ctrlItem, newItem, i;
   var wmm = "<% iw_webCfgValueHandler(wifiSection, "wmm", "DISABLE"); %>";

   var macClone = "<% iw_webCfgValueHandler(wifiSection, "macClone", "DISABLE"); %>";
   var txRateEnable = true;
   var txantennaEnable = false;
   var txRateN = "<% iw_webCfgValueHandler(wifiSection, "txRateN", "auto"); %>";


   var disableTxRate = false; //for 3131 debug

   var AutoConnEnable = <% iw_web_AutoConn_enable(); %>


   iw_virtual_initial(); //: For Link Protection setting

   // For wireless_basic form
   formItem = document.wireless_advan;






   if( VAPopMode == "CLIENT" || VAPopMode == "SLAVE" || VAPopMode == "AP-CLIENT"

    || VAPopMode == "CLIENT-ROUTER"

     )
   {
    document.getElementById("iw_beaconInterval").disabled = true;
    document.getElementById("iw_dtimInterval").disabled = true;

                document.getElementById("iw_inactiveTimeout").disabled = true;

    document.getElementById("iw_multicastRate").disabled = true;



   }


   if( VAPopMode == "CLIENT" || VAPopMode == "SLAVE" || VAPopMode == "AP-CLIENT" )
   {
                //disable 50ms roaming settings when opmode isn't AP
    isAPMode = false;



   } else {
    isAPMode = true;
   }
   if( VAPopMode == "SNIFFER" )

   {
    for( i = 0; i < formItem.elements.length; i++ )
    {
     formItem.elements[i].disabled = true;
    }
                      document.getElementById("Submit").disabled = false;
                      document.getElementById("bkpath").disabled = false;
                      document.getElementById("wifiSection").disabled = false;
                      document.getElementById("vapSection").disabled = false;
                      document.getElementById("roamingSection").disabled = false;
                      document.getElementById("iw_turboRoaming_enable").disabled = false;
   }
   var currenttype = "<% iw_webCfgValueHandler(wifiSection, "rfType", "failed");  %>";
   var typeStr, channelIndex, roamingIndex;


   var turboRoamingChannel_list = new Array();
   turboRoamingChannel_list["A"] = new Array("<% iw_webCfgValueHandler(roamingSection, "channel_a_0", "36"); %>", "<% iw_webCfgValueHandler(roamingSection, "channel_a_1", "36"); %>", "<% iw_webCfgValueHandler(roamingSection, "channel_a_2", "36"); %>");
   turboRoamingChannel_list["B"] = new Array("<% iw_webCfgValueHandler(roamingSection, "channel_b_0", "6"); %>", "<% iw_webCfgValueHandler(roamingSection, "channel_b_1", "6"); %>", "<% iw_webCfgValueHandler(roamingSection, "channel_b_2", "6"); %>");
   turboRoamingChannel_list["G"] = new Array("<% iw_webCfgValueHandler(roamingSection, "channel_g_0", "6"); %>", "<% iw_webCfgValueHandler(roamingSection, "channel_g_1", "6"); %>", "<% iw_webCfgValueHandler(roamingSection, "channel_g_2", "6"); %>");
   turboRoamingChannel_list["BG"] = new Array("<% iw_webCfgValueHandler(roamingSection, "channel_bg_0", "6"); %>", "<% iw_webCfgValueHandler(roamingSection, "channel_bg_1", "6"); %>", "<% iw_webCfgValueHandler(roamingSection, "channel_bg_2", "6"); %>");


   if( currenttype == "A-MODE" )
         {
          typeStr = "A";
          channelIndex = "A";
          roamingIndex = "A";
          disableTxRate = true;
          txantennaEnable = true;

    document.getElementById("Message_txRateMin").innerHTML = "(0 to 54Mbps, 0 to disable)"

   }else if( currenttype == "B-MODE" )
   {
    typeStr = "B";
          channelIndex = "B";
          roamingIndex = "B";
          disableTxRate = true;
          txantennaEnable = true;

    document.getElementById("Message_txRateMin").innerHTML = "(0 to 11Mbps, 0 to disable)"

         }else if( currenttype == "G-MODE" )
         {
          typeStr = "G";
          channelIndex = "G";
          roamingIndex = "G";
          disableTxRate = true;
          txantennaEnable = true;

    document.getElementById("Message_txRateMin").innerHTML = "(0 to 54Mbps, 0 to disable)"

         }else if( currenttype == "BGMixed" )
         {
          typeStr = "B/G Mixed";
          channelIndex = "G";
          roamingIndex = "BG";
          disableTxRate = true;
    txantennaEnable = true;

    document.getElementById("Message_txRateMin").innerHTML = "(0 to 54Mbps, 0 to disable)"

         }

         else if( currenttype == "GNMixed" )
         {
                hasNmode = true;
          typeStr = "G/N Mixed";
          channelIndex = "G";
          roamingIndex = "BG";
          txRateEnable = false;



          wmm = "ENABLE";
          txantennaEnable = true;
          document.getElementById("iw_wmm").disabled = true;

    document.getElementById("Message_txRateMin").innerHTML = "(0 to 64Mbps, 0 to disable)"

                document.getElementById('iw_txRate').disabled = true;
         }else if( currenttype == "BGNMixed" )
         {
                hasNmode = true;
          typeStr = "B/G/N Mixed";
          channelIndex = "G";
          roamingIndex = "BG";
          txRateEnable = false;



          wmm = "ENABLE";
          txantennaEnable = true;
          document.getElementById("iw_wmm").disabled = true;

    document.getElementById("Message_txRateMin").innerHTML = "(0 to 64Mbps, 0 to disable)"

                document.getElementById('iw_txRate').disabled = true;
         }else if( currenttype == "N-MODE-24G" )
         {
          isNonly = true;
                hasNmode = true;
          typeStr = "N Only (2.4GHz)";
          channelIndex = "G";
          roamingIndex = "BG";



          wmm = "ENABLE";
          txantennaEnable = true;
          document.getElementById("iw_wmm").disabled = true;

    document.getElementById("Message_txRateMin").innerHTML = "(0 to 64Mbps, 0 to disable)"

         }else if( currenttype == "ANMixed" )
         {
                hasNmode = true;
          typeStr = "A/N Mixed";
          channelIndex = "A";
          roamingIndex = "A";
          txRateEnable = false;



          wmm = "ENABLE";
          txantennaEnable = true;
          document.getElementById("iw_wmm").disabled = true;

    document.getElementById("Message_txRateMin").innerHTML = "(0 to 64Mbps, 0 to disable)"

                document.getElementById('iw_txRate').disabled = true;
         }else if( currenttype == "N-MODE-5G" )
         {
                hasNmode = true;
          isNonly = true;
          typeStr = "N Only (5GHz)";
          channelIndex = "A";
          roamingIndex = "A";



          wmm = "ENABLE";
          txantennaEnable = true;
          document.getElementById("iw_wmm").disabled = true;

    document.getElementById("Message_txRateMin").innerHTML = "(0 to 64Mbps, 0 to disable)"

         }




         //document.getElementById("iw_txRate").disabled = !txRateEnable;






         document.getElementById('rfType').innerHTML = typeStr;
   $('#iw_turboRoaming_enable').val(turboRoamingEnable);
   document.getElementById('turboRoaming_enable').checked = (turboRoamingEnable=="ENABLE")?true:false;
   draw_tbroaming_option();

   ctrlItem = formItem.iw_txPower;
   iw_selectSet( ctrlItem, "<% iw_webCfgValueHandler(wifiSection, "txPower", ""); %>" );


   ctrlItem = formItem.iw_txantenna;
   iw_selectSet( ctrlItem, "<% iw_webCfgValueHandler(wifiSection, "txantenna", ""); %>" );



   ctrlItem = formItem.iw_apAliveCheck;
   iw_selectSet( ctrlItem, "<% iw_webCfgValueHandler(roamingSection, "apAliveCheck", "DISABLE"); %>" );
            iw_selectSet(formItem.iw_virtualType, "<% iw_webCfgValueHandler("AeroLinkProtection", "type", "DISABLE"); %>");
   iw_selectSet(formItem.iw_virtual_APAliveCheck, "<% iw_webCfgValueHandler("AeroLinkProtection", "APAliveCheck", "DISABLE"); %>");
   iw_selectSet(formItem.iw_virtualPort, "<% iw_webCfgValueHandler("AeroLinkProtection", "numPort", "PORT1"); %>");
   iw_selectSet(formItem.iw_virtualRF, "<% iw_webCfgValueHandler("AeroLinkProtection", "rfIndex", "RF1"); %>");


   iw_onChange();

   fill_roaming_param(currenttype);

   iw_selectSet(formItem.iw_wmm, wmm);
   document.getElementById("iw_txantenna").disabled = !txantennaEnable;
   iw_txRateChange();
   iw_txantennaChange();







   $('#iw_macClone').val(macClone);

   $('#iw_macCloneMethod').val("<% iw_webCfgValueHandler(wifiSection, "macCloneMethod", ""); %>");




   iw_macCloneOnChange();







                 editPermission();



   if(AutoConnEnable != "DISABLE")
   {
    formItem.turboRoaming_enable.disabled = true;
    formItem.iw_turboRoaming_channel_0.disabled = true;
    formItem.iw_turboRoaming_channel_1.disabled = true;
    formItem.iw_turboRoaming_channel_2.disabled = true;
   }
   else
   {
    formItem.iw_turboRoaming_channel_0.disabled = false;
    formItem.iw_turboRoaming_channel_1.disabled = false;
    formItem.iw_turboRoaming_channel_2.disabled = false;
   }


   top.toplogo.location.reload();

   if ( iw_is5GHz(currenttype) ) {
    $('#iw_txrange').show();
   } else {
    $('#iw_txrange').hide();
   }
  }

  function fill_roaming_param(type)
  {

   var roam_thr_2g, roam_thr_5g, roam_alive_thr_2g, roam_alive_thr_5g, roam_thr_unit, roam_alive_thr_unit;

   if( "<% iw_webCfgValueHandler(roamingSection, "roamingThreshold_unit", "SNR"); %>" == "SNR" )
   {
    document.wireless_advan.iw_turboRoaming_rssiThreshold_unit_SNR.checked = true;
    roam_thr_unit = "_SNR"
   } else {
    document.wireless_advan.iw_turboRoaming_rssiThreshold_unit_Signal.checked = true;
    roam_thr_unit = "_Signal"
   }

   if( "<% iw_webCfgValueHandler(roamingSection, "roamingAlive_unit", "SNR"); %>" == "SNR" )
   {
    document.wireless_advan.iw_turboRoaming_rssiAlive_unit_SNR.checked = true;
    roam_alive_thr_unit = "_SNR"
   } else {
    document.wireless_advan.iw_turboRoaming_rssiAlive_unit_Signal.checked = true;
    roam_alive_thr_unit = "_Signal"
   }

   var roam_thr_SNR = $('#iw_turboRoaming_rssiThreshold_SNR').attr('name');
   var roam_thr_Signal = $('#iw_turboRoaming_rssiThreshold_Signal').attr('name');
   var roam_diff = $('#iw_turboRoaming_rssiDifference').attr('name');
   var roam_alive_thr_SNR = $('#iw_turboRoaming_rssiAlive_SNR').attr('name');
   var roam_alive_thr_Signal = $('#iw_turboRoaming_rssiAlive_Signal').attr('name');

   if ( iw_isLegacy(type) ) {
    $('#iw_turboRoaming_rssiThreshold_SNR').val(<% iw_webCfgValueHandler(roamingSection, "roamingThresholdLegacy_SNR", "30"); %>);
    $('#iw_turboRoaming_rssiThreshold_Signal').val(<% iw_webCfgValueHandler(roamingSection, "roamingThresholdLegacy_Signal", "-65"); %>);
    if ( iw_is5GHz(type) ) {
     $('#iw_turboRoaming_rssiDifference').val(<% iw_webCfgValueHandler(roamingSection, "roamingDifference5G", "7"); %>);
     $('#iw_turboRoaming_rssiAlive_SNR').val(<% iw_webCfgValueHandler(roamingSection, "roamingAlive5G_SNR", "28");%>);
     $('#iw_turboRoaming_rssiAlive_Signal').val(<% iw_webCfgValueHandler(roamingSection, "roamingAlive5G_Signal", "-68"); %>);
     $('#iw_turboRoaming_rssiDifference').attr('name', roam_diff + "5G");
     $('#iw_turboRoaming_rssiAlive_SNR').attr('name', roam_alive_thr_SNR + "5G_SNR");
     $('#iw_turboRoaming_rssiAlive_Signal').attr('name', roam_alive_thr_Signal + "5G_Signal");
    } else {
     $('#iw_turboRoaming_rssiDifference').val(<% iw_webCfgValueHandler(roamingSection, "roamingDifference2G", "7"); %>);
     $('#iw_turboRoaming_rssiAlive_SNR').val(<% iw_webCfgValueHandler(roamingSection, "roamingAlive2G_SNR", "28");%>);
     $('#iw_turboRoaming_rssiAlive_Signal').val(<% iw_webCfgValueHandler(roamingSection, "roamingAlive2G_Signal", "-68"); %>);
     $('#iw_turboRoaming_rssiDifference').attr('name', roam_diff + "2G");
     $('#iw_turboRoaming_rssiAlive_SNR').attr('name', roam_alive_thr_SNR + "2G_SNR");
     $('#iw_turboRoaming_rssiAlive_Signal').attr('name', roam_alive_thr_Signal + "2G_Signal");
    }
    $('#iw_turboRoaming_rssiThreshold_SNR').attr('name', roam_thr_SNR + "Legacy_SNR");
    $('#iw_turboRoaming_rssiThreshold_Signal').attr('name', roam_thr_Signal + "Legacy_Signal");
   } else {
    $('#iw_turboRoaming_rssiThreshold_SNR').val(<% iw_webCfgValueHandler(roamingSection, "roamingThresholdNmode_SNR", "40"); %>);
    if ( iw_is5GHz(type) ) {
     $('#iw_turboRoaming_rssiThreshold_Signal').val(<% iw_webCfgValueHandler(roamingSection, "roamingThresholdNmode5G_Signal", "-65"); %>);
     $('#iw_turboRoaming_rssiDifference').val(<% iw_webCfgValueHandler(roamingSection, "roamingDifference5G", "7"); %>);
     $('#iw_turboRoaming_rssiAlive_SNR').val(<% iw_webCfgValueHandler(roamingSection, "roamingAlive5G_SNR", "28");%>);
     $('#iw_turboRoaming_rssiAlive_Signal').val(<% iw_webCfgValueHandler(roamingSection, "roamingAlive5G_Signal", "-68"); %>);
     $('#iw_turboRoaming_rssiDifference').attr('name', roam_diff + "5G");
     $('#iw_turboRoaming_rssiAlive_SNR').attr('name', roam_alive_thr_SNR + "5G_SNR");
     $('#iw_turboRoaming_rssiAlive_Signal').attr('name', roam_alive_thr_Signal + "5G_Signal");
     $('#iw_turboRoaming_rssiThreshold_Signal').attr('name', roam_thr_Signal + "Nmode5G_Signal");
    } else {
     $('#iw_turboRoaming_rssiThreshold_Signal').val(<% iw_webCfgValueHandler(roamingSection, "roamingThresholdNmode24G_Signal", "-65"); %>);
     $('#iw_turboRoaming_rssiDifference').val(<% iw_webCfgValueHandler(roamingSection, "roamingDifference2G", "7"); %>);
     $('#iw_turboRoaming_rssiAlive_SNR').val(<% iw_webCfgValueHandler(roamingSection, "roamingAlive2G_SNR", "28");%>);
     $('#iw_turboRoaming_rssiAlive_Signal').val(<% iw_webCfgValueHandler(roamingSection, "roamingAlive2G_Signal", "-68"); %>);
     $('#iw_turboRoaming_rssiDifference').attr('name', roam_diff + "2G");
     $('#iw_turboRoaming_rssiAlive_SNR').attr('name', roam_alive_thr_SNR + "2G_SNR");
     $('#iw_turboRoaming_rssiAlive_Signal').attr('name', roam_alive_thr_Signal + "2G_Signal");
     $('#iw_turboRoaming_rssiThreshold_Signal').attr('name', roam_thr_Signal + "Nmode24G_Signal");
    }
    $('#iw_turboRoaming_rssiThreshold_SNR').attr('name', roam_thr_SNR + "Nmode_SNR");
   }
  }


  function iw_macCloneOnChange()
  {

   if( $('#iw_macClone').val() == "ENABLE" )
   {
    $('#iwArea_macClone_method').show();
    if( $('#iw_macCloneMethod').val() == "Static" )
     $('#iwArea_macClone_staticMac').show();
    else
     $('#iwArea_macClone_staticMac').hide();
   } else
   {
    $('#iwArea_macClone_method').hide();
    $('#iwArea_macClone_staticMac').hide();
   }
  }


  function iw_onChange(unit)
  {
   var formItem, ctrlItem, newItem, i, selIndex;

   if( VAPopMode == "CLIENT" || VAPopMode == "CLIENT-ROUTER")
   {
    $('#turboRoamingEnable').show();
    if ( $('#turboRoaming_enable').attr('checked') ) {
     $('#iw_turboRoaming_enable').val('ENABLE');
     $('#turboRoamingSettings').show();
     {
      $('#iw_apAliveCheck_Settings').show();
                           $('#iw_dualLink_Settings').hide();

      if ( $('#iw_turboRoaming_rssiThreshold_unit_SNR').attr('checked') && unit == 'rssiThreshold_unit_SNR')
       $('#iw_turboRoaming_rssiAlive_unit_SNR').attr('checked', true);
      else if ( $('#iw_turboRoaming_rssiThreshold_unit_Signal').attr('checked') && unit == 'rssiThreshold_unit_Signal')
       $('#iw_turboRoaming_rssiAlive_unit_Signal').attr('checked', true);
      else if ( $('#iw_turboRoaming_rssiAlive_unit_SNR').attr('checked') && unit == 'rssiAlive_unit_SNR')
       $('#iw_turboRoaming_rssiThreshold_unit_SNR').attr('checked', true);
      else if ( $('#iw_turboRoaming_rssiAlive_unit_Signal').attr('checked') && unit == 'rssiAlive_unit_Signal')
       $('#iw_turboRoaming_rssiThreshold_unit_Signal').attr('checked', true);

      if ( $('#iw_apAliveCheck').val() == "ENABLE" ) {
       $('#keep_alive').show();
      } else {
       $('#keep_alive').hide();
      }

     }

    } else {
     $('#iw_turboRoaming_enable').val('DISABLE');
     $('#turboRoamingSettings').hide();
    }
   }else
   {
    $('#turboRoamingEnable').hide();
    $('#turboRoamingSettings').hide();
         }


   if (VAPopMode == "CLIENT" || VAPopMode == "SLAVE")
   {
    $('#iw_virtualType_Settings').show();
    if($('#iw_virtualType').val() == "ENABLE"){
     $('#iw_virtual_APAliveCheck').show();
     $('#iw_virtual_tip').show();
    }else{
     $('#iw_virtual_APAliveCheck').hide();
     $('#iw_virtual_tip').hide();
    }
   } else
   {
    $('#iw_virtualType_Settings').hide();
    $('#iw_virtual_tip').hide();
    $('#iw_virtual_APAliveCheck').hide();
   }

  }


  function iw_txantennaChange()
  {
   var txRate_select = document.getElementById('iw_txRate');
   var antenna = document.getElementById("iw_txantenna");

   if(isNonly == true) {
    if (antenna.selectedIndex != 2) {
     if ((antenna_orig == 2 || antenna_orig == 10) && (txRate_select.selectedIndex < 9 && txRate_select.selectedIndex > 0)) {
      alert("Transmission rate: Only MSC0 to MSC7 are allowed for on antenna configuration");
      txRate_select.selectedIndex = txRate_select.selectedIndex + 8;
     }
     $('#iw_txRate option').each(function()
     {
      if ($(this).index() > 0 && $(this).index() < 9)
       $(this).hide();
     });
    } else {
     $('#iw_txRate option').each(function()
     {
      if ($(this).index() > 0 && $(this).index() < 9)
       $(this).show();
     });
    }
    antenna_orig = antenna.selectedIndex;
   }
  }


  function iw_txRateChange()
  {


   var txRate_select = document.getElementById('iw_txRate');
            if(isNonly == false){
                if(txRate_select.selectedIndex == 0 && VAPopMode != "SNIFFER")
                    document.getElementById("iw_txRateMin").disabled = false;
                else{
                    document.getElementById("iw_txRateMin").value = 0;
                    document.getElementById("iw_txRateMin").disabled = true;
                }



            }else {
                if(txRate_select.selectedIndex == 0 && VAPopMode != "SNIFFER"){ //Disable guardInterval if the value of txRate is 'auto'
                    document.getElementById("iw_txRateMin").disabled = false;
                }else{
                    document.getElementById("iw_txRateMin").value = 0;
                    document.getElementById("iw_txRateMin").disabled = true;
                }
            }


  }
        -->
    </script>
 <script>
    function adjustItems ()
    {
  var VAPopMode = new String("<% iw_webCfgValueHandler(	"wlanDevWIFI0", "operationMode",	"AP"); %>");

        if ( VAPopMode != "CLIENT" ) {
         $('#mac_clone_table').hide();
            $('#iw_macClone').attr('disabled', 'disabled');
        } else
        {
         $('#mac_clone_table').show();
        }
    }

 $(document).ready( function() {
  fillTxPowerOption();
  adjustItems();
 });


 function fillTxPowerOption()
 {
  var value = "<% iw_webCfgValueHandler(wifiSection, "txPowerdBm", ""); %>";
  var txPowerRange = <% iw_websTxPowerRange(index); %>;
  var min, max, idx;

  min = txPowerRange['minPower'];
  max = txPowerRange['maxPower'];

  if( value > max )
   value = max;
  else if ( value < min )
   value = min;

  for(idx = min; idx <= max ; idx++)
   $('#iw_txPowerdBm').append($("<option></option>").attr("value", idx).text(idx + ' dBm'));

  $('#iw_txPowerdBm').val(value);
 }
 function _txPowerOptionByName ()
 {
  var opt = '';
  opt += '<option value="AUTO">Auto</option>';
  opt += '<option value="FULL">FULL</option>';
  opt += '<option value="HIGH">High</option>';
  opt += '<option value="MEDIUM">Medium</option>';
  opt += '<option value="LOW">Low</option>';
  return opt;
 }

 </script>
</head>
<body onLoad="iw_onLoad();">

 <h2>



  <% iw_webSysDescHandler("AdvancedWirelessSettingsTree", "", "Advanced Wireless Settings"); %>
&nbsp;&nbsp;<% iw_websGetErrorString(); %>

</h2>

 <form name="wireless_advan" method="post" action="/forms/webSetWirelessAdvan">
 <table width="100%">

 <tr><td colspan="2" class="block_seperator"></td></tr>
 <tr>
  <td width=30% class="column_title">
   <% iw_webCfgDescHandler( wifiSection, "txRateA", "Transmission rate" ); %>
  </td>
  <td width=70%>
   <select size="1" id="iw_txRate" name="iw_txRate" onchange="iw_txRateChange();">
    <% iw_webGetWirelessAdvanTxRate(wifiSection); %>
   </select>
  </td>
 </tr>

 <tr>
        <td width=30% class="column_title">
            <% iw_webCfgDescHandler( wifiSection, "txRateMin", "Minimum Transmission rate" ); %>
        </td>
        <td width=70%>
            <input type="text" id="iw_txRateMin" name="iw_<% write(wifiSection); %>_txRateMin" size="5" maxlength="2" value="<% iw_webCfgValueHandler(wifiSection, "txRateMin", "0"); %>" />&nbsp;
            <a id="Message_txRateMin" style="text-decoration:none;color:black;">test</a>
        </td>
    </tr>




 <tr>
  <td width=30% class="column_title">
   <% iw_webCfgDescHandler( wifiSection, "multicastRateA", "Multicast rate" ); %>
  </td>
  <td width=70%>
   <select size="1" id="iw_multicastRate" name="iw_multicastRate">
    <% iw_webGetWirelessMulticastRate(wifiSection); %>
   </select>
  </td>
 </tr>
 <tr>
  <td width=30% class="column_title">
   <% iw_webCfgDescHandler( wifiSection, "txPower", "Transmission power" ); %>
  </td>
  <td width=70%>
   <select size="1" id="iw_txPowerdBm" name="iw_<% write(wifiSection); %>_txPowerdBm" style="width: 75px">
   </select>
  </td>
 </tr>


 <tr>
  <td width=30% class="column_title">
   <% iw_webCfgDescHandler( wifiSection, "beaconInterval", "Beacon interval" ); %>
  </td>
  <td width=70%>
   <input type="text" id="iw_beaconInterval" name="iw_<% write(wifiSection); %>_beaconInterval" size="6" maxlength="4" value="<% iw_webCfgValueHandler(wifiSection, "beaconInterval", ""); %>" />&nbsp;&nbsp;(40 to 1000ms)
  </td>
 </tr>
 <tr>
  <td width=30% class="column_title">
   <% iw_webCfgDescHandler( wifiSection, "dtimInterval", "DTIM interval" ); %>
  </td>
  <td width=70%>
   <input type="text" id="iw_dtimInterval" name="iw_<% write(wifiSection); %>_dtimInterval" size="5" maxlength="3" value="<% iw_webCfgValueHandler(wifiSection, "dtimInterval", ""); %>" />&nbsp;&nbsp;(1 to 15)
  </td>
 </tr>

    <tr>
        <td width=30% class="column_title">
            <% iw_webCfgDescHandler( wifiSection, "inactiveTimeout", "" ); %>
        </td>
        <td width=70%>
            <input type="text" id="iw_inactiveTimeout" name="iw_<% write(wifiSection); %>_inactiveTimeout" size="5" maxlength="3" value="<% iw_webCfgValueHandler(wifiSection, "inactiveTimeout", ""); %>" />&nbsp;&nbsp;(1 to 240 second)
        </td>
    </tr>




 <tr>
  <td width=30% class="column_title">
   <% iw_webCfgDescHandler( wifiSection, "fragThresh", "Fragmentation threshold" ); %>
  </td>
  <td width=70%>
   <input type="text" id="iw_fragThresh" name="iw_<% write(wifiSection); %>_fragThresh" size="6" maxlength="4" value="<% iw_webCfgValueHandler(wifiSection, "fragThresh", ""); %>" />&nbsp;&nbsp;(256 to 2346)
  </td>
 </tr>
 <tr>
  <td width=30% class="column_title">
   <% iw_webCfgDescHandler( wifiSection, "rtsThreshold", "RTS threshold" ); %>
  </td>
  <td width=70%>
   <input type="text" id="iw_rtsThreshold" name="iw_<% write(wifiSection); %>_rtsThreshold" size="6" maxlength="4" value="<% iw_webCfgValueHandler(wifiSection, "rtsThreshold", ""); %>" />&nbsp;&nbsp;(32 to 2346)
  </td>
 </tr>


 <tr id="iw_txrange">
  <td width=30% class="column_title">
   <% iw_webCfgDescHandler( wifiSection, "txrange", "Wireless radio transmission range" ); %>
  </td>
  <td width=70%>
   <input type="text" id="iw_txrange" name="iw_<% write(wifiSection); %>_txrange" size="6" maxlength="5" value="<% iw_webCfgValueHandler(wifiSection, "txrange", ""); %>" />&nbsp;&nbsp;(500 to 11000m)
  </td>
 </tr>
 <tr>
  <td width=30% class="column_title">
   <% iw_webCfgDescHandler( wifiSection, "txantenna", "Wireless transmission antenna" ); %>
  </td>
  <td width=70%>
   <select size="1" id="iw_txantenna" name="iw_<% write(wifiSection); %>_txantenna" onchange="iw_txantennaChange();">
    <option value="main-antenna">A</option>
    <option value="aux-antenna">B</option>

    <option value="diversity-antenna">Both</option>

   </select>
  </td>
 </tr>






 <tr>
   <td width="30%" class="column_title"><% iw_webCfgDescHandler(wifiSection, "wmm", "DISABLE"); %></td>
 <td width="70%" style="padding-left:0px;">
  <select size="1" id="iw_wmm" name="iw_<% write(wifiSection); %>_wmm">
      <option value="ENABLE">Enable</option>
      <option value="DISABLE">Disable</option>
        </select>
 </td>
 </tr>
 </table>
 <table id="turboRoamingEnable" style="display:none;" width="100%">
    <tr>
  <td width="30%" class="column_title"><% iw_webSysDescHandler("TurboRoaming", "", "failed"); %></td>
  <td width="70%">
   <input type="checkbox" id="turboRoaming_enable" onclick="iw_onChange();" />
    <label for="turboRoaming_enable"><% iw_webCfgDescHandler(roamingSection, "enable", "Enable"); %></label>
        </td>
    </tr>
 </table>

 <table id="turboRoamingSettings" style="display:none;" width="100%">
 <tr>
  <td width="30%" class="column_title"><% iw_webCfgDescHandler(wifiSection, "rfType", "failed"); %></td>
  <td width="70%"><div id="rfType"></div></td>
 </tr>
 <tr>
  <td></td>
 </tr>
 <tr>
        <td width="30%" class="column_title" valign="top"><% iw_webCfgDescHandler(roamingSection, "roamingThreshold2G_SNR", "Roaming threshold"); %></td>
  <td width="70%">
  <table width="100%">
  <tr>
  <td>
   <input type="radio" name="iw_<% write(roamingSection); %>_roamingThreshold_unit" id="iw_turboRoaming_rssiThreshold_unit_SNR" value="SNR" onChange="iw_onChange('rssiThreshold_unit_SNR');"/>
                        <label for="iw_turboRoaming_rssiThreshold_unit_SNR">SNR</label>
  <input type="text" id="iw_turboRoaming_rssiThreshold_SNR" name="iw_<% write(roamingSection); %>_roamingThreshold" size="6" maxlength="4" value=""> (5 to 40)
  </td>
  </tr>
  <tr>
  <td>
                        <input type="radio" name="iw_<% write(roamingSection); %>_roamingThreshold_unit" id="iw_turboRoaming_rssiThreshold_unit_Signal" value="Signal Strength" onChange="iw_onChange('rssiThreshold_unit_Signal');"/>
                        <label for="iw_turboRoaming_rssiThreshold_unit_Signal">Signal Strength</label>
  <input type="text" id="iw_turboRoaming_rssiThreshold_Signal" name="iw_<% write(roamingSection); %>_roamingThreshold" size="6" maxlength="4" value=""> dBm (-100 to -35)
  </td>
  </tr>
  </table>
  </td>
 </tr>
 <tr>
  <td width="30%" class="column_title"><% iw_webCfgDescHandler(roamingSection, "roamingDifference2G", "Roaming difference"); %></td>
  <td width="70%">
  <input type="text" id="iw_turboRoaming_rssiDifference" name="iw_<% write(roamingSection); %>_roamingDifference" size="6" maxlength="3" value=""> ( 5 to 20)
  </td>
 </tr>


 <tr>
   <td width="30%" class="column_title" valign="top"><% iw_webCfgDescHandler(roamingSection, "channel_b_0", "failed"); %></td>
 <td width="70%" style="padding-left:0px;">
  <table width="100%" style="padding-left:0px;margin-left:0px;">
      <tr style="padding-left:0px;margin-left:0px;">
          <td style="padding-left:0px;margin-left:0px;">
       <select style="padding-left:0px;" name="turboRoaming_channel" id="iw_turboRoaming_channel_0">
       </select>
       </td>
   </tr>

   <tr style="padding-left:0px;margin-left:0px;">
          <td style="padding-left:0px;margin-left:0px;">
       <select style="padding-left:0px;" name="turboRoaming_channel" id="iw_turboRoaming_channel_1">
       </select>
       </td>
   </tr>

   <tr style="padding-left:0px;margin-left:0px;">
          <td style="padding-left:0px;margin-left:0px;">
       <select style="padding-left:0px;" name="turboRoaming_channel" id="iw_turboRoaming_channel_2">
       </select>
       </td>
   </tr>
  </table>
 </td>
 </tr>
 <tr id="iw_apAliveCheck_Settings">
  <td width="30%" class="column_title"><% iw_webCfgDescHandler( roamingSection, "apAliveCheck", "AP alive check" ); %></td>
        <td width="70%">
      <select size="1" id="iw_apAliveCheck" name="iw_<% write(roamingSection); %>_apAliveCheck" onChange="iw_onChange();" >
       <option value="ENABLE">Enable</option>
       <option value="DISABLE">Disable</option>
   </select>
        </td>
 </tr>

 <tr id="keep_alive">
     <td width="30%" class="column_title" valign="top"><% iw_webCfgDescHandler( roamingSection, "roamingAlive2G_SNR", "AP candidate threshold"); %></td>
        <td width="70%">

  <table>
  <tr>
  <td>
   <input type="radio" name="iw_<% write(roamingSection); %>_roamingAlive_unit" id="iw_turboRoaming_rssiAlive_unit_SNR" value="SNR" onChange="iw_onChange('rssiAlive_unit_SNR');"/>
                        <label for="iw_turboRoaming_rssiAlive_unit_SNR">SNR</label>
          <input type="text" id="iw_turboRoaming_rssiAlive_SNR" name="iw_<% write(roamingSection); %>_roamingAlive" size="6" maxlength="4" value="" /> dB (5 to 40)
  </td>
  </tr>
  <tr>
  <td>
   <input type="radio" name="iw_<% write(roamingSection); %>_roamingAlive_unit" id="iw_turboRoaming_rssiAlive_unit_Signal" value="Signal Strength" onChange="iw_onChange('rssiAlive_unit_Signal');"/>
                        <label for="iw_turboRoaming_rssiAlive_unit_Signal">Signal Strength</label>
          <input type="text" id="iw_turboRoaming_rssiAlive_Signal" name="iw_<% write(roamingSection); %>_roamingAlive" size="6" maxlength="4" value="" /> dBm (-100 to -35)
  </td>
  </tr>
  </table>
 </td>
 </tr>
 </table>


 <table>
    <tr id="iw_virtualType_Settings" style="" width="100%">
  <td width="30%" class="column_title"><% iw_webCfgDescHandler( "AeroLinkProtection", "type", "" ); %></td>
  <td width="70%">
   <select size="1" id="iw_virtualType" name="iw_AeroLinkProtection_type" onChange="iw_onChange();" >
    <option value="DISABLE">Disable</option>




    <option value="ENABLE">Enable</option>

   </select>
  </td>
 </tr>
 <tr id="iw_virtual_APAliveCheck" style="" width="100%">
  <td width="30%" class="column_title"><% iw_webCfgDescHandler("AeroLinkProtection", "APAliveCheck",""); %></td>
  <td width-"70%">
   <select size="1" id="iw_virtual_APAliveCheck" name="iw_AeroLinkProtection_APAliveCheck" onChange="iw_onChange();">
    <option value="ENABLE">Enable</option>
    <option value="DISABLE">Disable</option>
   </select>
  </td>
 </tr>
 <table id="mac_clone_table">
 <tr>
  <td width="30%" class="column_title" valign="top"><% iw_webCfgDescHandler(wifiSection, "macClone", "DISABLE"); %></td>
  <td width="70%" style="padding-left:0px;">
   <select size="1" id="iw_macClone" name="iw_<% write(wifiSection); %>_macClone" onclick="iw_macCloneOnChange();">
    <option value="ENABLE">Enable</option>
    <option value="DISABLE">Disable</option>
   </select>
  </td>
 </tr>

 <tr id="iwArea_macClone_method">
  <td width="30%" class="column_title" valign="top"><% iw_webCfgDescHandler(wifiSection, "macCloneMethod", ""); %></td>
  <td width="70%" style="padding-left:0px;">
   <select size="1" id="iw_macCloneMethod" name="iw_<% write(wifiSection); %>_macCloneMethod" onclick="iw_macCloneOnChange();">
    <option value="Auto">Auto</option>
    <option value="Static">Static</option>
   </select>
  </td>
 </tr>
 <tr id="iwArea_macClone_staticMac">
  <td width="30%" class="column_title" valign="top"><% iw_webCfgDescHandler(wifiSection, "macCloneStaticMac", ""); %></td>
  <td width="70%" ><INPUT type="text" name="iw_<% write(wifiSection); %>_macCloneStaticMac" size="22" maxlength="17" value="<% iw_webCfgValueHandler(wifiSection, "macCloneStaticMac", ""); %>" /> (ex: 00:90:E8:00:00:01) </td>
 </tr>
 </table>
 <table width="100%">
 <tr>
  <td colspan="2">
   <hr />
   <input type="button" value="Submit" name="Submit" id="Submit" onclick="iw_onSubmit();"/>
   <input type="hidden" name="bkpath" id="bkpath" value="/wireless_advan.asp?index=<% write(index); %>" />
   <input type="hidden" name="wifiSection" id="wifiSection" value="<% write(wifiSection); %>" />
   <input type="hidden" name="vapSection" id="vapSection" value="<% write(vapSection); %>" />

   <input type="hidden" name="roamingSection" id="roamingSection" value="<% write(roamingSection); %>" />
   <input type="hidden" name="iw_<% write(roamingSection); %>_enable" id="iw_turboRoaming_enable" />

  </td>
 </tr>
 </table>
 </form>

 <div>
     <I id="iw_virtual_tip">* Please enable AeroLink Protection on your Access Point as well.</I>
 </div>

</body>
</html>
<script type="text/javascript">
	$(document).ready(function () {
		var isEditPermission = !<% iw_websCheckPermission(); %>;
		if (isEditPermission == 0) {
			$(":input").attr('disabled','disabled');
		}
	});
</script>
