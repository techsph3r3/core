<HTML>
<HEAD>
    <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate" />
    <meta http-equiv="Pragma" content="no-cache" />
    <meta http-equiv="Expires" content="0" />
 <LINK href="nport2g.css" rel="stylesheet" type="text/css">
 <% iw_webJSList_get(); %>
 <TITLE><% iw_webSysDescHandler("PingTracerouteTree", "", "Ping and Traceroute"); %></TITLE>
 <script type="text/javascript">
 <!--
  function CheckValue(form)
  {
   if(document.ping.srvName.value.length == 0 )
   {
    alert("Please enter IP or host name.");
    document.ping.srvName.focus();
    return false;

   }
  }

  function pingfunc()
  {
   if(document.ping.srvName.value.length == 0 )
   {
    alert("Please enter IP or host name.");
    document.ping.srvName.focus();
    return false;

   }
   document.ping.option.value = "0";
   document.ping.submit();
   document.ping.Pingbtn.disabled = true;
  }

  function window_onload()
  {
   document.ping.srvName.select();
   document.ping.srvName.focus();
  }
 -->
 </SCRIPT>
</HEAD>

<BODY onload="window_onload()">
 <H2><% iw_webSysDescHandler("PingTracerouteTree", "", "Ping and Traceroute"); %></H2>
 <FORM name="ping" action="/forms/webSetPingTrace" method="POST" onSubmit="return CheckValue(this)">
  <TABLE width="100%">
   <TR>
    <TD class="column_title">Destination</TD>
    <TD>
     <INPUT type="text" name="srvName" size="45" maxlength="40" value = "">
    </TD>
   </TR>
  </TABLE>
  <HR>
  <Input type="hidden" name="option" value="0">
  <INPUT type="button" name="Pingbtn" value="Ping" onclick="pingfunc()">
  <Input type="hidden" name="bkpath" value="/ping_trace.asp">
 </FORM>

 <PRE class="column_title"><% iw_webGetPingResult(); %></PRE>
</BODY>
</HTML>
