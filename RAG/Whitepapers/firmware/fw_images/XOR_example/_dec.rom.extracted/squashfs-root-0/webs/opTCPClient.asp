<TITLE>TCP Client Mode</TITLE>
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

     if(!form.DelimiterChar1Flag.checked && form.DelimiterChar2Flag.checked)
     {
      alert("Warning: Delimiter 2 is enabled without activating Delimiter 1 first.");
      form.DelimiterChar2.focus();
      return false;
     }

     if( !isValidNumber(form.ForceTxTime, 0, 65535, "Force transmit") ){
      form.ForceTxTime.focus();
      return false;
     }

     if (form.TCPDestHost1.value == "" && form.TCPDestHost2.value == "" && form.TCPDestHost3.value == "" && form.TCPDestHost4.value == "" ) {
      alert("You should at least specify one host to connect.");
      form.TCPDestHost1.focus();
      return false;
     }

     strip_spaces(form.TCPDestHost1);
     strip_spaces(form.TCPDestHost2);
     strip_spaces(form.TCPDestHost3);
     strip_spaces(form.TCPDestHost4);

     if (form.TCPDestHost1.value == "" && form.TCPDestHost2.value == "" && form.TCPDestHost3.value == "" && form.TCPDestHost4.value == "") {
      alert("You should at least specify one host to connect.");
      form.TCPDestHost1.focus();
      return false;
     }


     if( !isValidPort(form.TCPDestPort1, "Destination Port") )
     {
      form.TCPDestPort1.focus();
      return false;
     }

     if( !isValidPort(form.TCPDestPort2, "Destination Port") )
     {
      form.TCPDestPort2.focus();
      return false;
     }

     if( !isValidPort(form.TCPDestPort3, "Destination Port") )
     {
      form.TCPDestPort3.focus();
      return false;
     }

     if( !isValidPort(form.TCPDestPort4, "Destination Port") )
     {
      form.TCPDestPort4.focus();
      return false;
     }

     if( !isValidPortAll(form.TCPLocalPort1, "Designated local Port") )
     {
      form.TCPLocalPort1.focus();
      return false;
     }

     if( !isValidPortAll(form.TCPLocalPort2, "Designated local Port") )
     {
      form.TCPLocalPort2.focus();
      return false;
     }

     if( !isValidPortAll(form.TCPLocalPort3, "Designated local Port") )
     {
      form.TCPLocalPort3.focus();
      return false;
     }

     if( !isValidPortAll(form.TCPLocalPort4, "Designated local Port") )
     {
      form.TCPLocalPort4.focus();
      return false;
     }
   }
   return true;
  }

  function TClientCtrl() {
   if (document.opmode.ConnectionControl.value == "ANY_INACTIVITY_TIME")
    document.opmode.InactivityTime.disabled = false;
   else
    document.opmode.InactivityTime.disabled = true;
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
   TClientCtrl();

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
     <TABLE width=100% align="left">
         <TR>
             <TD width="30%" class="column_title"><% iw_webCfgDescHandler( serialConnectionSettings, "tcpAliveCheckTimeMin", "TCP alive check time"); %></TD>
             <TD width="70%" colspan="2"><input type="text" name="TCPAliveCheck" size="3" maxlength="2" value="7"
                    refinput="id_<% write(serialConnectionSettings); %>_tcpAliveCheckTimeMin">
                 <INPUT type="hidden"
                   size="3" maxlength="2"
                     id="id_<% write(serialConnectionSettings); %>_tcpAliveCheckTimeMin"
                  name="iw_<% write(serialConnectionSettings); %>_tcpAliveCheckTimeMin"
               value="<% iw_webCfgValueHandler(serialConnectionSettings, "tcpAliveCheckTimeMin", "4");%>">
                 (0 - 99 min)</TD>
         </TR>
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
             <TD width="30%" class="column_title"><% iw_webCfgDescHandler( serialConnectionSettings, "skipJammedIP", "Ignore jammed IP"); %></TD>
             <TD width="70%" colspan="2"><INPUT type="radio" name="IgnoreJam" value="ENABLE" id="IgnoreJam1" refinput="id_<% write(serialConnectionSettings); %>_skipJammedIP">
                 <label for="IgnoreJam1">Enable</label>
                 <INPUT type="radio" name="IgnoreJam" value="DISABLE" id="IgnoreJam0" refinput="id_<% write(serialConnectionSettings); %>_skipJammedIP" checked>
                 <label for="IgnoreJam0">Disable</label>
                 &nbsp;
                 <INPUT type="hidden"
                 id="id_<% write(serialConnectionSettings); %>_skipJammedIP"
                    name="iw_<% write(serialConnectionSettings); %>_skipJammedIP"
                    value="<% iw_webCfgValueHandler(serialConnectionSettings, "skipJammedIP", "DISABLE");%>"></TD>
         </TR>
         <TR>
             <TD width="30%" class="column_title"><% iw_webCfgDescHandler( serialConnectionSettings, "allowDriverCtrl", "Allow driver control"); %></TD>
             <TD width="70%" colspan="2"><INPUT type="radio" name="AllowDrvCtrl" value="ENABLE" id="allowdrvctrl1" refinput="id_<% write(serialConnectionSettings); %>_allowDriverCtrl">
                 <label for="allowdrvctrl1">Enable</label>
                 <INPUT type="radio" name="AllowDrvCtrl" value="DISABLE" id="allowdrvctrl0" refinput="id_<% write(serialConnectionSettings); %>_allowDriverCtrl" checked>
                 <label for="allowdrvctrl0">Disable</label>
                 <INPUT type="hidden"
                 id="id_<% write(serialConnectionSettings); %>_allowDriverCtrl"
                    name="iw_<% write(serialConnectionSettings); %>_allowDriverCtrl"
                    value="<% iw_webCfgValueHandler(serialConnectionSettings, "allowDriverCtrl", "DISABLE");%>"></TD>
         </TR>
<!--
          <TR>
                <TD width="30%" class="column_title">
                 <% iw_webCfgDescHandler( serialConnectionSettings, "allowDriverCtrl", "Secure"); %>
                </TD>
                <TD width="70%" colspan="2">
                 <INPUT type="radio" name="SecureMode" value="ENABLE" id="secureMode1" refinput="id_<% write(serialConnectionSettings); %>_secureMode">
                    <label for="secureMode1">Enable</label>
                    <INPUT type="radio" name="SecureMode" value="DISABLE" id="secureMode0" refinput="id_<% write(serialConnectionSettings); %>_secureMode" checked>
                    <label for="secureMode0">Disable</label>
                    <INPUT type="hidden"
                 id="id_<% write(serialConnectionSettings); %>_secureMode"
                    name="iw_<% write(serialConnectionSettings); %>_secureMode"
                    value="<% iw_webCfgValueHandler(serialConnectionSettings, "secureMode", "DISABLE");%>">
                </TD>
            </TR>
-->
   <TR>
    <TD width="30%" class="column_title">
     <% iw_webCfgDescHandler( serialApplicationSec, "ipv4DstHost1", "Destination address"); %> 1
    </TD>
    <TD colspan="2">
        <input type="text" name="TCPDestHost1" size="45" maxlength="40" id="TCPDestHost1"
            refinput="id_<% write(serialApplicationSec); %>_ipv4DstHost1">
        <INPUT type="hidden"
                      id="id_<% write(serialApplicationSec); %>_ipv4DstHost1"
                         name="iw_<% write(serialApplicationSec); %>_ipv4DstHost1"
                         value="<% iw_webCfgValueHandler(serialApplicationSec, "ipv4DstHost1", "");%>">
        <% iw_webCfgDescHandler( serialApplicationSec, "dstPort1", "Port"); %>
        <input type="text" name="TCPDestPort1" size="6" maxlength="5" value=""
          refinput="id_<% write(serialApplicationSec); %>_dstPort1">
        <INPUT type="hidden"
                      id="id_<% write(serialApplicationSec); %>_dstPort1"
                         name="iw_<% write(serialApplicationSec); %>_dstPort1"
                         value="<% iw_webCfgValueHandler(serialApplicationSec, "dstPort1", "4001");%>">
    </TD>
   </TR>
   <TR>
    <TD width="30%" class="column_title">
     <% iw_webCfgDescHandler( serialApplicationSec, "ipv4DstHost2", "Destination address"); %> 2
    </TD>
    <TD colspan="2">
        <input type="text" name="TCPDestHost2" size="45" maxlength="40" id="TCPDestHost2"
            refinput="id_<% write(serialApplicationSec); %>_ipv4DstHost2">
        <INPUT type="hidden"
                      id="id_<% write(serialApplicationSec); %>_ipv4DstHost2"
                         name="iw_<% write(serialApplicationSec); %>_ipv4DstHost2"
                         value="<% iw_webCfgValueHandler(serialApplicationSec, "ipv4DstHost2", "");%>">
           <% iw_webCfgDescHandler( serialApplicationSec, "dstPort2", "Port"); %>
        <input type="text" name="TCPDestPort2" size="6" maxlength="5" value=""
          refinput="id_<% write(serialApplicationSec); %>_dstPort2">
        <INPUT type="hidden"
                      id="id_<% write(serialApplicationSec); %>_dstPort2"
                         name="iw_<% write(serialApplicationSec); %>_dstPort2"
                         value="<% iw_webCfgValueHandler(serialApplicationSec, "dstPort2", "4001");%>">
    </TD>
   </TR>
   <TR>
    <TD width="30%" class="column_title">
     <% iw_webCfgDescHandler( serialApplicationSec, "ipv4DstHost3", "Destination address"); %> 3
    </TD>
    <TD colspan="2">
        <input type="text" name="TCPDestHost3" size="45" maxlength="40" id="TCPDestHost3"
          refinput="id_<% write(serialApplicationSec); %>_ipv4DstHost3">
        <INPUT type="hidden"
                      id="id_<% write(serialApplicationSec); %>_ipv4DstHost3"
                         name="iw_<% write(serialApplicationSec); %>_ipv4DstHost3"
                         value="<% iw_webCfgValueHandler(serialApplicationSec, "ipv4DstHost3", "");%>">
        <% iw_webCfgDescHandler( serialApplicationSec, "dstPort3", "Port"); %>
        <input type="text" name="TCPDestPort3" size="6" maxlength="5" value=""
          refinput="id_<% write(serialApplicationSec); %>_dstPort3">
        <INPUT type="hidden"
                      id="id_<% write(serialApplicationSec); %>_dstPort3"
                         name="iw_<% write(serialApplicationSec); %>_dstPort3"
                         value="<% iw_webCfgValueHandler(serialApplicationSec, "dstPort3", "4001");%>">
    </TD>
   </TR>
   <TR>
    <TD width="30%" class="column_title">
     <% iw_webCfgDescHandler( serialApplicationSec, "ipv4DstHost4", "Destination address"); %> 4
    </TD>
    <TD colspan="2">
     <input type="text" name="TCPDestHost4" size="45" maxlength="40" id="TCPDestHost4"
       refinput="id_<% write(serialApplicationSec); %>_ipv4DstHost4">
     <INPUT type="hidden"
                   id="id_<% write(serialApplicationSec); %>_ipv4DstHost4"
                      name="iw_<% write(serialApplicationSec); %>_ipv4DstHost4"
                      value="<% iw_webCfgValueHandler(serialApplicationSec, "ipv4DstHost4", "");%>">
         <% iw_webCfgDescHandler( serialApplicationSec, "dstPort4", "Port"); %>
         <input type="text" name="TCPDestPort4" size="6" maxlength="5" value=""
       refinput="id_<% write(serialApplicationSec); %>_dstPort4">
     <INPUT type="hidden"
                   id="id_<% write(serialApplicationSec); %>_dstPort4"
                      name="iw_<% write(serialApplicationSec); %>_dstPort4"
                      value="<% iw_webCfgValueHandler(serialApplicationSec, "dstPort4", "4001");%>">
    </TD>
   </TR>
   <TR>
    <TD width="30%" class="column_title">
     <% iw_webCfgDescHandler( serialApplicationSec, "localPort1", "Designated local port"); %> 1
    </TD>
    <TD width="70%" colspan="2">
     <INPUT type="text" name="TCPLocalPort1" size="6" maxlength="5" value=""
      refinput="id_<% write(serialApplicationSec); %>_localPort1">
     <INPUT type="hidden"
         id="id_<% write(serialApplicationSec); %>_localPort1"
            name="iw_<% write(serialApplicationSec); %>_localPort1"
            value="<% iw_webCfgValueHandler(serialApplicationSec, "localPort1", "4001");%>">
    </TD>
   </TR>
   <TR>
    <TD width="30%" class="column_title">
     <% iw_webCfgDescHandler( serialApplicationSec, "localPort2", "Designated local port"); %> 2
    </TD>
    <TD width="70%" colspan="2">
     <INPUT type="text" name="TCPLocalPort2" size="6" maxlength="5" value=""
      refinput="id_<% write(serialApplicationSec); %>_localPort2">
     <INPUT type="hidden"
         id="id_<% write(serialApplicationSec); %>_localPort2"
            name="iw_<% write(serialApplicationSec); %>_localPort2"
            value="<% iw_webCfgValueHandler(serialApplicationSec, "localPort2", "4001");%>">
    </TD>
   </TR>
   <TR>
    <TD width="30%" class="column_title">
     <% iw_webCfgDescHandler( serialApplicationSec, "localPort3", "Designated local port"); %> 3
    </TD>
    <TD width="70%" colspan="2">
     <INPUT type="text" name="TCPLocalPort3" size="6" maxlength="5" value=""
      refinput="id_<% write(serialApplicationSec); %>_localPort3">
     <INPUT type="hidden"
         id="id_<% write(serialApplicationSec); %>_localPort3"
            name="iw_<% write(serialApplicationSec); %>_localPort3"
            value="<% iw_webCfgValueHandler(serialApplicationSec, "localPort3", "4001");%>">
    </TD>
   </TR>
   <TR>
    <TD width="30%" class="column_title">
     <% iw_webCfgDescHandler( serialApplicationSec, "localPort4", "Designated local port"); %> 4
    </TD>
    <TD width="70%" colspan="2">
     <INPUT type="text" name="TCPLocalPort4" size="6" maxlength="5" value=""
      refinput="id_<% write(serialApplicationSec); %>_localPort4">
     <INPUT type="hidden"
         id="id_<% write(serialApplicationSec); %>_localPort4"
            name="iw_<% write(serialApplicationSec); %>_localPort4"
            value="<% iw_webCfgValueHandler(serialApplicationSec, "localPort4", "4001");%>">
    </TD>
   </TR>
   <TR>
    <TD width="30%" class="column_title">Connection control</TD>
    <TD width="70%" colspan="2">
    <select size="1" name="ConnectionControl" onchange="TClientCtrl()"
     refinput="id_<% write(serialApplicationSec); %>_connectionCtrl">
     <option value="STARTUP_NONE">Startup/None</option>
     <option value="ANY_NONE">Any&nbsp;Character/None</option>
     <option value="ANY_INACTIVITY_TIME">Any&nbsp;Character/Inactivity&nbsp;Time</option>
     <option value="DSR_ON_OFF">DSR&nbsp;On/DSR&nbsp;Off</option>
     <option value="DSR_ON_NONE">DSR&nbsp;On/None</option>
     <option value="DCD_ON_OFF">DCD&nbsp;On/DCD&nbsp;Off</option>
     <option value="DCD_ON_NONE">DCD&nbsp;On/None</option>
    </select>
    <INPUT type="hidden"
        id="id_<% write(serialApplicationSec); %>_connectionCtrl"
           name="iw_<% write(serialApplicationSec); %>_connectionCtrl"
           value="<% iw_webCfgValueHandler(serialApplicationSec, "connectionCtrl", "STARTUP_NONE");%>">
    </TD>
   </TR>
  </TABLE>

  <% include("op_serialDataPack.asp");%>

  <table id="submitBtnableId" width="100%">
      <tr><td>
       <hr>
    <INPUT type="submit" value="Submit" name="Submit">
   </td></tr>
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
