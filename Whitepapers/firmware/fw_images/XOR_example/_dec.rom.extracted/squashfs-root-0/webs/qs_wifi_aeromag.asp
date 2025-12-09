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

 //: onLoad
 $(function() {
  $('#qs_aeroMag').val("<% iw_qsCfgVal_get("AeroMag", "enable"); %>");
 });

-->
</script>
</head>
<body>
<% iw_webQuickSetup_nav(); %>
<form id="qsForm" action="/forms/web_qsSetting" method="POST">
    <div class="QS_SETTING">
        <h2>AeroMag</h2>
        <ul>
            <li class="QS_SETTING_TITLE">AeroMag</li>
            <li class="QS_SETTING_VALUE">
    <select size="1" id="qs_aeroMag" name="iw_AeroMag_enable" style="width: 80px">

     <option value="AP">AP</option>




    </select>
   </li>
   <li class="HELPER_IMG" id="RF_type">
     <img src="Info.png"/>
     <span class="TOOLTIP_TEXT">Wi-Fi configuration, which includes RF type and security, will be assigned automatically by AeroMag AP after reboot.</span>
   </li>
  </ul>
    </div>
    <div class="BUTTON_AREA">
  <div>
         <a class="BUTTON" href="setup_option.asp">Cancel</a>
   <a class="BUTTON" href="qs_wifi_settings_menu.asp">Back</a>
   <input type="submit" value="Next" class="BUTTON">
   <input type="hidden" name="bkpath" value="qs_wifi_aeromag.asp" />
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
