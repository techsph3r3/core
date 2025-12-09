<TITLE>RealCOM Mode</TITLE>
<script language="JavaScript">
 <!--
  var chk = true;
  function CheckValue(form)
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
   return true;
  }

  function iw_onChange(el){
   if (typeof conn_ctrl != "undefined"){
    if($.isFunction(conn_ctrl) == true){
     conn_ctrl();
    }
   }
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
 </script>
</HEAD>
<BODY onLoad="iw_onLoad();">
 <H2>Operation Modes<% iw_websGetErrorString(); %></H2>
 <FORM id="submitForm" name="opmode" method="POST" action="<% write(action_page); %>" onSubmit="return CheckValue(this)">
    <table><tr><td>
     <% include("op_applicationSelect.asp"); %>
  <% include("op_connectionCtrlinc.asp"); %>
     <TABLE width=100% align="left">
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
