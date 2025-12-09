<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%
 var wifiSection, vapSection, roamingSection;

 if ( iw_isset(index) == 0 )
 {
  index = 1;
 }

 if ( iw_isset(vapIndex) == 0 )
 {
  vapIndex = 0;
 }

 if (index==2)
 {
  wifiSection = "wlanDevWIFI1";
  vapSection = "wlanVap2";
  roamingSection = "turboRoaming1";
 }else
 {
  wifiSection = "wlanDevWIFI0";
  vapSection = "wlanVap1";
  roamingSection = "turboRoaming";
  index = 1;
 }

 if ( vapIndex != 0 )
 {
  vapSection = vapSection + "0" + vapIndex ;
 }
%>
<html>
<head>
 <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
 <meta http-equiv="Pragma" content="no-cache" />
 <link href="nport2g.css" rel="stylesheet" type="text/css" />
 <title>Operation Mode</title>
 <% iw_webJSList_get(); %>
 <script type="text/javascript">
 <!--
  var rf_type = new Array();
  rf_type[0] = new Array( "A", "A-MODE" );
  rf_type[1] = new Array( "B", "B-MODE" );
  rf_type[2] = new Array( "G", "G-MODE" );
  rf_type[3] = new Array( "B/G Mixed", "BGMixed" );

  var channel_list = new Array();







  channel_list["A"] = new Array(<% iw_webGetWirelessChan5G(index, vapIndex, 0); %>);



  channel_list["B"] = new Array(<% iw_webGetWirelessChan2G(index, vapIndex, 0); %>);
  channel_list["G"] = new Array(<% iw_webGetWirelessChan2G(index, vapIndex, 0); %>);

   var mem_state = <% iw_websMemoryChange(); %>;
  var http_req = iw_inithttpreq();

  var wirelessBasicList = <% iw_webGetWirelessBasicListArray(index, vapIndex); %>;
  var rfType = new String("<% iw_webCfgValueHandler( wifiSection,	"rfType",			"G-MODE" ); %>");
  var ssidBroadCast = new String("<% iw_webCfgValueHandler( vapSection, 	"ssidBroadCast",	"ENABLE" ); %>");

  var dhcpSrvEnable = new String("<% iw_webCfgValueHandler( "dhcpSrv",		"enable",			"DISABLE" );%>");


  var rssiRpEventEnable = new String("<% iw_webCfgValueHandler( "sysLog", "rssiReport", "DISABLE");%>");

  var currentIndex = new String("<% write(index);write(vapIndex); %>");

  function iw_onSubmit()
  {
   var mac_arr, enableCount = 0, MACrecord = new Array(), i, j;
   var form = document.wireless_basic;

   var roamingEnable = "<% iw_webCfgValueHandler(roamingSection, "enable", "DISABLE"); %>";

   var operationModeSet = document.getElementById("iw_operationMode").options[document.getElementById("iw_operationMode").selectedIndex].value;
   var isAP = (operationModeSet == "AP" || operationModeSet == "MASTER") ? true : false;
   if(roamingEnable=="ENABLE"){
   }

   return true;
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

   // For wireless_basic form
   formItem = document.wireless_basic;

   if( wirelessBasicList[currentIndex].opMode == "CLIENT" ||
    wirelessBasicList[currentIndex].opMode == "SLAVE" ||
    wirelessBasicList[currentIndex].opMode == "AP-CLIENT" ||
    wirelessBasicList[currentIndex].opMode == "REDUNDANT_CLIENT"

                                || wirelessBasicList[currentIndex].opMode == "SNIFFER"


    )
   {

   }else if( wirelessBasicList[currentIndex].opMode == "DISABLE" )
   {
    for( i = 0; i < formItem.elements.length; i++ )
    {
     formItem.elements[i].disabled = true;
    }
   }else if( 0 != <% write(vapIndex); %> )
   {
   }


   if( "<% iw_webCfgValueHandler("misc", "wlanEnable", "ENABLE"); %>" == "ENABLE" )
   {
    document.wireless_basic.iw_wlanEnable_En.checked = true;
   }else
   {
    document.wireless_basic.iw_wlanEnable_Dis.checked = true;
   }

   iw_selectSet( document.getElementById("iw_operationMode"), wirelessBasicList[currentIndex].opMode );

   iw_onOperationModeChange();


   editPermission();

   // CAUSION : This line must be executed in <body onLoad()>
   top.toplogo.location.reload();
  }

  function selall()
  {
   var i;
   for(i = 0; i < document.wireless_basic.length; i++)
   {
    if(document.wireless_basic.elements[i].value.length > 0 )
    {
    }
   }
  }

  function iw_onOperationModeChange()
  {
   var operationModeSet = document.getElementById("iw_operationMode").options[document.getElementById("iw_operationMode").selectedIndex].value;
   var isAP = (operationModeSet == "AP" || operationModeSet == "MASTER") ? true : false;
   var isRouter = (operationModeSet == "CLIENT-ROUTER") ? true : false;

   if( !isAP && !isRouter )
   {

    if( dhcpSrvEnable == "ENABLE" )
    {
     alert("If DHCP server is enabled, it is only allowed to enable AP mode at the same time.");
     iw_selectSet( document.getElementById("iw_operationMode"), "AP" );
     return false;
    }

   }

   if( isAP )
   {
    if( rssiRpEventEnable == "ENABLE" )
    {
     alert("If RSSI report events is enable, it is only allowed to enable non-AP mode at the same time.");
     iw_selectSet( document.getElementById("iw_operationMode"), "CLIENT" );
     return;
    }
   }
   iw_onChannelChange();


   document.getElementById("iw_wlanEnable_En").disabled = false;
   document.getElementById("iw_wlanEnable_Dis").disabled = false;




  }


  function iw_wlanEnable(enable)
  {
   var operationModeSet = document.getElementById("iw_operationMode").options[document.getElementById("iw_operationMode").selectedIndex].value;
   var isAP = (operationModeSet == "AP" || operationModeSet == "MASTER") ? true : false;
  }

  function iw_onChannelChange()
  {
  }

        -->
    </script>
</head>
<body onLoad="iw_onLoad();">

 <h2>Operation Mode&nbsp;&nbsp;<% iw_websGetErrorString(); %></h2>

 <form name="wireless_basic" method="post" action="/forms/webSetWirelessBasic" onSubmit="return iw_onSubmit();">

 <table width="100%">
 <tr><td colspan="2" class="block_seperator"></td></tr>

 <tr>
  <td width="30%" class="column_title"><% iw_webCfgDescHandler("misc", "wlanEnable", ""); %></td>
  <td width="70%">
   <input type="radio" name="iw_misc_wlanEnable" id="iw_wlanEnable_En" value="ENABLE" onclick='iw_wlanEnable(1);' />
   <label for="iw_wlanEnable_En">Enable</label>
   <input type="radio" name="iw_misc_wlanEnable" id="iw_wlanEnable_Dis" value="DISABLE" onclick='iw_wlanEnable(0);' />
   <label for="iw_wlanEnable_Dis">Disable</label>
  </td>
 </tr>

 <tr>
  <td colspan="2">&nbsp;<td>
 </tr>

 <tr>
  <td width=30% class="column_title">
   <% iw_webCfgDescHandler( "board", "operationMode", "OP Mode" ); %>
  </td>
  <td width=70%>
   <select size="1" id="iw_operationMode" name="iw_wlanDevWIFI0_operationMode" onChange="iw_onOperationModeChange()">

    <option value="AP">AP</option>


    <option value="CLIENT">Client</option>


    <option value="CLIENT-ROUTER">Client-Router</option>


    <option value="MASTER">Master</option>


    <option value="SLAVE">Slave</option>
                                <option value="SNIFFER">Sniffer</option>


   </select>
  </td>
 </tr>

 </table>

 <table width="100%">

 <tr>
  <td colspan="2">
   <hr />
   <span>
    <input type="submit" value="Submit" name="Submit" />
    <input type="hidden" name="bkpath" value="/wireless_opmode.asp" />
    <input type="hidden" name="wifiSection" value="<% write(wifiSection); %>" />
    <input type="hidden" name="vapSection" value="<% write(vapSection); %>" />
   </span>
  </td>
 </tr>
 </table>
 </form>
</body>
</html>
<script language="JavaScript" src="js/jquery-1.5.2.min.js"></script>
<script type="text/javascript">
	$(document).ready(function () {
		var isEditPermission = !<% iw_websCheckPermission(); %>;
		if (isEditPermission == 0) {
			$(":input").attr('disabled','disabled');
		}
	});
</script>
