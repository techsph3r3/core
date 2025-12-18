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
 function troam_change()
 {
  if($("#turboRoaming_enable").attr("checked"))
   $('#qsArea_troam').show();
  else
   $('#qsArea_troam').hide();
 }

 function troam_channel_list_init()
 {
  var rf_idx;
  var rf_type = new Array(
   new Array( "2.4GHz", "", "" ),
   new Array( "B", "B-MODE", "24G" ),
   new Array( "G", "G-MODE", "24G" ),
   new Array( "B/G Mixed", "BGMixed", "24G" ),
   new Array( "G/N Mixed", "GNMixed", "24G" ),
   new Array( "B/G/N Mixed", "BGNMixed", "24G" ),
   new Array( "N Only (2.4GHz)", "N-MODE-24G", "24G" ),
   new Array( "5GHz", "", "" ),
   new Array( "A", "A-MODE", "5G" ),
   new Array( "A/N Mixed", "ANMixed", "5G" ),
   new Array( "N Only (5GHz)", "N-MODE-5G", "5G" )
  );

  var dfs_chan_list = [ <% iw_dfs_channel_list(1, 0); %> ];
  var chan_list = new Array();
  chan_list["24G"] = new Array("Not Scanning", <% iw_webGetWirelessChan2G(1, 0, 0); %>);
  chan_list["5G"] = new Array("Not Scanning", <% iw_webGetWirelessChan5G(1, 0, 0); %>);

  for(rf_idx = 0; rf_idx < rf_type.length; rf_idx++)
  {
   if(rf_type[rf_idx][1] == "<% iw_qsCfgVal_get("wlanDevWIFI0", "rfType"); %>")
    break;
  }

  qs_chanList_init("#qs_channel1", chan_list[rf_type[rf_idx][2]], dfs_chan_list);
  qs_chanList_init("#qs_channel2", chan_list[rf_type[rf_idx][2]], dfs_chan_list);
  qs_chanList_init("#qs_channel3", chan_list[rf_type[rf_idx][2]], dfs_chan_list);
 }

 function troam_channel_sel()
 {
  var turbo_ch = [<% iw_qsTroamChan_get(); %>];

  $('#qs_channel1').val(turbo_ch[0]);

  if( turbo_ch[1] == turbo_ch[0])
   $('#qs_channel2').val("Not Scanning");
  else
   $('#qs_channel2').val(turbo_ch[1]);

  if( turbo_ch[2] == turbo_ch[0] || turbo_ch[2] == turbo_ch[1])
   $('#qs_channel3').val("Not Scanning");
  else
   $('#qs_channel3').val(turbo_ch[2]);
 }

 //: onLoad
 $(function()
 {
  // onload: Quick Setup MAP
  qs_nav_init("<% iw_qsCfgVal_get("wlanDevWIFI0", "operationMode"); %>");

  // onload: errMsg
  var errMsg = "<% iw_websGetErrorString(0); %>";
  if( errMsg.length > 0 )
   $("#qsForm > div:first-child").before("<div class='QS_ERR_MSG'>" + errMsg + "</div>");

  // onload: troam setting & area
  if( "<% iw_qsCfgVal_get("turboRoaming", "enable"); %>" == "ENABLE" )
   $("#turboRoaming_enable").attr("checked", true);
  else
   $("#turboRoaming_enable").attr("checked", false);
  troam_change();

  // onload: traom chan list
  troam_channel_list_init();
  troam_channel_sel();


  // submit
  $("#qsForm").submit(function()
  {
   //: troam (EANBLE/DISABLE)
   if( $("#turboRoaming_enable").attr("checked") )
    $("#iw_turboRoaming_enable").val("ENABLE");
   else
    $("#iw_turboRoaming_enable").val("DISABLE");

  });
    });
-->
</script>
</head>
<body>
<% iw_webQuickSetup_nav(); %>
<form id="qsForm" action="/forms/web_qsSetting_troam" method="POST">
    <div class="QS_SETTING">
        <h2>Client-Based Turbo Roaming</h2>
        <ul>
   <li class="QS_DESC_TITLE">If your AWK is installed on a moving vehicle, we highly recommend activating Turbo Roaming to ensure that your application operates smoothly.</li>
            <li class="QS_SETTING_TITLE"><% iw_webSysDescHandler("TurboRoaming", "", "failed"); %></li>
            <li class="QS_SETTING_VALUE">
    <input type="checkbox" id="turboRoaming_enable" onclick="troam_change();" />
       <label for="turboRoaming_enable"><% cfgDescGet("turboRoaming", "enable", ""); %></label>
    <input type="hidden" name="iw_turboRoaming_enable" id="iw_turboRoaming_enable"/>
      </li>
        </ul>

    </div>
    <div class="QS_SETTING" id="qsArea_troam">
        <ul>
            <li class="QS_SETTING_TITLE">Scan Channel 1</li>
            <li class="QS_SETTING_VALUE">
    <select size="1" id="qs_channel1" name="troam_chan1" style="width: 110px"></select>
   </li>
   <li class="HELPER_IMG" id="RF_type">
                <img src="Info.png"/>
                <span class="TOOLTIP_TEXT">Select the channels that your AP operates over. You may select up to 3 channels. The AWK will only scan the selected channels. <br/><br/>* indicates that the channel supports DFS. <br/>Please note that access points using DFS channels may have their channels changed automatically if radar signals are detected. As a result, those access points may no longer be in your scanning list.</span>
   </li>

   <li class="QS_SETTING_TITLE">Scan Channel 2</li>
            <li class="QS_SETTING_VALUE">
    <select size="1" id="qs_channel2" name="troam_chan2" style="width: 110px"></select>
   </li>

   <li class="QS_SETTING_TITLE">Scan Channel 3</li>
            <li class="QS_SETTING_VALUE">
    <select size="1" id="qs_channel3" name="troam_chan3" style="width: 110px"></select>
   </li>
  </ul>
    </div>
    <div class="BUTTON_AREA">
  <div>
         <a class="BUTTON" href="setup_option.asp">Cancel</a>
   <a class="BUTTON" href="qs_wifi_security.asp">Back</a>
   <input type="submit" value="Next" class="BUTTON">
   <input type="hidden" name="bkpath" value="qs_wifi_troam.asp" />
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
