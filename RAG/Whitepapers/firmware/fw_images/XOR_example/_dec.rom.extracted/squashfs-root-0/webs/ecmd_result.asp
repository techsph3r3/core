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
 var refresh_time_msec = 1000;

 function doLoad()
 {
     setTimeout( "refresh()", refresh_time_msec );
 }

 function refresh()
 {
  var is_finish = <% iw_webCmdExecuting_isFinish(); %>;
  var sURL = unescape(window.location.pathname);

  if ( is_finish == 0 )
  {
   window.location.replace( sURL );
   setTimeout( "refresh()", refresh_time_msec );
  }
 }
//-->
 </script>
</head>

<body onload="doLoad();">
 <h2> Executing result </h2>
 <br>
 <% iw_webCmdExecuting_result_get(); %></b><br><br>
</body>
</html>
