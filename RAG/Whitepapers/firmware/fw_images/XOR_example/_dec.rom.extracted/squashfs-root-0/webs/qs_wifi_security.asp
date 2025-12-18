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

 function authType_update()
 {
  $('#qsArea_wpa').hide();
  $('#qsArea_wep').hide();

  if( $('#qs_authType').val() == "WPA" || $('#qs_authType').val() == "WPA2" || $('#qs_authType').val() == "WPA_WPA2_MIX" )
   $('#qsArea_wpa').show();
  else if( $('#qs_authType').val() == "WEP" )
   $('#qsArea_wep').show();
 }

 function wep_init()
 {
  $('#qs_wepAuth').val("<% iw_qsCfgVal_get("wlanVap1", "wepAuth"); %>");
  $('#qs_wepType').val("<% iw_qsCfgVal_get("wlanVap1", "wepType"); %>");
  $('#qs_wepLen').val("<% iw_qsCfgVal_get("wlanVap1", "wepLen"); %>");
  $('#qs_wepKeyIndex').val("<% iw_qsCfgVal_get("wlanVap1", "wepKeyIndex"); %>");
 }

 function wpaMethod_update()
 {
  var rf_type = "<% iw_qsCfgVal_get("wlanDevWIFI0", "rfType"); %>";
  var TKIP_SUPPORT_RF_TYPE = ["A-MODE", "B-MODE", "G-MODE", "BGMixed"];

  var MIXED_NOT_SUPPORT_RF_TYPE = ["N-MODE-24G", "N-MODE-5G"];


  if( $.inArray( rf_type, TKIP_SUPPORT_RF_TYPE) != -1 )
  {
   $("#qs_wpa_method").append($("<option></option>").attr("value", "TKIP").text("TKIP"));
  }

  $("#qs_wpa_method").append($("<option></option>").attr("value", "AES").text("AES"));


  if( $.inArray( rf_type, MIXED_NOT_SUPPORT_RF_TYPE) == -1 )
  {
   $("#qs_wpa_method").append($("<option></option>").attr("value", "Mixed").text("Mixed"));
  }


  $('#qs_wpa_method').val("<% iw_qsCfgVal_get("wlanVap1", "wpaEncrypt"); %>");

 }

 function wpaType_update()
 {
  $("#qsArea_wpa_psk").hide();
  $("#qsArea_wpa_EntClient").hide();

  if( $('#qs_wpaType').val() == "PSK" )
  {
   $("#qsArea_wpa_psk").show();
  } else{
   $("#qsArea_wpa_EntClient").show();
  }
 }

 function wpaClient_proto_update()
 {
  var eapProto = $('#qs_eapProto').val();

  $('#qsArea_wpa_EntClient_TLS').hide();
  $('#qsAera_wpa_EntClient_TTLS').hide();
  $('#qsArea_wpa_EntClient_PEAP').hide();
  $('#qsArea_wpa_EntClient_TTLS_PEAP').hide();

  if( eapProto == "TLS" )
  {
   $('#qsArea_wpa_EntClient_TLS').show();
  } else if( eapProto == "TTLS" )
  {
   $('#qsAera_wpa_EntClient_TTLS').show();
   $('#qsArea_wpa_EntClient_TTLS_PEAP').show();
  } else if( eapProto == "PEAP" )
  {
   $('#qsArea_wpa_EntClient_PEAP').show();
   $('#qsArea_wpa_EntClient_TTLS_PEAP').show();
  } else
  {
   alert("Warn: unknown eapProto (" + eapProto + ")");
  }

 }

 function rekey_update()
 {
  var REKEY_OP = ["AP"];
  if( $.inArray( "<% iw_qsCfgVal_get("wlanDevWIFI0", "operationMode"); %>", REKEY_OP) != -1 )
   $("#qsArea_wpa_rekey").show();
  else
   $("#qsArea_wpa_rekey").hide();
 }

 function qs_var_verify()
 {
  var pwd;

  if( $('#qs_authType').val() == "WPA" || $('#qs_authType').val() == "WPA2" || $('#qs_authType').val() == "WPA_WPA2_MIX" )
  {
   pwd = $('#wpa_pwd').val();
   if( pwd.length < 8 ){
    alert("Invalid Passphrase. Please enter 8~63 ASCII characters or 64 HEX numbers.");
    return false;
   } else if ( pwd.length >= 64 )
   {
    if( !isHEXDelimiter( pwd ) )
    {
     alert("Invalid Passphrase. Please enter 8~63 ASCII characters or 64 HEX numbers.");
     return false;
          } else if ( pwd.length > 64 )
          {
           alert("Invalid Passphrase. Please enter 8~63 ASCII characters or 64 HEX numbers.");
     return false;
          }
         }else if(!isAsciiString( pwd )){
          alert("Invalid Passphrase. Please enter 8~63 ASCII characters or 64 HEX numbers.");
          return false;
         }
  }
  return true;
 }

 //: onLoad
 $(function()
 {
  // onLoad: Quick Setup MAP
  qs_nav_init("<% iw_qsCfgVal_get("wlanDevWIFI0", "operationMode"); %>");
  $(".QS_SETTING select").css("width", "130px");


  // onload: errMsg
  var errMsg = "<% iw_websGetErrorString(0); %>";
  if( errMsg.length > 0 )
   $("#qsForm > div:first-child").before("<div class='QS_ERR_MSG'>" + errMsg + "</div>");

  // onLoad: Security (OPEN/WEP/WPA/WPA2)
  $('#qs_authType').val("<% iw_qsCfgVal_get("wlanVap1", "authType"); %>");
  authType_update();
  wep_init();

  //: WPA method (TKIP/AES)
  $('#qs_wpaType').val("<% iw_qsCfgVal_get("wlanVap1", "wpaType"); %>");
  wpaMethod_update();

  $('#qs_wpaType').val("<% iw_qsCfgVal_get("wlanVap1", "qs_eapProto"); %>");
  wpaClient_proto_update();

  //: EAPOL 
  $('#qs_eapolVer').val("<% iw_qsCfgVal_get("wlanVap1", "eapolVersion"); %>");

  //: Rekey
  rekey_update();

  // WPA
  wpaType_update();

  // Verify
  $("#qsForm").submit(function()
  {
   return qs_var_verify();
  });

    });
-->
</script>
</head>
<body>
<% iw_webQuickSetup_nav(); %>
<form id="qsForm" action="/forms/web_qsSetting" method="POST">
    <div class="QS_SETTING">
        <h2>Wi-Fi Security</h2>
        <ul>
            <li class="QS_SETTING_TITLE"><% cfgDescGet("wlanVap1", "authType", ""); %></li>
            <li class="QS_SETTING_VALUE">
      <select size="1" id="qs_authType" name="iw_wlanVap1_authType" onclick="authType_update();">
    <option value="OPEN">Open</option>
    <option value="WEP">WEP</option>
    <option value="WPA">WPA</option>
    <option value="WPA2">WPA2</option>

    <option value="WPA_WPA2_MIX">WPA-WPA2 mixed</option>

      </select>
      </li>
        </ul>
    </div>
 <div class="QS_SETTING" id="qsArea_wep">
  <ul>
   <li class="QS_SETTING_TITLE"><% cfgDescGet( "wlanVap1", "wepAuth", "" ); %></li>
   <li class="QS_SETTING_VALUE">
    <select size="1" id="qs_wepAuth" name="iw_wlanVap1_wepAuth">
     <option value="OPEN">Open</option>
     <option value="SHARE">Shared</option>
    </select>
   </li>
  </ul>
  <ul>
   <li class="QS_SETTING_TITLE"><% cfgDescGet( "wlanVap1", "wepType", "" ); %></li>
   <li class="QS_SETTING_VALUE">
    <select size="1" id="qs_wepType" name="iw_wlanVap1_wepType">
     <option value="HEX">HEX</option>
     <option value="ASCII">ASCII</option>
    </select>
   </li>
  </ul>
  <ul>
   <li class="QS_SETTING_TITLE"><% cfgDescGet( "wlanVap1", "wepLen", "" ); %></li>
   <li class="QS_SETTING_VALUE">
    <select size="1" id="qs_wepLen" name="iw_wlanVap1_wepLen">
     <option value="64">64 Bits</option>
     <option value="128">128 Bits</option>
    </select>
   </li>
  </ul>
  <ul>
   <li class="QS_SETTING_TITLE"><% cfgDescGet( "wlanVap1", "wepKeyIndex", "" ); %></li>
   <li class="QS_SETTING_VALUE">
    <select size="1" id="qs_wepKeyIndex" name="iw_wlanVap1_wepKeyIndex">
     <option value="1">1</option>
     <option value="2">2</option>
     <option value="3">3</option>
     <option value="4">4</option>
    </select>
   </li>
  </ul>
  <ul>
   <li class="QS_SETTING_TITLE"><% cfgDescGet( "wlanVap1", "wepKey1", "" ); %></li>
   <li class="QS_SETTING_VALUE"><input type="password" id="iw_wepKey1" name="iw_wlanVap1_wepKey1" size="35" maxlength="26" value="<% iw_qsCfgVal_get("wlanVap1", "wepKey1"); %>"></li>
  </ul>
  <ul>
   <li class="QS_SETTING_TITLE"><% cfgDescGet( "wlanVap1", "wepKey2", "" ); %></li>
   <li class="QS_SETTING_VALUE"><input type="password" id="iw_wepKey2" name="iw_wlanVap1_wepKey2" size="35" maxlength="26" value="<% iw_qsCfgVal_get("wlanVap1", "wepKey2"); %>"></li>
  </ul>
  <ul>
   <li class="QS_SETTING_TITLE"><% cfgDescGet( "wlanVap1", "wepKey3", "" ); %></li>
   <li class="QS_SETTING_VALUE"><input type="password" id="iw_wepKey3" name="iw_wlanVap1_wepKey3" size="35" maxlength="26" value="<% iw_qsCfgVal_get("wlanVap1", "wepKey3"); %>"></li>
  </ul>
  <ul>
   <li class="QS_SETTING_TITLE"><% cfgDescGet( "wlanVap1", "wepKey4", "" ); %></li>
   <li class="QS_SETTING_VALUE"><input type="password" id="iw_wepKey4" name="iw_wlanVap1_wepKey4" size="35" maxlength="26" value="<% iw_qsCfgVal_get("wlanVap1", "wepKey4"); %>"></li>
  </ul>
 </div>
    <div class="QS_SETTING" id="qsArea_wpa">
        <ul>
            <li class="QS_SETTING_TITLE"><% cfgDescGet("wlanVap1", "wpaType", ""); %></li>
            <li class="QS_SETTING_VALUE">
       <select size="1" id="qs_wpaType" name="iw_wlanVap1_wpaType" onchange="wpaType_update();">
     <option value="PSK">Personal</option>
     <option value="ENTERPRISE">Enterprise</option>
       </select>
      </li>

      <li class="QS_SETTING_TITLE"><% cfgDescGet("wlanVap1", "wpaEncrypt", ""); %></li>
            <li class="QS_SETTING_VALUE">
       <select size="1" id="qs_wpa_method" name="iw_wlanVap1_wpaEncrypt">
       </select>
      </li>
   <li class="HELPER_IMG" id="RF_type">
                <img src="Info.png"/>
                <span class="TOOLTIP_TEXT">TKIP is not supported with 802.11n, and current RF type is <% iw_qsCfgVal_get("wlanDevWIFI0", "rfType"); %>.</span>
   </li>

   <li class="QS_SETTING_TITLE"><% cfgDescGet("wlanVap1", "eapolVersion", ""); %></li>
            <li class="QS_SETTING_VALUE">
       <select size="1" id="qs_eapolVer" name="iw_wlanVap1_eapolVersion">
     <option>1</option>
                    <option>2</option>
       </select>
      </li>

   <div id="qsArea_wpa_psk">
    <li class="QS_SETTING_TITLE"><% cfgDescGet("wlanVap1", "psk", ""); %></li>
    <li class="QS_SETTING_VALUE"><input type="password" size="70" maxlength="64" name="iw_wlanVap1_psk" id="wpa_pwd" value="<% iw_qsCfgVal_get("wlanVap1", "psk"); %>"> (8~63 ASCII characters or 64 HEX numbers)</li>

    <div id="qsArea_wpa_rekey">
     <li class="QS_SETTING_TITLE"><% cfgDescGet("wlanVap1", "rekey", ""); %></li>
     <li class="QS_SETTING_VALUE">
      <input type="text" size="7" maxlength="5" value = "<% iw_qsCfgVal_get("wlanVap1", "rekey"); %>">&nbsp;&nbsp;seconds (60 to 86400 seconds)
     </li>
    </div>
   </div>
   <div id="qsArea_wpa_EntClient">
    <li class="QS_SETTING_TITLE"><% cfgDescGet("wlanVap1", "eapProto", ""); %></li>
    <li class="QS_SETTING_VALUE">
     <select size="1" id="qs_eapProto" name="iw_wlanVap1_eapProto" onchange="wpaClient_proto_update();">
      <option value="TLS">TLS</option>
      <option value="TTLS">TTLS</option>
      <option value="PEAP">PEAP</option>
     </select>
       </li>

    <div id="qsArea_wpa_EntClient_TLS">
     <li class="QS_SETTING_TITLE">Client TLS</li>
    </div>
    <div id="qsAera_wpa_EntClient_TTLS">
     <li class="QS_SETTING_TITLE"><% cfgDescGet("wlanVap1", "ttlsInner", ""); %></li>
     <li class="QS_SETTING_VALUE">
      <select size="1" id="qs_ttlsInner" name="iw_wlanVap1_ttlsInner">
       <option value="PAP">PAP</option>
       <option value="CHAP">CHAP</option>
       <option value="MS-CHAP">MS-CHAP</option>
       <option value="MS-CHAPV2">MS-CHAP-V2</option>
      </select>
        </li>
    </div>
    <div id="qsArea_wpa_EntClient_PEAP">
     <li class="QS_SETTING_TITLE"><% cfgDescGet("wlanVap1", "peapInner", ""); %></li>
     <li class="QS_SETTING_VALUE">
      <select size="1" id="qs_peapInner" name="iw_wlanVap1_peapInner">
       <option value="MS-CHAPV2">MS-CHAP-V2</option>
      </select>
        </li>
    </div>
    <div id="qsArea_wpa_EntClient_TTLS_PEAP">
     <li class="QS_SETTING_TITLE"><% cfgDescGet("wlanVap1", "eapAnonymous", ""); %></li>
     <li class="QS_SETTING_VALUE"><input type="text" name="iw_wlanVap1_eapAnonymous" size="37" maxlength="31" value = "<% iw_webCfgValueHandler("wlanVap1", "eapAnonymous", ""); %>"></li>

     <li class="QS_SETTING_TITLE"><% cfgDescGet("wlanVap1", "eapUser", ""); %></li>
     <li class="QS_SETTING_VALUE"><input type="text" name="iw_wlanVap1_eapUser" size="37" maxlength="31" value = "<% iw_webCfgValueHandler("wlanVap1", "eapUser", ""); %>"></li>

     <li class="QS_SETTING_TITLE"><% cfgDescGet("wlanVap1", "eapPass", ""); %></li>
     <li class="QS_SETTING_VALUE"><input type="password" name="iw_wlanVap1_eapPass" size="37" maxlength="128" value = "<% iw_webCfgValueHandler("wlanVap1", "eapPass", ""); %>"></li>
    </div>
   </div>
  </ul>
 </div>
    <div class="BUTTON_AREA">
  <div>
         <a class="BUTTON" href="setup_option.asp">Cancel</a>
   <a class="BUTTON" href="qs_wifi_settings.asp">Back</a>
   <input type="submit" value="Next" class="BUTTON">
   <input type="hidden" name="nextPage" value="qs_wifi_troam.asp" />
   <input type="hidden" name="bkpath" value="qs_wifi_security.asp" />
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
