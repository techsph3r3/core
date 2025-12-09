<html>
<head>
 <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
 <link href="nport2g.css" rel="stylesheet" type="text/css">
 <TITLE><% iw_webSysDescHandler("AccountStatus", "", "Account Status"); %></TITLE>
 <% iw_webJSList_get(); %>
 <script type="text/javascript">
 <!--


  function editPermission()
  {
   var form = document.AccountMgmt, i, j = <% iw_websCheckPermission(); %>;
   if(j)
   {
    for(i = 0; i < form.length; i++)
     form.elements[i].disabled = true;
   }
  }




  function iw_onLoad()
  {
   var i;
   var index;
   /* Account Management */
   iw_selectSet(document.AccountMgmt.iw_accountMgmt_passwdStrengthCheck, "<% iw_webCfgValueHandler("accountMgmt", "passwdStrengthCheck"  , "ENABLE"); %>");
   for (i = 1; i <= 8; i++)
   {
    index = "iw_account_del_index"+i;
    if (document.getElementById("iw_account"+ i +"_username").value == "")
    {
     document.getElementById(index).disabled = true;
     $("#"+index).css(({'color':'gray'}));
    }

   }


                 editPermission();

   top.toplogo.location.reload();
  }

  function check_access_portals()
  {
   var form = document.AccountMgmt;
   var idx;
   var account = "na", iw_account= "na", account_http = "na";
   var access_poartls = 0;
   var access_https = 0;

   for( idx= 0; idx < form.length; idx++ )
   {
    if( form.elements[idx].id.match(/account.*_active.*/) && !form.elements[idx].id.match(/iw_account.*_active.*/) )
    {
     if( form.elements[idx].checked )
     {
      account = form.elements[idx].id.substr(0, 8);
      iw_account = "iw_" + account;
     }
     continue;
    } else if( form.elements[idx].id.match(account) && !form.elements[idx].id.match(iw_account) )
    {
     if( form.elements[idx].checked )
      access_poartls = 1;

     if( form.elements[idx].id.match(account + "_accessHttp")
      && form.elements[idx].checked )
      access_https = 1;
    }
   }

   if( access_https == 0 )
   {
    if( confirm("Warning! Some features of Moxa service will not work if HTTPS is disabled.") == false )
     return false;
   }

   if( access_poartls == 0 )
    return confirm("Warning! This device cannot be accessed remotely.");

   return true;
  }

  function CheckValue(form)
  {
   var idx;

   if( check_access_portals() == false )
    return false;

   for(idx = 0; idx < form.length; idx++)
   {
    if(form.elements[idx].type != "checkbox")
     continue;

    if(form.elements[idx].checked)
     form.elements["iw_" + form.elements[idx].id].value = "ENABLE";
    else
     form.elements["iw_" + form.elements[idx].id].value = "DISABLE";
   }
   return true;
  }

                function iw_account_del(accountIndex)
                {
                        if (window.confirm('Click OK to load account' + accountIndex + ' factory default settings.'))
                        {
    var form = document.AccountMgmt;
    if (CheckValue(form) == true)
    {
     document.getElementById("account_index").value=accountIndex;
     form.action='/forms/webDelaccount';
     form.submit();
    }
                        }
                }
    -->
    </script>
</head>
<body onload="iw_onLoad();">
 <h2><% iw_webSysDescHandler("AccountSetting", "", "Account Settings"); %> &nbsp;&nbsp;<% iw_websGetErrorString(); %></h2>
    <form name="AccountMgmt" method="POST" action="/forms/iw_webSetParameters" onSubmit="return CheckValue(this)">
   <h2>Password Policy</h2>
        <table width="100%">
   <tr>
                <td width="30%" class="column_title"><% iw_webCfgDescHandler("accountMgmt", "passwdLength", "Minimum password length"); %></td>
                <td width="70%">
                    <input name= "iw_accountMgmt_passwdLength" id="iw_accountMgmt_passwdLength" type="text" maxlength="3" size="5" value="<% iw_webCfgValueHandler("accountMgmt", "passwdLength", ""); %>"> (4 to 16 characters)
                </td>
            </tr>
            <tr>
                <td width="30%" class="column_title"><% iw_webCfgDescHandler("accountMgmt", "passwdStrengthCheck", "Passwowrd strength check"); %></td>
                <td width="70%">
                    <select id="iw_accountMgmt_passwdStrengthCheck" name="iw_accountMgmt_passwdStrengthCheck">
                        <option VALUE="ENABLE">Enable</option>
                        <option VALUE="DISABLE">Disable</option>
                    </select>
                </td>
            </tr>
            <tr>
                <td width="30%" class="column_title"><% iw_webCfgDescHandler("accountMgmt", "passwdExpiredTime", "Password expired time"); %></td>
                <td width="70%">
                    <input name= "iw_accountMgmt_passwdExpiredTime" id="iw_accountMgmt_passwdExpiredTime" type="text" maxlength="3" size="5" value="<% iw_webCfgValueHandler("accountMgmt", "passwdExpiredTime", ""); %>"> (0 to 365 days, 0 is disable)
                </td>
            </tr>
            <tr>
                <td width="30%" class="column_title"><% iw_webCfgDescHandler("accountMgmt", "loginretry", "Password retry count"); %></td>
                <td width="70%">
                    <input name= "iw_accountMgmt_loginretry" id="iw_accountMgmt_loginretry" type="text" maxlength="2" size="5" value="<% iw_webCfgValueHandler("accountMgmt", "loginretry", ""); %>"> (0 to 10, 0 is disable)
                </td>
            </tr>
   <tr>
     <td width="30%" class="column_title"><% iw_webCfgDescHandler("accountMgmt", "loginlockTime", "Lockout time"); %></td>
     <td width="70%">
    <input name= "iw_accountMgmt_loginlockTime" id="iw_accountMgmt_loginlockTime" type="text" maxlength="4" size="5" value="<% iw_webCfgValueHandler("accountMgmt", "loginlockTime", ""); %>"> (60 to 3600 seconds)
     </td>
   </tr>
        </table>
  <br>
  <h2>Account List</h2>
  <% iw_webGetAccountList(); %>
  *The only characters allowed in the Account Name are alphanumeric characters, the "at" sign (@), periods (.), and underscores (_).
        <hr />
        <input type="submit" value="Submit" name="Submit" />
        <input type="hidden" name="bkpath" value="account_status.asp">
        <Input type="hidden" id="account_index" name="account_index" value="">
    </form>
</body>
</html>
<script language="JavaScript" src="js/jquery-1.5.2.min.js"></script>
<script type="text/javascript">
	$(document).ready(function () {
		var isEditPermission = !<% iw_websCheckPermission(); %>;
		if (isEditPermission == 0) {
			$(":input").attr('disabled','disabled');
		}
	});
</script>
