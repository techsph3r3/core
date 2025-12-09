<HTML>
<HEAD>
 <META http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
    <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate" />
    <meta http-equiv="Pragma" content="no-cache" />
    <meta http-equiv="Expires" content="0" />
 <LINK href="nport2g.css" rel=stylesheet type=text/css>
 <TITLE><% iw_webSysDescHandler("OvpnSrvCert", "", "Server Certificate"); %></TITLE>
 <% iw_webJSList_get(); %>
 <SCRIPT type="text/javascript">
  /* Root CA */
  var srv_ca = <% iw_webGetOvpnSrvCAInfo(); %> ;
  /* Server CA */
  var srv_cert = <% iw_webGetOvpnSrvCert(); %> ;

  function verify_cert_name(filename, str)
        {
   var i;
   alphanum1 = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.-_@!#$%^&*()";
   ret = 1;

   for (i=0; i <filename.length; i++)
   {
    if (alphanum1.indexOf(filename.charAt(i)) < 0)
    {
     ret = 0;
     alert(str + " not in correct format, must be a-z, A-Z, 0-9, or.-_!@#$%^&*()");
     break;
    }
   }
   return ret;
  }

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
  function del_srv_rootca(type)
  {
   if (window.confirm('Click OK to delete certificate.'))
   {
    document.getElementById("file_rootca").disabled = true;
                $("#file_rootca").css(({'color':'gray'}));
                document.getElementById("iw_del_srv_ca").disabled = true;
                $("#iw_del_cli_ca").css(({'color':'gray'}));
                document.getElementById("iw_import_srv_ca").disabled = true;
                $("#iw_import_cli_ca").css(({'color':'gray'}));

    document.ovpnsrv_x509.action='/forms/webOvpnSrvDelRootCA';
    document.ovpnsrv_x509.submit();
   }
  }

  function import_srv_rootca(value)
  {
   var file_id;

   if ((document.ovpnsrv_x509.file_rootca.value == ""))
   {
    window.alert("Error! Please specify a file.");
    return false;
   }

   file_id = "file_rootca";

   $.ajaxFileUpload({
    url: '/forms/webOvpnSrvUploadKey?enc_type='+value,
    secureuri: false,
    fileElementId: file_id,
    dataType: 'txt',
    success: function(data)
    {
     if (data == "file_error")
     {
      alert("File is error!")
     }
     else if (data == "file_too_big")
     {
      alert("File size is too big!")
     }
     else if (data == "import_error")
     {
      alert("File import error!")
     }
     else if (data == value)
     {
      document.getElementById("file_rootca").disabled = true;
      $("#file_rootca").css(({'color':'gray'}));
      document.getElementById("iw_del_srv_ca").disabled = true;
      $("#iw_del_cli_ca").css(({'color':'gray'}));
      document.getElementById("iw_import_srv_ca").disabled = true;
      $("#iw_import_cli_ca").css(({'color':'gray'}));

      document.location.reload();
     }
    }
   });
  }

  function rootCAtable()
  {
   var color;
   var CAtable = document.getElementById("root_ca_table")
   var newRow = CAtable.insertRow(CAtable.rows.length);

   newRow.id = newRow.uniqueID;

   color = "beige";

   newCA = newRow.insertCell(0);
   newCA.className = "column_title";
   newCA.style.backgroundColor = color;
   newCA.innerHTML = srv_ca[0];

   newCA = newRow.insertCell(1);
   newCA.className = "column_title";
   newCA.style.backgroundColor = color;
   newCA.innerHTML = srv_ca[1];

   newCA = newRow.insertCell(2);
   newCA.className = "column_title";
   newCA.style.backgroundColor = color;

   newCA.innerHTML = "<INPUT type=\"file\" id=\"file_rootca\" name=\"file_rootca\"><input type=\"button\" value=\"Import\" id=\"iw_import_srv_ca\" onClick=\"import_srv_rootca(\'ovpn_x509_root_ca\');\" />  <input type=\"button\" value=\"Delete\" id=\"iw_del_srv_ca\" onClick=\"del_srv_rootca(\'ovpn_x509_srv_ca\');\" />";
  }

  function iw_x509OnLoad()
  {
   $.ajax({url:'/forms/webOvpnSrvCheckKey', type: 'GET', async: false, data: 'index=0&enc_type=root_ca', success: function(data) {
     if (data == "X509_ROOT_CA_OK")
     {
      document.getElementById("iw_del_srv_ca").disabled = false;
      $("#iw_del_srv_ca").css(({'color':'menutext'}));
     }
     else
     {
      document.getElementById("iw_del_srv_ca").disabled = true;
      $("#iw_del_srv_ca").css(({'color':'gray'}));
     }
    }
   });

   $.ajax({url:'/forms/webOvpnSrvCheckKey', type: 'GET', async: false, data: 'index=0&enc_type=server_ca', success: function(data) {
     if (data == "X509_SERVER_CA_OK")
     {
      document.getElementById("iw_del_srvCert").disabled = false;
      $("#iw_del_srvCert").css(({'color':'menutext'}));
     }
     else
     {
      document.getElementById("iw_del_srvCert").disabled = true;
      $("#iw_del_srvCert").css(({'color':'gray'}));
     }
    }
   });
  }

  /* Server CA */
  function del_srv_cert(type)
        {
            if (window.confirm('Click OK to delete certificate.'))
            {
    document.getElementById("iw_p12_file").disabled = true;
                $("#iw_p12_file").css(({'color':'gray'}));
                document.getElementById("iw_p12_import").disabled = true;
                $("#iw_p12_import").css(({'color':'gray'}));
                document.getElementById("iw_del_srvCert").disabled = true;
                $("#iw_del_cliCert").css(({'color':'gray'}));

                document.ovpn_x509_srv_upload.action='/forms/webOvpnSrvDelCert';
                document.ovpn_x509_srv_upload.submit();
            }
  }

  function import_srv_cert()
        {
            var file_path = document.ovpn_x509_srv_upload.iw_p12_file.value;
            var startIndex = (file_path.indexOf('\\') >= 0 ? file_path.lastIndexOf('\\') : file_path.lastIndexOf('/'));
            var password = document.ovpn_x509_srv_upload.pkcs12_password.value;

            if (file_path == "")
            {
                window.alert("Error! Please specify a file.");
                return false;
            }

            var filename = file_path.substring(startIndex);

            if (filename.indexOf('\\') === 0 || filename.indexOf('/') === 0)
            {
                filename = filename.substring(1);
            }

            if (filename.length > 31)
            {
                alert("Filename is too long. It should be less than 32");
                return false;
            }

            if (!verify_cert_name(filename, "Certificate name"))
            {
                return false;
   }

            if (password.length < 4)
            {
                alert("Please set Certificate Password. You must type in 4 to 63 characters");
                document.ovpn_x509_cli_upload.pkcs12_password.focus();
                return false;
            }

            if (!verify_cert_name(password, "<% iw_webCfgDescHandler("OvpnSrvPKCS", "pkcs12_password", ""); %>"))
            {
                return false;
            }

            $.ajaxFileUpload(
            {
                url: '/forms/webOvpnSrvUploadKey?enc_type=ovpn_x509_srv_pkcs12&filename='+filename+'&password='+password,
                secureuri: false,
                fileElementId: 'iw_p12_file',
    dataType: 'txt',
                success: function(data)
                {
                    if (data == "format_error")
                    {
                        alert("File format error!")
                    }
                    else if (data == "file_too_big")
                    {
                        alert("File size is too big!")
                    }
                    else if (data == "import_error")
                    {
                        alert("File import error!")
                    }
                    else if (data == "file_error")
                    {
                        alert("File import error!")
                    }
                    else if (data == "password_error")
                    {
                        alert("Import Password error!")
                    }
                    else if (data == "ovpn_x509_srv_pkcs12")
                    {
      document.getElementById("iw_p12_file").disabled = true;
                        $("#iw_p12_file").css(({'color':'gray'}));
                        document.getElementById("iw_p12_import").disabled = true;
                        $("#iw_p12_import").css(({'color':'gray'}));
                        document.getElementById("iw_del_srvCert").disabled = true;
                        $("#iw_del_cliCert").css(({'color':'gray'}));

                        document.ovpn_x509_srv_upload.action='/forms/webOvpnSrvCertUpload?&enc_type=ovpn_x509_srv_pkcs12&filename='+filename+'&password='+password;
                        document.ovpn_x509_srv_upload.submit();
                    }
                }
            }

            );
        }
  /* Show the PKCS12 table */
  function PKCS12table()
        {
   var color;
   var Certtable = document.getElementById("pkcs12_cert_table")
   var newRow = Certtable.insertRow(Certtable.rows.length);

   color = "beige";

   newRow.id = newRow.uniqueID;

   newCA = newRow.insertCell(0);
   newCA.className = "column_title";
   newCA.style.backgroundColor = color;
   newCA.innerHTML = srv_cert[1];

   newCA = newRow.insertCell(1);
   newCA.className = "column_title";
   newCA.style.backgroundColor = color;
   newCA.innerHTML = srv_cert[2];

   newCA = newRow.insertCell(2);
   newCA.className = "column_title";
   newCA.style.backgroundColor = color;
   newCA.innerHTML = srv_cert[3];

   newCA = newRow.insertCell(3);
   newCA.className = "column_title";
   newCA.style.backgroundColor = color;
   newCA.innerHTML = "<input type=\"button\" value=\"Delete\" id=\"iw_del_srvCert\" onClick=\"del_srv_cert(\'ovpn_x509_srv_pkcs12\');\" />";
        }


  function editPermission()
  {
   var form = document.ovpnsrv_x509, i, j = <% iw_websCheckPermission(); %>;
   var form2 = document.ovpn_x509_srv_upload;
   if(j)
   {
    for(i = 0; i < form.length; i++)
     form.elements[i].disabled = true;

    for(i = 0; i < form2.length; i++)
     form2.elements[i].disabled = true;

    document.getElementById("file_rootca").disabled = true;
                document.getElementById("iw_import_srv_ca").disabled = true;
                document.getElementById("iw_del_srv_ca").disabled = true;

                document.getElementById("iw_p12_file").disabled = true;
                document.getElementById("iw_p12_import").disabled = true;
                document.getElementById("iw_del_srvCert").disabled = true;
   }
  }


  var mem_state = <% iw_websMemoryChange(); %>;

  function iw_ChangeOnLoad()
  {

      editPermission();

   if (top.toplogo != null)
   {
    top.toplogo.location="./top.asp?time="+new Date();
    top.toplogo.location.reload();
   }
  }

 </SCRIPT>
</HEAD>
<BODY onLoad="rootCAtable();PKCS12table();iw_x509OnLoad();iw_ChangeOnLoad();">
 <FORM id="ovpnsrv_x509" name="ovpnsrv_x509" method="POST">
  <H2><% iw_webSysDescHandler("OvpnSrvCertUpload", "", "Server Certificate Upload"); %> <% iw_websGetErrorString(); %></H2>
  <TR>
            <TD colspan="2"><HR></TD>
        </TR>
  <INPUT type="hidden" name="bkpath" value="/ovpn_srv_cert_option.asp">
  <TABLE width="100%" id="root_ca_table">
         <TR>
             <TD class="block_title" width="10%">Name</TD>
                <TD class="block_title" width="70%">Subject</TD>
                <TD class="block_title" width="20%">Action</TD>
            </TR>
  </TABLE>
 </FORM>
 <FORM id="ovpn_x509_srv_upload" name="ovpn_x509_srv_upload" method="POST">
  <TR>
            <TD colspan="2"><HR></TD>
        </TR>
        <TABLE width="100%" id="p12_upload">
            <TR>
             <TD width="30%" class="column_title">
     <% iw_webSysDescHandler("X509PKCS12Upload", "", "PKCS#12 Upload"); %>
    </TD>
             <TD width="70%">
              <INPUT type="file" id="iw_p12_file" name="iw_p12_file">
              <INPUT type="button" value="Import" id="iw_p12_import" onClick="import_srv_cert()"; />
              <INPUT type="hidden" name="bkpath" value="/ovpn_srv_cert_option.asp">
             </TD>
            </TR>
              <TR>
              <TD width="30%" class="column_title">
      <% iw_webCfgDescHandler("OvpnSrvPKCS", "pkcs12_password", "PKCS#12 Password"); %>
     </TD>
             <TD width="70%">
              <INPUT type="password" id="pkcs12_password" name="pkcs12_password" size="69" maxlength="63">
             </TD>
            </TR>
        </TABLE>
        <TABLE width="100%" id="pkcs12_cert_table">
         <TR>
             <TD class="block_title" width="10%">Name</TD>
                <TD class="block_title" width="15%">Password</TD>
                <TD class="block_title" width="65%">Subject</TD>
                <TD class="block_title" width="10%">Action</TD>
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
