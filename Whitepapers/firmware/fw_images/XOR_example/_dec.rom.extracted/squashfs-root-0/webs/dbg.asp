<HTML>
<HEAD>
 <META http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
 <LINK href="nport2g.css" rel="stylesheet" type="text/css">
 <TITLE>Debug Log Settings</TITLE>
 <% iw_webJSList_get(); %>
 <script>

 // Global var
 var confData = <% iw_webGetPPPLogToJSON(); %>;

 $(document).ready( function() {
  // Init Page
  iw_changeStateOnLoad(top);
  // Load setting, load saved config data
  $('#iw_guaranLink_dbgLogService' + ' option[value="' + confData['dbgLogService'] + '"]').attr('selected', 'selected');
 });

 </script>
</HEAD>
<BODY>
 <H2>Debug Log Settings</H2>
 <form name="dbgLog" id="dbgLog" method="POST" action="/forms/webSetSystemPPPLogService" >
  <TABLE width="100%">
   <TR>
    <TD width="30%" class="column_title">Debug Log [PPP]</TD>
    <TD width="70%">
     <select id="iw_guaranLink_dbgLogService" name="iw_guaranLink_dbgLogService">
     <option value="ENABLE">Enable</option>
     <option value="DISABLE">Disable</option>
     </select>
    </TD>
   </TR>
  </TABLE>
  <input type="submit" value="Submit" name="Submit">
  <Input type="hidden" name="bkpath" value="/dbg.asp">
 </form>
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
