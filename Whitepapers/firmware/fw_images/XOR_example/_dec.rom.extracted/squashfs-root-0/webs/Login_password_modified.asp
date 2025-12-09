<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%
 var oldpasscheck;
 oldpasscheck = checkvalue;
%>
<html>
<head>
 <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
 <meta http-equiv="Pragma" content="no-cache" />
 <title>Moxa <% iw_webCfgValueMainHandler("board", "modelName",""); %><% iw_webGetMainIPAddress(); %></title>
 <% iw_webJSList_get(); %>
 <script type="text/javascript">
<!--
 if(window != top)
  top.location.href = window.location.href;

 var minPasswdLen = <% iw_webCfgValueMtdHandler("accountMgmt", "passwdLength", ""); %>;
 var strengthCheck = "<% iw_webCfgValueMtdHandler("accountMgmt", "passwdStrengthCheck"  , "ENABLE"); %>";
 var check = <% write(checkvalue); %>;

 $(document).ready(function()
 {
  $("#Passwd").keyup(function()
  {
   passwdHint();
  });

  if( strengthCheck == "ENABLE" ) {
         $('#Passwd_strength_notify').show();
         $('#Passwd_notify').hide();
   $('#Passwd_strenght_len').text("The minimum password length is " + minPasswdLen + " characters.");
        } else {
            $('#Passwd_strength_notify').hide();
            $('#Passwd_notify').show();
   $('#Passwd_len').text("The minimum password length is " + minPasswdLen + " characters.");
        }
  if (check == 0)
   alert("Old password is incorrect");
 });

 function passwdHint()
 {
  var new_passwd = document.getElementById("Passwd");
  var passwd_hint = document.getElementById("password_hint");
  var checkNumber = /(?=.*[0-9]).{1,}/;
  var checkUpLetter = /(?=.*[A-Z]).{1,}/;
  var checkLoLetter = /(?=.*[a-z]).{1,}/;
  var checkSpecialchar = /(?=.*[\-\+\?\*\$\[\]\^\.\(\)\|`!@#%&_=:;,/~]).{1,}/;

  if( new_passwd.value.length < minPasswdLen )
  {
   passwd_hint.innerHTML = " The minimum password length is " + minPasswdLen + " characters.";
   return 1;
  }
  else
   passwd_hint.innerHTML = "";

  if( strengthCheck == "ENABLE" )
  {
   if( !checkNumber.test(new_passwd.value) )
   {
    passwd_hint.innerHTML=" The password must contain at least one digit (0~9).";
    return 2;
   }
   else if( !checkUpLetter.test(new_passwd.value) || !checkLoLetter.test(new_passwd.value) )
   {
    passwd_hint.innerHTML=" The password must be a combination of upper and lower case letters (A~Z, a~z).";
    return 3;
   }
   else if( !checkSpecialchar.test(new_passwd.value) )
   {
    passwd_hint.innerHTML=" The password must contain at least one special character (~!@#$%^&*-_|;:,.<>[]{}())";
    return 4;
   }
   else
    passwd_hint.innerHTML = "";
  }

  return 0;
 }

 function CheckValue(form)
 {
  var ret = 0;

  if( form.NowPasswd.value.length <= 0 )
  {
   alert("'Old password' must to need.");
   form.NowPasswd.focus();
   return false;
  }


  if( form.Passwd.value.length <= 0 )
  {
   alert("'New password' must to need.");
   form.Passwd.focus();
   return false;
  }


  if( form.ConfPasswd.value.length <= 0 )
  {
   alert("'Confirm password' must to need.");
   form.ConfPasswd.focus();
   return false;
  }

  ret = passwdHint();
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

  alert("Password will be effective immediately");

  form.NowPasswd.value = disorganize(form.NowPasswd.value);
  form.Passwd.value = disorganize(form.Passwd.value);
  form.ConfPasswd.value = disorganize(form.ConfPasswd.value);

 }

-->
</script>
<style type="text/css">
 input {
  font-family: Verdana;
  font-size: 9pt;
  color: #000000;
 }
 body {
  font-family: Verdana;
  font-size: 10pt;
  background-color: #e5e5e5;
 }
 h2 {
  font-family: Verdana;
  font-size: 12pt;
  color: #0a51a1;
  background-color: #e5e5e5;
 }
</style>
</head>

<body style="margin:0px">
 <table border=0 cellpadding=0 cellspacing=0 width="100%" style="height:100%">
  <tr style="height:105px">
   <td style="background-image:url(lup_logo2.gif);border:0px"><IMG src="lup_logo1.gif" border=0 /></td>
  </tr>
  <tr style="height:auto">
   <td style="background-image:url(lleft_logo.gif);background-repeat: repeat-y;">
    <div style="vertical-align:middle;text-align: center;">
     <form name="ChangePassword" method="post" action="/forms/webSetUserChgPwd" onSubmit="return CheckValue(this)">
     <table border=0 cellpadding=0 cellspacing=0 style="height:auto;margin: 0 auto;text-align: left;">
      <tr>
       <td colspan="2"><h2><% iw_webGet_manufactureName(); %><% iw_webCfgValueMainHandler("board", "modelName",""); %></h2></td>
      </tr>
      <tr>
                            <td colspan="2"><h2><span style="color:red">"Please modify your password to meet password policy."</span></h2></td>
                        </tr>
      <tr>
       <td colspan="2">
        <span>
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
        </span>
       </td>
      </tr>
                        <tr><td>&nbsp;</td></tr>
      <tr>
       <td>Old Password : </td>
       <td><input type="password" name="NowPasswd" id="NowPasswd" maxlength="16" size="32" /></td>
      </tr>
      <tr><td>&nbsp;</td></tr>
      <tr>
       <td>New Password : </td>
       <td><input type="password" name="Passwd" id="Passwd" maxlength="16" size="32" /></td>
      </tr>
      <tr height="20px">
                            <td> </td>
                            <td width="240" style="font-size:0.8em;" id="password_hint"></td>
                        </tr>
      <tr>
       <td>Confirm New Password : </td>
       <td><input type="password" name="ConfPasswd" id="ConfPasswd" maxlength="16" size="32" /></td>
      </tr>
      <tr><td>&nbsp;</td></tr>
      <tr>
       <td> </td>
       <td><INPUT type="submit" value="Apply" name="Submit"><td>
       <Input type="hidden" name="bkpath" value="/Login_password_modified.asp?checkvalue=1">
      </tr>
     </table>
     </form>
    </div>
   </td>
  </tr>
  <tr style="height:50px">
   <td style="background-image:url(ldown_logo2.gif);border:0px"><IMG src="ldown_logo1.gif" border=0 /></td>
  </tr>
 </table>
 <img border="0" src="goahead.gif" width="155" height="31" style="position:absolute;left:105px;bottom:60px" />
</body>
</html>
