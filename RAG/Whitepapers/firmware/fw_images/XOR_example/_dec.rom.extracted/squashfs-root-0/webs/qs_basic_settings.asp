<!DOCTYPE html>
<html>

<head>
<meta charset="utf-8">
<meta http-equiv="X-UA-Compatible" content="IE=edge">
<title>Qicuk Setup</title>
<link rel="stylesheet" href="quickSetup.css">
<% iw_webJSList_get(); %>
<script type="text/javascript">
<!--
 // Nami: Must be the 1st line: web server init the quick setup
 var enter_status = <% iw_webQuickSetup_enter(); %>;
 // Nami: end

 var mon_list = <% iw_webGetOption("iwstr_mon"); %>;
 var week_idx_list = <% iw_webGetOption("iwstr_weekidx"); %>;
 var week_day_list = <% iw_webGetOption("iwstr_weekday"); %>;
 var dst_offset_time_list = <% iw_webGetOption("iwstr_dst_offsettime"); %>;

 function dst_update()
 {
  if( $("#dst_enable").is(':checked') )
   $("#qs_daylight_saving_area").show();
  else
   $("#qs_daylight_saving_area").hide();
 }

 function onload_time_area()
 {
  if( "<% iw_qsCfgVal_get("IWtime", "dstEnable"); %>" == "ENABLE" )
   $("#dst_enable").attr("checked", "checked");

  qs_init_option("#dst_on_month", mon_list, "<% iw_qsCfgVal_get("IWtime", "dstOnMonth"); %>");
  qs_init_option("#dst_on_week", week_idx_list, "<% iw_qsCfgVal_get("IWtime", "dstOnWeekIndex"); %>");
  qs_init_option("#dst_on_day", week_day_list, "<% iw_qsCfgVal_get("IWtime", "dstOnWeekDay"); %>");

  qs_init_option("#dst_off_month", mon_list, "<% iw_qsCfgVal_get("IWtime", "dstOffMonth"); %>");
  qs_init_option("#dst_off_week", week_idx_list, "<% iw_qsCfgVal_get("IWtime", "dstOffWeekIndex"); %>");
  qs_init_option("#dst_off_day", week_day_list, "<% iw_qsCfgVal_get("IWtime", "dstOffWeekDay"); %>");

  qs_init_option("#dst_offset", dst_offset_time_list, "<% iw_qsCfgVal_get("IWtime", "dstOffsetTime"); %>");

  dst_update();

 }

 function dhcp_update()
 {
  if( $('#qs_dhcp').val() == "ENABLE" )
   $('#qsArea_net').hide();
  else
   $('#qsArea_net').show();
 }

 //: onload
 $(function()
 {
  if( enter_status == 1 ) // the 1st entering quick setup
   top.contents.location.reload();
  else if ( enter_status == 2 ) // someone has been in quick setup
  {
   top.main.location="/setup_option.asp";
  }

  // onload: errMsg
  var errMsg = "<% iw_websGetErrorString(0); %>";
  if( errMsg.length > 0 )
   $("#qsForm > div:first-child").before("<div class='QS_ERR_MSG'>" + errMsg + "</div>");

  // onload: Quick Setup MAP
  qs_nav_init("<% iw_qsCfgVal_get("wlanDevWIFI0", "operationMode"); %>");

  // onload: time
  onload_time_area();

  // onload: DHCP Client
  $('#qs_dhcp').val("<% iw_qsCfgVal_get("netDev1", "dhcp"); %>");
  dhcp_update();

  // event: daylight saving
  $('#dst_enable').click(function(){
   dst_update();
  });

  $("#qsForm").submit(function()
  {
   // verify device name
   if( $('#device_name').val() == '' )
   {
    alert("<% iw_webCfgDescHandler("board", "deviceName", ""); %> cannot be empty.");
    return false;
   }

   // submit: password
   if( $('#new_pwd').val() != $('#new_pwd2').val() )
   {
    alert('New password and confirm password are not same!');
    return false;
   }

   // submit: dst
   if( $("#dst_enable").is(':checked') )
    $("#iw_IWtime_dstEnable").val("ENABLE");
   else
    $("#iw_IWtime_dstEnable").val("DISABLE");
  });
 });

 function set_time()
 {
  var http_req = iw_inithttpreq();

  if (!http_req)
  {
   alert("Init request fail, please try again later!");
   return false;
  }

  http_req.open( "POST", "/forms/webSetBasicTime", true );
  http_req.setRequestHeader( "Content-type", "application/x-www-form-urlencoded" );
  http_req.send( "Year=" + $("#Year").val()
       + "&Month=" + $('#Month').val()
       + "&Day=" + $('#Day').val()
       + "&Hour=" + $('#Hour').val()
       + "&Minutes=" + $('#Minutes').val()
       + "&Seconds=" + $('#Seconds').val());


  http_req.onreadystatechange = function()
  {
   if(http_req.readyState == 4 && http_req.status == 200)
   {
    window.location="Login.asp";
   }
  }
 }
-->
</script>
</head>
<body>
<% iw_webQuickSetup_nav(); %>
<form id="qsForm" action="/forms/web_qsSetting_basic_setting" method="POST">
    <div class="QS_SETTING">
        <h2>Device Information</h2>
        <ul>
            <li class="QS_SETTING_TITLE"><% cfgDescGet("board", "deviceName", ""); %></li>
            <li class="QS_SETTING_VALUE"><INPUT type="text" id="device_name" name="iw_board_deviceName" size="40" maxlength="31" value = "<% iw_qsCfgVal_get("board", "deviceName"); %>" /></li>
        </ul>

  <h2>System Time</h2>
  <ul>
   <li class="QS_SETTING_TITLE">Current local time</li>
   <li class="QS_SETTING_VALUE">
    <INPUT type="text" id="Year" size="4" maxlength="4" value="<% iw_webSysValueHandler("Dateyear", "", "");" %>" />&nbsp;/
    <INPUT type="text" id="Month" size="2" maxlength="2" value="<% iw_webSysValueHandler("Datemonth", "", ""); %>" />&nbsp;/
    <INPUT type="text" id="Day" size="2" maxlength="2" value="<% iw_webSysValueHandler("Dateday", "", ""); %>" />&nbsp;&nbsp;
    <INPUT type="text" id="Hour" size="2" maxlength="2" value="<% iw_webSysValueHandler("Datehour", "", ""); %>" />:
    <INPUT type="text" id="Minutes" size="2" maxlength="2" value="<% iw_webSysValueHandler("Datemin", "", ""); %>" />:
    <INPUT type="text" id="Seconds" size="2" maxlength="2" value="<% iw_webSysValueHandler("Datesec", "", ""); %>" /> (YYYY/MM/DD HH:MM:SS)
   </li>
   <li class="QS_SETTING_TITLE">&nbsp;&nbsp;</li>
   <li class="QS_SETTING_BUTTON"><input type="button" id="qs_set_time" value="Set Time" onClick="set_time();" style="height: 22px"/>(Note that "Set Time" would cause re-login.)</li>

   <li class="QS_SETTING_TITLE">Time protocol</li>
   <li class="QS_SETTING_VALUE">SNTP</li>

   <li class="QS_SETTING_TITLE"><% cfgDescGet("IWtime", "firstTimeSrv", ""); %></li>
   <li class="QS_SETTING_VALUE"><input type="text" name="iw_IWtime_firstTimeSrv" size="48" maxlength="39" value="<% iw_qsCfgVal_get("IWtime", "firstTimeSrv"); %>" style="width:410px"/></li>

   <li class="QS_SETTING_TITLE">Time zone</li>
   <li class="QS_SETTING_VALUE">
    <select size="1" id="qs_timezone" name="iw_IWtime_timeZone" style="width:410px">
     <% iw_webGet_TimezoneTable(); %>
    </select>
   </li>

   <li class="QS_SETTING_TITLE"><% iw_webSysDescHandler("DSTTitle", "", ""); %></li>
   <li class="QS_SETTING_VALUE">
    <input type="checkbox" name="dst_enable" id="dst_enable" />
       <label for="turboRoaming_enable">Enable</label>
    <input type="hidden" id="iw_IWtime_dstEnable" name="iw_IWtime_dstEnable" id="iw_"/>
   </li>

   <div id="qs_daylight_saving_area">
    <ul>
     <li class="QS_SETTING_TITLE">&nbsp;&nbsp;</li>
     <li class="QS_SETTING_VALUE_TITLE">Starts at</li>
     <li class="QS_SETTING_VALUE">
      <select id="dst_on_month" name="iw_IWtime_dstOnMonth"></select>
      <select id="dst_on_week" name="iw_IWtime_dstOnWeekIndex"></select>
      <select id="dst_on_day" name="iw_IWtime_dstOnWeekDay"></select>&nbsp;&nbsp;
      <input type="text" name="iw_IWtime_dstOnTrigHour" size="2" maxlength="2" value="<% iw_qsCfgVal_get("IWtime", "dstOnTrigHour"); %>" />:
      <input type="text" name="iw_IWtime_dstOnTrigMin" size="2" maxlength="2" value="<% iw_qsCfgVal_get("IWtime", "dstOnTrigMin"); %>" /> (HH:MM)
     </li>

     <li class="QS_SETTING_TITLE">&nbsp;&nbsp;</li>
     <li class="QS_SETTING_VALUE_TITLE">Stops at</li>
     <li class="QS_SETTING_VALUE">
      <select id="dst_off_month" name="iw_IWtime_dstOffMonth"></select>
      <select id="dst_off_week" name="iw_IWtime_dstOffWeekIndex"></select>
      <select id="dst_off_day" name="iw_IWtime_dstOffWeekDay"></select>
      &nbsp;&nbsp;
      <input type="text" name="iw_IWtime_dstOffTrigHour" size="2" maxlength="2" value="<% iw_qsCfgVal_get("IWtime", "dstOffTrigHour"); %>" />:
      <input type="text" name="iw_IWtime_dstOffTrigMin" size="2" maxlength="2" value="<% iw_qsCfgVal_get("IWtime", "dstOffTrigMin"); %>" /> (HH:MM)
     </li>

     <li class="QS_SETTING_TITLE">&nbsp;&nbsp;</li>
     <li class="QS_SETTING_VALUE_TITLE">Time offset</li>
     <li class="QS_SETTING_VALUE">
      <select id="dst_offset" name="iw_IWtime_dstOffsetTime"></select>
     </li>
    </ul>
   </div>
  </ul>
        <h2>IP Settings</h2>
        <ul>
            <li class="QS_SETTING_TITLE"><% cfgDescGet("netDev1", "dhcp", ""); %></li>
            <li class="QS_SETTING_VALUE">
     <select id="qs_dhcp" name="iw_netDev1_dhcp" size="1" onclick="dhcp_update();">
    <option value="ENABLE">DHCP</option>
    <option value="DISABLE">Static</option>
     </select>
   </li>

   <div id="qsArea_net">
             <li class="QS_SETTING_TITLE"><% cfgDescGet("netDev1", "ipv4Addr", ""); %></li>
             <li class="QS_SETTING_VALUE"><input type="text" name="iw_netDev1_ipv4Addr" size="20" value="<% iw_qsCfgVal_get("netDev1", "ipv4Addr"); %>" /></li>

             <li class="QS_SETTING_TITLE"><% cfgDescGet("netDev1", "ipv4Mask", ""); %></li>
             <li class="QS_SETTING_VALUE"><input type="text" name="iw_netDev1_ipv4Mask" size="20" value="<% iw_qsCfgVal_get("netDev1", "ipv4Mask"); %>" /></li>

             <li class="QS_SETTING_TITLE"><% cfgDescGet("netDev1", "ipv4GateWay", ""); %></li>
             <li class="QS_SETTING_VALUE"><input type="text" name="iw_netDev1_ipv4GateWay" size="20" value="<% iw_qsCfgVal_get("netDev1", "ipv4GateWay"); %>" /></li>
   </div>
        </ul>

        <h2>User Settings</h2>
        <ul>
            <li class="QS_SETTING_TITLE"><% cfgDescGet("account1", "username", ""); %></li>
            <li class="QS_SETTING_VALUE"><input type="text" name="iw_account1_username" size="20" maxlength="36" value="<% iw_qsCfgVal_get("account1", "username"); %>" style="width: 140px" /></li>
   <li class="HELPER_IMG" id="RF_type">
                <img src="Info.png"/>
                <span class="TOOLTIP_TEXT">This is the 1st account, which is always in Admin group.</span>
   </li>

   <li class="QS_SETTING_TITLE">Current password</li>
            <li class="QS_SETTING_VALUE"><input type="password" name="cur_pwd" size="20" maxlength="16" style="width: 140px" /></li>
   <li class="HELPER_IMG" id="RF_type">
                <img src="Info.png"/>
                <span class="TOOLTIP_TEXT">The 1st account's password won't be changed if current password field is blank.</span>
   </li>

            <li class="QS_SETTING_TITLE">New password</li>
            <li class="QS_SETTING_VALUE"><input type="password" id="new_pwd" name="new_pwd" size="20" maxlength="16" style="width: 140px" /></li>

   <li class="QS_SETTING_TITLE">Confirm password</li>
            <li class="QS_SETTING_VALUE"><input type="password" id="new_pwd2" size="20" maxlength="16" style="width: 140px" /></li>
        </ul>

    </div>
    <div class="BUTTON_AREA">
  <div>
         <a class="BUTTON" href="setup_option.asp">Cancel</a>
   <input type="submit" value="Next" class="BUTTON">
   <input type="hidden" name="nextPage" value="qs_wifi_settings_menu.asp" />
   <input type="hidden" name="bkpath" value="qs_basic_settings.asp" />
  </div>

    </div>
</form>
</body>
<script language="JavaScript" src="js/jquery-1.5.2.min.js"></script>
<script type="text/javascript">
	$(document).ready(function () {
		var isEditPermission = !<% iw_websCheckPermission(); %>;
		if (isEditPermission == 0) {
			$(":input").attr('disabled','disabled');
		}
	});
</script>
