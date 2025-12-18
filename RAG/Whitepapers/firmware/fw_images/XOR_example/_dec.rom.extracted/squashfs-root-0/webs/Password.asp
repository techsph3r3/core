<HTML>
<HEAD>
    <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate" />
    <meta http-equiv="Pragma" content="no-cache" />
    <meta http-equiv="Expires" content="0" />
 <LINK href="nport2g.css" rel=stylesheet type=text/css>
 <TITLE><% iw_webSysDescHandler("ChangePasswordTree", "", "Change Password"); %></TITLE>
 <% iw_webJSList_get(); %>
 <script type="text/javascript">
 <!--
  var passwdLength = <% iw_webCfgValueMtdHandler("accountMgmt", "passwdLength", ""); %>;
        var passwdStrengthCheck = "<% iw_webCfgValueMtdHandler("accountMgmt", "passwdStrengthCheck"  , "ENABLE"); %>";

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
   var ret = 0;
   if( "<% iw_webCfgValueHandler("trapSnmp", "enable", "DISABLE"); %>" == "ENABLE" &&
    "<% iw_webCfgValueHandler("trapSnmp", "version", "V1, V2c, V3"); %>".match("V3") &&
    "<% iw_webCfgValueHandler("trapSnmp", "adminAuthType", "No Auth"); %>" != "No Auth" ){
    if( 8 > passwdLength )
     minPasswdLen = 8;
   }
      if( form.Passwd.value.length < minPasswdLen )
      {
          alert("'New password' must be at least " + minPasswdLen + " bytes.");
     form.Passwd.focus();
          return false;
      }
      if( form.ConfPasswd.value.length < minPasswdLen )
      {
          alert("'Confirm password' must be at least " + minPasswdLen + " bytes.");
     form.ConfPasswd.focus();
          return false;
      }
   if( form.Passwd.value != form.ConfPasswd.value )
   {
    alert("The password confirmation dose not match.");
    form.Passwd.focus();
    return false;
   }

   if( form.Passwd.value == form.NowPasswd.value )
   {
    alert("'New password' is the same as the 'old password'");
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

   alert("Password will be effective immediately");

   form.NowPasswd.value = disorganize(form.NowPasswd.value);
   form.Passwd.value = disorganize(form.Passwd.value);
   form.ConfPasswd.value = disorganize(form.ConfPasswd.value);

  }

  var mem_state = <% iw_websMemoryChange(); %>;

  function iw_load()
  {
   if( passwdStrengthCheck == "ENABLE" ) {
    $('#Passwd_strength_notify').show();
    $('#Passwd_notify').hide();
    $('#Passwd_strenght_len').text("The minimum password length is " + passwdLength + " characters.");
            } else {
    $('#Passwd_strength_notify').hide();
    $('#Passwd_notify').show();
    $('#Passwd_len').text("The minimum password length is " + passwdLength + " characters.");
            }

   if (location.protocol == 'http:') {
    alert(iw_warrningMessage('SECURITY_PASSWORD'));
   }

   top.toplogo.location.reload();
  }

  function iw_ChangeOnLoad()
  {
   top.toplogo.location.reload();
  }
    -->
    </Script>
</HEAD>
<BODY onLoad="iw_load();iw_ChangeOnLoad();">
 <H2><% iw_webSysDescHandler("ChangePasswordTree", "", "Change Password"); %> <% iw_websGetErrorString(); %></H2>
 <FORM name="user_add" method="POST" action="/forms/webSetUserChgPwd" onSubmit="return CheckValue(this)">
  <TABLE width="100%">
   <TR>
    <TD width="30%" class="column_title">Current password</TD>
    <TD width="70%"><INPUT type="password" name="NowPasswd" maxlength="16" size="22"></TD>
   </TR>
   <TR>
    <TD width="30%" class="column_title">New password</TD>
    <TD width="70%"><INPUT type="password" name="Passwd" maxlength="16" size="22"></TD>
   </TR>
   <TR>
    <TD width="30%" class="column_title">Confirm password</TD>
    <TD width="70%"><INPUT type="password" name="ConfPasswd" maxlength="16" size="22"></TD>
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
     <HR>
   <INPUT type="submit" value="Apply" name="Submit">
   <INPUT type="hidden" name="UserName" value="admin">
   <Input type="hidden" name="bkpath" value="/Password.asp">
    </FORM>
</BODY></HTML>
