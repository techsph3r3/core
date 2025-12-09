<HTML>
<HEAD>
 <META http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
 <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate" />
 <meta http-equiv="Pragma" content="no-cache" />
 <meta http-equiv="Expires" content="0" />
 <LINK href="nport2g.css" rel=stylesheet type=text/css>
 <TITLE> Error Notification </TITLE>
 <% iw_webJSList_get(); %>
 <script type="text/javascript">
 <!--
 function iw_onLoad()
 {
  var error_val = location.search.split('error=')[1] ? parseInt(location.search.split('error=')[1]) : 0;
  var mark;
  var message;
  switch(error_val) {
  case 2:
   mark = "Security Warning!";
   message = "Detect the abnormal changes by unauthenticated source. Please use HTTPS protocol to access web UI for your network safety.";
   break;
  case 404:
  default:
   mark = "404 Error";
   message = "Page not found.";
   break;
  }

  $("#err_mark").append(mark);
  $("#err_message").append(message);
 }
 //-->
 </SCRIPT>
</HEAD>
<BODY onLoad="iw_onLoad();">
 <P><H2>Error Notification</H2></P>
 <P><H1><div id="err_mark"></div></H1></P>
 <P><div id="err_message"></div></P>
</BODY>
</HTML>
