<!DOCTYPE html>
<html>

<head>
<meta charset="utf-8">
<meta http-equiv="X-UA-Compatible" content="IE=edge">
<title>Qicuk Setup</title>
<link rel="stylesheet" href="setup_option.css">
<% iw_webJSList_get(); %>
<script type="text/javascript">
<!--

 //: onload
 $(function(){

  if( <% iw_webQuickSetup_exit(); %> )
   top.contents.location.reload();

  if( <% iw_webQuickSetup_occupied(); %>
   || <% iw_websCheckPermission(); %>)
  {
   $('#qs_option').removeAttr('href');
   $('#qs_option').addClass('SETUP_OPTION_BUTTON_DISABLE');
  }

  top.toplogo.location.reload();

 });
-->
</script>
</head>

<body>
    <div class="SETUP_SEL">
        <div class="SETUP_OPTION">
            <a id="qs_option" href="qs_basic_settings.asp" class="SETUP_OPTION_BUTTON">Quick Setup</a>
            <p>Click "Quick Setup" to configure your AWK in few simple steps.</p>
        </div>

        <div class="SETUP_OPTION">
            <a href="ConfirmConfImp.asp" class="SETUP_OPTION_BUTTON">Import/Export</a>
            <p>Click "Import/Export" to perform configuration backup or recovery.</p>
        </div>

        <div class="SETUP_OPTION">
            <a href="main.asp" class="SETUP_OPTION_BUTTON">Overview</a>
            <p>Click “Overview” to view the AWK's basic device information.</p>
        </div>
    </div>
</body>
</html>
