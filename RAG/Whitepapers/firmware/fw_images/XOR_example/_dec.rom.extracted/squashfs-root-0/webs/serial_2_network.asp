<HTML>
<HEAD>
 <LINK href="./nport2g.css" rel="stylesheet" type="text/css">
 <% iw_webJSList_get(); %>
 <TITLE>Serial to Network Connections</TITLE>
 <SCRIPT language="JavaScript">
 <!--
  function showTerm(port)
  {
   //window.open("TermApplet.htm?Port=" + port, "_blank", "width=640, height=622");
  }
 //-->
 </SCRIPT>
</HEAD>
<BODY>
 <H2>Serial to Network Connections</H2>
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
   <TD class="block_title" width="5%" align="center">Port</TD>
   <TD class="block_title" width="22%" colspan="2" align="center">OP Mode</TD>
   <TD class="block_title" width="*" colspan=<%iw_web_getMaxConns();%> align="center">Connections</TD>
  </TR>
  <SCRIPT language="JavaScript">
   var tbl = <%iw_webSerial2NetworkStatus();%>;
   var port, conn;
   var line;
   var color;
   line = <%iw_web_getMaxConns();%>;
   for(port = 1; port <= 1; port++)
   {
    if(port % 2 == 0)
     color = "beige";
    else
     color = "azure";
    document.write("<TR style=\"background-color: " + color + ";\">");
    document.write("<TD align=\"center\" rowspan=" + line + " nowrap>" + port + "</TD>");
    document.write("<TD align=\"center\" rowspan=" + line + " width=20>");
    document.write(tbl[0]+'/'+tbl[1]);
    document.write("</TD>");
    document.write("<TD nowrap rowspan=" + line +"></TD>");
    for( conn =1 ; conn <= line ; conn++ )
    {
     //document.write("<TD align=\"center\" nowrap>[<SPAN style=\"width: 120px;\">" + tbl[1+conn] + "</SPAN>]</TD>");
     if(tbl[1+conn])
      document.write("<TD align=\"center\" nowrap>[<SPAN >" + tbl[1+conn] + "</SPAN>]</TD>");
     else
      document.write("<TD align=\"center\" nowrap>[<SPAN style=\"width: 120px;\">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</SPAN>]</TD>")
    }

    /*if(tbl[(4 + 2) * port - (4 + 2) + 1])
					document.write("<A HREF=\"javascript:showTerm(" + port + ");\"><IMG border=0 src=\"term.gif\"></A>");
				else
					document.write("&nbsp;");
				document.write("</TD>");
				*/
    //
    /*for(conn = 1; conn <= line; conn++)
				{
					if(conn != 1 && conn % 4 == 1)
					{
						document.write("</TR>");
						document.write("<TR style=\"background-color: " + color + ";\">");
					}
					if(tbl[(4 + 2) * port - (4 + 2) + conn + 1] == "")
						document.write("<TD align=\"center\" nowrap>[<SPAN style=\"width: 120px;\">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</SPAN>]</TD>");
					else
						document.write("<TD align=\"center\" nowrap>[<SPAN style=\"width: 120px;\">" + tbl[(4 + 2) * port - (4 + 2) + conn + 1] + "</SPAN>]</TD>");
				}*/
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
