<!DOCTYPE html PUBLIC "-//W3C//Dtd html 4.01 Transitional//EN">
<html>
<head>
 <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
 <link href="nport2g.css" rel=stylesheet type=text/css>
 <noscript>
  <meta http-equiv="refresh" content="2">
 </noscript>
 <script type="text/javascript">
<!--
 var sURL = unescape(window.location.pathname);
 var update_proc = <% iw_webGetUpgradeFWProgress(); %>;
 var errString = '<% iw_websGetErrorString(1); %>';
 var refresh_time_msec = 1000;
 function doLoad()
 {
     setTimeout( "refresh()", refresh_time_msec );
 }

 function refresh()
 {
  if( errString.length != 0 )
  {
   window.location.replace( "/ConfirmUpgrade.asp" );
  }else if (update_proc == 100)
  {
   document.getElementById("area_on").style.display = "";
   window.location.replace( "/reboot_warn.asp" );
  }else
  {
   document.getElementById("area_on").style.display = "none";
   window.location.replace( sURL );
   setTimeout( "refresh()", refresh_time_msec );
  }
 }
//-->
 </script>
</head>

<body onload="doLoad();">
 <h2> <% iw_websGetErrorString(1); %> </h2>
 <table width="100%">
 <tr>
    <td width="100%" class="column_title"> Upgrade Status </td>
 </tr>
 <tr>
    <td width="100%" class="column_title"><br> Upgrading, please wait... <% iw_webGetUpgradeFWProgress(); %> %<br><br><br></td>
 </tr>
 </table>
 <table width="90%" border="1">
 <tr>
  <td>



   <img src="/green_pix.jpg" height="16" width="<% iw_webGetUpgradeFWProgress(); %>%">

  </td>
 </tr>
 </table>

 <div id="area_on">
 <br><br><br><b><% iw_webGetUpgradeStatusMsg(); %></b><br><br>
 </div>
</body>
</html>
