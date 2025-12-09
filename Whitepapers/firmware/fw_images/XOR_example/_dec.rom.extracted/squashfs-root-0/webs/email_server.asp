<HTML>
<HEAD>
 <META http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
    <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate" />
    <meta http-equiv="Pragma" content="no-cache" />
    <meta http-equiv="Expires" content="0" />
 <LINK href="nport2g.css" rel="stylesheet" type="text/css">
 <TITLE><% iw_webSysDescHandler("EmailServerTree", "", "E-mail Server Settings"); %></TITLE>
 <% iw_webJSList_get(); %>
 <script type="text/javascript">
 <!--
  var http_req = false;
  var counter;
  var timeout;

  function EmailTest( form )
  {
   http_req = iw_inithttpreq();

   if (!http_req )
   {
    alert('Cannot create httpreq instance.');
         return false;
   }

   var sendData = "server="+document.getElementById("iw_emailSmtp_smtpSrv").value;
   sendData += "&username="+document.getElementById("iw_emailSmtp_userName").value;
   sendData += "&password="+document.getElementById("iw_emailSmtp_password").value;

   if( document.getElementById("iw_emailSmtp_from").value.length > 0 )
    sendData += "&from="+document.getElementById("iw_emailSmtp_from").value;

   if( document.getElementById("iw_emailSmtp_mailAddr1").value.length > 0 )
    sendData += "&to1="+document.getElementById("iw_emailSmtp_mailAddr1").value;

   if( document.getElementById("iw_emailSmtp_mailAddr2").value.length > 0 )
    sendData += "&to2="+document.getElementById("iw_emailSmtp_mailAddr2").value;

   if( document.getElementById("iw_emailSmtp_mailAddr3").value.length > 0 )
    sendData += "&to3="+document.getElementById("iw_emailSmtp_mailAddr3").value;

   if( document.getElementById("iw_emailSmtp_mailAddr4").value.length > 0 )
    sendData += "&to4="+document.getElementById("iw_emailSmtp_mailAddr4").value;

   document.getElementById("EmailTestMsg").innerHTML = "Connecting to server, please wait...";

      http_req.open( "POST", "/forms/web_SendTestEmail", true );
      http_req.setRequestHeader( "Content-type", "application/x-www-form-urlencoded" );
   http_req.setRequestHeader( "Content-length", sendData.length );
      http_req.send( sendData );

   http_req.onreadystatechange = function ()
   {
    if(http_req.readyState == 4)
    {
     document.getElementById("EmailTestMsg").innerHTML = "";
     http_req.onreadystatechange = function() {};

     if(http_req.status == 200)
     {
      alert('Test e-mail is sent.');

      return true;
     }

     alert('Test e-mail sending failed, please check SMTP settings.');
     return false;
    }
   };

      return true;
  }
  /* 2008-07-31. End */

  function CheckValue(form)
  {
   if( document.getElementById("iw_emailSmtp_from").value.length > 0 )
    if( !isValidEmail( document.getElementById("iw_emailSmtp_from"), "From e-mail address") )
     return false;

   if( document.getElementById("iw_emailSmtp_mailAddr1").value.length > 0 )
    if( !isValidEmail( document.getElementById("iw_emailSmtp_mailAddr1"), "To e-mail address 1") )
     return false;

   if( document.getElementById("iw_emailSmtp_mailAddr2").value.length > 0 )
    if( !isValidEmail( document.getElementById("iw_emailSmtp_mailAddr2"), "To e-mail address 2") )
     return false;

   if( document.getElementById("iw_emailSmtp_mailAddr3").value.length > 0 )
    if( !isValidEmail( document.getElementById("iw_emailSmtp_mailAddr3"), "To e-mail address 3") )
     return false;

   if( document.getElementById("iw_emailSmtp_mailAddr4").value.length > 0 )
    if( !isValidEmail( document.getElementById("iw_emailSmtp_mailAddr4"), "To e-mail address 4") )
     return false;
   return true;
  }


        function editPermission()
        {
                var form = document.mail_set, i, j = <% iw_websCheckPermission(); %>;
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

 //-->
 </SCRIPT>
</HEAD>
<BODY onLoad="iw_ChangeOnLoad();">
 <H2><% iw_webSysDescHandler("EmailServerTree", "", "E-mail Server Settings"); %> <% iw_websGetErrorString(); %></H2>
 <FORM name="mail_set" method="POST" action="/forms/iw_webSetParameters" onSubmit="return CheckValue(this)">
  <TABLE width="100%">
   <TR>
    <TD width="25%" class="column_title">Mail server (SMTP)</TD>
    <TD width="75%">
     <INPUT type="text" id="iw_emailSmtp_smtpSrv" name="iw_emailSmtp_smtpSrv" size="45" maxlength="40" value = "<% iw_webCfgValueHandler("emailSmtp", "smtpSrv", ""); %>">
    </TD>
   </TR>
   <TR>
      <TD width="25%" class="column_title"><% iw_webCfgDescHandler("emailSmtp", "userName", "User name"); %></TD>
      <TD width="75%">
       <INPUT type="text" id="iw_emailSmtp_userName" name="iw_emailSmtp_userName" size="37" maxlength="32" value = "<% iw_webCfgValueHandler("emailSmtp", "userName", ""); %>">
      </TD>
     </TR>
     <TR>
      <TD width="25%" class="column_title"><% iw_webCfgDescHandler("emailSmtp", "password", "Password"); %></TD>
      <TD width="75%">
       <INPUT type="password" id="iw_emailSmtp_password" name="iw_emailSmtp_password" size="21" maxlength="16" value = "<% iw_webCfgValueHandler("emailSmtp", "password", ""); %>">
      </TD>
     </TR>
   <TR>
    <TD width="25%" class="column_title"><% iw_webCfgDescHandler("emailSmtp", "from", "From e-mail address"); %></TD>
    <TD width="75%">
     <INPUT type="text" id="iw_emailSmtp_from" name="iw_emailSmtp_from" size="69" maxlength="63" value = "<% iw_webCfgValueHandler("emailSmtp", "from", ""); %>">
    </TD>
   </TR>
   <TR>
    <TD width="25%" class="column_title"><% iw_webCfgDescHandler("emailSmtp", "mailAddr1", "To e-mail address 1"); %></TD>
    <TD width="75%">
     <INPUT type="text" id="iw_emailSmtp_mailAddr1" name="iw_emailSmtp_mailAddr1" size="69" maxlength="63" value = "<% iw_webCfgValueHandler("emailSmtp", "mailAddr1", ""); %>">
    </TD>
   </TR>
   <TR>
    <TD width="25%" class="column_title"><% iw_webCfgDescHandler("emailSmtp", "mailAddr2", "To e-mail address 2"); %></TD>
    <TD width="75%">
     <INPUT type="text" id="iw_emailSmtp_mailAddr2" name="iw_emailSmtp_mailAddr2" size="69" maxlength="63" value = "<% iw_webCfgValueHandler("emailSmtp", "mailAddr2", ""); %>">
    </TD>
   </TR>
   <TR>
    <TD width="25%" class="column_title"><% iw_webCfgDescHandler("emailSmtp", "mailAddr3", "To e-mail address 3"); %></TD>
    <TD width="75%">
     <INPUT type="text" id="iw_emailSmtp_mailAddr3" name="iw_emailSmtp_mailAddr3" size="69" maxlength="63" value = "<% iw_webCfgValueHandler("emailSmtp", "mailAddr3", ""); %>">
    </TD>
   </TR>
   <TR>
    <TD width="25%" class="column_title"><% iw_webCfgDescHandler("emailSmtp", "mailAddr4", "To e-mail address 4"); %></TD>
    <TD width="75%">
     <INPUT type="text" id="iw_emailSmtp_mailAddr4" name="iw_emailSmtp_mailAddr4" size="69" maxlength="63" value = "<% iw_webCfgValueHandler("emailSmtp", "mailAddr4", ""); %>">
    </TD>
   </TR>
   <TR>
    <TD colspan="2"><HR>
     <INPUT type="submit" name="Submit" value="Submit">
     <input type="button" value="Send Test Mail" onclick="javascript:EmailTest(this);">
     <Input type="hidden" name="bkpath" value="/email_server.asp">
     <span id="EmailTestMsg"></span>
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
