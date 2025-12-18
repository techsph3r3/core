<HTML>
<HEAD>
 <META http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
    <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate" />
    <meta http-equiv="Pragma" content="no-cache" />
    <meta http-equiv="Expires" content="0" />
 <LINK href="nport2g.css" rel=stylesheet type=text/css>
 <TITLE><% iw_webSysDescHandler("OvpnSrvConfExport", "", "Server to User Config"); %></TITLE>
 <% iw_webJSList_get(); %>
 <SCRIPT type="text/javascript">
 <!--

  function Backup()
  {
         document.location.href='ovpncli_config.ini' ;
  }

  function iw_x509OnLoad()
        {
            $.ajax({url:'/forms/webOvpnSrvCheckKey', type: 'GET', async: false, data: 'index=0&enc_type=root_ca', success: function(data) {
                    if (data == "X509_ROOT_CA_OK")
                    {
                        document.getElementById("ovpn_export").disabled = false;
                        $("#ovpn_export").css(({'color':'menutext'}));
                    }
                    else
                    {
                        document.getElementById("ovpn_export").disabled = true;
                        $("#ovpn_export").css(({'color':'gray'}));
                    }
                }
            });
  }


  function editPermission()
  {
   if(<% iw_websCheckPermission(); %>)
                        document.getElementById("ovpn_export").disabled = true;
  }


  var mem_state = <% iw_websMemoryChange(); %>;
  function iw_ChangeOnLoad()
  {


                 editPermission();


   top.toplogo.location = "./top.asp?time="+new Date();
   top.toplogo.location.reload();
  }

 //-->
 </SCRIPT>
</HEAD>
<BODY onLoad="iw_x509OnLoad();iw_ChangeOnLoad();">
 <H2><% iw_webSysDescHandler("OvpnSrvConfExport", "", "Server to User Config"); %> <% iw_websGetErrorString(); %></H2>
 <TABLE width="100%">
  <tr>
   <TD width="25%" class="column_title" colspan="2"><% iw_webSysDescHandler("OvpnSrvUserConfigExport", "", "User Config File Export"); %></TD>
  <TR>
   <TD colspan="2"><HR>
    <INPUT type="button" id="ovpn_export" name="ovpn_export" value="Export" onClick="Backup()">
   </TD>
  </TR>
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
