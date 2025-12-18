<HTML>
<HEAD>
    <META http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
    <META http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate" />
    <META http-equiv="Pragma" content="no-cache" />
    <META http-equiv="Expires" content="0" />
    <LINK href="nport2g.css" rel=stylesheet type=text/css>
    <TITLE><% iw_webSysDescHandler("X509Generate", "", "Certficate Generation"); %></TITLE>
 <% iw_webJSList_get(); %>
    <SCRIPT type="text/javascript">

 var root_ca = <% iw_webOvpnGetCAInfo(); %> ;
 var ovpnsrv_ca = <% iw_webOvpnGetSrvCAInfo(); %> ;
 var ovpncli_ca = <% iw_webOvpnGetCliCAInfo(); %> ;

 $(function(){
  $('#gen_root_ca').click(function(){
   gen_rootca();
  });

  $('#iw_export_rootca').click(function(){
   export_root_ca_cert();
  });

  /* Generate Certificate */
  $('#gen_cert').click(function(){
            gen_ca();
        });
 });

 function verify_x509_name(name, str)
    {
        var i;
        alphanum1 = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.-_@!#$%^&*()";
        ret = 1;

        if (name.value.length > 0)
        {
            for (i=0; i <name.value.length; i++)
            {
                if (alphanum1.indexOf(name.value.charAt(i)) < 0)
                {
                    ret = 0;
                    alert(str + " not in correct format, must be a-z, A-Z, 0-9, or.-_!@#$%^&*()");
                    name.focus();
                 break;
             }
         }
        }
     return ret;
    }

 /* Root CA */
 function disable_all_button()
 {
  /* Gen Cert */
  document.getElementById("gen_root_ca").disabled = true;
        $("#gen_root_ca").css(({'color':'gray'}));
  document.getElementById("gen_cert").disabled = true;
        $("#gen_cert").css(({'color':'gray'}));

  /* Export */
  document.getElementById("iw_export_rootca").disabled = true;
        $("#iw_export_rootca").css(({'color':'gray'}));
        document.getElementById("export_server_pkcs12").disabled = true;
        $("#export_server_pkcs12").css(({'color':'gray'}));
        document.getElementById("export_client_pkcs12").disabled = true;
        $("#export_client_pkcs12").css(({'color':'gray'}));

  /* Delete */
  document.getElementById("iw_del_rootca").disabled = true;
        $("#iw_del_rootca").css(({'color':'gray'}));
        document.getElementById("iw_del_ovpnsrv_ca").disabled = true;
        $("#iw_del_ovpnsrv_ca").css(({'color':'gray'}));
        document.getElementById("iw_del_ovpncli_ca").disabled = true;
        $("#iw_del_ovpncli_ca").css(({'color':'gray'}));
 }

 function del_cert(index, type)
 {
  var cert_index = "index="+index;
  var cert_type = "enc_type="+type;

  if (window.confirm('Click OK to delete certificate.'))
  {
   disable_all_button();
   document.ovpn_x509.action='/forms/webOvpnDelCert?'+cert_index+"&"+cert_type;
   document.ovpn_x509.submit();
  }
 }

 function CAtable()
 {
  var i;
  var color;
  var CAtable = document.getElementById("ca_table")
  /* Root CA */
  for (i = 0 ; i < 1 ; i++)
  {
   var newRow = CAtable.insertRow(CAtable.rows.length);
   newRow.id = newRow.uniqueID;
   if(i%2==0){
    color = "beige";
   }
   else{
    color = "azure";
   }

   newCA = newRow.insertCell(0);
   newCA.className = "column_title";
   newCA.style.backgroundColor = color;
   newCA.innerHTML = root_ca[i][1];

   newCA = newRow.insertCell(1);
   newCA.className = "column_title";
   newCA.style.backgroundColor = color;
   newCA.innerHTML = root_ca[i][2];

   newCA = newRow.insertCell(2);
   newCA.className = "column_title";
   newCA.style.backgroundColor = color;
   if (i == 0)
    newCA.innerHTML = "<input type=\"button\" value=\"Delete\" id=\"iw_del_rootca\" onClick=\"del_cert(\'0\', \'x509_root_ca\');\" />";
  }

  /* Server CA */
  CAtable = document.getElementById("ovpnca_table")
  for (i = 0 ; i < 1 ; i++)
  {
   var newRow = CAtable.insertRow(CAtable.rows.length);
   newRow.id = newRow.uniqueID;
   if(i%2==0){
    color = "beige";
   }
   else{
    color = "azure";
   }

   newCA = newRow.insertCell(0);
   newCA.className = "column_title";
   newCA.style.backgroundColor = color;
   newCA.innerHTML = ovpnsrv_ca[i][1];

   newCA = newRow.insertCell(1);
   newCA.className = "column_title";
   newCA.style.backgroundColor = color;
   newCA.innerHTML = ovpnsrv_ca[i][2];

   newCA = newRow.insertCell(2);
   newCA.className = "column_title";
   newCA.style.backgroundColor = color;
   if (i == 0)
    newCA.innerHTML = "<input type=\"button\" value=\"Delete\" id=\"iw_del_ovpnsrv_ca\" onClick=\"del_cert(\'0\', \'x509_ovpnsrv_ca\');\" /><input type=\"button\" value=\"PKCS#12 Export\" id=\"export_server_pkcs12\" onClick=\"export_server_ca_cert();\"> ";
  }

  /* Client CA */
  CAtable = document.getElementById("ovpnca_table")
  for (i = 0 ; i < 1 ; i++)
  {
   var newRow = CAtable.insertRow(CAtable.rows.length);
   newRow.id = newRow.uniqueID;
   if(i%2==0){
    color = "azure";
   }
   else{
    color = "beige";
   }

   newCA = newRow.insertCell(0);
   newCA.className = "column_title";
   newCA.style.backgroundColor = color;
   newCA.innerHTML = ovpncli_ca[i][1];

   newCA = newRow.insertCell(1);
   newCA.className = "column_title";
   newCA.style.backgroundColor = color;
   newCA.innerHTML = ovpncli_ca[i][2];

   newCA = newRow.insertCell(2);
   newCA.className = "column_title";
   newCA.style.backgroundColor = color;
   if (i == 0)
    newCA.innerHTML = "<input type=\"button\" value=\"Delete\" id=\"iw_del_ovpncli_ca\" onClick=\"del_cert(\'0\', \'x509_ovpncli_ca\');\" /><input type=\"button\" value=\"PKCS#12 Export\" id=\"export_client_pkcs12\" onClick=\"export_client_ca_cert();\">";
  }

 }

 function gen_rootca()
 {
  var form = document.ovpn_x509;

  if (!isValidNumber(form.iw_OvpnRootCA_cert_days, 1, 99999, "<% iw_webCfgDescHandler("IPSecX509", "cert_days", ""); %>"))
  {
   form.iw_OvpnRootCA_cert_days.focus();
   return false;
  }

  if (form.iw_OvpnRootCA_cert_country_name.value.length <= 0)
  {
   alert("Please set Country name.");
   form.iw_OvpnRootCA_cert_country_name.focus();
   return false;
  }

  if (!verify_x509_name(form.iw_OvpnRootCA_cert_country_name, "<% iw_webCfgDescHandler("IPSecX509", "cert_country_name", ""); %>"))
  {
   return false;
  }

  if (form.iw_OvpnRootCA_cert_state_name.value.length <= 0)
  {
   alert("Please set State or province name.");
   form.iw_OvpnRootCA_cert_state_name.focus();
   return false;
  }

  if (!verify_x509_name(form.iw_OvpnRootCA_cert_state_name, "<% iw_webCfgDescHandler("IPSecX509", "cert_state_name", ""); %>"))
  {
   return false;
  }

  if (!verify_x509_name(form.iw_OvpnRootCA_cert_city, "<% iw_webCfgDescHandler("IPSecX509", "cert_city", ""); %>"))
  {
   return false;
  }

  if (form.iw_OvpnRootCA_cert_oragnization_name.value.length <= 0)
  {
   alert("Please set Organization name.");
   form.iw_OvpnRootCA_cert_oragnization_name.focus();
   return false;
  }

  if (!verify_x509_name(form.iw_OvpnRootCA_cert_oragnization_name, "<% iw_webCfgDescHandler("IPSecX509", "cert_oragnization_name", ""); %>"))
  {
   return false;
  }

  if (!verify_x509_name(form.iw_OvpnRootCA_cert_oragnization_unit, "<% iw_webCfgDescHandler("IPSecX509", "cert_oragnization_unit", ""); %>"))
  {
    return false;
  }

  if (form.iw_OvpnRootCA_cert_common_name.value.length <= 0)
  {
   alert("Please set Common name.");
   form.iw_OvpnRootCA_cert_common_name.focus();
   return false;
  }

  if (!verify_x509_name(form.iw_OvpnRootCA_cert_common_name, "<% iw_webCfgDescHandler("IPSecX509", "cert_common_name", ""); %>"))
  {
   return false;
  }

  if (!verify_x509_name(form.iw_OvpnRootCA_cert_email, "<% iw_webCfgDescHandler("IPSecX509", "cert_email", ""); %>"))
  {
   return false;
  }

  disable_all_button();

  document.ovpn_x509.action= '/forms/webOvpnGenRootCACert';
        form.submit();
 }

 function export_root_ca_cert()
    {
     document.location.href='cert.pem?index=0&type=ovpn_x509_root_ca';
    }

 /* Generate CA */
 function gen_ca()
 {
  var form = document.ovpnca_x509;

  if ("<% iw_webCfgValueHandler("OvpnRootCA", "cert_state_name", ""); %>" == "")
  {
   alert("Please generate Root CA first!");
   return false;
  }

  if (!isValidNumber(form.iw_OvpnCA_days, 1, 99999, "<% iw_webCfgDescHandler("IPSecX509", "cert_days", ""); %>"))
  {
   form.iw_OvpnCA_days.focus();
   return false;
  }

  if (form.iw_OvpnCA_password.value.length < 4)
  {
   alert("Please set Certificate Password. You must type in 4 to 63 characters");
   form.iw_OvpnCA_password.focus();
   return false;
  }

  if (!verify_x509_name(form.iw_OvpnCA_password, "<% iw_webCfgDescHandler("IPSecX509", "cert_password", ""); %>"))
  {
   return false;
  }

  if (!verify_x509_name(form.iw_OvpnCA_oragnization_unit, "<% iw_webCfgDescHandler("IPSecX509", "cert_oragnization_unit", ""); %>"))
  {
   return false;
  }

  if (!verify_x509_name(form.iw_OvpnCA_email, "<% iw_webCfgDescHandler("IPSecX509", "localcert1name", ""); %>"))
  {
   return false;
  }

  if (form.iw_OvpnCA_mode.value == "SERVER" )
  {
   document.ovpnca_x509.action= '/forms/webOvpnGenServerCert';
  }
  else
  {
   document.ovpnca_x509.action= '/forms/webOvpnGenClientCert';
  }

  disable_all_button();

        form.submit();
 }

 function export_server_ca_cert()
    {
        document.location.href='cert.pem?index=0&type=ovpn_x509_server_ca';
    }

 function export_client_ca_cert()
    {
        document.location.href='cert.pem?index=0&type=ovpn_x509_client_ca';
    }

 function iw_x509OnLoad()
    {
     $.ajax({url:'/forms/webOvpnCheckKey', type: 'GET', async: false, data: 'index=0&enc_type=root_ca', success: function(data) {
         if (data == "X509_ROOT_CA_OK")
         {
    document.getElementById("iw_export_rootca").disabled = false;
                $("#iw_export_rootca").css(({'color':'menutext'}));
                document.getElementById("iw_del_rootca").disabled = false;
                $("#iw_del_rootca").css(({'color':'menutext'}));
         }
   else
   {
    document.getElementById("iw_export_rootca").disabled = true;
                $("#iw_export_rootca").css(({'color':'gray'}));
                document.getElementById("iw_del_rootca").disabled = true;
                $("#iw_del_rootca").css(({'color':'gray'}));
   }
   }
     });

     $.ajax({url:'/forms/webOvpnCheckKey', type: 'GET', async: false, data: 'index=0&enc_type=server_ca', success: function(data) {
         if (data == "X509_SERVER_CA_OK")
         {
    document.getElementById("export_server_pkcs12").disabled = false;
                $("#export_server_pkcs12").css(({'color':'menutext'}));
                document.getElementById("iw_del_ovpnsrv_ca").disabled = false;
                $("#iw_del_ovpnsrv_ca").css(({'color':'menutext'}));
         }
   else
   {
    document.getElementById("export_server_pkcs12").disabled = true;
                $("#export_server_pkcs12").css(({'color':'gray'}));
                document.getElementById("iw_del_ovpnsrv_ca").disabled = true;
                $("#iw_del_ovpnsrv_ca").css(({'color':'gray'}));
   }
   }
     });

  $.ajax({url:'/forms/webOvpnCheckKey', type: 'GET', async: false, data: 'index=0&enc_type=client_ca', success: function(data) {
         if (data == "X509_CLIENT_CA_OK")
         {
    document.getElementById("export_client_pkcs12").disabled = false;
                $("#export_client_pkcs12").css(({'color':'menutext'}));
                document.getElementById("iw_del_ovpncli_ca").disabled = false;
                $("#iw_del_ovpncli_ca").css(({'color':'menutext'}));
         }
   else
   {
    document.getElementById("export_client_pkcs12").disabled = true;
                $("#export_client_pkcs12").css(({'color':'gray'}));
                document.getElementById("iw_del_ovpncli_ca").disabled = true;
                $("#iw_del_ovpncli_ca").css(({'color':'gray'}));
   }
   }
     });
 }


 function editPermission()
 {
  var form = document.ovpn_x509, i, j = <% iw_websCheckPermission(); %>;
  var form2 = document.ovpnca_x509;
  if(j)
  {
   for(i = 0; i < form.length; i++)
    form.elements[i].disabled = true;

   for(i = 0; i < form2.length; i++)
    form2.elements[i].disabled = true;

   /* Gen */
   document.getElementById("gen_root_ca").disabled = true;
   document.getElementById("gen_cert").disabled = true;

   /* Delete */
   document.getElementById("iw_del_rootca").disabled = true;
   document.getElementById("iw_del_ovpnsrv_ca").disabled = true;
   document.getElementById("iw_del_ovpncli_ca").disabled = true;
  }
 }


 var mem_state = <% iw_websMemoryChange(); %>;

 function iw_ChangeOnLoad()
 {

  editPermission();

  if (top.toplogo != null)
  {
   top.toplogo.location = "./top.asp?time="+new Date();
   top.toplogo.location.reload();
  }
 }
 </SCRIPT>
</HEAD>
<BODY onLoad="CAtable();iw_ChangeOnLoad();iw_x509OnLoad();">
<FORM id="ovpn_x509" name="ovpn_x509" method="POST">
 <H2>
  <% iw_webSysDescHandler("X509Generate", "", "Certificate Generation"); %> <% iw_websGetErrorString(); %>
 </H2>
     <TABLE width="100%" id="root_ca">
            <TR>
                <TD width="25%" class="column_title" colspan="2">
     <% iw_webSysDescHandler("IPSecX509CertGen", "", "Root Certificate Generation"); %>
    </TD>
            </TR>
            <TR>
             <TD width="30%" class="column_title">
     <% iw_webCfgDescHandler("IPSecX509", "cert_days", ""); %>
    </TD>
                <TD width="70%">
                 <INPUT type="text" id="iw_OvpnRootCA_cert_days" name="iw_OvpnRootCA_cert_days" size="6" maxlength="5" value="<% iw_webCfgValueHandler("OvpnRootCA", "cert_days", ""); %>"> (days)
             </TD>
            </TR>
            <TR>
             <TD width="30%" class="column_title">
     <% iw_webCfgDescHandler("IPSecX509", "cert_country_name", ""); %>
    </TD>
                <TD width="70%">
                 <INPUT type="text" id="iw_OvpnRootCA_cert_country_name" name="iw_OvpnRootCA_cert_country_name" size="3" maxlength="2" value="<% iw_webCfgValueHandler("OvpnRootCA", "cert_country_name", ""); %>">
             </TD>
            </TR>
            <TR>
             <TD width="30%" class="column_title">
     <% iw_webCfgDescHandler("IPSecX509", "cert_state_name", ""); %>
    </TD>
                <TD width="70%">
                 <INPUT type="text" id="iw_OvpnRootCA_cert_state_name" name="iw_OvpnRootCA_cert_state_name" size="40" maxlength="31" value="<% iw_webCfgValueHandler("OvpnRootCA", "cert_state_name", ""); %>">
             </TD>
   <TR>
             <TD width="30%" class="column_title">
     <% iw_webCfgDescHandler("IPSecX509", "cert_city", ""); %>
    </TD>
                <TD width="70%">
                 <INPUT type="text" id="iw_OvpnRootCA_cert_city" name="iw_OvpnRootCA_cert_city" size="40" maxlength="31" value="<% iw_webCfgValueHandler("OvpnRootCA", "cert_city", ""); %>">
             </TD>
            </TR>
            <TR>
             <TD width="30%" class="column_title">
     <% iw_webCfgDescHandler("IPSecX509", "cert_oragnization_name", ""); %>
    </TD>
                <TD width="70%">
                 <INPUT type="text" id="iw_OvpnRootCA_cert_oragnization_name" name="iw_OvpnRootCA_cert_oragnization_name" size="40" maxlength="31" value="<% iw_webCfgValueHandler("OvpnRootCA", "cert_oragnization_name", ""); %>">
             </TD>
            </TR>
            <TR>
             <TD width="30%" class="column_title">
     <% iw_webCfgDescHandler("IPSecX509", "cert_oragnization_unit", ""); %>
    </TD>
                <TD width="70%">
                 <INPUT type="text" id="iw_OvpnRootCA_cert_oragnization_unit" name="iw_OvpnRootCA_cert_oragnization_unit" size="40" maxlength="31" value="<% iw_webCfgValueHandler("OvpnRootCA", "cert_oragnization_unit", ""); %>">
             </TD>
            </TR>
            <TR>
             <TD width="30%" class="column_title">
     <% iw_webCfgDescHandler("IPSecX509", "cert_common_name", ""); %>
    </TD>
                <TD width="70%">
                 <INPUT type="text" id="iw_OvpnRootCA_cert_common_name" name="iw_OvpnRootCA_cert_common_name" size="40" maxlength="31" value="<% iw_webCfgValueHandler("OvpnRootCA", "cert_common_name", ""); %>">
             </TD>
            </TR>
            <TR>
             <TD width="30%" class="column_title">
     <% iw_webCfgDescHandler("IPSecX509", "cert_email", ""); %>
    </TD>
                <TD width="70%">
                 <INPUT type="text" id="iw_OvpnRootCA_cert_email" name="iw_OvpnRootCA_cert_email" size="69" maxlength="63" value="<% iw_webCfgValueHandler("OvpnRootCA", "cert_email", ""); %>">
             </TD>
            </TR>
   <TR>
             <TD>
                 <INPUT width="100" type="button" id="gen_root_ca" value="Generate Root CA">
                 <iNPUT width="100" type="button" id="iw_export_rootca" value="Export Root CA">
                 <INPUT type="hidden" name="bkpath" value="/ovpn_x509_gen.asp">
             </TD>
            </TR>
  </TABLE>
  <TABLE width="100%" id="ca_table">
         <TR>
                <TD class="block_title" width="10%">Name</td>
                <TD class="block_title" width="70%">Subject</td>
                <TD class="block_title" width="20%">Action</td>
         </TR>
        </TABLE>
</FORM>
<FORM id="ovpnca_x509" name="ovpnca_x509" method="POST">
  <TABLE width="100%" id="ovpn_ca">
            <TR>
             <TD colspan="2"><HR></TD>
            </TR>
            <TR>
                <TD width="25%" class="column_title">
     <% iw_webSysDescHandler("OpenVPNCertGen", "", "Certificate Generation"); %>
    </TD>
    <TD width="75%">
                 <SELECT size="1" id="iw_OvpnCA_mode" name="iw_OvpnCA_mode">
                  <OPTION value="SERVER">Server</OPTION>
                  <OPTION value="CLIENT">Client</OPTION>
                 </SELECT>
             </TD>
            </TR>
            <TR>
             <TD width="30%" class="column_title">
     <% iw_webCfgDescHandler("IPSecX509", "cert_days", ""); %>
    </TD>
                <TD width="70%">
                 <INPUT type="text" id="iw_OvpnCA_days" name="iw_OvpnCA_days" size="6" maxlength="5"> (days)
             </TD>
            </TR>
            <TR>
             <TD width="30%" class="column_title">
     <% iw_webCfgDescHandler("IPSecX509", "cert_password", ""); %> (4 to 63 characters)
    </TD>
                <TD width="70%">
                 <INPUT type="text" id="iw_OvpnCA_password" name="iw_OvpnCA_password" size="69" maxlength="63">
             </TD>
            </TR>
            <TR>
             <TD width="30%" class="column_title">
     <% iw_webCfgDescHandler("IPSecX509", "cert_oragnization_unit", ""); %>
    </TD>
                <TD width="70%">
                 <INPUT type="text" id="iw_OvpnCA_oragnization_unit" name="iw_OvpnCA_oragnization_unit" size="40" maxlength="31">
             </TD>
            </TR>
            <TR>
             <TD width="30%" class="column_title">
     <% iw_webCfgDescHandler("IPSecX509", "cert_email", ""); %>
    </TD>
                <TD width="70%">
                 <INPUT type="text" id="iw_OvpnCA_email" name="iw_OvpnCA_email" size="69" maxlength="63">
             </TD>
            </TR>
            <TR>
             <TD>
                 <INPUT width="100" type="button" id="gen_cert" value="Generate Certificate" />
                 <INPUT type="hidden" name="bkpath" value="/ovpn_x509_gen.asp">
             </TD>
            </TR>
        </TABLE>
  <TABLE width="100%" id="ovpnca_table">
         <TR>
                <TD class="block_title" width="10%">Name</td>
                <TD class="block_title" width="70%">Subject</td>
                <TD class="block_title" width="20%">Action</td>
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
