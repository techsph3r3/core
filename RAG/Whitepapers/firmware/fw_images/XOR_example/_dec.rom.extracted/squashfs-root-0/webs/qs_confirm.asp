<!DOCTYPE html>
<html>


<head>
<meta charset="utf-8">
<meta http-equiv="X-UA-Compatible" content="IE=edge">
<title>Qicuk Setup</title>
<link rel="stylesheet" href="quickSetup.css">
<% iw_webJSList_get(); %>
<script>
<!--
 function ip_address()
 {
  if( "<% iw_qsCfgVal_get("netDev1", "dhcp"); %>" == "ENABLE" )
  {
   $("#qs_dhcp").text('DHCP');
   $("#qsArea_net").hide();
  } else
  {
   $("#qs_dhcp").text('Static');
   $("#qsArea_net").show();
  }
 }

 function wifi_opmode()
 {

  if( "<% iw_qsCfgVal_get("AeroMag", "enable"); %>" != "DISABLE")
  {
   $('#qs_wifi_opmode').text("AeroMag - <% iw_qsCfgVal_get("AeroMag", "enable"); %>");
   return true;
  }

  {
   // not Areo Mag
   $("#qsArea_wifi_setting").show();

   if( "<% iw_qsCfgVal_get("wlanDevWIFI0", "operationMode"); %>" == "CLIENT")
   {
    $("#qs_wifi_opmode").text("Client");
   } else
   {
    $("#qs_wifi_opmode").text("<% iw_qsCfgVal_get("wlanDevWIFI0", "operationMode"); %>");
   }
  }
 }

 function wifi_security()
 {
  var authType= "<% iw_qsCfgVal_get("wlanVap1", "authType"); %>";


  //: AeroMag case
  if( "<% iw_qsCfgVal_get("AeroMag", "enable"); %>" != "DISABLE")
  {
   $('#qs_wifi_authType').text("(AeroMag)").css('font-style', 'italic');
   $('#qsArea_wpa').hide();
   return true;
  }


  //: WPA area
  if( authType == "WPA" || authType == "WPA2")
  {
   $("#qsArea_wpa").show();
   if( "<% iw_qsCfgVal_get("wlanVap1", "wpaType"); %>" == "PSK")
    $("#wpaType").text("Personal");
   else
    $("#wpaType").text("Enterprise");

  } else
  {
   $("#qsArea_wpa").hide();
  }
 }

 function wifi_troam()
 {

  //: AeroMag case
  if( "<% iw_qsCfgVal_get("AeroMag", "enable"); %>" == "Client")
  {
   $('#qs_troam_enable').text("(AeroMag)").css('font-style', 'italic');
   $("#qsArea_traom").hide();
   return true;
  }


  if( "<% iw_qsCfgVal_get("wlanDevWIFI0", "operationMode"); %>" == "CLIENT" )
  {
   $("#qsArea_traom").show();
   if( "<% iw_qsCfgVal_get("turboRoaming", "enable", ""); %>" == "ENABLE")
    $("#qsArea_traom_chans").show();
   else
    $("#qsArea_traom_chans").hide();
  } else
  {
   $("#qsArea_traom").hide();
  }
 }

 function serial()
 {
  var serial_onoff = "<% iw_qsCfgVal_get("serialOpMode1", "application"); %>";
  var serail_op = "<% iw_qsCfgVal_get("serialOpMode1", "operationMode"); %>";

  $("#qsArea_serial_tcpServer").hide();
  $("#qsArea_serial_tcpClient").hide();
  $("#qsArea_serial_udp").hide();

  if( serail_op == "REAL_COM" )
   $("#qs_serial_mode").text("Real COM");
  else if( serail_op == "TCP_SERVER" )
  {
   $("#qsArea_serial_tcpServer").show();
   $("#qs_serial_mode").text("TCP Server");
  } else if( serail_op == "TCP_CLIENT" )
  {
   $("#qs_serial_mode").text("TCP Client");
   $("#qsArea_serial_tcpClient").show();
  } else if( serail_op == "UDP")
  {
   $("#qs_serial_mode").text("UDP");
   $("#qsArea_serial_udp").show();
  }

  if( serial_onoff == "DISABLE")
  {
   $("#qs_serial_mode").text("Disable");
   $("#qsArea_serial_basic").hide();
  } else
  {
   $("#qsArea_serial_basic").show();

   if( "<% iw_qsCfgVal_get("serialPortSetting1", "portStopBit"); %>" == "15" )
    $("#qs_serial_portStopBit").text("1.5");
   else
    $("#qs_serial_portStopBit").text("<% iw_qsCfgVal_get("serialPortSetting1", "portStopBit"); %>");

   if( "<% iw_qsCfgVal_get("serialPortSetting1", "portParity"); %>" == "NONE" )
    $("#qs_serial_portParity").text("None");
   else if( "<% iw_qsCfgVal_get("serialPortSetting1", "portParity"); %>" == "ODD")
    $("#qs_serial_portParity").text("Odd");
   else if( "<% iw_qsCfgVal_get("serialPortSetting1", "portParity"); %>" == "EVEN")
    $("#qs_serial_portParity").text("Even");
   else if( "<% iw_qsCfgVal_get("serialPortSetting1", "portParity"); %>" == "MARK")
    $("#qs_serial_portParity").text("Mark");
   else if( "<% iw_qsCfgVal_get("serialPortSetting1", "portParity"); %>" == "SPACE")
    $("#qs_serial_portParity").text("Space");

   if( "<% iw_qsCfgVal_get("serialPortSetting1", "portInterface"); %>" == "RS232")
    $("#qs_serial_portInterface").text("RS-232");
   else if( "<% iw_qsCfgVal_get("serialPortSetting1", "portInterface"); %>" == "RS422")
    $("#qs_serial_portInterface").text("RS-422");
   else if( "<% iw_qsCfgVal_get("serialPortSetting1", "portInterface"); %>" == "RS485_2_WIRE")
    $("#qs_serial_portInterface").text("RS-485 2-wire");
   else if( "<% iw_qsCfgVal_get("serialPortSetting1", "portInterface"); %>" == "RS485_4_WIRE")
    $("#qs_serial_portInterface").text("RS-485 4-wire");
  }
 }

 function qs_saveRestart()
 {
  $("#action_type").val("RESTART");
 }

 function qs_submit()
 {
  $("#action_type").val("SUBMIT");
 }

 //: onLoad
 $(function()
 {
  // onload: Quick Setup MAP
  qs_nav_init("<% iw_qsCfgVal_get("wlanDevWIFI0", "operationMode"); %>");

  ip_address();

  if( "<% iw_qsCfgVal_get("AeroMag", "enable"); %>" != "DISABLE")
  {
   $('#qs_wifi_ssid').text("(AeroMag)").css('font-style', 'italic');
   $('#qs_wifi_rftype').text("(AeroMag)").css('font-style', 'italic');
  }

  wifi_opmode();
  wifi_security();
  wifi_troam();


  serial();


  // submit
  $("#qsForm").submit(function()
  {

  });
    });
-->
</script>
</head>
<body>
<% iw_webQuickSetup_nav(); %>
<form id="qsForm" action="/forms/web_qsSave" method="POST">
 <div class="QS_SETTING" id="qsAera_confirm">
  <h2>Device Info. and IP Settings <% iw_websGetErrorString(); %></h2>
  <ul> <!-- Device Information -->
            <li class="QS_SETTING_TITLE"><% cfgDescGet("board", "deviceName", ""); %></li>
            <li class="QS_SETTING_VALUE"><% iw_qsCfgVal_get("board", "deviceName"); %></li>
        </ul> <!-- Device Information -->
  <ul> <!-- IP Settings -->
   <li class="QS_SETTING_TITLE"><% cfgDescGet("netDev1", "dhcp", ""); %></li>
   <li class="QS_SETTING_VALUE" id="qs_dhcp"></li>

   <div id="qsArea_net">
    <li class="QS_SETTING_TITLE"><% cfgDescGet("netDev1", "ipv4Addr", ""); %></li>
    <li class="QS_SETTING_VALUE"><% iw_qsCfgVal_get("netDev1", "ipv4Addr"); %></li>

    <li class="QS_SETTING_TITLE"><% cfgDescGet("netDev1", "ipv4Mask", ""); %></li>
             <li class="QS_SETTING_VALUE"><% iw_qsCfgVal_get("netDev1", "ipv4Mask"); %></li>

             <li class="QS_SETTING_TITLE"><% cfgDescGet("netDev1", "ipv4GateWay", ""); %></li>
             <li class="QS_SETTING_VALUE"><% iw_qsCfgVal_get("netDev1", "ipv4GateWay"); %></%></li>
   </div>
  </ul> <!-- IP Settings -->
  <ul> <!-- User Settings -->
            <li class="QS_SETTING_TITLE"><% cfgDescGet("account1", "username", ""); %></li>
            <li class="QS_SETTING_VALUE"><% iw_qsCfgVal_get("account1", "username"); %></li>
        </ul> <!-- Device Information -->
  <h2>Wi-Fi Settings</h2>
  <ul> <!-- Wi-Fi: Basic Settings -->
   <li class="QS_SETTING_TITLE"><% cfgDescGet("wlanDevWIFI0", "operationMode", ""); %></li>
            <li class="QS_SETTING_VALUE" id="qs_wifi_opmode"></li>
  </ul> <!-- Wi-Fi: Basic Settings -->
  <div id="qsArea_wifi_setting">
   <ul> <!-- Wi-Fi: Basic Settings -->
    <li class="QS_SETTING_TITLE"><% cfgDescGet("wlanVap1", "ssid", ""); %></li>
             <li class="QS_SETTING_VALUE" id="qs_wifi_ssid"><% iw_qsCfgVal_get("wlanVap1", "ssid"); %></li>

    <li class="QS_SETTING_TITLE"><% cfgDescGet("wlanDevWIFI0", "rfType", ""); %></li>
             <li class="QS_SETTING_VALUE" id="qs_wifi_rftype"><% iw_qsCfgVal_get("wlanDevWIFI0", "rfType"); %></li>
   </ul> <!-- Wi-Fi: Basic Settings -->
   <ul> <!-- Wi-Fi: Security -->
    <li class="QS_SETTING_TITLE"><% cfgDescGet("wlanVap1", "authType", ""); %></li>
             <li class="QS_SETTING_VALUE" id="qs_wifi_authType"><% iw_qsCfgVal_get("wlanVap1", "authType"); %></li>

    <div id="qsArea_wpa">
     <li class="QS_SETTING_TITLE"><% cfgDescGet("wlanVap1", "wpaType", ""); %></li>
     <li class="QS_SETTING_VALUE" id="wpaType"></li>

     <li class="QS_SETTING_TITLE"><% cfgDescGet("wlanVap1", "wpaEncrypt", ""); %></li>
              <li class="QS_SETTING_VALUE"><% iw_qsCfgVal_get("wlanVap1", "wpaEncrypt"); %></li>

     <li class="QS_SETTING_TITLE"><% cfgDescGet("wlanVap1", "eapolVersion", ""); %></li>
     <li class="QS_SETTING_VALUE"><% iw_qsCfgVal_get("wlanVap1", "eapolVersion"); %></li>
    </div>
   </ul> <!-- Wi-Fi: Basic Settings -->
   <div id="qsArea_traom">
    <ul>
     <li class="QS_SETTING_TITLE"><% iw_webSysDescHandler("TurboRoaming", "", "failed"); %></li>
     <li class="QS_SETTING_VALUE" id="qs_troam_enable"><% iw_qsCfgVal_get("turboRoaming", "enable", ""); %></li>
    </ul>
    <div id="qsArea_traom_chans">
     <ul>
      <li class="QS_SETTING_TITLE">Scan Channel</li>
      <li class="QS_SETTING_VALUE"><% iw_qsTroamChan_get(); %></li>
     </ul>
    </div>
   </div>
  </div>
 </div>

    <div class="BUTTON_AREA">
  <p>If more detailed configuration is required, click "Submit" to link to access the standard setup page.</p>
  <div>
         <a class="BUTTON" href="setup_option.asp">Cancel</a>
   <a class="BUTTON" href="<% iw_webQuickSetup_backPage("qs_confirm.asp"); %>">Back</a>
   <input type="submit" value="Submit" class="BUTTON" onclick="qs_submit();">
   <input type="submit" value="Save and Restart" class="BUTTON" onclick="qs_saveRestart();" style="width: 125px">
   <input type="hidden" id="action_type" name="action_type" />

  </div>
 </div>
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
