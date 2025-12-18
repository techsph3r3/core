<HTML>
<HEAD>
 <LINK href="./nport2g.css" rel="stylesheet" type="text/css">
 <% iw_webJSList_get(); %>
 <TITLE>Serial Port Error Count</TITLE>
</HEAD>
<BODY>
 <H2>Serial Port Error Count</H2>
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
   <TD class="block_title" align="center" rowspan=2 nowrap>Port</TD>
   <TD class="block_title" align="center" colspan=4 nowrap>ErrCnt</TD>
  </TR>
  <TR class="column_title_bg">
   <TD class="block_title" align="center" nowrap>Frame</TD>
   <TD class="block_title" align="center" nowrap>Parity</TD>
   <TD class="block_title" align="center" nowrap>Overrun</TD>
   <TD class="block_title" align="center" nowrap>Break</TD>
  </TR>
  <SCRIPT language="JavaScript">
   var tbl = <% iw_webGetPortErr(); %>;
   var port;
   var color;
   for(port = 1; port <= 1; port++)
   {
    if(port % 2 == 0)
     color = "beige";
    else
     color = "azure";
    document.write("<TR style=\"background-color: " + color + ";\">");
    document.write("<TD align=\"center\" nowrap>" + port + "</TD>");
    document.write("<TD align=\"right\" nowrap>" + tbl[4*port-4] + "</TD>");
    document.write("<TD align=\"right\" nowrap>" + tbl[4*port-3] + "</TD>");
    document.write("<TD align=\"right\" nowrap>" + tbl[4*port-2] + "</TD>");
    document.write("<TD align=\"right\" nowrap>" + tbl[4*port-1] + "</TD>");
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
