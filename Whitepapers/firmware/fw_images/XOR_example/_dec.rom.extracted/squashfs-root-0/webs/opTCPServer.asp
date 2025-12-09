<TITLE>TCP Server Mode</TITLE>
 <SCRIPT language="JavaScript">
 <!--
  var chk = true;
  function CheckValue(form)
  {
   if(chk)
   {
     if( !isValidNumber(form.TCPAliveCheck, 0, 99, "TCP alive check time") ){
      form.TCPAliveCheck.focus();
      return false;
     }
     if( !isValidNumber(form.InactivityTime, 0, 65535, "Inactivity time") )
     {
      form.InactivityTime.focus();
      return false;
     }

     if( !isValidNumber(form.PackLen, 0, 1024, "Packing length") )
     {
      form.PackLen.focus();
      return false;
     }

     if(form.DelimiterChar1.disabled == false && !isHEXDelimiter(form.DelimiterChar1.value))
     {
      alert("Invalid input: \"Delimiter Char 1\" (" + form.DelimiterChar1.value + ")");
      form.DelimiterChar1.focus();
      return false;
     }

     if(form.DelimiterChar2.disabled == false && !isHEXDelimiter(form.DelimiterChar2.value))
     {
      alert("Invalid input: \"Delimiter Char 2\" (" + form.DelimiterChar2.value + ")");
      form.DelimiterChar2.focus();
      return false;
     }

     if( !isValidNumber(form.ForceTxTime, 0, 65535, "Force transmit") ){
      form.ForceTxTime.focus();
      return false;
     }

     if(!form.DelimiterChar1Flag.checked && form.DelimiterChar2Flag.checked)
     {
      alert("Warning: Delimiter 2 is enabled without activating Delimiter 1 first.");
      form.DelimiterChar2.focus();
      return false;
     }

     if( !isValidPort(form.TCPDataPort, "TCP port") )
     {
      form.TCPDataPort.focus();
      return false;
     }

     if( !isValidPort(form.TCPCmdPort, "Cmd port") )
     {
      form.TCPCmdPort.focus();
      return false;
     }
   }
   return true;
  }


  function editPermission()
  {
   var form = document.opmode, i, j = <% iw_websCheckPermission(); %>;
   if(j)
   {
    for(i = 0; i < form.length; i++)
     form.elements[i].disabled = true;
   }
  }


  function iw_onLoad(){

                 editPermission();

  }
 // -->
 </SCRIPT>
</HEAD>
<BODY onload="iw_onLoad();">
 <H2>Operation Modes<% iw_websGetErrorString(); %></H2>
 <FORM id="submitForm" name="opmode" method="POST" action="<% write(action_page); %>" onSubmit="return CheckValue(this)">
 <table><tr><td>
  <% include("op_applicationSelect.asp"); %>
  <% include("op_connectionCtrlinc.asp"); %>
  <TABLE width="100%">
    <TR>
             <TD width="30%" class="column_title"><% iw_webCfgDescHandler( serialApplicationSec, "tcpInactiveTime", "Inactivity time"); %></TD>
             <TD width="70%" colspan="2">
              <input type="text" name="InactivityTime" size="6" maxlength="5" value=""
                    refinput="id_<% write(serialApplicationSec); %>_tcpInactiveTime">
                 <INPUT type="hidden"
                   size="3" maxlength="2"
                     id="id_<% write(serialApplicationSec); %>_tcpInactiveTime"
                  name="iw_<% write(serialApplicationSec); %>_tcpInactiveTime"
               value="<% iw_webCfgValueHandler(serialApplicationSec, "tcpInactiveTime", "0");%>">
                 (0 - 65535 ms)</TD>
         </TR>
         <TR>
             <TD width="30%" class="column_title">
              <% iw_webCfgDescHandler( serialApplicationSec, "TCP_server_data_port", "TCP port"); %>
             </TD>
             <TD width="70%" colspan="2">
              <input type="text" name="TCPDataPort" size="6" maxlength="5" value="4001"
                  refinput="id_<% write(serialApplicationSec); %>_TCP_server_data_port">
                 <INPUT type="hidden"
                   size="3" maxlength="2"
                     id="id_<% write(serialApplicationSec); %>_TCP_server_data_port"
                  name="iw_<% write(serialApplicationSec); %>_TCP_server_data_port"
               value="<% iw_webCfgValueHandler(serialApplicationSec, "TCP_server_data_port", "4001");%>">
             </TD>
         </TR>
         <TR>
             <TD width="30%" class="column_title">
              <% iw_webCfgDescHandler( serialApplicationSec, "TCP_server_cmd_port", "Cmd port"); %>
             </TD>
             <TD width="70%" colspan="2">
              <input type="text" name="TCPCmdPort" size="6" maxlength="5" value="4001"
                  refinput="id_<% write(serialApplicationSec); %>_TCP_server_cmd_port">
                 <INPUT type="hidden"
                   size="3" maxlength="2"
                     id="id_<% write(serialApplicationSec); %>_TCP_server_cmd_port"
                  name="iw_<% write(serialApplicationSec); %>_TCP_server_cmd_port"
               value="<% iw_webCfgValueHandler(serialApplicationSec, "TCP_server_cmd_port", "4001");%>">
             </TD>
         </TR>
         <TR>
             <TD width="30%" valign="top" class="column_title"><% iw_webSysDescHandler( "ConnectionGoesDown", "", "Connection goes down"); %></TD>
             <TD width="70%" colspan="2"> RTS&nbsp;
                 <INPUT type="radio" name="RTSDown" id="RTSDown1" value="ENABLE" refinput="id_<% write(serialConnectionSettings); %>_RTS_off_drop">
                 <label for="RTSDown1">
                     <% iw_webSysDescHandler( "serialAlwaysLow", "", "always low"); %>
                 </label>
                 <INPUT type="radio" name="RTSDown" id="RTSDown0" value="DISABLE" refinput="id_<% write(serialConnectionSettings); %>_RTS_off_drop">
                 <label for="RTSDown0">
                     <% iw_webSysDescHandler( "serialAlwaysHigh", "", "always high"); %>
                 </label>
                 <INPUT type="hidden"
                 id="id_<% write(serialConnectionSettings); %>_RTS_off_drop"
                    name="iw_<% write(serialConnectionSettings); %>_RTS_off_drop"
                    value="<% iw_webCfgValueHandler(serialConnectionSettings, "RTS_off_drop", "DISABLE");%>">
                 <BR>
                 DTR
                 <INPUT type="radio" name="DTRDown" id="DTRDown1" value="ENABLE" refinput="id_<% write(serialConnectionSettings); %>_DTR_off_drop">
                 <label for="DTRDown1">
                     <% iw_webSysDescHandler( "serialAlwaysLow", "", "always low"); %>
                 </label>
                 <INPUT type="radio" name="DTRDown" id="DTRDown0" value="DISABLE" refinput="id_<% write(serialConnectionSettings); %>_DTR_off_drop">
                 <label for="DTRDown0">
                     <% iw_webSysDescHandler( "serialAlwaysHigh", "", "always high"); %>
                 </label>
                 <INPUT type="hidden"
                 id="id_<% write(serialConnectionSettings); %>_DTR_off_drop"
                    name="iw_<% write(serialConnectionSettings); %>_DTR_off_drop"
                    value="<% iw_webCfgValueHandler(serialConnectionSettings, "DTR_off_drop", "DISABLE");%>"></TD>
         </TR>
  </TABLE>
     <% include("op_serialDataPack.asp");%>
     <table id="submitBtnableId" width="100%">
      <tr><td><hr></td></tr>
      <tr><td><INPUT type="submit" value="Submit" name="Submit"></td></tr>
        </table>
  </td></tr></table>
 </FORM>
<script language="JavaScript" src="js/jquery-1.5.2.min.js"></script>
<script type="text/javascript">
	$(document).ready(function () {
		var isEditPermission = !<% iw_websCheckPermission(); %>;
		if (isEditPermission == 0) {
			$(":input").attr('disabled','disabled');
		}
	});
</script>
