<TITLE>RFC2217 Mode</TITLE>
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

     if( !isValidPort(form.TCPDataPort, "TCP port") )
     {
      form.TCPDataPort.focus();
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


 function iw_OnLoad()
        {

                editPermission();

                top.toplogo.location.reload();
        }

 // -->
 </SCRIPT>
</HEAD>
<BODY onload="iw_OnLoad();">
 <H2>Operation Modes<% iw_websGetErrorString(); %></H2>
 <FORM id="submitForm" name="opmode" method="POST" action="<% write(action_page); %>" onSubmit="return CheckValue(this)">
 <table><tr><td>
  <% include("op_applicationSelect.asp");%>
  <TABLE width="100%">
   <TR>
             <TD width="30%" class="column_title">
              <% iw_webCfgDescHandler( serialConnectionSettings, "tcpAliveCheckTimeMin", "TCP alive check time"); %>
             </TD>
             <TD width="70%" colspan="2"><input type="text" name="TCPAliveCheck" size="3" maxlength="2" value="7"
                    refinput="id_<% write(serialConnectionSettings); %>_tcpAliveCheckTimeMin">
                 <INPUT type="hidden"
                   size="3" maxlength="2"
                     id="id_<% write(serialConnectionSettings); %>_tcpAliveCheckTimeMin"
                  name="iw_<% write(serialConnectionSettings); %>_tcpAliveCheckTimeMin"
               value="<% iw_webCfgValueHandler(serialConnectionSettings, "tcpAliveCheckTimeMin", "4");%>">
                 (0 - 99 min)
             </TD>
         </TR>
         <TR>
             <TD width="30%" class="column_title">
              <% iw_webCfgDescHandler( serialApplicationSec, "op_TcpPort", "TCP port"); %>
             </TD>
             <TD width="70%" colspan="2">
              <input type="text" name="TCPDataPort" size="6" maxlength="5" value="4001"
                  refinput="id_<% write(serialApplicationSec); %>_op_TcpPort">
                 <INPUT type="hidden"
                   size="3" maxlength="2"
                     id="id_<% write(serialApplicationSec); %>_op_TcpPort"
                  name="iw_<% write(serialApplicationSec); %>_op_TcpPort"
               value="<% iw_webCfgValueHandler(serialApplicationSec, "op_TcpPort", "4001");%>">
             </TD>
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
