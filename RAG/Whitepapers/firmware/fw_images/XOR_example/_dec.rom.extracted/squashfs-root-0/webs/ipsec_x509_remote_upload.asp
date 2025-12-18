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
  var remote_cert = <% iw_webGetRemoteCert(); %> ;

  function del_cert(index, type)
  {
   var cert_index = "index="+index;
   var cert_type = "enc_type="+type;
   if (window.confirm('Click OK to delete certificate.'))
   {
    document.getElementById("iw_remote_cert").disabled = true;
    $("#iw_remote_cert").css(({'color':'gray'}));
    document.getElementById("iw_remote_cert_import").disabled = true;
    $("#iw_remote_cert_import").css(({'color':'gray'}));
    document.getElementById("iw_del_remotecert_1").disabled = true;
    $("#iw_del_remotecert_1").css(({'color':'gray'}));
    document.getElementById("iw_del_remotecert_2").disabled = true;
    $("#iw_del_remotecert_2").css(({'color':'gray'}));
    document.getElementById("iw_del_remotecert_3").disabled = true;
    $("#iw_del_remotecert_3").css(({'color':'gray'}));
    document.getElementById("iw_del_remotecert_4").disabled = true;
    $("#iw_del_remotecert_4").css(({'color':'gray'}));
    document.getElementById("iw_del_remotecert_5").disabled = true;
    $("#iw_del_remotecert_5").css(({'color':'gray'}));

    document.remote_cert_upload.action='/forms/webDelCert?'+cert_index+"&"+cert_type;
    document.remote_cert_upload.submit();
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

  function import_remote_cert()
  {
   var file_path = document.remote_cert_upload.iw_remote_cert.value;
   var index;
   var i;
   var startIndex = (file_path.indexOf('\\') >= 0 ? file_path.lastIndexOf('\\') : file_path.lastIndexOf('/'));

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

   for (i = 0; i < 5; i++)
   {
    if (remote_cert[i][1] == "DISABLE")
    {
     index = remote_cert[i][0];
     break;
    }
   }
   if (i == 5)
   {
    alert("Remote certificates are full!");
    return false;
   }

   $.ajaxFileUpload(
   {
    url: '/forms/webUploadKey?index='+index+'&enc_type=x509_remote_upload_cert&filename='+filename,
    secureuri: false,
    fileElementId: 'iw_remote_cert',
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
     else if (data == "x509_remote_upload_cert")
     {
      document.getElementById("iw_remote_cert").disabled = true;
      $("#iw_remote_cert").css(({'color':'gray'}));
      document.getElementById("iw_remote_cert_import").disabled = true;
      $("#iw_remote_cert_import").css(({'color':'gray'}));
      document.getElementById("iw_del_remotecert_1").disabled = true;
      $("#iw_del_remotecert_1").css(({'color':'gray'}));
      document.getElementById("iw_del_remotecert_2").disabled = true;
      $("#iw_del_remotecert_2").css(({'color':'gray'}));
      document.getElementById("iw_del_remotecert_3").disabled = true;
      $("#iw_del_remotecert_3").css(({'color':'gray'}));
      document.getElementById("iw_del_remotecert_4").disabled = true;
      $("#iw_del_remotecert_4").css(({'color':'gray'}));
      document.getElementById("iw_del_remotecert_5").disabled = true;
      $("#iw_del_remotecert_5").css(({'color':'gray'}));

      document.remote_cert_upload.action='/forms/webCertUpload?index='+index+'&enc_type=x509_remote_upload_cert&filename='+filename;
      document.remote_cert_upload.submit();
     }
    }
   }

   );
  }

  function RemoteCerttable()
  {
   var i;
   var index;
   var color;
   var Certtable = document.getElementById("remote_cert_table")
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
    newCA.innerHTML = remote_cert[i][2];

    newCA = newRow.insertCell(1);
    newCA.className = "column_title";
    newCA.style.backgroundColor = color;
    newCA.innerHTML = remote_cert[i][3];

    newCA = newRow.insertCell(2);
    newCA.className = "column_title";
    newCA.style.backgroundColor = color;
    newCA.innerHTML = "<input type=\"button\" value=\"Delete\" id=\"iw_del_remotecert_"+remote_cert[i][0]+"\" onClick=\"del_cert("+remote_cert[i][0]+", \'x509_remote_upload_cert\');\" />";

    if (remote_cert[i][1] == "ENABLE")
    {
     document.getElementById("iw_del_remotecert_"+remote_cert[i][0]+"").disabled = false;
     $("#iw_del_remotecert_"+remote_cert[i][0]+"").css(({'color':'menutext'}));
    }
    else
    {
     document.getElementById("iw_del_remotecert_"+remote_cert[i][0]+"").disabled = true;
     $("#iw_del_remotecert_"+remote_cert[i][0]+"").css(({'color':'gray'}));
    }
   }

  }


  function editPermission()
  {
   var form = document.remote_cert_upload, i, j = <% iw_websCheckPermission(); %>;
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

<BODY onLoad="RemoteCerttable();iw_ChangeOnLoad();">
 <FORM id="remote_cert_upload" name="remote_cert_upload" method="POST">
  <H2><% iw_webSysDescHandler("IPSecX509RemoteCertUpload", "", "Remote Certificate Upload"); %> <% iw_websGetErrorString(); %></H2>
  <TABLE width="100%" id="remote_upload">
   <tr>
   <TD width="20%" class="column_title"><% iw_webSysDescHandler("IPSecX509RemoteCertUploadStr", "", "Remote certificate upload"); %></TD>
   <td width="80%">
   <input type="file" id="iw_remote_cert" name="iw_remote_cert">
   <input type="button" value="Import" id="iw_remote_cert_import" onClick="import_remote_cert()"; />
   <Input type="hidden" name="bkpath" value="/ipsec_x509_remote_upload.asp">
   </td>
   </tr>
  </table>
  <TABLE width="100%" id="remote_cert_table">
                <tr>
                        <td class="block_title" width="20%">Name</td>
                        <td class="block_title" width="70%">Subject</td>
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
