<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%
 var wifiSection, vapSection, roamingSection;



 if ( iw_isset(devIndex) == 0 )
 {
  devIndex = 1;
 }

 if ( iw_isset(vapIndex) == 0 )
 {
  vapIndex = 0;
 }

 if (devIndex==2)
 {
  wifiSection = "wlanDevWIFI1";
  vapSection = "wlanVap2";
  roamingSection = "turboRoaming1";




 }else
 {
  wifiSection = "wlanDevWIFI0";
  vapSection = "wlanVap1";
  roamingSection = "turboRoaming";




  devIndex = 1;
 }

 if ( vapIndex != 0 )
 {
  vapSection = vapSection + "0" + vapIndex ;
 }
%>
<html>
<head>
 <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
    <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate" />
    <meta http-equiv="Pragma" content="no-cache" />
    <meta http-equiv="Expires" content="0" />
 <link href="nport2g.css" rel="stylesheet" type="text/css" />
 <title>



 <% iw_webSysDescHandler( "BasicWirelessSettingsTree", "", "Basic Wireless Settings" ); %></title>
 <% iw_webJSList_get(); %>
 <script type="text/javascript">
  var rf_type = new Array(

  new Array( "2.4GHz", "" ),
  new Array( "B", "B-MODE" ),
  new Array( "G", "G-MODE" ),
  new Array( "B/G Mixed", "BGMixed" ),
  new Array( "G/N Mixed", "GNMixed" ),
  new Array( "B/G/N Mixed", "BGNMixed" ),
  new Array( "N Only (2.4GHz)", "N-MODE-24G" ),
  new Array( "5GHz", "" ),
  new Array( "A", "A-MODE" ),
  new Array( "A/N Mixed", "ANMixed" ),
  new Array( "N Only (5GHz)", "N-MODE-5G" )






  );

  var channel_list = new Array();
  channel_list["B"] = new Array(<% iw_webGetWirelessChan2G(devIndex, 0, 0); %>);
  channel_list["G"] = new Array(<% iw_webGetWirelessChan2G_GChan(devIndex, 0, 0); %>);
  channel_list["A"] = new Array(<% iw_webGetWirelessChan5G(devIndex, 0, 0); %>);
  var ht40_chan_list = [ <% iw_ht40_channel_list(devIndex, 0); %> ];

  var dfs_chan_list = [ <% iw_dfs_channel_list(devIndex, 0); %> ];
  var channel_state = new Array();
       channel_state["A"] = <% iw_webCfgValueHandler(wifiSection, "channel_a", "36"); %>;
        channel_state["B"] = <% iw_webCfgValueHandler(wifiSection, "channel_b", "6"); %>;
        channel_state["G"] = <% iw_webCfgValueHandler(wifiSection, "channel_g", "1"); %>;

        channel_state["N24GHz"] = <% iw_webCfgValueHandler(wifiSection, "channel_n24GHz", "1"); %>;
        channel_state["N5GHz"] = <% iw_webCfgValueHandler(wifiSection, "channel_n5GHz", "36"); %>;
  var channel_listStrKey = new Array();
  channel_listStrKey['A-MODE'] = new Array( "A", "A");
  channel_listStrKey['B-MODE'] = new Array( "B", "B");
  channel_listStrKey['G-MODE'] = new Array( "G", "G");
  channel_listStrKey['BGMixed'] = new Array( "G", "G");

  channel_listStrKey['GNMixed'] = new Array( "G", "N24GHz");
  channel_listStrKey['BGNMixed'] = new Array( "G", "N24GHz");
  channel_listStrKey['N-MODE-24G'] = new Array( "G", "N24GHz");
  channel_listStrKey['ANMixed'] = new Array( "A", "N5GHz");
  channel_listStrKey['N-MODE-5G'] = new Array( "A", "N5GHz");


  var vap = <% iw_webGetWirelessVap(devIndex, vapIndex); %>;
  var isAP = (vap.opMode == "AP" || vap.opMode == "MASTER" || vap.opMode == "REDUNDANT_AP" || vap.opMode == "ACC" || vap.opMode == "ACA") ? 1 : 0;

   var mem_state = <% iw_websMemoryChange(); %>;
  var http_req = iw_inithttpreq();
  var wirelessBasicList = <% iw_webGetWirelessBasicListArray(devIndex, vapIndex); %>;
  var rfType = new String("<% iw_webCfgValueHandler( wifiSection,	"rfType",			"G-MODE" ); %>");

  var ssidBroadCast = new String("<% iw_webCfgValueHandler( vapSection, 	"ssidBroadCast",	"ENABLE" ); %>");
  var dhcpSrvEnable = new String("<% iw_webCfgValueHandler( "dhcpSrv",		"enable",			"DISABLE" );%>");

  var currentIndex = new String("<% write(devIndex);write(vapIndex); %>");


  var proxyArp = "<% iw_webCfgValueHandler( wifiSection,	"proxyArp",			"ENABLE" ); %>";



  var mgmt_frame_encrypt = "<% iw_webCfgValueHandler( vapSection, "mgmtEncryption", "DISABLE" ); %>";



  var aerolink_ap = "<% iw_webCfgValueHandler( vapSection, "aerolink_ap", "DISABLE" ); %>";


  var lfpt_enable = "<% iw_webCfgValueMainHandler( "linkFaultPassThrough", "enable", "DISABLE" ); %>";


  function iw_onSubmit(form)
  {
   var rfTypeSet = $('#iw_rfType option:selected').val();







   if( document.wireless_basic.iw_ssid.value.length == 0 )
   {
    alert("SSID cannot be empty.");
    document.wireless_basic.iw_ssid.focus();
    return false;
   }

   if(! isAsciiString(document.wireless_basic.iw_ssid.value))
   {
    alert("Invalid SSID: ASCII only");
    document.wireless_basic.iw_ssid.focus();
    return false;
   }
   if( "ENABLE" == "<% iw_webCfgValueHandler(roamingSection, "enable", "DISABLE"); %>" )
   {
    if( "<% iw_webCfgValueHandler( "board", "operationMode", "OP Mode" ); %>" == 'AP-CLIENT' &&
     (vap.opMode == 'CLIENT' || vap.opMode == 'CLIENT-ROUTER')&&
     rfType != rfTypeSet )
    {
     alert( "Modifying RF mode may affect behavior of turbo roaming.\nPlease check turbo roaming settings in \"Advanced Wireless Settings\"." );
    }

   }
   if( rfTypeSet == "GNMixed" || rfTypeSet == "BGNMixed" || rfTypeSet == "ANMixed" )
   {
    if( "<% iw_webCfgValueHandler( wifiSection,	"txRateN", "auto" ); %>" != "auto" )
     alert( "Transmission rate will be forced to \"Auto\" when using N-Mixed mode." );
   }
   return true;
  }

  //initial
  function iw_initial(){
  }
  function iw_multiSecure_onChange()
  {
   var isAP = (vap.opMode == "AP" || vap.opMode == "MASTER" || vap.opMode == "REDUNDANT_AP" || vap.opMode == "ACC" || vap.opMode == "ACA") ? 1 : 0;
  }


  function editPermission()
  {
   var form = document.wireless_basic, i, j = <% iw_websCheckPermission(); %>;
   if(j)
   {
    for(i = 0; i < form.length; i++)
     form.elements[i].disabled = true;
   }
  }


  function iw_onLoad()
  {
   var formItem, ctrlItem, newItem, i;

   var AutoConnEnable = <% iw_web_AutoConn_enable(); %>


   // For wireless_basic form
   formItem = document.wireless_basic;
   iw_initial(); //: Multiple SSID init.


   document.getElementById("iw_proxyArp_En").disabled = true;
   document.getElementById("iw_proxyArp_Dis").disabled = true;
   $(".proxy_arp_item").hide();

   if (proxyArp == "ENABLE")
    formItem.iw_proxyArp_En.checked = true;
   else
    formItem.iw_proxyArp_Dis.checked = true;



   document.getElementById("iw_mgmtEncryption_En").disabled = false;
            document.getElementById("iw_mgmtEncryption_Dis").disabled = false;

            if (mgmt_frame_encrypt == "ENABLE")
                formItem.iw_mgmtEncryption_En.checked = true;
            else
                formItem.iw_mgmtEncryption_Dis.checked = true;



   document.getElementById("iw_aerolink_ap_En").disabled = false;
            document.getElementById("iw_aerolink_ap_Dis").disabled = false;

   if( vap.opMode == "AP" || vap.opMode == "MASTER" )
   {
             if (aerolink_ap == "ENABLE") {
                 formItem.iw_aerolink_ap_En.checked = true;
     $('#iw_aerolink_ap_tip').show();
             } else {
                 formItem.iw_aerolink_ap_Dis.checked = true;
     $('#iw_aerolink_ap_tip').hide();
    }

    $('#iw_aerolink_ap_En').click(function() {
     if ( $(this).is(':checked') ) {
      $('#iw_aerolink_ap_tip').show();
     }
    });

    $('#iw_aerolink_ap_Dis').click(function() {
     if ( $(this).is(':checked') ) {
                        $('#iw_aerolink_ap_tip').hide();
                    }
    });
   }
   else {
    $('#areolink_ap').hide();
    $('#iw_aerolink_ap_tip').hide();
   }


   if( vap.opMode == "CLIENT" ||
                vap.opMode == "CLIENT-ROUTER" ||
    vap.opMode == "SLAVE" ||
    vap.opMode == "AP-CLIENT" ||
    vap.opMode == "REDUNDANT_CLIENT" )
   {
    document.getElementById("site_survey").style.display = "";

       document.getElementById("iw_channel").disabled = true;
       $(".channel_item").hide();


    document.getElementById("iw_channel").disabled = true;
    document.getElementById("iw_ssidBroadCast_En").disabled = true;
    document.getElementById("iw_ssidBroadCast_Dis").disabled = true;
    $(".channel_item").hide();
    $(".ssid_broadcast_item").hide();
    if( vap.opMode == "CLIENT-ROUTER" )
    {
     document.getElementById("iw_proxyArp_En").disabled = false;
     document.getElementById("iw_proxyArp_Dis").disabled = false;
     $(".proxy_arp_item").show();
    }


   }

            else if (vap.opMode == "SNIFFER") {

                document.getElementById("iw_ssidBroadCast_En").disabled = true;
                document.getElementById("iw_ssidBroadCast_Dis").disabled = true;
                $(".ssid_broadcast_item").hide();
                $('#row_ssid').hide();

            }


   else if( vap.opMode == "DISABLE" )
   {
    for( i = 0; i < formItem.elements.length; i++ )
    {
     formItem.elements[i].disabled = true;
    }
   }else if( 0 != <% write(vapIndex); %> )
   {
    document.getElementById("site_survey").style.display = "none";
    document.getElementById("iw_rfType").disabled = true;





       document.getElementById("iw_channel").disabled = true;


    document.getElementById("iw_channel").disabled = true;
    document.getElementById("iw_channelWidth").disabled = true;
    document.getElementById("iw_ssidBroadCast_En").disabled = false;
    document.getElementById("iw_ssidBroadCast_Dis").disabled = false;

   }
   document.getElementById("iw_operationMode").innerHTML = iwStrMap(vap.opMode);

   // Load RF type
   ctrlItem = formItem.iw_rfType;
   for( i = 0; i < ctrlItem.options.length; i++ )
   {
    ctrlItem.options[i] = null;
   }
   for( i = 0; i < rf_type.length; i++ )
   {

                if(vap.opMode == "SNIFFER") // SNIFFER mode only show BGN Mixed and AN Mixed.
                {
                    if(rf_type[i][1] != "" && rf_type[i][1] != "B-MODE" && rf_type[i][1] != "BGNMixed" && rf_type[i][1] != "ANMixed")
                        continue;
                }

    newItem = document.createElement("option");
    newItem.text = rf_type[i][0];
    newItem.value = rf_type[i][1];
    ctrlItem.options.add(newItem);
    if( rf_type[i][1] == "" )
    {
     newItem.disabled = "disabled";
     newItem.style.backgroundColor = "black";
     newItem.style.color = "white";
    }
   }
            if(vap.opMode != "SNIFFER")
       iw_selectSet( ctrlItem, rfType );
            else
            {
    if(rfType == "B-MODE")
     iw_selectSet( ctrlItem, "B-MODE");
    else if(rfType == "G-MODE" || rfType == "BGMixed" || rfType == "GNMixed" || rfType == "BGNMixed" || rfType == "N-MODE-24G")
                    iw_selectSet( ctrlItem, "BGNMixed");
                else
                    iw_selectSet( ctrlItem, "ANMixed");
            }





   if (ssidBroadCast == "ENABLE")
    formItem.iw_ssidBroadCast_En.checked = true;
   else
    formItem.iw_ssidBroadCast_Dis.checked = true;
   iw_selectSet( document.getElementById("iw_channelWidth"), "<% iw_webCfgValueHandler(wifiSection, "channelWidth", "20MHz"); %>" );





   iw_onRfTypeChange();
   iw_multiSecure_onChange();
   // CAUSION : This line must be executed in <body onLoad()>


   if(AutoConnEnable != "DISABLE")
   {
    document.getElementById("iw_rfType").disabled = true;
    document.getElementById("iw_channel").disabled = true;
    document.getElementById("iw_channelWidth").disabled = true;
    if(vap.vapIndex == 0)
     document.getElementById("iw_ssid").disabled = true;
    document.getElementById("iw_mgmtEncryption_En").disabled = true;
    document.getElementById("iw_mgmtEncryption_Dis").disabled = true;
   }
   else
   {
    document.getElementById("iw_rfType").disabled = false;
    document.getElementById("iw_channel").disabled = false;
    document.getElementById("iw_ssid").disabled = false;
    document.getElementById("iw_channelWidth").disabled = false;
    document.getElementById("iw_mgmtEncryption_En").disabled = false;
    document.getElementById("iw_mgmtEncryption_Dis").disabled = false;
   }



                 editPermission();


   top.toplogo.location.reload();
  }
  function cleanChannelList(){
   // For wireless_basic form
   channelList = document.wireless_basic.iw_channel;
   for( i = channelList.length - 1; i >= 0 ; i-- ){
    channelList.remove(i);
   }
  }
  function addChannelToList(channel, rf_idx){
   // For wireless_basic form
            var sign = '';
            var freq = '';
            if ( jQuery.inArray( parseInt(channel), dfs_chan_list ) != -1 ) {
                sign = '*'; // DFS channel
            }

            { // non-DFS channel
                channelList = document.wireless_basic.iw_channel;
                option = document.createElement("option");
//              option.text = channel + sign;
    option.text = channel + sign + freq;
                option.value = channel;
                channelList.options.add(option);
      }
        }


  function channelset(){
   var rfTypeSet = document.getElementById("iw_rfType").value;
   var rfKey = channel_listStrKey[rfTypeSet][0];

   cleanChannelList();
   var channel = channel_list[rfKey];
   for( i = 0; i < channel.length; i++ ){
    addChannelToList(channel[i], rfKey);
   }
   iw_selectSet( document.getElementById('iw_channel'),channel_state[channel_listStrKey[rfTypeSet][1]]);


  }

  function iw_onChannelChange()
  {
   var is_passiveChannel = 0;
   var rfTypeSet = document.getElementById("iw_rfType").options[document.getElementById("iw_rfType").selectedIndex].value;
   var channel = document.getElementById("iw_channel").options[document.getElementById("iw_channel").selectedIndex].value;

   var isAP = (vap.opMode == "AP" || vap.opMode == "MASTER" || vap.opMode == "REDUNDANT_AP" || vap.opMode == "ACC" || vap.opMode == "ACA") ? 1 : 0;




   // check passive channel
   if ( http_req )
   {
    var req_str = "forms/web_checkPassiveChannel?rfType=" +rfTypeSet+ "&channel=" +channel + "&isAP=" +isAP;

    http_req.open( "GET", req_str, false );
    http_req.send( null );

    is_passiveChannel = Number( http_req.responseText );
   }


   if( isAP )
   {
    if( is_passiveChannel != 0)
    {
     // 802.11b is forced to broadcast SSID
     document.getElementById("iw_ssidBroadCast_En").checked = true;
     document.getElementById("iw_ssidBroadCast_En").disabled = true;
     document.getElementById("iw_ssidBroadCast_Dis").disabled = true;
    }else
    {
     document.getElementById("iw_ssidBroadCast_En").disabled = false;
     document.getElementById("iw_ssidBroadCast_Dis").disabled = false;
    }
   }else // Client Mode
   {
    document.getElementById("iw_ssidBroadCast_En").disabled = true;
    document.getElementById("iw_ssidBroadCast_Dis").disabled = true;
   }
   UpdateChannelWidth(rfTypeSet);
   iw_onChannelWidthChange();






            if ( jQuery.inArray( parseInt($('#iw_channel').val()), ht40_chan_list ) == -1 ||
                 rfTypeSet == 'A-MODE' ) {

                $('#iw_channelWidth').val('20MHz');
                $('#iw_chBonding').hide();
            } else {
                $('#iw_channelWidth').removeAttr("disabled");
                $('#iw_channelWidth').val('<% iw_webCfgValueHandler(wifiSection, "channelWidth", "20MHz"); %>');
                if ( $('#iw_channelWidth').val() == '20/40MHz') {
                    $('#iw_chBonding').show();
                } else {
                    $('#iw_chBonding').hide();
                }
            }

  }


  function iw_onChannelWidthChange()
  {
   var rfTypeSet = document.getElementById("iw_rfType").options[document.getElementById("iw_rfType").selectedIndex].value;






  if(rfTypeSet == 'ANMixed' || rfTypeSet == 'N-MODE-5G' || rfTypeSet == 'GNMixed' || rfTypeSet == 'BGNMixed' || rfTypeSet == 'N-MODE-24G')



   {
    $('#iw_chWdith').show();
    var is_channel_width_20MHz = $('#iw_chWdith option:selected').val() == "20MHz" ? 1 : 0;
    if( isAP != 1
        || is_channel_width_20MHz == 1)
    {
         $('#iw_chBonding').hide();
    } else {
     $('#iw_chBonding').show();
    }

    var i;
    var channelList = document.getElementById("iw_channel");
    var option, channelIndex = channelList.selectedIndex;
    var selectedChannel = parseInt($('#iw_channel option:selected').val());
    if( rfTypeSet == 'ANMixed' || rfTypeSet == 'N-MODE-5G' )
    {
      if ( isAP == 1
           && is_channel_width_20MHz == 0
           && selectedChannel == 165 )
     {
        alert('Channel 165 supports Channel width 20MHz only.');
      $('#iw_chBonding').hide();
     } else
     {
      selectedChannel = ((selectedChannel & 0x4) && (selectedChannel != 140) && (selectedChannel != channel_list["A"][channel_list["A"].length - 1])) ? selectedChannel + 4 : selectedChannel - 4;
     }
    }else
    {
     selectedChannel = selectedChannel <= 7 ? selectedChannel + 4 : selectedChannel - 4;
    }
    document.getElementById("iw_channelBonding").innerHTML = selectedChannel;
   }else
   {
    document.getElementById("iw_chWdith").style.display = "none";
    document.getElementById("iw_chBonding").style.display = "none";
   }
  }

  function iw_onRfTypeChange()
  {
   var formItem, ctrlItem, newItem, i, selIndex;
   var rfTypeSet = document.getElementById("iw_rfType").options[document.getElementById("iw_rfType").selectedIndex].value;

   // For wireless_basic form
   formItem = document.wireless_basic;

   if( rfTypeSet == "A-MODE" && 0 == <% iw_webGetTxEnhanceVersion(devIndex); %> && "<%iw_webCfgValueHandler(wifiSection, "txenhance", "DISABLE");%>" == "ENABLE" )
   {
    alert( 'Can not use A mode when "Transmission enhancement" is enabled.' );
    iw_selectSet( document.getElementById("iw_rfType"), "BGMixed" );
   }
   // Update Channel
   selIndex = formItem.iw_rfType.selectedIndex;
   if( selIndex > 2 )
    selIndex = 2;
   ctrlItem = formItem.iw_channel;

   channelset();
   iw_onChannelChange();
            if ( isAP && iw_is5GHz( rfTypeSet) ) {
                $('#dfs_tip').show();
                //$('#dfs_tip').hide();
            } else {
                $('#dfs_tip').hide();
            }

   UpdateChannelWidth(rfTypeSet);
  }

  function UpdateChannelWidth(rfTypeSet)
  {
   var obj = document.getElementById("iw_channelWidth");
   obj.options.length = 0;




   obj.options.add(new Option("20 MHz","20MHz"));
   if ( jQuery.inArray( parseInt($('#iw_channel').val()), ht40_chan_list ) != -1 )
   obj.options.add(new Option("20/40 MHz","20/40MHz"));





   iw_selectSet( obj, "<% iw_webCfgValueHandler(wifiSection, "channelWidth", "20MHz"); %>" );
  }

  function Survey()
  {

   if(lfpt_enable == "ENABLE")
    alert("Because LFPT will be triggered due to Site Survey, please disable LFPT first in order to do Site Survey.");
   else

    window.open('site_survey.asp?index=<% write(devIndex); %>','_blank','toolbar=no,location=no,directories=no,scrollbars=yes,width=720,height=600,resizable=no');
  }
    </script>
</head>
<body onload="iw_onLoad();">

 <h2>



  <% iw_webSysDescHandler( "BasicWirelessSettingsTree", "", "Basic Wireless Settings" ); %>&nbsp;&nbsp;<% iw_websGetErrorString(); %></h2>

 <form name="wireless_basic" method="post" action="/forms/webSetWirelessBasic" onsubmit="return iw_onSubmit(this);">

 <table width="100%">
 <tr><td colspan="2" class="block_seperator"></td></tr>
<tr>
  <td width="30%" class="column_title">

   <% iw_webCfgDescHandler( "board", "operationMode", "OP Mode" ); %>



  </td>
  <td width="70%">
   <div id="iw_operationMode">
   </div>
  </td>
 </tr>

 <tr>
  <td width="30%" class="column_title">
   <% iw_webCfgDescHandler( wifiSection, "rfType", "RF type" ); %>
  </td>
  <td width="70%">
   <select size="1" id="iw_rfType" name="iw_<% write(wifiSection); %>_rfType" onChange="iw_onRfTypeChange();">
   </select>
  </td>
 </tr>
 <tr class="channel_item">
  <td width="30%" class="column_title">
   <% iw_webCfgDescHandler( wifiSection, "channel_g", "Channel" ); %>
  </td>

  <td width="70%">
   <select size="1" id="iw_channel" name="iw_channel" onchange='iw_onChannelChange();'>
   </select>
  </td>
 </tr>
 </table>
 <table width="100%" id="iw_chWdith">
 <tr>
  <td width="30%" class="column_title">
   <% iw_webCfgDescHandler( wifiSection, "channelWidth", "Channel width" ); %>
  </td>
  <td width="70%">
   <select size="1" id="iw_channelWidth" name="iw_<% write(wifiSection); %>_channelWidth" onchange='iw_onChannelWidthChange();'>
    <option value="5MHz">5 MHz</option>
    <option value="10MHz">10 MHz</option>
    <option value="20MHz">20 MHz</option>
    <option value="20/40MHz">20/40 MHz</option>
   </select>
  </td>
 </tr>
 </table>

 <table width="100%" id="iw_chBonding">
 <tr>
  <td width="30%" class="column_title">
   Channel bonding
  </td>
  <td width="70%">
   <div id="iw_channelBonding"></div>
  </td>
 </tr>
 </table>

 <table width="100%">

 <tr id="row_ssid">
  <td width="30%" class="column_title">
   <% iw_webCfgDescHandler( vapSection, "ssid", "SSID" ); %>
  </td>
  <td width="70%">

   <input type="text" id="iw_ssid" name="iw_<% write(vapSection); %>_ssid" size="38" maxlength="32" value = "<% iw_webCfgValueHandler( vapSection, "ssid", "MOXA" ); %>" />




   &nbsp;&nbsp;&nbsp;&nbsp;
   <input type=button value="Site Survey" id="site_survey" name="site_survey" onclick="Survey();" style="display:none;" />
  </td>
 </tr>
 <tr class="proxy_arp_item">
  <td width="30%" class="column_title">
   <% iw_webCfgDescHandler( "wlanDevWIFI0", "proxyArp", "Proxy arp" ); %>
  </td>

  <td width="70%">
   <input type="radio" name="iw_<% write(wifiSection); %>_proxyArp" id="iw_proxyArp_En" value="ENABLE" />
   <label for="iw_proxyArp_En">Enable</label>
   <input type="radio" name="iw_<% write(wifiSection); %>_proxyArp" id="iw_proxyArp_Dis" value="DISABLE" />
   <label for="iw_proxyArp_Dis">Disable</label>
  </td>
 </tr>



 <tr class="ssid_broadcast_item">
  <td width="30%" class="column_title">
   <% iw_webCfgDescHandler( vapSection, "ssidBroadCast", "SSID broadcast" ); %>
  </td>

  <td width="70%">
   <input type="radio" name="iw_<% write(vapSection); %>_ssidBroadCast" id="iw_ssidBroadCast_En" value="ENABLE" />
   <label for="iw_ssidBroadCast_En">Enable</label>
   <input type="radio" name="iw_<% write(vapSection); %>_ssidBroadCast" id="iw_ssidBroadCast_Dis" value="DISABLE" />
   <label for="iw_ssidBroadCast_Dis">Disable</label>
  </td>
 </tr>
 </table>
 <table width="100%" id="areolink_ap">
    <tr>
  <tr>
         <td width="30%" class="column_title">
             <% iw_webCfgDescHandler( vapSection, "aerolink_ap", "AeroLink AP" ); %>
         </td>
         <td width="70%">
             <input type="radio" name="iw_<% write(vapSection); %>_aerolink_ap" id="iw_aerolink_ap_En" value="ENABLE" />
             <label for="iw_aerolink_ap_En">Enable</label>
             <input type="radio" name="iw_<% write(vapSection); %>_aerolink_ap" id="iw_aerolink_ap_Dis" value="DISABLE" />
             <label for="iw_aerolink_ap_Dis">Disable</label>
         </td>
  </tr>
    </tr>
    </table>


    <table width="100%">
    <tr>
  <tr>
         <td width="30%" class="column_title">
             <% iw_webCfgDescHandler( vapSection, "mgmtEncryption", "mgmtEncryption" ); %>
         </td>
         <td width="70%">
             <input type="radio" name="iw_<% write(vapSection); %>_mgmtEncryption" id="iw_mgmtEncryption_En" value="ENABLE" />
             <label for="iw_mgmtEncryption_En">Enable</label>
             <input type="radio" name="iw_<% write(vapSection); %>_mgmtEncryption" id="iw_mgmtEncryption_Dis" value="DISABLE" />
             <label for="iw_mgmtEncryption_Dis">Disable</label>
         </td>
  </tr>
  <tr>
   <td width="30%" class="column_title">
             <% iw_webCfgDescHandler( vapSection, "mgmtEncryptionPassword", "mgmtEncryptionPassword" ); %>
         </td>
   <td width=70%>
             <input type="password" id="iw_<% write(vapSection); %>_mgmtEncryptionPassword" name="iw_<% write(vapSection); %>_mgmtEncryptionPassword" size="37" maxlength="128" value = "<% iw_webCfgValueHandler(vapSection, "mgmtEncryptionPassword", "AGREEMENT"); %>">
         </td>
  </tr>
    </tr>
    </table>
 <table width="100%">
 <tr>
  <td colspan="2">
   <hr />
   <span>
    <input type="submit" value="Submit" name="Submit" />
    <input type="hidden" name="bkpath" value="/wireless_basic.asp?devIndex=<% write(devIndex); %>&amp;vapIndex=<% write(vapIndex); %>" />
    <input type="hidden" name="wifiSection" value="<% write(wifiSection); %>" />
    <input type="hidden" name="vapSection" value="<% write(vapSection); %>" />
   </span>
  </td>
 </tr>
 </table>
 </form>

    <div>
        <I id="dfs_tip">* indicates that the channel supports DFS</I>
    </div>


 <div>
     <I id="iw_aerolink_ap_tip">* Please enable AeroLink Protection on your Wi-Fi Client as well.</I>
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
