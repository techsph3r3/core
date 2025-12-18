<HTML>
<HEAD>
 <META http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
    <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate" />
    <meta http-equiv="Pragma" content="no-cache" />
    <meta http-equiv="Expires" content="0" />
 <LINK href="nport2g.css" rel=stylesheet type=text/css>
 <TITLE><% iw_webSysDescHandler("IPSecX509LocalCertUpload", "", "Local Certificate Upload"); %></TITLE>
 <% iw_webJSList_get(); %>
 <SCRIPT type="text/javascript">
  var pkcs12_cert = <% iw_webGetPKCS12Cert(); %> ;

  function del_cert(index, type)
  {
   var cert_index = "index="+index;
   var cert_type = "enc_type="+type;
   if (window.confirm('Click OK to delete certificate.'))
   {
    document.getElementById("iw_p12_file").disabled = true;
    $("#iw_p12_file").css(({'color':'gray'}));
    document.getElementById("iw_p12_import").disabled = true;
    $("#iw_p12_import").css(({'color':'gray'}));
    document.getElementById("iw_del_localcert_1").disabled = true;
    $("#iw_del_localcert_1").css(({'color':'gray'}));
    document.getElementById("iw_del_localcert_2").disabled = true;
    $("#iw_del_localcert_2").css(({'color':'gray'}));
    document.getElementById("iw_del_localcert_3").disabled = true;
    $("#iw_del_localcert_3").css(({'color':'gray'}));
    document.getElementById("iw_del_localcert_4").disabled = true;
    $("#iw_del_localcert_4").css(({'color':'gray'}));
    document.getElementById("iw_del_localcert_5").disabled = true;
    $("#iw_del_localcert_5").css(({'color':'gray'}));

    document.x509_p12_upload.action='/forms/webDelCert?'+cert_index+"&"+cert_type;
    document.x509_p12_upload.submit();
   }
  }

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

  function import_local_cert()
  {
   var file_path = document.x509_p12_upload.iw_p12_file.value;
   var index;
   var i;
   var startIndex = (file_path.indexOf('\\') >= 0 ? file_path.lastIndexOf('\\') : file_path.lastIndexOf('/'));
   var password = document.x509_p12_upload.pkcs12_password.value;

   if (file_path == "")
   {
    window.alert("Error! Please specify a file.");
    return false;
   }
   var filename = file_path.substring(startIndex);;
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

   if (document.x509_p12_upload.pkcs12_password.value.length < 4)
   {
    alert("Please set Certificate Password. You must type in 4 to 63 characters");
    document.x509_p12_upload.pkcs12_password.focus();
    return false;
   }

   if (!verify_cert_name(document.x509_p12_upload.pkcs12_password.value, "<% iw_webCfgDescHandler("IPSecX509", "pkcs12_1_password", ""); %>"))
   {
    return false;
   }

   for (i = 0; i < 5; i++)
   {
    if (pkcs12_cert[i][1] == "DISABLE")
    {
     index = pkcs12_cert[i][0];
     break;
    }
   }
   if (i == 5)
   {
    alert("Local certificates are full!");
    return false;
   }

   $.ajaxFileUpload(
   {
    url: '/forms/webUploadKey?index='+index+'&enc_type=x509_local_pkcs12&filename='+filename+'&password='+password,
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
     else if (data == "x509_local_pkcs12")
     {
      document.getElementById("iw_p12_file").disabled = true;
      $("#iw_p12_file").css(({'color':'gray'}));
      document.getElementById("iw_p12_import").disabled = true;
      $("#iw_p12_import").css(({'color':'gray'}));
      document.getElementById("iw_del_localcert_1").disabled = true;
      $("#iw_del_localcert_1").css(({'color':'gray'}));
      document.getElementById("iw_del_localcert_2").disabled = true;
      $("#iw_del_localcert_2").css(({'color':'gray'}));
      document.getElementById("iw_del_localcert_3").disabled = true;
      $("#iw_del_localcert_3").css(({'color':'gray'}));
      document.getElementById("iw_del_localcert_4").disabled = true;
      $("#iw_del_localcert_4").css(({'color':'gray'}));
      document.getElementById("iw_del_localcert_5").disabled = true;
      $("#iw_del_localcert_5").css(({'color':'gray'}));

      document.x509_p12_upload.action='/forms/webCertUpload?index='+index+'&enc_type=x509_local_pkcs12&filename='+filename+'&password='+password;
      document.x509_p12_upload.submit();
     }
    }
   }

   );
  }

  function PKCS12table()
  {
   var i;
   var index;
   var color;
   var Certtable = document.getElementById("pkcs12_cert_table")
   for (i = 0 ; i < 5 ; i++)
   {
    var newRow = Certtable.insertRow(Certtable.rows.length);
    newRow.id = newRow.uniqueID;
    index = i+1;
    if(i%2==0){
     color = "beige";
    }
    else{
     color = "azure";
    }

    newCA = newRow.insertCell(0);
    newCA.className = "column_title";
    newCA.style.backgroundColor = color;
    newCA.innerHTML = pkcs12_cert[i][2];

    newCA = newRow.insertCell(1);
    newCA.className = "column_title";
    newCA.style.backgroundColor = color;
    newCA.innerHTML = pkcs12_cert[i][3];

    newCA = newRow.insertCell(2);
    newCA.className = "column_title";
    newCA.style.backgroundColor = color;
    newCA.innerHTML = pkcs12_cert[i][4];

    newCA = newRow.insertCell(3);
    newCA.className = "column_title";
    newCA.style.backgroundColor = color;
    newCA.innerHTML = "<input type=\"button\" value=\"Delete\" id=\"iw_del_localcert_"+pkcs12_cert[i][0]+"\" onClick=\"del_cert("+pkcs12_cert[i][0]+", \'x509_local_pkcs12\');\" />";

    if (pkcs12_cert[i][1] == "ENABLE")
    {
     document.getElementById("iw_del_localcert_"+pkcs12_cert[i][0]+"").disabled = false;
     $("#iw_del_localcert_"+pkcs12_cert[i][0]+"").css(({'color':'menutext'}));
    }
    else
    {
     document.getElementById("iw_del_localcert_"+pkcs12_cert[i][0]+"").disabled = true;
     $("#iw_del_localcert_"+pkcs12_cert[i][0]+"").css(({'color':'gray'}));
    }
   }

  }


        function editPermission()
        {
                var form = document.x509_p12_upload, i, j = <% iw_websCheckPermission(); %>;
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

   top.toplogo.location = "./top.asp?time="+new Date();
   top.toplogo.location.reload();
  }

 </SCRIPT>
</HEAD>

<BODY onLoad="PKCS12table();iw_ChangeOnLoad();">
 <FORM id="x509_p12_upload" name="x509_p12_upload" method="POST">
  <H2><% iw_webSysDescHandler("IPSecX509LocalCertUpload", "", "Local Certificate Upload"); %> <% iw_websGetErrorString(); %></H2>
  <TABLE width="100%" id="p12_upload">
   <tr>
   <TD width="10%" class="column_title"><% iw_webSysDescHandler("X509PKCS12Upload", "", "PKCS#12 Upload"); %></TD>
   <td width="90%">
   <input type="file" id="iw_p12_file" name="iw_p12_file">
   <input type="button" value="Import" id="iw_p12_import" onClick="import_local_cert()"; />
   <Input type="hidden" name="bkpath" value="/ipsec_x509_p12_upload.asp">
   </td>
   </tr>
   <tr>
   <TD width="10%" class="column_title"><% iw_webCfgDescHandler("IPSecX509", "pkcs12_1_password", "PKCS#12 Password"); %></TD>
   <td width="90%">
   <INPUT type="text" id="pkcs12_password" name="pkcs12_password" size="69" maxlength="63">
   </td>
   </tr>
  </table>
  <TABLE width="100%" id="pkcs12_cert_table">
                <tr>
                        <td class="block_title" width="10%">Name</td>
                        <td class="block_title" width="15%">Password</td>
                        <td class="block_title" width="65%">Subject</td>
                        <td class="block_title" width="10%">Action</td>
                </tr>

  </TABLE>
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
