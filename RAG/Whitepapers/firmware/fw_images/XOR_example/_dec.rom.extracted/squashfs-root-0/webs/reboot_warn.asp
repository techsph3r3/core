<HTML>
<HEAD>
 <META http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
 <LINK href="nport2g.css" rel="stylesheet" type="text/css">
 <TITLE><% iw_webSysDescHandler("RestartTree", "", "Restart System"); %></TITLE>
 <script type="text/javascript">
 <!--
  var timeoutId;

  var timeout = 40 + Math.ceil(1.5 * <% iw_webGetTotalNumOfVaps(); %>) ;




  function timer_set()
  {
   setTimeout("closepage()", timeout * 1000 );
   <% iw_webSysReboot(); %>
  }

  function closepage()
  {
   top.location.replace(location.protocol + "//" +"<% iw_webGetRestartConnectIP(); %>");
  }


  function countDown()
  {
   timeout--;
   document.reboot.timeRemain.value=timeout;
   if (timeout <= 0)
   {
     document.reboot.timeRemain.value=0;
   }
  }

  function timecheck()
  {
     document.reboot.timeRemain.value=timeout;
      timeoutId = setInterval(countDown, 1000);
  }
    -->
    </SCRIPT>
</HEAD>

<BODY onLoad="timer_set();timecheck();">
 <FORM name="reboot" method="POST">
  <TABLE width="100%">
  <TR>



   <TD><B><font font-size="5pt" color="#009966" face="Verdana" >&nbsp;&nbsp;<% iw_webSysDescHandler("RestartTree", "", "Restart System"); %></font></B></TD>

  </TR>
  <TR>
    <TD colspan="2"></TD>
  </TR>
  <TR>
    <TD colspan="2"></TD>
  </TR>
  <TR>
   <TD> <B><font size="2" face="Verdana">&nbsp;&nbsp;The system is restarting ... </font></B></TD>
  </TR>
  <TR>
   <TD> <B><font size="2" face="Verdana">&nbsp;&nbsp;The web console Login screen will reload in <INPUT readonly size="2" name=timeRemain> seconds.</font></B></TD>
  </TR>
  </TABLE>
 </FORM>
</BODY>
</HTML>
