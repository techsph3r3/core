<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%
        var account_index;

 account_index = "account" + accountIndex;
%>

<HTML>
<HEAD>
 <META http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
    <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate" />
    <meta http-equiv="Pragma" content="no-cache" />
    <meta http-equiv="Expires" content="0" />
 <LINK href="nport2g.css" rel="stylesheet" type="text/css">
 <% iw_webJSList_get(); %>
 <script type="text/javascript">
 <!--
  var orig_active = "<% iw_webCfgValueHandler(account_index, "active", ""); %>";
  var orig_user = "<% iw_webCfgValueHandler(account_index, "username", ""); %>";
  var passwdLength = <% iw_webCfgValueMtdHandler("accountMgmt", "passwdLength", ""); %>;
  var passwdStrengthCheck = "<% iw_webCfgValueMtdHandler("accountMgmt", "passwdStrengthCheck"  , "ENABLE"); %>";
  function iw_activechange()
  {
   var active = document.getElementById("active").options[document.getElementById("active").selectedIndex].value;
   if (active == "DISABLE")
   {
    document.getElementById("group").disabled = true;
    document.getElementById("username").disabled = true;
    document.getElementById("Passwd").disabled = true;
    document.getElementById("ConfPasswd").disabled = true;
    document.getElementById("accessHttp_enable").disabled = true;
    document.getElementById("accessHttp_disable").disabled = true;
    document.getElementById("accessConsole_enable").disabled = true;
    document.getElementById("accessConsole_disable").disabled = true;
    document.getElementById("accessMoxaService_enable").disabled = true;
    document.getElementById("accessMoxaService_disable").disabled = true;
    document.getElementById("accessDiag_enable").disabled = true;
    document.getElementById("accessDiag_disable").disabled = true;
   }
   else
   {
    document.getElementById("group").disabled = false;
    document.getElementById("username").disabled = false;
    document.getElementById("Passwd").disabled = false;
    document.getElementById("ConfPasswd").disabled = false;
    document.getElementById("accessHttp_enable").disabled = false;
    document.getElementById("accessHttp_disable").disabled = false;
    document.getElementById("accessConsole_enable").disabled = false;
    document.getElementById("accessConsole_disable").disabled = false;
    document.getElementById("accessMoxaService_enable").disabled = false;
    document.getElementById("accessMoxaService_disable").disabled = false;
    document.getElementById("accessDiag_enable").disabled = false;
    document.getElementById("accessDiag_disable").disabled = false;
   }
  }

  function passwdCheck(new_passwd, minPasswdLen)
        {
            var checkNumber = /(?=.*[0-9]).{1,}/;
            var checkUpLetter = /(?=.*[A-Z]).{1,}/;
            var checkLoLetter = /(?=.*[a-z]).{1,}/;
            var checkSpecialchar = /(?=.*[\-\+\?\*\$\[\]\^\.\(\)\|`!@#%&_=:;,/~]).{1,}/;

            if( new_passwd.value.length < minPasswdLen )
            {
                return 1;
            }

            if( passwdStrengthCheck == "ENABLE" )
            {
                if( !checkNumber.test(new_passwd.value) )
                {
                    return 2;
                }
                else if( !checkUpLetter.test(new_passwd.value) || !checkLoLetter.test(new_passwd.value) )
                {
                    return 3;
                }
                else if( !checkSpecialchar.test(new_passwd.value) )
                {
                    return 4;
                }
            }
            return 0;
        }

  function CheckValue(form)
  {
   var minPasswdLen = passwdLength;
   if ("<% iw_webCfgValueHandler("trapSnmp", "enable", "DISABLE"); %>" == "ENABLE" &&
    "<% iw_webCfgValueHandler("trapSnmp", "version", "V1, V2c, V3"); %>".match("V3") &&
    "<% iw_webCfgValueHandler("trapSnmp", "adminAuthType", "No Auth"); %>" != "No Auth"){
    if( 8 > passwdLength )
     minPasswdLen = 8;
   }

   if (form.username.value.length == 0)
   {
    alert("'Username' must not be empty.");
    form.username.focus();
    return false;
   }
   if (form.Passwd.value.length < minPasswdLen)
   {
    alert("'New password' must be at least " + minPasswdLen + " bytes.");
    form.Passwd.focus();
    return false;
   }
   if (form.ConfPasswd.value.length < minPasswdLen)
   {
    alert("'Confirm password' must be at least " + minPasswdLen + " bytes.");
    form.ConfPasswd.focus();
    return false;
   }
   if (form.Passwd.value != form.ConfPasswd.value)
   {
    alert("The password confirmation dose not match.");
    form.Passwd.focus();
    return false;
   }

   ret = passwdCheck(form.Passwd, minPasswdLen)
            if( ret != 0 )
            {
                if (ret == 1)
                    alert("Invalid Password. The minimum password length is " + minPasswdLen + " characters.");
                else if (ret == 2)
                    alert("Invalid Password. The password must contain at least one digit (0~9).");
                else if (ret == 3)
                    alert("Invalid Password. The password must be a combination of upper and lower case letters (A~Z, a~z).");
                else if (ret == 4)
                    alert("Invalid Password. The password must contain at least one special character (~!@#$%^&*-_|;:,.<>[]{}())");
                form.Passwd.focus();
                return false;
            }

   form.Passwd.value = disorganize(form.Passwd.value);
   form.ConfPasswd.value = disorganize(form.ConfPasswd.value);


   if( orig_active == "ENABLE" )
   {
    alert("Password will be effective immediately");
   }

  }


  function editPermission()
  {
   var form = document.account_setting, i, j = <% iw_websCheckPermission(); %>;
   if(j)
   {
    for(i = 0; i < form.length; i++)
     form.elements[i].disabled = true;
   }
  }


  var mem_state = <% iw_websMemoryChange(); %>;
  function iw_OnLoad()
  {
   var index = <% write(accountIndex); %>;
   if (index == 1)
   {
    document.getElementById("active").disabled = true;
    document.getElementById("group").disabled = true;
   }
   iw_selectSet(document.account_setting.active, "<% iw_webCfgValueHandler(account_index, "active", ""); %>");
   iw_selectSet(document.account_setting.group, "<% iw_webCfgValueHandler(account_index, "group", ""); %>");

   if ("<% iw_webCfgValueHandler(account_index, "accessHttp", "ENABLE"); %>" == "ENABLE")
    document.account_setting.accessHttp_enable.checked = true;
   else
    document.account_setting.accessHttp_disable.checked = true;

   if ("<% iw_webCfgValueHandler(account_index, "accessConsole", "ENABLE"); %>" == "ENABLE")
    document.account_setting.accessConsole_enable.checked = true;
   else
    document.account_setting.accessConsole_disable.checked = true;

   if ("<% iw_webCfgValueHandler(account_index, "accessDiag", "ENABLE"); %>" == "ENABLE")
    document.account_setting.accessDiag_enable.checked = true;
   else
    document.account_setting.accessDiag_disable.checked = true;

   if ("<% iw_webCfgValueHandler(account_index, "accessMoxaService", "ENABLE"); %>" == "ENABLE")
    document.account_setting.accessMoxaService_enable.checked = true;
   else
    document.account_setting.accessMoxaService_disable.checked = true;

   if( passwdStrengthCheck == "ENABLE" ) {
                $('#Passwd_strength_notify').show();
                $('#Passwd_notify').hide();
                $('#Passwd_strenght_len').text("The minimum password length is " + passwdLength + " characters.");
            } else {
                $('#Passwd_strength_notify').hide();
                $('#Passwd_notify').show();
                $('#Passwd_len').text("The minimum password length is " + passwdLength + " characters.");
            }

   iw_activechange();


            editPermission();



   if (location.protocol == 'http:') {
    alert(iw_warrningMessage('SECURITY_PASSWORD'));
   }

   top.toplogo.location.reload();
  }


    -->
    </Script>
</HEAD>
<BODY onload="iw_OnLoad();">
 <H2><% iw_webSysDescHandler("AccountSetting", "", "Account Setting"); %> <% iw_websGetErrorString(); %></H2>
 <FORM name="account_setting" method="POST" action="/forms/webSetAccount" onSubmit="return CheckValue(this)">
  <TABLE width="100%">
   <TR>
    <TD width="30%" class="column_title"><% iw_webCfgDescHandler(account_index, "active", "DISABLE"); %></TD>
    <TD width="70%">
     <SELECT size="1" id="active" name="active" onchange='iw_activechange();'>
                <option value="ENABLE">Enable</option>
                <option value="DISABLE">Disable</option>
                                  </SELECT>
    </TD>
   </TR>
   <TR>
    <TD width="30%" class="column_title"><% iw_webCfgDescHandler(account_index, "group", "Admin"); %></TD>
    <TD width="70%">
     <SELECT size="1" id="group" name="group">
                <option value="Admin">Admin</option>
                <option value="User">User</option>
                                  </SELECT>
    </TD>
   </TR>
   <TR>
    <TD width="30%" class="column_title"><% iw_webCfgDescHandler(account_index, "username", ""); %></TD>
    <TD width="70%">
     <INPUT type="text" id="username" name="username" size="16" maxlength="36" value="<% iw_webCfgValueHandler(account_index, "username", ""); %>"> (A-Z, a-z, 0-9, '@', '.', and '_')
    </TD>
   </TR>
   <TR>
    <TD width="30%" class="column_title">New Password</TD>
    <TD width="70%">
     <INPUT type="password" id="Passwd" name="Passwd" size="16" maxlength="16"><span id="Passwd_msg"></span>
    </TD>
   </TR>
   <TR>
    <TD width="30%" class="column_title">Confirm Password</TD>
    <TD width="70%">
     <INPUT type="password" id="ConfPasswd" name="ConfPasswd" size="16" maxlength="16">
    </TD>
   </TR>
  </TABLE>
  <ul id="Passwd_strength_notify">
   <li>Your password must follow the password policy.</li>
            <li>The password must contain at least one digit (0~9).</li>
            <li>The password must be a combination of upper and lower case letters (A~Z, a~z).</li>
            <li>The password must contain at least one special character (~!@#$%^&*-_|;:,.<>[]{}()).</li>
            <li id="Passwd_strenght_len"></li>
        </ul>
        <ul id="Passwd_notify">
   <li>Your password must follow the password policy.</li>
            <li id="Passwd_len"></li>
        </ul>
  <BR>
  <H2><% iw_webSysDescHandler("AccountAccessPortals", "", "Accessible Access Portals"); %></H2>
  <TABLE>
   <TR>
    <TD width="30%" class="column_title"><% iw_webCfgDescHandler(account_index, "accessHttp", "HTTP/HTTPS"); %></TD>
    <TD width="70%">
     <INPUT type="radio" name="accessHttp" value="ENABLE" id="accessHttp_enable">Enable</INPUT>
     <INPUT type="radio" name="accessHttp" value="DISABLE" id="accessHttp_disable">Disable</INPUT>
    </TD>
   </TR>
   <TR>
    <TD width="30%" class="column_title"><% iw_webCfgDescHandler(account_index, "accessConsole", "---"); %></TD>
    <TD width="70%">
     <INPUT type="radio" name="accessConsole" value="ENABLE" id="accessConsole_enable">Enable</INPUT>
     <INPUT type="radio" name="accessConsole" value="DISABLE" id="accessConsole_disable">Disable</INPUT>
    </TD>
   </TR>
   <TR>
    <TD width="30%" class="column_title"><% iw_webCfgDescHandler(account_index, "accessMoxaService", "---"); %></TD>
    <TD width="70%">
     <INPUT type="radio" name="accessMoxaService" value="ENABLE" id="accessMoxaService_enable">Enable</INPUT>
     <INPUT type="radio" name="accessMoxaService" value="DISABLE" id="accessMoxaService_disable">Disable</INPUT>
    </TD>
   </TR>
   <TR>
    <TD width="30%" class="column_title"><% iw_webCfgDescHandler(account_index, "accessDiag", "---"); %></TD>
    <TD width="70%">
     <INPUT type="radio" name="accessDiag" value="ENABLE" id="accessDiag_enable">Enable</INPUT>
     <INPUT type="radio" name="accessDiag" value="DISABLE" id="accessDiag_disable">Disable</INPUT>
    </TD>
   </TR>
  </TABLE>
  <TABLE>
   <TR>
    <TD colspan="2"><HR>
     <INPUT type="submit" value="Submit" name="Submit">
     <Input type="hidden" name="bkpath" value="/account_setting.asp?accountIndex=<% write(accountIndex); %>">
     <input type="hidden" name="account_index" value="<% write(account_index); %>">
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
