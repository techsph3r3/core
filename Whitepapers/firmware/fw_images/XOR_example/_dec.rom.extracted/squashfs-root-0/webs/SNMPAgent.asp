<HTML>
<HEAD>
 <META http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
    <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate" />
    <meta http-equiv="Pragma" content="no-cache" />
    <meta http-equiv="Expires" content="0" />
 <LINK href="nport2g.css" rel="stylesheet" type="text/css">
 <TITLE>SNMP Agent Configuration</TITLE>
 <% iw_webJSList_get(); %>
 <script type="text/javascript">
 <!--
  var passlen = <% iw_webGetPasswordLength(); %>;
  function CheckValue(form)
  {
   if( document.getElementById("iw_trapSnmp_enable").selectedIndex != 0 )
   {
    return true;
   }
       if( form.iw_trapSnmp_ro_community.value.length == 0 )
       {
    alert("Read community cannot be empty.");
    form.iw_trapSnmp_ro_community.focus();
                    return false;
                     }
   if(form.iw_trapSnmp_ro_community.disabled == false && !isAlphaNumericString(form.iw_trapSnmp_ro_community.value))
   {
    window.alert("Invalid input: \"Read community\".\nThe string contains illegal characters.");
    form.iw_trapSnmp_ro_community.focus();
    return false;
   }
       if( form.iw_trapSnmp_rw_community.value.length == 0 )
       {
    alert("Write community cannot be empty.");
    form.iw_trapSnmp_rw_community.focus();
                    return false;
                     }
   if(form.iw_trapSnmp_rw_community.disabled == false && !isAlphaNumericString(form.iw_trapSnmp_rw_community.value))
   {
    window.alert("Invalid input: \"Write community\".\nThe string contains illegal characters.");
    form.iw_trapSnmp_rw_community.focus();
    return false;
   }
   if(form.iw_trapSnmp_adminKey.disabled == false && form.iw_trapSnmp_adminKey.value.length < 8)
   {
    window.alert("Key must be at least 8 bytes.");
    form.iw_trapSnmp_adminKey.focus();
    return false;
   }
   if((document.getElementById("iw_trapSnmp_version").selectedIndex == 2) && (document.getElementById("iw_trapSnmp_adminAuthType").selectedIndex != 0) && (passlen < 8))
   {
    window.alert("Admin password is too short.\nBefore you enable SNMPv3, please change the password on the Maintenance->Password page.\nThe password of the admin account must be at least 8 bytes.");
    form.iw_trapSnmp_adminAuthType.focus();
    return false;
   }
   if((document.getElementById("iw_trapSnmp_version").selectedIndex == 0) && (document.getElementById("iw_trapSnmp_adminAuthType").selectedIndex != 0) && (passlen < 8))
   {
    window.alert("Admin password is too short.\nBefore you enable SNMPv3, please change the password on the Maintenance->Password page.\nThe password of the admin account must be at least 8 bytes.");
    form.iw_trapSnmp_adminAuthType.focus();
    return false;
   }
   return true;
  }
  function snmpver()
  {
   if(document.getElementById("iw_trapSnmp_version").selectedIndex == 1)
   {
    document.network_snmp.iw_trapSnmp_adminAuthType.disabled = true;
    document.network_snmp.iw_trapSnmp_adminAuthKey.disabled = true;
    document.network_snmp.iw_trapSnmp_adminKey.disabled = true;

    document.network_snmp.iw_trapSnmp_userAuthAccount.disabled = true;

   }
   else
   {
    document.network_snmp.iw_trapSnmp_adminAuthType.disabled = false;
    if(document.getElementById("iw_trapSnmp_adminAuthType").value == "No Auth")
    {
     document.network_snmp.iw_trapSnmp_adminKey.disabled = true;
     document.network_snmp.iw_trapSnmp_adminAuthKey.disabled = true;

     document.network_snmp.iw_trapSnmp_userAuthAccount.disabled = true;

    }
    else
    {

     document.network_snmp.iw_trapSnmp_userAuthAccount.disabled = false;

     document.network_snmp.iw_trapSnmp_adminAuthKey.disabled = false;
     if(document.getElementById("iw_trapSnmp_adminAuthKey").value == "DISABLE")
     {
      document.network_snmp.iw_trapSnmp_adminKey.disabled = true;
     }
     else
     {
      document.network_snmp.iw_trapSnmp_adminKey.disabled = false;
     }
    }
   }

  }

  function iw_SNMPaOnLoad()
  {
   iw_selectSet(document.network_snmp.iw_trapSnmp_enable, "<% iw_webCfgValueHandler("trapSnmp", "enable", "DISABLE"); %>");
              iw_selectSet(document.network_snmp.iw_trapSnmp_version, "<% iw_webCfgValueHandler("trapSnmp", "version", "V1, V2c, V3"); %>");
              iw_selectSet(document.network_snmp.iw_trapSnmp_adminAuthType, "<% iw_webCfgValueHandler("trapSnmp", "adminAuthType", "No Auth"); %>");

              iw_selectSet(document.network_snmp.iw_trapSnmp_userAuthAccount, "<% iw_webCfgValueHandler("trapSnmp", "userAuthAccount", "0"); %>");

              iw_selectSet(document.network_snmp.iw_trapSnmp_adminAuthKey, "<% iw_webCfgValueHandler("trapSnmp", "adminAuthKey", "DISABLE"); %>");
              iw_selectSet(document.network_snmp.iw_trapSnmp_rmtMngt, "<% iw_webCfgValueHandler("trapSnmp", "rmtMngt", "DISABLE"); %>");

   snmpver();
  }


  function editPermission()
  {
   var form = document.network_snmp, i, j = <% iw_websCheckPermission(); %>;
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
<BODY onload="iw_SNMPaOnLoad();iw_ChangeOnLoad();">
 <H2><% iw_webSysDescHandler("SNMPAgentTree", "", "SNMP Agent"); %> <% iw_websGetErrorString(); %></H2>
 <FORM name="network_snmp" method="POST" action="/forms/iw_webSetParameters" onSubmit="return CheckValue(this)">
  <TABLE width="100%">
   <TR>
    <TD width="30%" class="column_title"><% iw_webCfgDescHandler("trapSnmp", "enable", "Enable"); %></TD>
    <TD width="70%">
     <SELECT size="1" id=iw_trapSnmp_enable name="iw_trapSnmp_enable">
                <option value="ENABLE">Enable</option>
                <option value="DISABLE">Disable</option>
                                  </SELECT>
    </TD>
   </TR>
   <TR>
    <TD width="30%" class="column_title"><% iw_webCfgDescHandler("trapSnmp", "rmtMngt", "Remote management"); %></TD>
    <TD width="70%">
     <SELECT size="1" id=iw_trapSnmp_rmtMngt name="iw_trapSnmp_rmtMngt">
       <option value="ENABLE">Enable</option>
       <option value="DISABLE">Disable</option>
     </SELECT>
    </TD>
   </TR>
   <TR>
    <TD width="30%" class="column_title"><% iw_webCfgDescHandler("trapSnmp", "ro_community", "Read community"); %></TD>
    <TD width="70%">
    <INPUT type="text" name="iw_trapSnmp_ro_community" size="36" maxlength="31" value = "<% iw_webCfgValueHandler("trapSnmp", "ro_community", ""); %>">
    </TD>
   </TR>
   <TR>
    <TD width="30%" class="column_title"><% iw_webCfgDescHandler("trapSnmp", "rw_community", "Write community"); %></TD>
    <TD width="70%">
    <INPUT type="text" name="iw_trapSnmp_rw_community" size="36" maxlength="31" value = "<% iw_webCfgValueHandler("trapSnmp", "rw_community", ""); %>">
    </TD>
   </TR>
   <TR>
    <TD width="30%" class="column_title"><% iw_webCfgDescHandler("trapSnmp", "version", "SNMP agent version"); %></TD>
    <TD width="70%">
     <SELECT size="1" id=iw_trapSnmp_version name="iw_trapSnmp_version" onchange="snmpver();">
                             <option value="V1, V2c, V3">V1, V2c, V3</option>
                                   <option value="V1, V2c">V1, V2c</option>
                                   <option value="V3">V3 Only</option>
                                  </SELECT>
    </TD>
   </TR>
   <TR>
    <TD width="30%" class="column_title"><% iw_webCfgDescHandler("trapSnmp", "adminAuthType", "Admin authentication type"); %></TD>
    <TD width="70%">
     <SELECT size="1" id="iw_trapSnmp_adminAuthType" name="iw_trapSnmp_adminAuthType" onchange="snmpver();">
      <OPTION value="No Auth" selected>No Auth</OPTION>
      <OPTION value="MD5">MD5</OPTION>
      <OPTION value="SHA">SHA</OPTION>
     </SELECT>
    </TD>
   </TR>

   <TR>
    <TD width="30%" class="column_title"><% iw_webCfgDescHandler("trapSnmp", "userAuthAccount", "Admin authentication type"); %></TD>
    <TD width="70%">
    <SELECT size="1" id="iw_trapSnmp_userAuthAccount" name="iw_trapSnmp_userAuthAccount" onchange="snmpver();">
     <% iw_webSNMPv3AccountSelection(); %>
    </SELECT>
    </TD>
   </TR>

   <TR>
    <TD width="30%" class="column_title"><% iw_webCfgDescHandler("trapSnmp", "adminAuthKey", "Admin privacy type"); %></TD>
    <TD width="70%">
     <SELECT size="1" id="iw_trapSnmp_adminAuthKey" name="iw_trapSnmp_adminAuthKey" onchange="snmpver();">
      <OPTION value="DISABLE" selected>Disable</OPTION>
      <OPTION value="DES">DES</OPTION>
      <OPTION value="AES">AES</OPTION>
     </SELECT>
    </TD>
   </TR>
   <TR>
    <TD width="30%" class="column_title"><% iw_webCfgDescHandler("trapSnmp", "adminKey", "key"); %></TD>
    <TD width="70%">
     <INPUT type="password" id="iw_trapSnmp_adminKey" name="iw_trapSnmp_adminKey" size="44" maxlength="39" value = "<% iw_webCfgValueHandler("trapSnmp", "adminKey", ""); %>">
    </TD>
   </TR>
   <TR>
    <TD width="30%" class="column_title"></TD>
    <TD width="70%"></TD>
   </TR>
   <TR>
    <TD width="30%" class="column_title"></TD>
    <TD width="70%"></TD>
   </TR>
  </TABLE>






    <H2><% iw_webSysDescHandler("PrivateMIBInformationtTree", "", "Private MIB information"); %></H2>
  <TABLE width="100%">
   <TR>
    <TD width="30%" class="column_title"><% iw_webCfgDescHandler("trapSnmp", "privMib", "Device Object ID"); %></TD>
    <TD width="70%">
     <% iw_webCfgValueHandler("trapSnmp", "privMib", ""); %>
    </TD>
   </TR>
   <TR>
    <TD colspan="2"><HR>
     <INPUT type="submit" value="Submit" name="Submit">
     <Input type="hidden" name="bkpath" value="/SNMPAgent.asp">
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
