<TITLE>UDP Mode</TITLE>
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
      alert("Delimiter Char 2 is enabled without Delimiter Char 1 activated first.");
      form.DelimiterChar2.focus();
      return false;
     }

     if( !isValidNumber(form.ForceTxTime, 0, 65535, "Force transmit") ){
      form.ForceTxTime.focus();
      return false;
     }
     if( form.UDPDestIPBegin1.value.length > 0 )
     {
      if( !verifyIP(form.UDPDestIPBegin1, "Destination IP") )
      {
       form.UDPDestIPBegin1.focus();
       return false;
      }
     }
     form.UDPDestIPEnd1.value = form.UDPDestIPBegin1.value;
     if( form.UDPDestIPBegin1.value == "" && form.UDPDestIPBegin2.value == "" && form.UDPDestIPBegin3.value == "" && form.UDPDestIPBegin4.value == "" )
     {
      alert("You should at least specify a target host.");
      form.UDPDestIPBegin1.focus();
      return false;
     }

     if( form.UDPDestIPBegin1.value == "" && form.UDPDestIPEnd1.value != "" )
     {
      alert("You should speciy a begin address.");
      form.UDPDestIPBegin1.focus();
      return false;
     }

     if( form.UDPDestIPBegin1.value != "" && form.UDPDestIPEnd1.value != "" )
     {
      if(!isSameSubnet(form.UDPDestIPBegin1, mask, form.UDPDestIPEnd1))
      {
       form.UDPDestIPBegin1.focus();
       return false;
      }
     }

     if( form.UDPDestIPBegin1.value.length > 0 )
     {
      if( !verifyIP(form.UDPDestIPBegin1, "Destination IP") )
      {
       form.UDPDestIPBegin1.focus();
       return false;
      }
     }
     if( form.UDPDestIPEnd1.value.length > 0 )
     {
      if( !verifyIP(form.UDPDestIPEnd1, "Destination IP") )
      {
       form.UDPDestIPEnd1.focus();
       return false;
      }
     }

     if( form.UDPDestIPBegin2.value == "" && form.UDPDestIPEnd2.value != "" )
     {
      alert("You should speciy a begin address.");
      form.UDPDestIPBegin2.focus();
      return false;
     }

     if( form.UDPDestIPBegin2.value.length > 0 )
     {
      if( !verifyIP(form.UDPDestIPBegin2, "Destination IP") )
      {
       form.UDPDestIPBegin2.focus();
       return false;
      }
     }
     if( form.UDPDestIPEnd2.value.length > 0 )
     {
      if( !verifyIP(form.UDPDestIPEnd2, "Destination IP") )
      {
       form.UDPDestIPEnd2.focus();
       return false;
      }
     }

     if( form.UDPDestIPBegin2.value != "" && form.UDPDestIPEnd2.value != "" )
     {
      if(!isSameSubnet(form.UDPDestIPBegin2, mask, form.UDPDestIPEnd2))
      {
       form.UDPDestIPBegin2.focus();
       return false;
      }
     }

     if( form.UDPDestIPBegin3.value == "" && form.UDPDestIPEnd3.value != "" )
     {
      alert("You should speciy a begin address.");
      form.UDPDestIPBegin3.focus();
      return false;
     }

     if( form.UDPDestIPBegin3.value.length > 0 )
     {
      if( !verifyIP(form.UDPDestIPBegin3, "Destination IP") )
      {
       form.UDPDestIPBegin3.focus();
       return false;
      }
     }
     if( form.UDPDestIPEnd3.value.length > 0 )
     {
      if( !verifyIP(form.UDPDestIPEnd3, "Destination IP") )
      {
       form.UDPDestIPEnd3.focus();
       return false;
      }
     }

     if( form.UDPDestIPBegin3.value != "" && form.UDPDestIPEnd3.value != "" )
     {
      if(!isSameSubnet(form.UDPDestIPBegin3, mask, form.UDPDestIPEnd3))
      {
       form.UDPDestIPBegin3.focus();
       return false;
      }
     }

     if( form.UDPDestIPBegin4.value == "" && form.UDPDestIPEnd4.value != "" )
     {
      alert("You should speciy a begin address.");
      form.UDPDestIPBegin4.focus();
      return false;
     }

     if( form.UDPDestIPBegin4.value.length > 0 )
     {
      if( !verifyIP(form.UDPDestIPBegin4, "Destination IP") )
      {
       form.UDPDestIPBegin4.focus();
       return false;
      }
     }
     if( form.UDPDestIPEnd4.value.length > 0 )
     {
      if( !verifyIP(form.UDPDestIPEnd4, "Destination IP") )
      {
       form.UDPDestIPEnd4.focus();
       return false;
      }
     }

     if( form.UDPDestIPBegin4.value != "" && form.UDPDestIPEnd4.value != "" )
     {
      if(!isSameSubnet(form.UDPDestIPBegin4, mask, form.UDPDestIPEnd4))
      {
       form.UDPDestIPBegin4.focus();
       return false;
      }
     }
     if( !isValidPort(form.UDPDestPort1, "Destination Port") )
     {
      form.UDPDestPort1.focus();
      return false;
     }

     if( !isValidPort(form.UDPDestPort2, "Destination Port") )
     {
      form.UDPDestPort2.focus();
      return false;
     }

     if( !isValidPort(form.UDPDestPort3, "Destination Port") )
     {
      form.UDPDestPort3.focus();
      return false;
     }

     if( !isValidPort(form.UDPDestPort4, "Destination Port") )
     {
      form.UDPDestPort4.focus();
      return false;
     }
     if( !isValidPort(form.UDPLocalPort, "Local listen port") )
     {
      form.UDPLocalPort.focus();
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
      <% iw_webCfgDescHandler( serialApplicationSec, "ipv4UDPdstBegin1", "Destination address"); %> 1
     </TD>
     <TD width="70%" colspan="2">
      Begin
      <input type="text" name="UDPDestIPBegin1" size="20" maxlength="15" id="UDPDestIPBegin1" id="RasppDestHost1" onKeyUp="ChangeDrvCtl(this);"
        refinput="id_<% write(serialApplicationSec); %>_ipv4UDPdstBegin1">
      <INPUT type="hidden"
                    id="id_<% write(serialApplicationSec); %>_ipv4UDPdstBegin1"
                       name="iw_<% write(serialApplicationSec); %>_ipv4UDPdstBegin1"
                       value="<% iw_webCfgValueHandler(serialApplicationSec, "ipv4UDPdstBegin1", "");%>">
               &nbsp;End
      <input type="text" name="UDPDestIPEnd1" size="20" maxlength="15" id="UDPDestIPEnd1" id="RasppDestHost1" onKeyUp="ChangeDrvCtl(this);"
        refinput="id_<% write(serialApplicationSec); %>_ipv4UDPdstEnd1">
      <INPUT type="hidden"
                    id="id_<% write(serialApplicationSec); %>_ipv4UDPdstEnd1"
                       name="iw_<% write(serialApplicationSec); %>_ipv4UDPdstEnd1"
                       value="<% iw_webCfgValueHandler(serialApplicationSec, "ipv4UDPdstEnd1", "");%>">
               &nbsp;Port
               <INPUT type="text" name="UDPDestPort1" size="6" maxlength="5" value=""
        refinput="id_<% write(serialApplicationSec); %>_UDPdstPort1">
               <INPUT type="hidden"
                    id="id_<% write(serialApplicationSec); %>_UDPdstPort1"
                       name="iw_<% write(serialApplicationSec); %>_UDPdstPort1"
                       value="<% iw_webCfgValueHandler(serialApplicationSec, "UDPdstPort1", "4001");%>">
     </TD>
    </TR>
    <TR>
     <TD width="30%" class="column_title">
      <% iw_webCfgDescHandler( serialApplicationSec, "ipv4UDPdstBegin2", "Destination address"); %> 2
     </TD>
     <TD width="70%" colspan="2">
      Begin
      <input type="text" name="UDPDestIPBegin2" size="20" maxlength="15" id="UDPDestIPBegin2" id="RasppDestHost2" onKeyUp="ChangeDrvCtl(this);"
        refinput="id_<% write(serialApplicationSec); %>_ipv4UDPdstBegin2">
      <INPUT type="hidden"
                    id="id_<% write(serialApplicationSec); %>_ipv4UDPdstBegin2"
                       name="iw_<% write(serialApplicationSec); %>_ipv4UDPdstBegin2"
                       value="<% iw_webCfgValueHandler(serialApplicationSec, "ipv4UDPdstBegin2", "");%>">
               &nbsp;End
      <input type="text" name="UDPDestIPEnd2" size="20" maxlength="15" id="UDPDestIPEnd2" id="RasppDestHost2" onKeyUp="ChangeDrvCtl(this);"
        refinput="id_<% write(serialApplicationSec); %>_ipv4UDPdstEnd2">
      <INPUT type="hidden"
                    id="id_<% write(serialApplicationSec); %>_ipv4UDPdstEnd2"
                       name="iw_<% write(serialApplicationSec); %>_ipv4UDPdstEnd2"
                       value="<% iw_webCfgValueHandler(serialApplicationSec, "ipv4UDPdstEnd2", "");%>">
               &nbsp;Port
               <INPUT type="text" name="UDPDestPort2" size="6" maxlength="5" value=""
        refinput="id_<% write(serialApplicationSec); %>_UDPdstPort2">
               <INPUT type="hidden"
                    id="id_<% write(serialApplicationSec); %>_UDPdstPort2"
                       name="iw_<% write(serialApplicationSec); %>_UDPdstPort2"
                       value="<% iw_webCfgValueHandler(serialApplicationSec, "UDPdstPort2", "4001");%>">
     </TD>
    </TR>
    <TR>
     <TD width="30%" class="column_title">
      <% iw_webCfgDescHandler( serialApplicationSec, "ipv4UDPdstBegin3", "Destination address"); %> 3
     </TD>
     <TD width="70%" colspan="2">
      Begin
      <input type="text" name="UDPDestIPBegin3" size="20" maxlength="15" id="UDPDestIPBegin3" id="RasppDestHost3" onKeyUp="ChangeDrvCtl(this);"
        refinput="id_<% write(serialApplicationSec); %>_ipv4UDPdstBegin3">
      <INPUT type="hidden"
                    id="id_<% write(serialApplicationSec); %>_ipv4UDPdstBegin3"
                       name="iw_<% write(serialApplicationSec); %>_ipv4UDPdstBegin3"
                       value="<% iw_webCfgValueHandler(serialApplicationSec, "ipv4UDPdstBegin3", "");%>">
               &nbsp;End
      <input type="text" name="UDPDestIPEnd3" size="20" maxlength="15" id="UDPDestIPEnd3" id="RasppDestHost3" onKeyUp="ChangeDrvCtl(this);"
        refinput="id_<% write(serialApplicationSec); %>_ipv4UDPdstEnd3">
      <INPUT type="hidden"
                    id="id_<% write(serialApplicationSec); %>_ipv4UDPdstEnd3"
                       name="iw_<% write(serialApplicationSec); %>_ipv4UDPdstEnd3"
                       value="<% iw_webCfgValueHandler(serialApplicationSec, "ipv4UDPdstEnd3", "");%>">
               &nbsp;Port
               <INPUT type="text" name="UDPDestPort3" size="6" maxlength="5" value=""
        refinput="id_<% write(serialApplicationSec); %>_UDPdstPort3">
               <INPUT type="hidden"
                    id="id_<% write(serialApplicationSec); %>_UDPdstPort3"
                       name="iw_<% write(serialApplicationSec); %>_UDPdstPort3"
                       value="<% iw_webCfgValueHandler(serialApplicationSec, "UDPdstPort3", "4001");%>">
     </TD>
    </TR>
    <TR>
     <TD width="30%" class="column_title">
      <% iw_webCfgDescHandler( serialApplicationSec, "ipv4UDPdstBegin4", "Destination address"); %> 4
     </TD>
     <TD width="70%" colspan="2">
      Begin
      <input type="text" name="UDPDestIPBegin4" size="20" maxlength="15" id="UDPDestIPBegin4" id="RasppDestHost4" onKeyUp="ChangeDrvCtl(this);"
        refinput="id_<% write(serialApplicationSec); %>_ipv4UDPdstBegin4">
      <INPUT type="hidden"
                    id="id_<% write(serialApplicationSec); %>_ipv4UDPdstBegin4"
                       name="iw_<% write(serialApplicationSec); %>_ipv4UDPdstBegin4"
                       value="<% iw_webCfgValueHandler(serialApplicationSec, "ipv4UDPdstBegin4", "");%>">
               &nbsp;End
      <input type="text" name="UDPDestIPEnd4" size="20" maxlength="15" id="UDPDestIPEnd4" id="RasppDestHost4" onKeyUp="ChangeDrvCtl(this);"
        refinput="id_<% write(serialApplicationSec); %>_ipv4UDPdstEnd4">
      <INPUT type="hidden"
                    id="id_<% write(serialApplicationSec); %>_ipv4UDPdstEnd4"
                       name="iw_<% write(serialApplicationSec); %>_ipv4UDPdstEnd4"
                       value="<% iw_webCfgValueHandler(serialApplicationSec, "ipv4UDPdstEnd4", "");%>">
               &nbsp;Port
               <INPUT type="text" name="UDPDestPort4" size="6" maxlength="5" value=""
        refinput="id_<% write(serialApplicationSec); %>_UDPdstPort4">
               <INPUT type="hidden"
                    id="id_<% write(serialApplicationSec); %>_UDPdstPort4"
                       name="iw_<% write(serialApplicationSec); %>_UDPdstPort4"
                       value="<% iw_webCfgValueHandler(serialApplicationSec, "UDPdstPort4", "4001");%>">
     </TD>
    </TR>
    <TR>
     <TD width="30%" class="column_title">
      <% iw_webCfgDescHandler( serialApplicationSec, "UDPLocalPort", "Local listen port"); %>
     </TD>
     <TD width="70%" colspan="2">
      <INPUT type="text" name="UDPLocalPort" size="6" maxlength="5" value=""
       refinput="id_<% write(serialApplicationSec); %>_UDPLocalPort">
               <INPUT type="hidden"
          id="id_<% write(serialApplicationSec); %>_UDPLocalPort"
          name="iw_<% write(serialApplicationSec); %>_UDPLocalPort"
          value="<% iw_webCfgValueHandler(serialApplicationSec, "UDPLocalPort", "4001");%>">
     </TD>
    </TR>
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
