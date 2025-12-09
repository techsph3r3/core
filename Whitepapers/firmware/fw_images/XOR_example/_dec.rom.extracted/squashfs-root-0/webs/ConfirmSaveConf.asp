<HTML>
<HEAD>
    <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate" />
    <meta http-equiv="Pragma" content="no-cache" />
    <meta http-equiv="Expires" content="0" />
 <LINK href="nport2g.css" rel="stylesheet" type="text/css">
 <TITLE><% iw_webSysDescHandler("SaveConfigTree", "", "Save Configuration"); %></TITLE>
 <script type="text/javascript">
 <!--
  function check()
  {
   iw_DisableBtn();
  }
  function iw_DisableBtn()
  {
   document.saveConfig.Save.disabled = true;
  }


  function editPermission()
  {
   var form = document.saveConfig, i, j = <% iw_websCheckPermission(); %>;
   if(j)
   {
    for(i = 0; i < form.length; i++)
     form.elements[i].disabled = true;
   }
  }


  function iw_OnLoad()
  {

                 editPermission();

                 top.toplogo.location.reload();
         }
 //-->	
 </SCRIPT>
</HEAD>
<BODY onload="iw_OnLoad();">
 <H2><% iw_webSysDescHandler("SaveConfigTree", "", "Save Configuration"); %> <% iw_websGetErrorString(); %></H2>
 <P>
  You must save the changes and restart the system for configuration changes to take effect.<br>
        Click <B>Save</B> to save configuration changes to the system memory. <br>
 </P>
 <FORM name="saveConfig"method="GET" action="/forms/web_SetMainSaveConfig" onsubmit="return check()">
  <TABLE width="100%">
   <TR>
    <TD colspan="2"><HR>
      <INPUT type="submit" value="Save" name="Save">
      <Input type="hidden" name="bkpath" value="/ConfirmSaveConf.asp">
    </TD>
   </TR>
  </TABLE>
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
