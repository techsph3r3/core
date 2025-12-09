<HTML>
<HEAD>
 <LINK href="./nport2g.css" rel="stylesheet" type="text/css">
 <% iw_webJSList_get(); %>
 <TITLE>Serial Port Status</TITLE>
</HEAD>
<BODY>
 <H2>Serial Port Status</H2>
 <SCRIPT language="JavaScript">
  function do_referesh()
  {
   if(document.getElementById("ref5").checked)
   document.location.reload();
  }
  function check_referesh()
  {
   if(document.getElementById("ref5").checked)
    window.setTimeout("do_referesh()", 15000);
  }
  if(window.setTimeout)
  {
   document.write("<INPUT type='checkbox' id='ref5' checked onclick='check_referesh()'><label for='ref5'>Auto refresh</label>");
   check_referesh();
  }
 </SCRIPT>
 <TABLE width="100%">
  <TR class="column_title_bg">
   <TD class="block_title" align="center" nowrap>Port</TD>
   <TD class="block_title" align="center" nowrap>TxCnt</TD>
   <TD class="block_title" align="center" nowrap>RxCnt</TD>
   <TD class="block_title" align="center" nowrap>TxTotalCnt</TD>
   <TD class="block_title" align="center" nowrap>RxTotalCnt</TD>
   <TD class="block_title" align="center" nowrap>DSR</TD>
   <TD class="block_title" align="center" nowrap>DTR</TD>
   <TD class="block_title" align="center" nowrap>RTS</TD>
   <TD class="block_title" align="center" nowrap>CTS</TD>
   <TD class="block_title" align="center" nowrap>DCD</TD>
   <TD class="block_title" align="center" nowrap>Buffering</TD>
  </TR>
  <SCRIPT language="JavaScript">
   var tbl = <%iw_webGetPortStatus();%>;
   var port;
   var color;
   var minus;
   for(port = 1; port <= 1; port++)
   {
    if(port % 2 == 0)
     color = "beige";
    else
     color = "azure";
    document.write("<TR style=\"background-color: " + color + ";\">");
    document.write("<TD align=\"center\" nowrap>" + port + "</TD>");
    for(minus = 10; minus >= 7; minus--)
    {
     document.write("<TD align=\"right\" nowrap>" + tbl[10*port-minus] + "</TD>");
    }
    for(minus = 6; minus >= 2; minus--)
    {
     if(tbl[10*port-minus] == "true")
      document.write("<TD align=\"center\" nowrap><img src=\"./on.jpg\"></TD>");
     else
      document.write("<TD align=\"center\" nowrap><img src=\"./off.jpg\"></TD>");
    }
    document.write("<TD align=\"right\" nowrap>" + tbl[10*port-1] + "</TD>");
    document.write("</TR>");
   }
  </SCRIPT>
 </TABLE>
</BODY>
</HTML>
<script language="JavaScript" src="js/jquery-1.5.2.min.js"></script>
<script type="text/javascript">
	$(document).ready(function () {
		var isEditPermission = !<% iw_websCheckPermission(); %>;
		if (isEditPermission == 0) {
			$(":input").attr('disabled','disabled');
		}
	});
</script>
