<!DOCTYPE html>
<html>

<head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <title>Qicuk Setup</title>
    <link rel="stylesheet" href="quickSetup.css">
 <link rel="stylesheet" href="setup_option.css">
 <% iw_webJSList_get(); %>
 <script type="text/javascript">
 <!--

 function manual_href()
    {
        if( "<% iw_qsCfgVal_get("AeroMag", "enable"); %>" == "DISABLE" )
        {
            $('#qs_manual').attr("href", "qs_wifi_settings.asp");
        } else if( confirm("If you choose Manual, AeroMag will be default deactivated. Do you want to proceed?") == true)
        {
            $('#qs_manual').attr("href", "qs_wifi_settings.asp");
        }
    }
   -->
 </script>
</head>
<body>
<% iw_webQuickSetup_nav(); %>
 <div class="SETUP_SEL">
        <div class="SETUP_OPTION">
            <a class="SETUP_OPTION_BUTTON" id="qs_manual" onclick="manual_href()">Manual</a>
            <p>Configure your wireless communication in 3 simple steps.</p>
        </div>
  <div class="SETUP_OPTION">
            <a href="qs_wifi_aeromag.asp" class="SETUP_OPTION_BUTTON">AeroMag</a>
            <p>Use AeroMag to enable your wireless topology.</p>
        </div>
 </div>
    <div class="BUTTON_AREA">
        <div>
            <a class="BUTTON" href="setup_option.asp">Cancel</a>
            <a class="BUTTON" href="qs_basic_settings.asp">Back</a>
        </div>
    </div>
</body>
