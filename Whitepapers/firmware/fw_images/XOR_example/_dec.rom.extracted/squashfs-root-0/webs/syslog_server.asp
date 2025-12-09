<HTML>
<HEAD>
 <META http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
    <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate" />
    <meta http-equiv="Pragma" content="no-cache" />
    <meta http-equiv="Expires" content="0" />
 <LINK href="nport2g.css" rel="stylesheet" type="text/css">
 <TITLE><% iw_webSysDescHandler("SysLogServerTree", "", "Syslog Server Settings"); %></TITLE>
 <% iw_webJSList_get(); %>
 <script type="text/javascript">
 <!--
  function CheckValue(form)
  {

   if(!isValidPort(form.iw_sysLogSrv1_port, "Syslog port"))
   {
    form.iw_sysLogSrv1_port.focus();
    return false;
   }
   if(!isValidPort(form.iw_sysLogSrv2_port, "Syslog port"))
   {
    form.iw_sysLogSrv2_port.focus();
    return false;
   }
   if(!isValidPort(form.iw_sysLogSrv3_port, "Syslog port"))
   {
    form.iw_sysLogSrv3_port.focus();
    return false;
   }
   return true;
  }


  function editPermission()
  {
   var form = document.trap_set, i, j = <% iw_websCheckPermission(); %>;
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
 <H2><% iw_webSysDescHandler("SysLogServerTree", "", "Syslog Server Settings"); %> <% iw_websGetErrorString(); %></H2>
 <FORM name="trap_set" method="POST" action="/forms/iw_webSetParameters" onSubmit="return CheckValue(this)">
  <TABLE width="100%">
   <TR>
    <TD width="25%" class="column_title"><% iw_webCfgDescHandler("sysLogSrv1", "logSrv", "Syslog Server"); %> 1</TD>
    <TD width="75%">
     <INPUT type="text" id="iw_sysLogSrv1_logSrv" name="iw_sysLogSrv1_logSrv" size="44" maxlength="39" value = "<% iw_webCfgValueHandler("sysLogSrv1", "logSrv", ""); %>">
    </TD>
   </TR>
   <TR>
    <TD width="25%" class="column_title"><% iw_webCfgDescHandler("sysLogSrv1", "port", "Syslog port"); %></TD>
    <TD width="75%">
     <INPUT type="text" id="iw_sysLogSrv1_port" name="iw_sysLogSrv1_port" size="8" maxlength="5" value = "<% iw_webCfgValueHandler("sysLogSrv1", "port", ""); %>">
    </TD>
   </TR>
   <TR>
    <TD width="25%" class="column_title"><% iw_webCfgDescHandler("sysLogSrv2", "logSrv", "Syslog Server"); %> 2</TD>
    <TD width="75%">
     <INPUT type="text" id="iw_sysLogSrv2_logSrv" name="iw_sysLogSrv2_logSrv" size="44" maxlength="39" value = "<% iw_webCfgValueHandler("sysLogSrv2", "logSrv", ""); %>">
    </TD>
   </TR>
   <TR>
    <TD width="25%" class="column_title"><% iw_webCfgDescHandler("sysLogSrv2", "port", "Syslog port"); %></TD>
    <TD width="75%">
     <INPUT type="text" id="iw_sysLogSrv2_port" name="iw_sysLogSrv2_port" size="8" maxlength="5" value = "<% iw_webCfgValueHandler("sysLogSrv2", "port", ""); %>">
    </TD>
   </TR>
   <TR>
    <TD width="25%" class="column_title"><% iw_webCfgDescHandler("sysLogSrv3", "logSrv", "Syslog Server"); %> 3</TD>
    <TD width="75%">
     <INPUT type="text" id="iw_sysLogSrv3_logSrv" name="iw_sysLogSrv3_logSrv" size="44" maxlength="39" value = "<% iw_webCfgValueHandler("sysLogSrv3", "logSrv", ""); %>">
    </TD>
   </TR>
   <TR>
    <TD width="25%" class="column_title"><% iw_webCfgDescHandler("sysLogSrv3", "port", "Syslog port"); %></TD>
    <TD width="75%">
     <INPUT type="text" id="iw_sysLogSrv3_port" name="iw_sysLogSrv3_port" size="8" maxlength="5" value = "<% iw_webCfgValueHandler("sysLogSrv3", "port", ""); %>">
    </TD>
   </TR>
  </TABLE><hr>
  <INPUT type="submit" value="Submit" name="Submit">
  <Input type="hidden" name="bkpath" value="/syslog_server.asp">
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
