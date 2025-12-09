<HTML>
<HEAD>
 <LINK href="nport2g.css" rel="stylesheet" type="text/css">
 <% iw_webJSList_get(); %>
 <TITLE>Degug Log</TITLE>
</HEAD>
 <script type="text/javascript">
 <!--
  function confirm_clearlog()
  {
   if (window.confirm("Are you sure to clear dbg log?"))
   {
    document.dbglog.clean.value = "1";
    document.dbglog.Log.value = "";
    document.dbglog.submit();
   }
  }

  function scroll_to_latest(e)
  {
   e.scrollTop = e.scrollHeight;
  }

  function Backup()
  {
          document.location.href='dbglog.log' ;
  }

         var mem_state = <% iw_websMemoryChange(); %>;
              function iw_ChangeOnLoad()
              {
                        top.toplogo.location.reload();
              }
    -->
    </Script>

 <H2>Debug Log</H2>
<BODY onLoad = "scroll_to_latest(document.dbglog.Log);iw_ChangeOnLoad();">
 <FORM name="dbglog" method="POST" action="/forms/webSetSystemPPPLogData">
  <Table width="100%">
   <TR>
    <TD>
     <TEXTAREA name="Log" rows="20" cols="100" READONLY><% iw_webGetSystemPPPLogData(); %>
     </TEXTAREA>
    </TD>

   </TR>

  <TR>
         <TD><HR>
   <INPUT type="hidden" name="clean" value="0">
   <INPUT type="button" name="Export" value="Export Log" onClick="Backup()";>
   <INPUT type="button" name="ClearLog" value="Clear Log" onclick="confirm_clearlog();">
   <INPUT type="button" name="Refresh" value="Refresh" onClick="window.location.reload()">
   <Input type="hidden" name="bkpath" value="/dbglog.asp">
   </TD>
     </TR>
     </Table>
 </FORM>
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
