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
 function qs_type_default()
 {
  $("#qs_type").val("DEFAULT");
 }

 function qs_type_bak()
 {
  $("#qs_type").val("BAK");
 }

 //: onload
 $(function()
 {
  var enter_status = <% iw_webQuickSetup_enter(); %>;
  if( enter_status == 1 ) // the 1st entering quick setup
   top.contents.location.reload();
  else if ( enter_status == 2 ) // someone has been in quick setup
  {
   top.main.location="/setup_option.asp";
  }

  $('.NAV .NAV_BOX .NAV_NO').addClass("NAV_NO_DISABLE");
  $('.NAV .NAV_BOX .NAV_DESC').addClass("NAV_DESC_DISABLE");
  $('.NAV .NAV_BOX').addClass("NAV_BOX_DISABLE");

  $('.NAV a').removeAttr('href');
  $('.NAV .NAV_ARROW').css('border-color', 'transparent transparent transparent #F2F2F2');

 });
-->
</script>
</head>
<body>
<% iw_webQuickSetup_nav(); %>
<form id="qsForm" action="/forms/web_qsSetting_type" method="POST">
    <div class="QS_SETTING">
        <h2>Do you want to setup from the default or saved configuration settings?</h2>
 </div>
    <div class="BUTTON_AREA">
  <div>
         <a class="BUTTON" href="setup_option.asp">Exit</a>
   <input type="submit" value="Default Settings" class="BUTTON" style="width:105px;" onclick="qs_type_default();">
   <input type="submit" value="Saved Settings" class="BUTTON" style="width:105px;" onclick="qs_type_bak();">
   <input type="hidden" name="qs_type" id="qs_type"/>
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
