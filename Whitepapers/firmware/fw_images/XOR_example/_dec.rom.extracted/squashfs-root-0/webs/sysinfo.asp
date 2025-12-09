<HTML>
<HEAD>
 <META http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
    <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate" />
    <meta http-equiv="Pragma" content="no-cache" />
    <meta http-equiv="Expires" content="0" />
 <LINK href="nport2g.css" rel=stylesheet type=text/css>
 <TITLE><% iw_webSysDescHandler("SysInfoSettingsTree", "", "System Info Settings"); %></TITLE>
 <% iw_webJSList_get(); %>
 <script type="text/javascript">
 <!--
  function CheckValue(form)
  {
   if(form.iw_board_deviceName.value.length<=0)
   {
    alert("<% iw_webCfgDescHandler("board", "deviceName", ""); %> cannot be empty.");
    form.iw_board_deviceName.focus();
    return false;
   }
            return true;
        }


 function editPermission()
 {
  var form = document.sysinfo, i, j = <% iw_websCheckPermission(); %>;
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
    -->
    </Script>
</HEAD>
<BODY onLoad="iw_ChangeOnLoad();">
 <H2><% iw_webSysDescHandler("SysInfoSettingsTree", "", "System Info Settings"); %> <% iw_websGetErrorString(); %></H2>
 <FORM name="sysinfo" method="POST" action="/forms/iw_webSetParameters" onSubmit="return CheckValue(this)">
    <TABLE width="100%">
  <TR>
   <TD width=30% class="column_title"><% iw_webCfgDescHandler("board", "deviceName", "Device name"); %></TD>
   <TD width=70%>
    <INPUT type="text" name="iw_board_deviceName" size="40" maxlength="31" value = "<% iw_webCfgValueHandler("board", "deviceName", ""); %>">
   </TD>
  </TR>
  <TR>
   <TD width=30% class="column_title"><% iw_webCfgDescHandler("board", "deviceLocation", "Device location"); %></TD>
   <TD width=70%>
    <INPUT type="text" name="iw_board_deviceLocation" size="40" maxlength="31" value = "<% iw_webCfgValueHandler("board", "deviceLocation", ""); %>">
   </TD>
  </TR>
  <TR>
   <TD width=30% class="column_title"><% iw_webCfgDescHandler("board", "deviceDescription", "Device description"); %></TD>
   <TD width=70%>
    <INPUT type="text" name="iw_board_deviceDescription" size="40" maxlength="31" value = "<% iw_webCfgValueHandler("board", "deviceDescription", ""); %>">
   </TD>
  </TR>
  <TR>
   <TD width=30% class="column_title"><% iw_webCfgDescHandler("board", "deviceContactInfo", "Device contact information"); %></TD>
   <TD width=70%>
    <INPUT type="text" name="iw_board_deviceContactInfo" size="40" maxlength="31" value = "<% iw_webCfgValueHandler("board", "deviceContactInfo", ""); %>">
   </TD>
  </TR>

  <TR>
   <TD width=30% class="column_title"><% iw_webCfgDescHandler("board", "webLoginMessage", "Web Login Message"); %></TD>
   <TD>
             <TEXTAREA name="iw_board_webLoginMessage" rows="4" cols="70" maxlength="240" WRAP=PHYSICAL style="overflow-x:hidden"><% iw_webCfgValueHandler("board", "webLoginMessage", ""); %></TEXTAREA>
            </TD>
  </TR>
  <TR>
   <TD width=30% class="column_title"><% iw_webCfgDescHandler("board", "webLoginFailMessage", "Login Authentication Failure Message"); %></TD>
   <TD>
             <TEXTAREA name="iw_board_webLoginFailMessage" rows="4" cols="70" maxlength="240" WRAP=PHYSICAL style="overflow-x:hidden"><% iw_webCfgValueHandler("board", "webLoginFailMessage", ""); %></TEXTAREA>
            </TD>
  </TR>

         <TR>
             <TD colspan="2"><HR>
                    <Span align="right">
   <INPUT type="submit" value="Submit" name="Submit">
    <Input type="hidden" name="bkpath" value="/sysinfo.asp">
                    </Span>
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
