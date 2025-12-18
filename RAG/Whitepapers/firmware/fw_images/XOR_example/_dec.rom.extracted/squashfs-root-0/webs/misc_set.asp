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
              if ("<% iw_webCfgValueHandler("misc", "resetBtnEnable", "ENABLE"); %>" == "ENABLE")
     document.misc.iw_misc_resetBtnEnable_En.checked = true;
    else
     document.misc.iw_misc_resetBtnEnable_Dis.checked = true;







          }


  function editPermission()
  {
   var form = document.misc, i, j = <% iw_websCheckPermission(); %>;
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
 <H2><% iw_webSysDescHandler("MiscSettingTree", "", "Miscellaneous Settings"); %> <% iw_websGetErrorString(); %></H2>
 <FORM name="misc" method="POST" action="/forms/iw_webSetParameters">
  <TABLE width=100%>
   <TR>
    <TD width="10%" class="column_title"><% iw_webCfgDescHandler("misc", "resetBtnEnable", "Reset Button"); %></TD>
    <TD width="90%">
     <input type="radio" name="iw_misc_resetBtnEnable" id="iw_misc_resetBtnEnable_En" value="ENABLE">
     <label for="iw_misc_resetBtnEnable_En">Always enable</label>
     <input type="radio" name="iw_misc_resetBtnEnable" id="iw_misc_resetBtnEnable_Dis" value="DISABLE">
     <label for="iw_misc_resetBtnEnable_Dis">Disable factory reset function after 60 seconds.</label>
    </TD>
   </TR>
   <TR>
    <TD colspan="2">
     <HR>
     <INPUT type="submit" value="Submit" name="Submit">
     <Input type="hidden" name="bkpath" value="/misc_set.asp">
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
