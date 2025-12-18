<TITLE>RealCOM Mode</TITLE>
 <SCRIPT language="JavaScript">
 <!--
  var chk = true;
  function ChangeDrvCtl(form) {
   if (document.opmode.RasppDestHost1.value.length >0 && document.opmode.RasppDestHost2.value.length >0) {
    document.opmode.allowdrvctrl1.disabled = false;
    document.opmode.allowdrvctrl0.disabled = false;
   } else{
    document.opmode.allowdrvctrl1.disabled = true;
    document.opmode.allowdrvctrl0.disabled = true;
   }
  }

  function CheckValue(form)
  {
  /*	if(chk) */
   {
     strip_spaces(form.RasppDestHost1);
     strip_spaces(form.RasppDestHost2);

     if (form.RasppDestHost1.value == "" && form.RasppDestHost2.value == "") {
      alert("You should at least specify one host to connect.");
      form.RasppDestHost1.focus();
      return false;
     }

     if( !isValidNumber(form.RasppDestDataPort1, 1, 65535, "Destination TCP port") ){
      form.RasppDestDataPort1.focus();
      return false;
     }

     if( !isValidNumber(form.RasppDestCmdPort1, 1, 65535, "Destination Cmd port") ){
      form.RasppDestCmdPort1.focus();
      return false;
     }

     if( !isValidNumber(form.RasppDestDataPort2, 1, 65535, "Destination TCP port") ){
      form.RasppDestDataPort2.focus();
      return false;
     }

     if( !isValidNumber(form.RasppDestCmdPort2, 1, 65535, "Destination Cmd Port") ){
      form.RasppDestCmdPort2.focus();
      return false;
     }

     if( !isValidNumber(form.RasppLocalDataPort1, 0, 65535, "Designated local TCP port 1") ){
      form.RasppLocalDataPort1.focus();
      return false;
     }

     if( !isValidNumber(form.RasppLocalCmdPort1, 0, 65535, "Designated local cmd port 1") ){
      form.RasppLocalCmdPort1.focus();
      return false;
     }

     if( !isValidNumber(form.RasppLocalDataPort2, 0, 65535, "Designated local TCP port 2") ){
      form.RasppLocalDataPort2.focus();
      return false;
     }

     if( !isValidNumber(form.RasppLocalCmdPort2, 0, 65535, "Designated local cmd port 2") ){
      form.RasppLocalCmdPort2.focus();
      return false;
     }

     if( !isValidNumber(form.TCPAliveCheck, 0, 99, "TCP alive check time") ){
      form.TCPAliveCheck.focus();
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
   if (typeof conn_ctrl != "undefined"){
    if($.isFunction(conn_ctrl) == true){
     conn_ctrl();
    }
   }


                 editPermission();


  }
 // -->
 </SCRIPT>
</HEAD>
<BODY onLoad="iw_onLoad();">
  <H2>Operation Modes<% iw_websGetErrorString(); %></H2>
 <FORM id="submitForm" name="opmode" method="POST" action="<% write(action_page); %>" onSubmit="return CheckValue(this)">
  <% include("op_applicationSelect.asp"); %>
  <TABLE id="opmodeTableId" width="100%" align="left">
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
                  <TD width="30%" class="column_title">
        <% iw_webCfgDescHandler( serialConnectionSettings, "skipJammedIP", "Ignore jammed IP"); %>
      </TD>
                  <TD colspan="2">
                   <INPUT type="radio" name="IgnoreJam" value="ENABLE" id="IgnoreJam1" refinput="id_<% write(serialConnectionSettings); %>_skipJammedIP">
                      <label for="IgnoreJam1">Enable</label>
                      <INPUT type="radio" name="IgnoreJam" value="DISABLE" id="IgnoreJam0" refinput="id_<% write(serialConnectionSettings); %>_skipJammedIP" checked>
                      <label for="IgnoreJam0">Disable</label>
                      &nbsp;
                      <INPUT type="hidden"
                   id="id_<% write(serialConnectionSettings); %>_skipJammedIP"
                      name="iw_<% write(serialConnectionSettings); %>_skipJammedIP"
                      value="<% iw_webCfgValueHandler(serialConnectionSettings, "skipJammedIP", "DISABLE");%>">
                  </TD>
              </TR>
              <TR>
                  <TD width="30%" class="column_title">
                   <% iw_webCfgDescHandler( serialConnectionSettings, "allowDriverCtrl", "Allow driver control"); %>
                  </TD>
                  <TD colspan="2">
                   <INPUT type="radio" name="AllowDrvCtrl" value="ENABLE" id="allowdrvctrl1" refinput="id_<% write(serialConnectionSettings); %>_allowDriverCtrl">
                      <label for="allowdrvctrl1">Enable</label>
                      <INPUT type="radio" name="AllowDrvCtrl" value="DISABLE" id="allowdrvctrl0" refinput="id_<% write(serialConnectionSettings); %>_allowDriverCtrl" checked>
                      <label for="allowdrvctrl0">Disable</label>
                      <INPUT type="hidden"
                   id="id_<% write(serialConnectionSettings); %>_allowDriverCtrl"
                      name="iw_<% write(serialConnectionSettings); %>_allowDriverCtrl"
                      value="<% iw_webCfgValueHandler(serialConnectionSettings, "allowDriverCtrl", "DISABLE");%>">
      </TD>
              </TR>
<!-- <TR>
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
        <% iw_webCfgDescHandler( serialApplicationSec, "ipv4RRC_dstHost2", "Destination address"); %> 1
       </TD>
       <TD colspan="2">
        <TABLE>
         <TR>
          <TD width=45% rowspan=2>
           <input type="text" name="RasppDestHost1" size="45" maxlength="40"
             id="RasppDestHost1" onKeyUp="ChangeDrvCtl(this);"
             refinput="id_<% write(serialApplicationSec); %>_ipv4RRC_dstHost1">
           <INPUT type="hidden"
                         id="id_<% write(serialApplicationSec); %>_ipv4RRC_dstHost1"
                            name="iw_<% write(serialApplicationSec); %>_ipv4RRC_dstHost1"
                            value="<% iw_webCfgValueHandler(serialApplicationSec, "ipv4RRC_dstHost1", "");%>">
          </TD>
          <TD>
           &nbsp;
           <% iw_webCfgDescHandler( serialApplicationSec, "RRC_dstDataPort1", "TCP port"); %>
           &nbsp;&nbsp;
           <INPUT type="text" name="RasppDestDataPort1" size="6" maxlength="5" value="63950"
             refinput="id_<% write(serialApplicationSec); %>_RRC_dstDataPort1">
           <INPUT type="hidden"
                         id="id_<% write(serialApplicationSec); %>_RRC_dstDataPort1"
                            name="iw_<% write(serialApplicationSec); %>_RRC_dstDataPort1"
                            value="<% iw_webCfgValueHandler(serialApplicationSec, "RRC_dstDataPort1", "63950");%>">
          </TD>
         </TR>
         <TR>
          <TD>
           &nbsp;
           <% iw_webCfgDescHandler( serialApplicationSec, "RRC_dstCmdPort1", "Cmd port"); %>
           &nbsp;
           <INPUT type="text" name="RasppDestCmdPort1" size="6" maxlength="5" value="63966"
             refinput="id_<% write(serialApplicationSec); %>_RRC_dstCmdPort1">
           <INPUT type="hidden"
                         id="id_<% write(serialApplicationSec); %>_RRC_dstCmdPort1"
                            name="iw_<% write(serialApplicationSec); %>_RRC_dstCmdPort1"
                            value="<% iw_webCfgValueHandler(serialApplicationSec, "RRC_dstCmdPort1", "63966");%>">
          </TD>
         </TR>
        </TABLE>
       </TD>
      </TR>
      <TR>
       <TD width="30%" class="column_title">
        <% iw_webCfgDescHandler( serialApplicationSec, "ipv4RRC_dstHost2", "Destination address"); %> 2
       </TD>
       <TD colspan="2">
        <TABLE>
         <TR>
          <TD width=45% rowspan=2>
           <input type="text" name="RasppDestHost2" size="45" maxlength="40"
             id="RasppDestHost2" onKeyUp="ChangeDrvCtl(this);"
             refinput="id_<% write(serialApplicationSec); %>_ipv4RRC_dstHost2">
           <INPUT type="hidden"
                         id="id_<% write(serialApplicationSec); %>_ipv4RRC_dstHost2"
                            name="iw_<% write(serialApplicationSec); %>_ipv4RRC_dstHost2"
                            value="<% iw_webCfgValueHandler(serialApplicationSec, "ipv4RRC_dstHost2", "");%>">
          </TD>
          <TD>
           &nbsp;
           <% iw_webCfgDescHandler( serialApplicationSec, "RRC_dstDataPort1", "TCP port"); %>
           &nbsp;&nbsp;
           <INPUT type="text" name="RasppDestDataPort2" size="6" maxlength="5" value="63950"
             refinput="id_<% write(serialApplicationSec); %>_RRC_dstDataPort2">
           <INPUT type="hidden"
                         id="id_<% write(serialApplicationSec); %>_RRC_dstDataPort2"
                            name="iw_<% write(serialApplicationSec); %>_RRC_dstDataPort2"
                            value="<% iw_webCfgValueHandler(serialApplicationSec, "RRC_dstDataPort2", "63950");%>">
          </TD>
         </TR>
         <TR>
          <TD>
           &nbsp;
           <% iw_webCfgDescHandler( serialApplicationSec, "RRC_dstCmdPort1", "Cmd port"); %>
           &nbsp;
           <INPUT type="text" name="RasppDestCmdPort2" size="6" maxlength="5" value="63966"
             refinput="id_<% write(serialApplicationSec); %>_RRC_dstCmdPort2">
           <INPUT type="hidden"
                         id="id_<% write(serialApplicationSec); %>_RRC_dstCmdPort2"
                            name="iw_<% write(serialApplicationSec); %>_RRC_dstCmdPort2"
                            value="<% iw_webCfgValueHandler(serialApplicationSec, "RRC_dstCmdPort2", "63966");%>">
          </TD>
         </TR>
        </TABLE>
       </TD>
     </TR>
    <TR>
     <TD width="30%" class="column_title">
      <% iw_webCfgDescHandler( serialApplicationSec, "RRC_localData_port1", "Designated local TCP port "); %> 1
     </TD>
     <TD colspan="2">
      <INPUT type="text" name="RasppLocalDataPort1"
       size="6" maxlength="5" value="0"
       refinput="id_<% write(serialApplicationSec); %>_RRC_localData_port1">
      <INPUT type="hidden"
                   id="id_<% write(serialApplicationSec); %>_RRC_localData_port1"
                      name="iw_<% write(serialApplicationSec); %>_RRC_localData_port1"
                      value="<% iw_webCfgValueHandler(serialApplicationSec, "RRC_localData_port1", "0");%>">
     </TD>
    </TR>
    <TR>
     <TD width="30%" class="column_title">
      <% iw_webCfgDescHandler( serialApplicationSec, "RRC_localCmd_port1", "Designated local cmd port "); %> 1
     </TD>
     <TD colspan="2">
      <INPUT type="text" name="RasppLocalDataPort1"
       size="6" maxlength="5" value="0"
       refinput="id_<% write(serialApplicationSec); %>_RRC_localCmd_port1">
      <INPUT type="hidden"
                   id="id_<% write(serialApplicationSec); %>_RRC_localCmd_port1"
                      name="iw_<% write(serialApplicationSec); %>_RRC_localCmd_port1"
                      value="<% iw_webCfgValueHandler(serialApplicationSec, "RRC_localCmd_port1", "0");%>">
     </TD>
    </TR>
    <TR>
     <TD width="30%" class="column_title">
      <% iw_webCfgDescHandler( serialApplicationSec, "RRC_localData_port1", "Designated local TCP port "); %> 2
     </TD>
     <TD colspan="2">
      <INPUT type="text" name="RasppLocalDataPort2"
       size="6" maxlength="5" value="0"
       refinput="id_<% write(serialApplicationSec); %>_RRC_localData_port2">
      <INPUT type="hidden"
                   id="id_<% write(serialApplicationSec); %>_RRC_localData_port2"
                      name="iw_<% write(serialApplicationSec); %>_RRC_localData_port2"
                      value="<% iw_webCfgValueHandler(serialApplicationSec, "RRC_localData_port2", "0");%>">
     </TD>
    </TR>
    <TR>
     <TD width="30%" class="column_title">
      <% iw_webCfgDescHandler( serialApplicationSec, "RRC_localCmd_port1", "Designated local cmd port "); %> 2
     </TD>
     <TD colspan="2">
      <INPUT type="text" name="RasppLocalCmdPort2"
       size="6" maxlength="5" value="0"
       refinput="id_<% write(serialApplicationSec); %>_RRC_localCmd_port2">
      <INPUT type="hidden"
                   id="id_<% write(serialApplicationSec); %>_RRC_localCmd_port2"
                      name="iw_<% write(serialApplicationSec); %>_RRC_localCmd_port2"
                      value="<% iw_webCfgValueHandler(serialApplicationSec, "RRC_localCmd_port2", "0");%>">
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
