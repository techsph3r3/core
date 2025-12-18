<TITLE>Modbus Mode</TITLE>
 <SCRIPT language="JavaScript">
 <!--
  var chk = true;
  var mask = new Object;
  mask.value = new Object;
  mask.value = "255.255.255.0";

  function CheckValue(form)
  {
   if(chk)
   {

     if( !isValidPort(form.ModbusPort, "Modbus listen port") )
     {
      form.ModbusPort.focus();
      return false;
     }
     if( !isValidNumber(form.ModbusSerialTimeout, 300, 120000, "Serial response time-out") )
     {
      form.ModbusSerialTimeout.focus();
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
  <TABLE width="100%">

    <TR>
     <TD width="30%" class="column_title">
      <% iw_webCfgDescHandler( serialApplicationSec, "ModbusPort", "Modbus listen port"); %>
     </TD>
     <TD width="80%" colspan="2">
      <INPUT type="text" name="ModbusPort" size="6" maxlength="5" value=""
       refinput="id_<% write(serialApplicationSec); %>_ModbusPort">
               <INPUT type="hidden"
          id="id_<% write(serialApplicationSec); %>_ModbusPort"
          name="iw_<% write(serialApplicationSec); %>_ModbusPort"
          value="<% iw_webCfgValueHandler(serialApplicationSec, "ModbusPort", "502");%>">
     </TD>
    </TR>
        <TR>
     <TD width="30%" class="column_title">
      <% iw_webCfgDescHandler( serialApplicationSec, "ModbusSerialTimeout", "Serial response time-out"); %>
     </TD>
     <TD width="80%" colspan="2">
      <INPUT type="text" name="ModbusSerialTimeout" size="6" maxlength="6" value=""
       refinput="id_<% write(serialApplicationSec); %>_ModbusSerialTimeout">
               <INPUT type="hidden"
          id="id_<% write(serialApplicationSec); %>_ModbusSerialTimeout"
          name="iw_<% write(serialApplicationSec); %>_ModbusSerialTimeout"
          value="<% iw_webCfgValueHandler(serialApplicationSec, "ModbusSerialTimeout", "3000");%>">
          (300~120000 ms)
     </TD>
    </TR>
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
