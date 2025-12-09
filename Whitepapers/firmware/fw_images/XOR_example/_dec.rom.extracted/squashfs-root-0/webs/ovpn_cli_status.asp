<HTML>
<HEAD>
    <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate" />
    <meta http-equiv="Pragma" content="no-cache" />
    <meta http-equiv="Expires" content="0" />
 <LINK href="nport2g.css" rel="stylesheet" type="text/css">
 <% iw_webJSList_get(); %>
 <TITLE><% iw_webSysDescHandler("OvpnCliStatus", "", "OpenVPN Client Status"); %></TITLE>
</HEAD>
 <script type="text/javascript">
 <!--
  var mem_state = <% iw_websMemoryChange(); %>;
  function iw_ChangeOnLoad()
  {
   top.toplogo.location.reload();
  }

  function Backup()
        {
            document.location.href='ovpn_cli.status' ;
        }
    -->
    </Script>
<H2><% iw_webSysDescHandler("OvpnCliStatus", "", "OpenVPN Client Status"); %></H2>
<BODY onLoad = "iw_ChangeOnLoad();">
 <Table width="100%">
 <TR>
  <TD>
  <TEXTAREA name="Log" rows="20" cols="100" READONLY><% iw_webGetOvpnCliStatus(); %>
  </TEXTAREA>
  </TD>
 </TR>
 <TR>
        <TD><HR>
            <INPUT type="button" name="Export" value="Export Status Log" onClick="Backup()";>
            <INPUT type="button" name="Refresh" value="Refresh" onClick="window.location.reload()">
            <Input type="hidden" name="bkpath" value="/ovpn_cli_status.asp">
        </TD>
    </TR>
 </Table>
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
