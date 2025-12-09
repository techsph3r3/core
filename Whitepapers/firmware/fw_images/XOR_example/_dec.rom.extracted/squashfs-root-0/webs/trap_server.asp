<HTML>
<HEAD>
 <META http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
    <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate" />
    <meta http-equiv="Pragma" content="no-cache" />
    <meta http-equiv="Expires" content="0" />
 <LINK href="nport2g.css" rel="stylesheet" type="text/css">
 <TITLE><% iw_webSysDescHandler("TrapSetingsTree", "", "SNMP Trap Receiver Settings"); %></TITLE>
 <% iw_webJSList_get(); %>
 <script type="text/javascript">
 <!--
  function CheckValue(form)
  {
   return true;
  }
        function iw_trap_setOnLoad()
         {
              iw_selectSet(document.trap_set.iw_trapSnmp_firstTrapVer, "<% iw_webCfgValueHandler("trapSnmp", "firstTrapVer", "V1"); %>");
              iw_selectSet(document.trap_set.iw_trapSnmp_secondTrapVer, "<% iw_webCfgValueHandler("trapSnmp", "secondTrapVer", "V1"); %>");
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
<BODY onLoad="iw_trap_setOnLoad();iw_ChangeOnLoad();">
 <H2><% iw_webSysDescHandler("TrapSetingsTree", "", "SNMP Trap Receiver Settings"); %> <% iw_websGetErrorString(); %></H2>
 <FORM name="trap_set" method="POST" action="/forms/iw_webSetParameters" onSubmit="return CheckValue(this)">
  <TABLE width="100%">
   <TR>
    <TD width="25%" class="column_title"><% iw_webCfgDescHandler("trapSnmp", "firstTrapVer", "1st Trap version"); %></TD>
    <TD width="75%">
    <SELECT size="1" id="iw_trapSnmp_firstTrapVer" name="iw_trapSnmp_firstTrapVer">
                <option value="V1">V1</option>
                <option value="V2">V2</option>
               </SELECT>
    </TD>
   </TR>
   <TR>
    <TD width="25%" class="column_title"><% iw_webCfgDescHandler("trapSnmp", "firstTrapSrv", "Primary trap server"); %></TD>
    <TD width="75%">
     <INPUT type="text" id="iw_trapSnmp_firstTrapSrv" name="iw_trapSnmp_firstTrapSrv" size="44" maxlength="39" value = "<% iw_webCfgValueHandler("trapSnmp", "firstTrapSrv", ""); %>">
    </TD>
   </TR>
   <TR>
    <TD width="25%" class="column_title"><% iw_webCfgDescHandler("trapSnmp", "firstTrapCommunity", "Primary trap community"); %></TD>
    <TD width="75%">
     <INPUT type="text" id="iw_trapSnmp_firstTrapCommunity" name="iw_trapSnmp_firstTrapCommunity" size="36" maxlength="31" value = "<% iw_webCfgValueHandler("trapSnmp", "firstTrapCommunity", ""); %>">
    </TD>
   </TR>
   <TR>
    <TD width="25%" class="column_title"><% iw_webCfgDescHandler("trapSnmp", "secondTrapVer", "2nd Trap version"); %></TD>
    <TD width="75%">
    <SELECT size="1" id="iw_trapSnmp_secondTrapVer" name="iw_trapSnmp_secondTrapVer">
                <option value="V1">V1</option>
                <option value="V2">V2</option>
               </SELECT>
    </TD>
   </TR>
   <TR>
    <TD width="25%" class="column_title"><% iw_webCfgDescHandler("trapSnmp", "secondTrapSrv", "Secondary trap server"); %></TD>
    <TD width="75%">
     <INPUT type="text" id="iw_trapSnmp_secondTrapSrv" name="iw_trapSnmp_secondTrapSrv" size="44" maxlength="39" value = "<% iw_webCfgValueHandler("trapSnmp", "secondTrapSrv", ""); %>">
    </TD>
   </TR>
   <TR>
    <TD width="25%" class="column_title"><% iw_webCfgDescHandler("trapSnmp", "secondTrapCommunity", "Secondary trap community"); %></TD>
    <TD width="75%">
     <INPUT type="text" id="iw_trapSnmp_secondTrapCommunity" name="iw_trapSnmp_secondTrapCommunity" size="36" maxlength="31" value = "<% iw_webCfgValueHandler("trapSnmp", "secondTrapCommunity", ""); %>">
    </TD>
   </TR>
   <TR>
    <TD colspan="2"><HR>
     <INPUT type="submit" name="Submit" value="Submit">
     <Input type="hidden" name="bkpath" value="/trap_server.asp">
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
