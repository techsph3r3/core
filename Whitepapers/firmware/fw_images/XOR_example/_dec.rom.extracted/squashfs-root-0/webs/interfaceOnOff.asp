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

  function editPermission()
  {
   var form = document.interfaceOnOff, i, j = <% iw_websCheckPermission(); %>;
   if(j)
   {
    for(i = 0; i < form.length; i++)
     form.elements[i].disabled = true;
   }
  }


  function iw_checkinterface()
  {
   var form = document.interfaceOnOff;

   if (

    form.elements["iw_lanEnable_Dis"].checked






      )
    return confirm("If you disable all interface(s), you will not be able to remotely access this device.");

   return true;
  }

  function iw_onSubmit(form)
  {
   if (iw_checkinterface() == false)
    return false;
  }

         var mem_state = <% iw_websMemoryChange(); %>;
               function iw_ChangeOnLoad()
               {

                        if( "<% iw_webCfgValueHandler("misc", "lanEnable", "ENABLE"); %>" == "ENABLE" )
                        {
                                document.interfaceOnOff.iw_lanEnable_En.checked = true;
                        }else
                        {
                                document.interfaceOnOff.iw_lanEnable_Dis.checked = true;
                        }
                 editPermission();

                        top.toplogo.location.reload();
               }

 //-->
 </SCRIPT>
</HEAD>
<BODY onLoad="iw_ChangeOnLoad();">
 <H2><% iw_webSysDescHandler("InterfaceOnOffTree", "", "Interface On/Off"); %> <% iw_websGetErrorString(); %></H2>
 <FORM name="interfaceOnOff" method="POST" action="/forms/iw_webSetParameters" onSubmit="return iw_onSubmit(this);">
  <TABLE width=100%>

   <TR>
    <TD width="30%" class="column_title"><% iw_webCfgDescHandler("misc", "lanEnable", ""); %></TD>
    <TD width="70%">
     <INPUT type="radio" name="iw_misc_lanEnable" id="iw_lanEnable_En" value="ENABLE" />
     <LABEL for="iw_lanEnable_En">Enable</LABEL>
     <INPUT type="radio" name="iw_misc_lanEnable" id="iw_lanEnable_Dis" value="DISABLE" />
     <LABEL for="iw_lanEnable_Dis">Disable</LABEL>
    </TD>
   </TR>
   <TR>
    <TD colspan="2">
    <HR>
    <INPUT type="submit" value="Submit" name="Submit">
    <Input type="hidden" name="bkpath" value="/interfaceOnOff.asp">
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
