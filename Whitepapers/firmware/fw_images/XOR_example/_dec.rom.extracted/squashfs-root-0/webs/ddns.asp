<html>
<head>
 <META http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
 <LINK href="nport2g.css" rel="stylesheet" type="text/css">
 <title><% iw_webSysDescHandler("DDNSTree", "", "DDNS"); %></title>
 <% iw_webJSList_get(); %>
 <script language="JavaScript">

 var data = { "ddns" : { "enable" : "<% iw_webCfgValueHandler("ddns", "enable", ""); %>",
       "serviceProvider" : "<% iw_webCfgValueHandler("ddns", "serviceProvider", ""); %>",
        }
    };

 $(document).ready( function() {
  iw_loadConfig(data);
  draw_ddns_info(data['ddns']['serviceProvider']);
  event_change($('#iw_ddns_serviceProvider'));
  iw_changeStateOnLoad(top);
 });

 function draw_ddns_info( provider )
 {
  if ( provider == 'dyndns.org' ) {
   $('#ddns_dyndns').show();
   $('#ddns_no-ip').hide();
  } else if ( provider == 'no-ip.org' ) {
   $('#ddns_no-ip').show();
   $('#ddns_dyndns').hide();
  } else {
   // no such option
  }
 }

 function event_change ( slt )
 {
  $(slt).bind ('change', function(event) {
   draw_ddns_info($(this).val());
  });
 }


        function editPermission()
        {
                var form = document.DynDNS, i, j = <% iw_websCheckPermission(); %>;
                if(j)
                {
                        for(i = 0; i < form.length; i++)
                                form.elements[i].disabled = true;
                }
        }


        function iw_OnLoad()
        {

                editPermission();

                top.toplogo.location.reload();
        }

 </script>
</head>
<body onload="iw_OnLoad();">
 <H2><% iw_webSysDescHandler("DDNSTree", "", "DDNS"); %> <% iw_websGetErrorString(); %></H2>
 <form name="DynDNS" method="POST" action="/forms/iw_webSetParameters">
  <table width="100%">
   <tr>
    <td width="30%" class="column_title"><% iw_webCfgDescHandler("ddns", "enable", ""); %></td>
    <td width="70%">
     <select id="iw_ddns_enable" name="iw_ddns_enable">
      <option VALUE="ENABLE">Enable</option>
      <option VALUE="DISABLE">Disable</option>
     </select>
    </td>
   </tr>
   <tr>
    <td width="30%" class="column_title"><% iw_webCfgDescHandler("ddns", "serviceProvider", ""); %></td>
    <td width="70%">
     <select id="iw_ddns_serviceProvider" name="iw_ddns_serviceProvider">
      <option VALUE="no-ip.org">no-ip.org</option>
      <option VALUE="dyndns.org">dyndns.org</option>
     </select>
    </td>
   </tr>
  </table>
  <table id="ddns_no-ip">
   <tr>
    <td width="30%" class="column_title"><% iw_webCfgDescHandler("ddns", "hostname1", ""); %></td>
    <td width="70%">
     <input name= "iw_ddns_hostname1" id="iw_ddns_hostname1" type="text" maxlength="31" size="36" value="<% iw_webCfgValueHandler("ddns", "hostname1", ""); %>">
    </td>
   </tr>
   <tr>
    <td width="30%" class="column_title"><% iw_webCfgDescHandler("ddns", "userName1", ""); %></td>
    <td width="70%">
     <input name= "iw_ddns_userName1" id="iw_ddns_userName1" type="text" maxlength="31" size="36" value="<% iw_webCfgValueHandler("ddns", "userName1", ""); %>">
    </td>
   </tr>
   <tr>
    <td width="30%" class="column_title"><% iw_webCfgDescHandler("ddns", "userPassword1", ""); %></td>
    <td width="70%">
     <input type="password" name= "iw_ddns_userPassword1" id="iw_ddns_userPassword1" maxlength="31" size="36" value="<% iw_webCfgValueHandler("ddns", "userPassword1", ""); %>">
    </td>
   </tr>
  </table>
  <table id="ddns_dyndns">
   <tr>
    <td width="30%" class="column_title"><% iw_webCfgDescHandler("ddns", "hostname2", ""); %></td>
    <td width="70%">
     <input name= "iw_ddns_hostname2" id="iw_ddns_hostname2" type="text" maxlength="31" size="36" value="<% iw_webCfgValueHandler("ddns", "hostname2", ""); %>">
    </td>
   </tr>
   <tr>
    <td width="30%" class="column_title"><% iw_webCfgDescHandler("ddns", "userName2", ""); %></td>
    <td width="70%">
     <input name= "iw_ddns_userName2" id="iw_ddns_userName2" type="text" maxlength="31" size="36" value="<% iw_webCfgValueHandler("ddns", "userName2", ""); %>">
    </td>
   </tr>
   <tr>
    <td width="30%" class="column_title"><% iw_webCfgDescHandler("ddns", "userPassword2", ""); %></td>
    <td width="70%">
     <input type="password" name= "iw_ddns_userPassword2" id="iw_ddns_userPassword2" maxlength="31" size="36" value="<% iw_webCfgValueHandler("ddns", "userPassword2", ""); %>">
    </td>
   </tr>
  </table>
  <hr />
  <input type="submit" value="Submit" name="submit" />
  <input type="hidden" name="bkpath" value="ddns.asp">
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
