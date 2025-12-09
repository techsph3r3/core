<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
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


 NumArray = new Array();
 function StrToHex(str)
 {
  var i = 0;
  var ret = 0;
  table = new Array("0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "a", "b", "c", "d", "e", "f");
  for (i = 0; i < 16; ++i) {
   if (str.charAt(0) == table[i])
    ret = i*16;
  }
  for (i = 0; i < 16; ++i) {
   if (str.charAt(1) == table[i])
    ret += i;
  }
  return ret;
 }

 function DecToHexStr(d)
 {
  table = new Array("0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "a", "b", "c", "d", "e", "f");
  var ret = "";
  var i = d/16;
  for (var j = 0; j <= i; ++j)
   var c = table[j];
  ret += c;

  i = d%16;
  for (var j = 0; j < 16; ++j) {
   if (j == i) {
    var c = table[j];
    break;
   }
  }
  ret += c;
  return ret;
 }

 function SetCookie()
 {
  theName = "<% iw_webGetAuthCookieName(); %>" + "=";

  // get chall by sychronize javascript request
  var http_req = iw_inithttpreq();
  var d = new Date();
  http_req.open( "GET", "/webNonce?user=" + document.InputPassword.Username.value + "&time=" + d.getTime(), false );
  http_req.send( null );
  var chall = http_req.responseText;

  var op = document.InputPassword.Password.value;
  theValue = MD5( op + chall );
  var expires = null;
  var toomanyLogin = <% iw_webAccountLoginExceed(); %>;

  if(toomanyLogin)
  {
   alert("The number of concurrent users has exceeded the limit (32 users). Please try again later.");
   return ;
  }
  document.cookie = theName + escape(theValue) + "; path=/" + ((expires == null) ? " " : "; expires = " + expires.toGMTString());
  document.InputPassword.Password.value="";


  var is_pass = 1;
  var is_lock = 0;

  jQuery.ajax({
            url :'none.asp?Username=' + document.InputPassword.Username.value,
   /* Disable sync */
            async: false,
            success: function(data)
            {
                if (data == "ACCOUNT_LOCK")
                    is_lock = 1; // account is been locked
            },
            complete: function(response)
            {
                if(response.status == 200)
                {
                    is_pass = 0;
                }
            }
        });

  if( is_pass == 0 )
  {
   load(is_pass, is_lock)
   return false;
  }

 }

 function ClearCookie()
 {
  theCookieName = "<% iw_webGetAuthCookieName(); %>" + "=";
  document.cookie = theCookieName;

  load(1, 0);

 }


 Function.prototype.getMultiLine = function ()
 {
     var lines = new String(this);

     lines = lines.substring(lines.indexOf("/*") + 3, lines.lastIndexOf("*/"));

     return lines;
 }

 function load(is_pass, is_lock)
 {
  var loginMsg = function(){/* <% iw_webCfgValueHandler("board", "webLoginMessage", ""); %> */}
  var loginFailMsg = function(){/* <% iw_webCfgValueHandler("board", "webLoginFailMessage", ""); %> */}

  if ( is_lock == 1 ) {
   document.getElementById("notify_msg").innerHTML = "<td colspan=\"2\"><h2><span style=\"color:red\">This account is locked.</span></h2></td>";
  } else {

   var error_val = location.search.split('error=')[1] ? parseInt(location.search.split('error=')[1]) : 0;
   switch (error_val) {
   case 67838270:
    document.getElementById("notify_msg").innerHTML = "<td colspan=\"2\"><h2><span style=\"color:red\">Login denied due to unauthorized access.</span></h2></td>";
    break;
   default:
    break;
   }

  }

  if( is_pass == 1 )
   document.getElementById("info").innerHTML = "<tr><td><font style=\"word-break: break-all; white-space: pre-wrap;\">" + loginMsg.getMultiLine() + "</font></td></tr>";
  else
   document.getElementById("info").innerHTML = "<tr><td><font style=\"word-break: break-all; white-space: pre-wrap;\">" + loginFailMsg.getMultiLine() + "</font></td></tr>";
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


<body style="margin:0px" onload="document.InputPassword.Username.focus();ClearCookie();">



 <table border=0 cellpadding=0 cellspacing=0 width="100%" style="height:100%">
  <tr style="height:105px">
   <td style="background-image:url(lup_logo2.gif);border:0px;background-repeat:repeat-x"><IMG src="lup_logo1.gif" border=0 /></td>
  </tr>
  <tr style="height:auto">
   <td style="background-image:url(lleft_logo.gif);background-repeat: repeat-y;">
    <div style="vertical-align:middle;text-align: center;">
     <form name="InputPassword" method="post" action="/home.asp" onSubmit="return SetCookie();">
     <table border=0 cellpadding=0 cellspacing=0 style="height:auto;margin: 0 auto;text-align: left;">
      <tr>
       <td colspan="2"><h2><% iw_webGet_manufactureName(); %><% iw_webCfgValueMainHandler("board", "modelName",""); %></h2></td>
      </tr>
      <tr><td>&nbsp;</td></tr>
      <tr id="notify_msg">
      </tr>
      <tr><td>&nbsp;</td></tr>
      <tr>
       <td>Username : </td>

       <td><input type="text" name="Username" id="Username" maxlength="32" size="32" /></td>



      </tr>
      <tr><td>&nbsp;</td></tr>
      <tr>
       <td>Password : </td>

       <td><input type="password" name="Password" id="Password" maxlength="32" size="32" /></td>
       <td><input type="hidden" name="iw_interface" id="iw_interface" maxlength="32" size="32" value="web" /></td>



      </tr>
      <tr><td>&nbsp;</td></tr>
      <tr>
       <td>&nbsp;</td>
       <td align=right><input type="image" value="Login" name="Submit" src="llogin.gif" /></td>
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

 <table id="info" width="300" height="30" style="position:absolute;left:105px;bottom:120px"></table>

 <img border="0" src="goahead.gif" width="155" height="31" style="position:absolute;left:105px;bottom:60px" />
</body>
</html>
