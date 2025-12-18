<HTML>
<HEAD>
 <META http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
    <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate" />
    <meta http-equiv="Pragma" content="no-cache" />
    <meta http-equiv="Expires" content="0" />
 <LINK href="nport2g.css" rel="stylesheet" type="text/css">
 <TITLE><% iw_webSysDescHandler("RestartTree", "", "Restart System"); %></TITLE>
 <script type="text/javascript">
 <!--
 var mem_state = <% iw_websMemoryChange(); %>;
 function check_restart()
 {
  var ret = 0;

  if (mem_state == 2)
   ret = window.confirm('The configuration has been changed without saving to flash.\nDo you want to restart the device anyway?');

  if(mem_state != 2 || ret)
  {
   document.getElementById("SaveValue").value = "0";
   document.save.submit();
   iw_DisableBtn();
  }
 }
 function check_save_restart()
 {
  document.getElementById("SaveValue").value = "1";
  document.save.submit();
  iw_DisableBtn();
 }


 function editPermission()
 {
  var form = document.save, i, j = <% iw_websCheckPermission(); %>;
  if(j)
  {
   for(i = 0; i < form.length; i++)
    form.elements[i].disabled = true;
  }
 }


 function iw_RestartMsgOnLoad()
 {
  if(mem_state == 2 )
   document.getElementById("restarttab").style.display = "none";
  else
   document.getElementById("savetab").style.display = "none";

  editPermission();


 }
 function iw_DisableBtn()
 {
  document.save.restart1.disabled = true;
  document.save.restart2.disabled = true;
  document.save.SaveRestart.disabled = true;
 }
 //-->	
 </SCRIPT>
</HEAD>
<BODY onLoad="iw_RestartMsgOnLoad();">
 <H2><% iw_webSysDescHandler("RestartTree", "", "Restart System"); %> <% iw_websGetErrorString(); %></H2>
 <FORM name="save" method="GET" action="/forms/webSetMainRestart" onsubmit="check_restart();">
  <TABLE id=restarttab width="100%">
   <TR>
    <TD width="100%" class="block_title">!!! Warning !!!</TD>
   </TR>
   <TR>
    <TD><BR>
     <B>
      The system will restart immediately after you click Restart. All Ethernet connections will be disconnected.<BR>
     </B>
    </TD>
   </TR>

   <TR>
    <TD colspan="2"><HR>
      <INPUT type="button" value="Restart" name="restart1" onclick="check_restart()">
    </TD>
   </TR>
  </TABLE>
  <TABLE id=savetab width="100%">
   <TR>
    <TD width="100%" class="block_title">!!! Warning !!!</TD>
   </TR>
   <TR>
    <TD><BR>
     <B>
      Click Restart to discard configuration changes and restart the system.<BR>
     </B>
    </TD>
   </TR>
   <TR>
    <TD><BR>
     <B>
      Click Save and Restart to save configuration changes and restart the system.<BR>
     </B>
    </TD>
   </TR>
   <TR>
    <TD colspan="2"><HR>
      <INPUT type="button" value="Restart" name="restart2" onclick="check_restart()">&nbsp;&nbsp;<INPUT type="button" value="Save and Restart" name="SaveRestart" onclick="check_save_restart()">
    </TD>
   </TR>
  </TABLE>
  <INPUT type="hidden" id="SaveValue" name="SaveValue" value="0">
  <br>
  <H2>Network Settings After Reboot</H2>
  <% iw_webGetRebootNetworkConf(); %>
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
