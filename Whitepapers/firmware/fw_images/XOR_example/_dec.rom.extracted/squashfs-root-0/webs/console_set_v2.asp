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
 var mem_state = <% iw_websMemoryChange(); %>;
 var httpsEnable = 0, moxaService = 0;

 function iw_checkRemoteAccess()
 {
  var form = document.console;
  var idx, miscEnable = 0, ifaceEnable = 0;

  for(idx = 0; idx < form.length; idx++)
  {
   if(form.elements[idx].type != "checkbox")
    continue;

   if ( form.elements[idx].id.match(/.*misc.*/) )
   {
    if(form.elements[idx].checked)
     miscEnable = 1;
   } else if( form.elements[idx].id.match(/.*webEnable.*/)
        || form.elements[idx].id.match(/.*WebEnable.*/) )
   {
    if( form.elements["misc_webEnable"].checked
     && form.elements[idx].checked )
     ifaceEnable = 1;
   } else if( form.elements[idx].id.match(/.*httpsEnable.*/)
        || form.elements[idx].id.match(/.*HttpsEnable.*/) )
   {
    if( form.elements["misc_httpsEnable"].checked
     && form.elements[idx].checked )
     {
      ifaceEnable = 1;
      httpsEnable = 1;
     }
   } else if( form.elements[idx].id.match(/.*telnetEnable.*/)
        || form.elements[idx].id.match(/.*TelnetEnable.*/) )
   {
    if( form.elements["misc_telnetEnable"].checked
     && form.elements[idx].checked )
     ifaceEnable = 1;
   } else if( form.elements[idx].id.match(/.*sshEnable.*/)
        || form.elements[idx].id.match(/.*SshEnable.*/) )
   {
    if( form.elements["misc_sshEnable"].checked
     && form.elements[idx].checked )
     ifaceEnable = 1;
   } else if( form.elements[idx].id.match(/.*moxaServiceEnable.*/)
        || form.elements[idx].id.match(/.*MoxaServiceEnable.*/) )
   {
    if( form.elements["misc_moxaServiceEnable"].checked
     && form.elements[idx].checked )
     {
      ifaceEnable = 1;
      moxaService = 1;
     }
   }
  }

  if(miscEnable == 0 || ifaceEnable == 0)
   return confirm("Warning! This device cannot be accessed remotely!");

  return true;
 }

 function iw_checkMoxaSevicesAccess()
 {
  var form = document.console;

  if( form.elements["misc_moxaServiceEnable"].checked
   && !form.elements["misc_httpsEnable"].checked)
   return confirm("Warning! Some features of Moxa services will not work if HTTPS is disabled.");

  if(httpsEnable == 0 && moxaService == 1)
   return confirm("Warning! Some features of Moxa services will not work if HTTPS is disabled.");

  return true;
 }

 function iw_onSubmit(form)
 {
  var idx;

  if( iw_checkRemoteAccess() == false )
   return false;

  if( iw_checkMoxaSevicesAccess() == false )
   return false;

  for(idx = 0; idx < form.length; idx++)
  {
   if(form.elements[idx].type != "checkbox")
    continue;

   if ( form.elements[idx].id.match(/.*Enable.*/)
     || form.elements[idx].id.match(/.*active.*/) )
   {
    if(form.elements[idx].checked)
     form.elements["iw_" + form.elements[idx].id].value = "ENABLE";
    else
     form.elements["iw_" + form.elements[idx].id].value = "DISABLE";
   } else
   {
    /* Exception */
    if( form.elements[idx].id.match("trapSnmp_enable") )
     if( form.elements[idx].checked )
      form.elements["iw_trapSnmp_enable"].value = "ENABLE";
     else
      form.elements["iw_trapSnmp_enable"].value = "DISABLE";
   }
  }
 }

 function editPermission()
 {
  var form = document.console, i, j = <% iw_websCheckPermission(); %>;
  if(j)
  {
   for(i = 0; i < form.length; i++)
    form.elements[i].disabled = true;
  }
 }

 function iw_onChange()
 {
  var idx;
  var form = document.console;

  for(idx = 0; idx < form.length; idx++)
  {
   if(form.elements[idx].type != "checkbox")
    continue;

   if(form.elements[idx].id.match(/.*WebEnable.*/))
    form.elements[idx].disabled = (form.elements["misc_webEnable"].checked) ? false : true;

   if(form.elements[idx].id.match(/.*HttpsEnable.*/))
    form.elements[idx].disabled = (form.elements["misc_httpsEnable"].checked) ? false : true;

   if(form.elements[idx].id.match(/.*TelnetEnable.*/))
    form.elements[idx].disabled = (form.elements["misc_telnetEnable"].checked) ? false : true;

   if(form.elements[idx].id.match(/.*SshEnable.*/))
    form.elements[idx].disabled = (form.elements["misc_sshEnable"].checked) ? false : true;

   if(form.elements[idx].id.match(/.*SnmpEnable.*/))
    form.elements[idx].disabled = (form.elements["trapSnmp_enable"].checked) ? false : true;

   if(form.elements[idx].id.match(/.*MoxaServiceEnable.*/))
    form.elements[idx].disabled = (form.elements["misc_moxaServiceEnable"].checked) ? false : true;
  }
 }

 function iw_onChange_accessibleNet()
 {
  if( document.getElementById("iw_accessibleNet_En").checked )
   document.getElementById("area_accessibleNet").style.display = "";
  else
      document.getElementById("area_accessibleNet").style.display = "none";
 }

 function iw_onLoad_accessibleNet()
 {
  var form = document.console;
  if( "<% iw_webCfgValueHandler("consolesAccessibleNet", "enable", ""); %>" == "ENABLE" )
  {
   form.iw_accessibleNet_En.checked = true;
  }else
  {
   form.iw_accessibleNet_Dis.checked = true;
  }
  iw_selectSet(document.console.iw_consolesAccessibleNet_policy, "<% iw_webCfgValueHandler("consolesAccessibleNet", "policy", ""); %>");

 }

 function iw_ChangeOnLoad()
 {
  iw_onChange();
  iw_onLoad_accessibleNet();
  iw_onChange_accessibleNet();
  editPermission();
  top.toplogo.location.reload();
 }



  //-->
  </SCRIPT>
</HEAD>
<BODY onLoad="iw_ChangeOnLoad();">
  <H2><% iw_webSysDescHandler("ConsoleSettingTree", "", "Console Settings"); %> <% iw_websGetErrorString(); %></H2>
  <FORM name="console" method="POST" action="/forms/iw_webSetParameters" onSubmit="return iw_onSubmit(this);">
  <TABLE>
    <TR>
      <TD width="30%" class="column_title"><% iw_webCfgDescHandler("misc", "autoLogoutTimeout", "Auto logout--"); %></TD>
   <TD width="70%">
        <INPUT type="text" id="iw_misc_autoLogoutTimeout" name="iw_misc_autoLogoutTimeout" size="5" maxlength="2" value="<% iw_webCfgValueHandler("misc", "autoLogoutTimeout", ""); %>" /> (1 to 60 minutes)
      </TD>
  </TABLE>
  <br />
  <h2>Accessible Interfaces</h2>
  <% iw_webGetConsoleSettings(); %>
  * If you disable all access portals, you will not be able to remotely access this device.<br/>
  * If you disable HTTPS, some Moxa service features will be disabled. <br/>
  <br/>
  <h2>Accessible Net List</h2>
  <TABLE width="100%">
 <TR>
   <TD width="30%" class="column_title"><% iw_webCfgDescHandler("consolesAccessibleNet", "enable", ""); %></TD>
   <TD width="70%">
   <INPUT type="radio" name="iw_consolesAccessibleNet_enable" id="iw_accessibleNet_En" value="ENABLE" onclick='iw_onChange_accessibleNet();' />
   <label for="iw_accessibleNet_En">Enable</label>
   <input type="radio" name="iw_consolesAccessibleNet_enable" id="iw_accessibleNet_Dis" value="DISABLE" onclick='iw_onChange_accessibleNet();' />
   <label for="iw_accessibleNet_Dis">Disable</label>
  </td>
 </TR>
  </TABLE width="100%">
  <DIV id="area_accessibleNet" style="display:none;">
  <TABLE width="100%">
   <TR>
   <TD width="30%" class="column_title"><% iw_webCfgDescHandler("consolesAccessibleNet", "policy", ""); %></TD>
   <TD width="70%">
     <SELECT size="1" id="iw_consolesAccessibleNet_policy" name="iw_consolesAccessibleNet_policy">
       <option value="ACCEPT">Accept</option>
       <option value="DROP">Drop</option>
    </SELECT>
   </TD>
 </TR>
  <TABLE>
  </TABLE>
  <% iw_webGetConsoleAccessibleIPList(); %>
  </DIV>
  <TABLE width="100%">
    <TR>
      <TD colspan="2">
    <HR>
      <INPUT type="submit" value="Submit" name="Submit">
      <Input type="hidden" name="bkpath" value="/console_set_v2.asp">
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
