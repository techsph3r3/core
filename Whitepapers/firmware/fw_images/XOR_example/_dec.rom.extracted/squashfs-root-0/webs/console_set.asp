<HTML>
<HEAD>
 <META http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
    <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate" />
    <meta http-equiv="Pragma" content="no-cache" />
    <meta http-equiv="Expires" content="0" />
 <LINK href="nport2g.css" rel=stylesheet type=text/css>
 <TITLE><% iw_webSysDescHandler("ConsoleSettingTree", "", "Console Settings"); %></TITLE>
 <% iw_webJSList_get(); %>
 <script type="text/javascript">
 <!--
        function iw_consoleOnLoad(form)
         {
              if ("<% iw_webCfgValueHandler("misc", "webEnable", "DISABLE"); %>" == "ENABLE")
    document.console.iw_misc_webEnable0.checked = true;
   else
    document.console.iw_misc_webEnable1.checked = true;

              if ("<% iw_webCfgValueHandler("misc", "httpsEnable", "DISABLE"); %>" == "ENABLE")
    document.console.iw_misc_httpsEnable0.checked = true;
   else
    document.console.iw_misc_httpsEnable1.checked = true;

              if ("<% iw_webCfgValueHandler("misc", "telnetEnable", "DISABLE"); %>" == "ENABLE")
    document.console.iw_misc_telnetEnable0.checked = true;
   else
    document.console.iw_misc_telnetEnable1.checked = true;

              if ("<% iw_webCfgValueHandler("misc", "sshEnable", "DISABLE"); %>" == "ENABLE")
    document.console.iw_misc_sshEnable0.checked = true;
   else
    document.console.iw_misc_sshEnable1.checked = true;
          }


  function editPermission()
  {
   var form = document.console, i, j = <% iw_websCheckPermission(); %>;
   if(j)
   {
    for(i = 0; i < form.length; i++)
     form.elements[i].disabled = true;
   }
  }



         var mem_state = <% iw_websMemoryChange(); %>;
  function iw_ChangeOnLoad()
               {

                 editPermission();

   top.toplogo.location.reload();
  }

 //-->
 </SCRIPT>
</HEAD>
<BODY onLoad="iw_consoleOnLoad();iw_ChangeOnLoad();">
 <H2><% iw_webSysDescHandler("ConsoleSettingTree", "", "Console Settings"); %> <% iw_websGetErrorString(); %></H2>
 <FORM name="console" method="POST" action="/forms/iw_webSetParameters">
  <TABLE width=100%>
   <TR>
    <TD width="30%" class="column_title"><% iw_webCfgDescHandler("misc", "webEnable", "HTTP console"); %></TD>
    <TD width="70%">
     <INPUT type="radio" name="iw_misc_webEnable" value="ENABLE" id="iw_misc_webEnable0" checked><label for="iw_misc_webEnable0">Enable</label>
     <INPUT type="radio" name="iw_misc_webEnable" value="DISABLE" id="iw_misc_webEnable1"><label for="iw_misc_webEnable1">Disable</label>
    </TD>
   </TR>

    <TR>
     <TD width="30%" class="column_title"><% iw_webCfgDescHandler("misc", "httpsEnable", "HTTPS console"); %></TD>
     <TD width="70%">
      <INPUT type="radio" name="iw_misc_httpsEnable" value="ENABLE" id="iw_misc_httpsEnable0" checked><label for="iw_misc_httpsEnable0">Enable</label>
      <INPUT type="radio" name="iw_misc_httpsEnable" value="DISABLE" id="iw_misc_httpsEnable1"><label for="iw_misc_httpsEnable1">Disable</label>
     </TD>
    </TR>

   <TR>
    <TD width="30%" class="column_title"><% iw_webCfgDescHandler("misc", "telnetEnable", "Telnet console"); %></TD>
    <TD width="70%">
     <INPUT type="radio" name="iw_misc_telnetEnable" value="ENABLE" id="iw_misc_telnetEnable0" checked><label for="iw_misc_telnetEnable0">Enable</label>
     <INPUT type="radio" name="iw_misc_telnetEnable" value="DISABLE" id="iw_misc_telnetEnable1"><label for="iw_misc_telnetEnable1">Disable</label>
    </TD>
   </TR>

    <TR>
     <TD width="30%" class="column_title"><% iw_webCfgDescHandler("misc", "sshEnable", "SSH console"); %></TD>
     <TD width="70%">
      <INPUT type="radio" name="iw_misc_sshEnable" value="ENABLE" id="iw_misc_sshEnable0" checked><label for="iw_misc_sshEnable0">Enable</label>
      <INPUT type="radio" name="iw_misc_sshEnable" value="DISABLE" id="iw_misc_sshEnable1"><label for="iw_misc_sshEnable1">Disable</label>
     </TD>
    </TR>
   <TR>
    <TD colspan="2">
     <HR>
     <INPUT type="submit" value="Submit" name="Submit">
     <Input type="hidden" name="bkpath" value="/console_set.asp">
    </TD>
   </TR>
  </TABLE>
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
