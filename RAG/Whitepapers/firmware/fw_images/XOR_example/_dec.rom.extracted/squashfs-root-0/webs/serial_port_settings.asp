<HTML>
<HEAD>
 <LINK href="./nport2g.css" rel="stylesheet" type="text/css">
 <% iw_webJSList_get(); %>
 <TITLE>Serial Port Settings</TITLE>
</HEAD>
<BODY>
 <H2>Serial Port Settings</H2>
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
   <TD class="block_title" width="5%" rowspan="2">Port</TD>
   <TD class="block_title" width="12%" rowspan="2">Baud Rate</TD>
   <TD class="block_title" width="12%" rowspan="2">Data Bits</TD>
   <TD class="block_title" width="12%" rowspan="2">Stop Bits</TD>
   <TD class="block_title" width="9%" rowspan="2">Parity</TD>
   <TD class="block_title" width="18%" align="center" colspan="2">Flow Control</TD>
   <TD class="block_title" width="12%" rowspan="2">FIFO</TD>
   <TD class="block_title" width="20%" rowspan="2">Interface</TD>
  </TR>
  <TR class="column_title_bg">
   <TD class="block_title" width="9%">RTS/CTS</TD>
   <TD class="block_title" width="9%">XON/XOFF</TD>
  </TR>
  <SCRIPT language="JavaScript">
   var tbl = <%iw_webGetPortSetting();%>;
   var port;
   var color;
   for(port = 1; port <= 1; port++)
   {
    if(port % 2 == 0)
     color = "beige";
    else
     color = "azure";
    document.write("<TR style=\"background-color: " + color + ";\">");
    document.write("<TD alian=\"center\" nowrap>" + port + "</TD>");
    document.write("<TD nowrap>" + tbl[8*port-8] + "</TD>");
    document.write("<TD nowrap>" + tbl[8*port-7] + "</TD>");
    document.write("<TD nowrap>" + tbl[8*port-6] + "</TD>");
    document.write("<TD nowrap>" + tbl[8*port-5] + "</TD>");
    document.write("<TD nowrap>" + tbl[8*port-4] + "</TD>");
    document.write("<TD nowrap>" + tbl[8*port-3] + "</TD>");
    document.write("<TD nowrap>" + iwSerialStrMap(tbl[8*port-2]) + "</TD>");
    document.write("<TD nowrap>" + iwSerialStrMap(tbl[8*port-1]) + "</TD>");
    document.write("</TD>");
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
