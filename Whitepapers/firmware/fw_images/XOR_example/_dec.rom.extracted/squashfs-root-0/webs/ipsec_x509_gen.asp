<HTML>
<HEAD>
 <META http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
    <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate" />
    <meta http-equiv="Pragma" content="no-cache" />
    <meta http-equiv="Expires" content="0" />
 <LINK href="nport2g.css" rel=stylesheet type=text/css>
 <TITLE><% iw_webSysDescHandler("X509Generate", "", "Certficate Generation"); %></TITLE>
 <% iw_webJSList_get(); %>
 <SCRIPT type="text/javascript">
  var trust_ca = <% iw_webGetCAInfo(); %> ;
  var local_cert = <% iw_webGetLocalCert(); %> ;

  function del_cert(index, type)
  {
   var cert_index = "index="+index;
   var cert_type = "enc_type="+type;
   if (window.confirm('Click OK to delete certificate.'))
   {
    document.getElementById("gen_root_ca").disabled = true;
    $("#gen_root_ca").css(({'color':'gray'}));
    document.getElementById("iw_export_rootca").disabled = true;
    $("#iw_export_rootca").css(({'color':'gray'}));
    document.getElementById("iw_del_rootca").disabled = true;
    $("#iw_del_rootca").css(({'color':'gray'}));
    document.getElementById("file_ca2").disabled = true;
    $("#file_ca2").css(({'color':'gray'}));
    document.getElementById("iw_import_trustca2").disabled = true;
    $("#iw_import_trustca2").css(({'color':'gray'}));
    document.getElementById("iw_del_trustca2").disabled = true;
    $("#iw_del_trustca2").css(({'color':'gray'}));
    document.getElementById("file_ca3").disabled = true;
    $("#file_ca3").css(({'color':'gray'}));
    document.getElementById("iw_import_trustca3").disabled = true;
    $("#iw_import_trustca3").css(({'color':'gray'}));
    document.getElementById("iw_del_trustca3").disabled = true;
    $("#iw_del_trustca3").css(({'color':'gray'}));

    document.getElementById("gen_local_cert").disabled = true;
    $("#gen_local_cert").css(({'color':'gray'}));
    document.getElementById("iw_export_localcert_1").disabled = true;
    $("#iw_export_localcert_1").css(({'color':'gray'}));
    document.getElementById("iw_export_localcertp12_1").disabled = true;
    $("#iw_export_localcertp12_1").css(({'color':'gray'}));
    document.getElementById("iw_del_localcert_1").disabled = true;
    $("#iw_del_localcert_1").css(({'color':'gray'}));
    document.getElementById("iw_export_localcert_2").disabled = true;
    $("#iw_export_localcert_2").css(({'color':'gray'}));
    document.getElementById("iw_export_localcertp12_2").disabled = true;
    $("#iw_export_localcertp12_2").css(({'color':'gray'}));
    document.getElementById("iw_del_localcert_2").disabled = true;
    $("#iw_del_localcert_2").css(({'color':'gray'}));
    document.getElementById("iw_export_localcert_3").disabled = true;
    $("#iw_export_localcert_3").css(({'color':'gray'}));
    document.getElementById("iw_export_localcertp12_3").disabled = true;
    $("#iw_export_localcertp12_3").css(({'color':'gray'}));
    document.getElementById("iw_del_localcert_3").disabled = true;
    $("#iw_del_localcert_3").css(({'color':'gray'}));
    document.getElementById("iw_export_localcert_4").disabled = true;
    $("#iw_export_localcert_4").css(({'color':'gray'}));
    document.getElementById("iw_export_localcertp12_4").disabled = true;
    $("#iw_export_localcertp12_4").css(({'color':'gray'}));
    document.getElementById("iw_del_localcert_4").disabled = true;
    $("#iw_del_localcert_4").css(({'color':'gray'}));
    document.getElementById("iw_export_localcert_5").disabled = true;
    $("#iw_export_localcert_5").css(({'color':'gray'}));
    document.getElementById("iw_export_localcertp12_5").disabled = true;
    $("#iw_export_localcertp12_5").css(({'color':'gray'}));
    document.getElementById("iw_del_localcert_5").disabled = true;
    $("#iw_del_localcert_5").css(({'color':'gray'}));

    document.ipsec_x509.action='/forms/webDelCert?'+cert_index+"&"+cert_type;
    document.ipsec_x509.submit();
   }
  }

  function export_cert(index, type)
  {
   var cert_index = "index="+index;
   var cert_type = "type="+type;
   document.location.href='cert.pem?' + cert_index + "&"+ cert_type;
  }
  function import_trust_ca(ca_num, value)
  {
   var file_id;
   if ((ca_num == "2" && document.ipsec_x509.file_ca2.value == "") || (ca_num == "3" && document.ipsec_x509.file_ca3.value == ""))
   {
    window.alert("Error! Please specify a file.");
    return false;
   }
   file_id = "file_ca"+ca_num;

   $.ajaxFileUpload(
   {
    url: '/forms/webUploadKey?index='+ca_num+'&enc_type='+value,
    secureuri: false,
    fileElementId: file_id,
    dataType: 'txt',
    success: function(data)
    {
     if (data == "file_error")
      alert("File is error!")
     else if (data == "file_too_big")
      alert("File size is too big!")
     else if (data == "import_error")
      alert("File import error!")
     else if (data == value)
      document.location.reload();
    }
   }

   );
  }

  function trustCAtable()
  {
   var i;
   var color;
   var CAtable = document.getElementById("trust_ca_table")
   for (i = 0 ; i < 3 ; i++)
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
    newCA.innerHTML = trust_ca[i][1];

    newCA = newRow.insertCell(1);
    newCA.className = "column_title";
    newCA.style.backgroundColor = color;
    newCA.innerHTML = trust_ca[i][2];

    newCA = newRow.insertCell(2);
    newCA.className = "column_title";
    newCA.style.backgroundColor = color;
    if (i == 0)
     newCA.innerHTML = "<input type=\"button\" value=\"Delete\" id=\"iw_del_rootca\" onClick=\"del_cert(\'0\', \'x509_root_ca\');\" />";
    else
     newCA.innerHTML = "<INPUT type=\"file\" id=\"file_ca"+trust_ca[i][0]+"\" name=\"file_ca"+trust_ca[i][0]+"\"><input type=\"button\" value=\"Import\" id=\"iw_import_trustca"+trust_ca[i][0]+"\" onClick=\"import_trust_ca("+trust_ca[i][0]+", \'x509_trust_ca\');\" />  <input type=\"button\" value=\"Delete\" id=\"iw_del_trustca"+trust_ca[i][0]+"\" onClick=\"del_cert("+trust_ca[i][0]+", \'x509_trust_ca\');\" />";
   }

  }

  function localCerttable()
  {
   var i;
   var index;
   var color;
   var Certtable = document.getElementById("local_cert_table")
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
    newCA.innerHTML = "Local certificate"+" "+index;

    newCA = newRow.insertCell(1);
    newCA.className = "column_title";
    newCA.style.backgroundColor = color;
    newCA.innerHTML = local_cert[i][1];

    newCA = newRow.insertCell(2);
    newCA.className = "column_title";
    newCA.style.backgroundColor = color;
    newCA.innerHTML = local_cert[i][2];

    newCA = newRow.insertCell(3);
    newCA.className = "column_title";
    newCA.style.backgroundColor = color;
    newCA.innerHTML = local_cert[i][3];

    newCA = newRow.insertCell(4);
    newCA.className = "column_title";
    newCA.style.backgroundColor = color;
    newCA.innerHTML = local_cert[i][4];

    newCA = newRow.insertCell(5);
    newCA.className = "column_title";
    newCA.style.backgroundColor = color;
    newCA.innerHTML = local_cert[i][5];

    newCA = newRow.insertCell(6);
    newCA.className = "column_title";
    newCA.style.backgroundColor = color;
    newCA.innerHTML = "<input type=\"button\" value=\"Certificate Export\" id=\"iw_export_localcert_"+local_cert[i][0]+"\" onClick=\"export_cert("+local_cert[i][0]+", \'x509_local_cert\');\" /><input type=\"button\" value=\"PKCS#12 Export\" id=\"iw_export_localcertp12_"+local_cert[i][0]+"\" onClick=\"export_cert("+local_cert[i][0]+", \'x509_local_cert_p12\');\"><input type=\"button\" value=\"Delete\" id=\"iw_del_localcert_"+local_cert[i][0]+"\" onClick=\"del_cert("+local_cert[i][0]+", \'x509_local_cert\');\" />";

    if (local_cert[i][1] != "")
    {
     document.getElementById("iw_export_localcert_"+local_cert[i][0]+"").disabled = false;
     $("#iw_export_localcert_"+local_cert[i][0]+"").css(({'color':'menutext'}));
     document.getElementById("iw_export_localcertp12_"+local_cert[i][0]+"").disabled = false;
     $("#iw_export_localcertp12_"+local_cert[i][0]+"").css(({'color':'menutext'}));
     document.getElementById("iw_del_localcert_"+local_cert[i][0]+"").disabled = false;
     $("#iw_del_localcert_"+local_cert[i][0]+"").css(({'color':'menutext'}));
    }
    else
    {
     document.getElementById("iw_export_localcert_"+local_cert[i][0]+"").disabled = true;
     $("#iw_export_localcert_"+local_cert[i][0]+"").css(({'color':'gray'}));
     document.getElementById("iw_export_localcertp12_"+local_cert[i][0]+"").disabled = true;
     $("#iw_export_localcertp12_"+local_cert[i][0]+"").css(({'color':'gray'}));
     document.getElementById("iw_del_localcert_"+local_cert[i][0]+"").disabled = true;
     $("#iw_del_localcert_"+local_cert[i][0]+"").css(({'color':'gray'}));
    }
   }

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

  function gen_rootca()
  {
   var form = document.ipsec_x509;

   if (!isValidNumber(form.iw_IPSecX509_cert_days, 1, 99999, "<% iw_webCfgDescHandler("IPSecX509", "cert_days", ""); %>"))
   {
    form.iw_IPSecX509_cert_days.focus();
    return false;
   }

   if (form.iw_IPSecX509_cert_password.value.length < 4)
   {
    alert("Please set Certificate Password. You must type in 4 to 63 characters");
    form.iw_IPSecX509_cert_password.focus();
    return false;
   }

   if (!verify_x509_name(form.iw_IPSecX509_cert_password, "<% iw_webCfgDescHandler("IPSecX509", "cert_password", ""); %>"))
   {
    return false;
   }

   if (form.iw_IPSecX509_cert_country_name.value.length <= 0)
   {
    alert("Please set Country name.");
    form.iw_IPSecX509_cert_country_name.focus();
    return false;
   }
   if (!verify_x509_name(form.iw_IPSecX509_cert_country_name, "<% iw_webCfgDescHandler("IPSecX509", "cert_country_name", ""); %>"))
   {
    return false;
   }

   if (form.iw_IPSecX509_cert_state_name.value.length <= 0)
   {
    alert("Please set State or province name.");
    form.iw_IPSecX509_cert_state_name.focus();
    return false;
   }
   if (!verify_x509_name(form.iw_IPSecX509_cert_state_name, "<% iw_webCfgDescHandler("IPSecX509", "cert_state_name", ""); %>"))
   {
    return false;
   }

   if (!verify_x509_name(form.iw_IPSecX509_cert_city, "<% iw_webCfgDescHandler("IPSecX509", "cert_city", ""); %>"))
   {
    return false;
   }

   if (form.iw_IPSecX509_cert_oragnization_name.value.length <= 0)
   {
    alert("Please set Organization name.");
    form.iw_IPSecX509_cert_oragnization_name.focus();
    return false;
   }

   if (!verify_x509_name(form.iw_IPSecX509_cert_oragnization_name, "<% iw_webCfgDescHandler("IPSecX509", "cert_oragnization_name", ""); %>"))
   {
    return false;
   }
   if (!verify_x509_name(form.iw_IPSecX509_cert_oragnization_unit, "<% iw_webCfgDescHandler("IPSecX509", "cert_oragnization_unit", ""); %>"))
   {
    return false;
   }

   if (form.iw_IPSecX509_cert_common_name.value.length <= 0)
   {
    alert("Please set Common name.");
    form.iw_IPSecX509_cert_common_name.focus();
    return false;
   }
   if (!verify_x509_name(form.iw_IPSecX509_cert_common_name, "<% iw_webCfgDescHandler("IPSecX509", "cert_common_name", ""); %>"))
   {
    return false;
   }
   if (!verify_x509_name(form.iw_IPSecX509_cert_email, "<% iw_webCfgDescHandler("IPSecX509", "cert_email", ""); %>"))
   {
    return false;
   }


   document.getElementById("gen_root_ca").disabled = true;
   $("#gen_root_ca").css(({'color':'gray'}));
   document.getElementById("iw_export_rootca").disabled = true;
   $("#iw_export_rootca").css(({'color':'gray'}));
   document.getElementById("iw_del_rootca").disabled = true;
   $("#iw_del_rootca").css(({'color':'gray'}));
   document.getElementById("file_ca2").disabled = true;
   $("#file_ca2").css(({'color':'gray'}));
   document.getElementById("iw_import_trustca2").disabled = true;
   $("#iw_import_trustca2").css(({'color':'gray'}));
   document.getElementById("iw_del_trustca2").disabled = true;
   $("#iw_del_trustca2").css(({'color':'gray'}));
   document.getElementById("file_ca3").disabled = true;
   $("#file_ca3").css(({'color':'gray'}));
   document.getElementById("iw_import_trustca3").disabled = true;
   $("#iw_import_trustca3").css(({'color':'gray'}));
   document.getElementById("iw_del_trustca3").disabled = true;
   $("#iw_del_trustca3").css(({'color':'gray'}));

   document.getElementById("gen_local_cert").disabled = true;
   $("#gen_local_cert").css(({'color':'gray'}));
   document.getElementById("iw_export_localcert_1").disabled = true;
   $("#iw_export_localcert_1").css(({'color':'gray'}));
   document.getElementById("iw_export_localcertp12_1").disabled = true;
   $("#iw_export_localcertp12_1").css(({'color':'gray'}));
   document.getElementById("iw_del_localcert_1").disabled = true;
   $("#iw_del_localcert_1").css(({'color':'gray'}));
   document.getElementById("iw_export_localcert_2").disabled = true;
   $("#iw_export_localcert_2").css(({'color':'gray'}));
   document.getElementById("iw_export_localcertp12_2").disabled = true;
   $("#iw_export_localcertp12_2").css(({'color':'gray'}));
   document.getElementById("iw_del_localcert_2").disabled = true;
   $("#iw_del_localcert_2").css(({'color':'gray'}));
   document.getElementById("iw_export_localcert_3").disabled = true;
   $("#iw_export_localcert_3").css(({'color':'gray'}));
   document.getElementById("iw_export_localcertp12_3").disabled = true;
   $("#iw_export_localcertp12_3").css(({'color':'gray'}));
   document.getElementById("iw_del_localcert_3").disabled = true;
   $("#iw_del_localcert_3").css(({'color':'gray'}));
   document.getElementById("iw_export_localcert_4").disabled = true;
   $("#iw_export_localcert_4").css(({'color':'gray'}));
   document.getElementById("iw_export_localcertp12_4").disabled = true;
   $("#iw_export_localcertp12_4").css(({'color':'gray'}));
   document.getElementById("iw_del_localcert_4").disabled = true;
   $("#iw_del_localcert_4").css(({'color':'gray'}));
   document.getElementById("iw_export_localcert_5").disabled = true;
   $("#iw_export_localcert_5").css(({'color':'gray'}));
   document.getElementById("iw_export_localcertp12_5").disabled = true;
   $("#iw_export_localcertp12_5").css(({'color':'gray'}));
   document.getElementById("iw_del_localcert_5").disabled = true;
   $("#iw_del_localcert_5").css(({'color':'gray'}));

   document.ipsec_x509.action='/forms/webGenRootCA';
   form.submit();
  }

  function gen_localcert()
  {
   var form = document.ipsec_x509;
   var i;
   var empty = 0;
   var local_cert_active = [
    "<% iw_webCfgValueHandler("IPSecX509", "localcert1active", ""); %>",
    "<% iw_webCfgValueHandler("IPSecX509", "localcert2active", ""); %>",
    "<% iw_webCfgValueHandler("IPSecX509", "localcert3active", ""); %>",
    "<% iw_webCfgValueHandler("IPSecX509", "localcert4active", ""); %>",
    "<% iw_webCfgValueHandler("IPSecX509", "localcert5active", ""); %>",
   ];
   if ("<% iw_webCfgValueHandler("IPSecX509", "cert_password", ""); %>" == "")
   {
    alert("Please generate Root CA first!");
    return false;
   }

   for (i = 0; i < 5; i++)
   {
    if (local_cert_active[i] == "DISABLE")
    {
     empty = 1;
     break;
    }
   }
   if (empty != 1)
   {
    alert("Local Certificate list is full!");
    return false;
   }

   if (!isValidNumber(form.local_cert_days, 1, 99999, "<% iw_webCfgDescHandler("IPSecX509", "cert_days", ""); %>"))
   {
    form.local_cert_days.focus();
    return false;
   }

   if (form.local_cert_password.value.length < 4)
   {
    alert("Please set Certificate Password. You must type in 4 to 63 characters");
    form.local_cert_password.focus();
    return false;
   }

   if (!verify_x509_name(form.local_cert_password, "<% iw_webCfgDescHandler("IPSecX509", "cert_password", ""); %>"))
   {
    return false;
   }

   if (!verify_x509_name(form.local_cert_oragnization_unit, "<% iw_webCfgDescHandler("IPSecX509", "cert_oragnization_unit", ""); %>"))
   {
    return false;
   }
   if (form.local_cert_name.value.length <= 0)
   {
    alert("Please set Certificate name.");
    form.local_cert_name.focus();
    return false;
   }
   if (!verify_x509_name(form.local_cert_name, "<% iw_webCfgDescHandler("IPSecX509", "localcert1name", ""); %>"))
   {
    return false;
   }
   if (!verify_x509_name(form.local_cert_email, "<% iw_webCfgDescHandler("IPSecX509", "cert_email", ""); %>"))
   {
    return false;
   }

   document.getElementById("gen_root_ca").disabled = true;
   $("#gen_root_ca").css(({'color':'gray'}));
   document.getElementById("iw_export_rootca").disabled = true;
   $("#iw_export_rootca").css(({'color':'gray'}));
   document.getElementById("iw_del_rootca").disabled = true;
   $("#iw_del_rootca").css(({'color':'gray'}));
   document.getElementById("file_ca2").disabled = true;
   $("#file_ca2").css(({'color':'gray'}));
   document.getElementById("iw_import_trustca2").disabled = true;
   $("#iw_import_trustca2").css(({'color':'gray'}));
   document.getElementById("iw_del_trustca2").disabled = true;
   $("#iw_del_trustca2").css(({'color':'gray'}));
   document.getElementById("file_ca3").disabled = true;
   $("#file_ca3").css(({'color':'gray'}));
   document.getElementById("iw_import_trustca3").disabled = true;
   $("#iw_import_trustca3").css(({'color':'gray'}));
   document.getElementById("iw_del_trustca3").disabled = true;
   $("#iw_del_trustca3").css(({'color':'gray'}));

   document.getElementById("gen_local_cert").disabled = true;
   $("#gen_local_cert").css(({'color':'gray'}));
   document.getElementById("iw_export_localcert_1").disabled = true;
   $("#iw_export_localcert_1").css(({'color':'gray'}));
   document.getElementById("iw_export_localcertp12_1").disabled = true;
   $("#iw_export_localcertp12_1").css(({'color':'gray'}));
   document.getElementById("iw_del_localcert_1").disabled = true;
   $("#iw_del_localcert_1").css(({'color':'gray'}));
   document.getElementById("iw_export_localcert_2").disabled = true;
   $("#iw_export_localcert_2").css(({'color':'gray'}));
   document.getElementById("iw_export_localcertp12_2").disabled = true;
   $("#iw_export_localcertp12_2").css(({'color':'gray'}));
   document.getElementById("iw_del_localcert_2").disabled = true;
   $("#iw_del_localcert_2").css(({'color':'gray'}));
   document.getElementById("iw_export_localcert_3").disabled = true;
   $("#iw_export_localcert_3").css(({'color':'gray'}));
   document.getElementById("iw_export_localcertp12_3").disabled = true;
   $("#iw_export_localcertp12_3").css(({'color':'gray'}));
   document.getElementById("iw_del_localcert_3").disabled = true;
   $("#iw_del_localcert_3").css(({'color':'gray'}));
   document.getElementById("iw_export_localcert_4").disabled = true;
   $("#iw_export_localcert_4").css(({'color':'gray'}));
   document.getElementById("iw_export_localcertp12_4").disabled = true;
   $("#iw_export_localcertp12_4").css(({'color':'gray'}));
   document.getElementById("iw_del_localcert_4").disabled = true;
   $("#iw_del_localcert_4").css(({'color':'gray'}));
   document.getElementById("iw_export_localcert_5").disabled = true;
   $("#iw_export_localcert_5").css(({'color':'gray'}));
   document.getElementById("iw_export_localcertp12_5").disabled = true;
   $("#iw_export_localcertp12_5").css(({'color':'gray'}));
   document.getElementById("iw_del_localcert_5").disabled = true;
   $("#iw_del_localcert_5").css(({'color':'gray'}));

   document.ipsec_x509.action= '/forms/webGenLocalCert';
   form.submit();
  }


  function iw_x509OnLoad()
  {
   $.ajax({url:'/forms/webCheckKey', type: 'GET', async: false, data: 'index=0&enc_type=root_ca', success: function(data) {
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

   $.ajax({url:'/forms/webCheckKey', type: 'GET', async: false, data: 'index=1&enc_type=trust_ca', success: function(data) {
     if (data == "X509_TRUST_CA_OK")
     {
      document.getElementById("iw_del_trustca2").disabled = false;
      $("#iw_del_trustca2").css(({'color':'menutext'}));
     }
     else
     {
      document.getElementById("iw_del_trustca2").disabled = true;
      $("#iw_del_trustca2").css(({'color':'gray'}));
     }
    }
   });

   $.ajax({url:'/forms/webCheckKey', type: 'GET', async: false, data: 'index=2&enc_type=trust_ca', success: function(data) {
     if (data == "X509_TRUST_CA_OK")
     {
      document.getElementById("iw_del_trustca3").disabled = false;
      $("#iw_del_trustca3").css(({'color':'menutext'}));
     }
     else
     {
      document.getElementById("iw_del_trustca3").disabled = true;
      $("#iw_del_trustca3").css(({'color':'gray'}));
     }
    }
   });
  }


  function editPermission()
  {
   var form = document.ipsec_x509, i, j = <% iw_websCheckPermission(); %>;
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


   if (top.toplogo != null)
   {
    top.toplogo.location = "./top.asp?time="+new Date();
    top.toplogo.location.reload();
   }
  }


 </SCRIPT>
</HEAD>
<BODY onLoad="trustCAtable();localCerttable();iw_x509OnLoad();iw_ChangeOnLoad()">
 <FORM id="ipsec_x509" name="ipsec_x509" method="POST">
  <H2><% iw_webSysDescHandler("X509Generate", "", "Certificate Generation"); %> <% iw_websGetErrorString(); %></H2>
  <TABLE width="100%" id="root_ca">
   <tr>
    <TD width="25%" class="column_title" colspan="2"><% iw_webSysDescHandler("IPSecX509CertGen", "", "Root Certificate Generation"); %></TD>
   </tr>
   <TR>
   <TD width="30%" class="column_title"><% iw_webCfgDescHandler("IPSecX509", "cert_days", ""); %></TD>
    <TD width="70%">
    <INPUT type="text" id="iw_IPSecX509_cert_days" name="iw_IPSecX509_cert_days" size="6" maxlength="5" value="<% iw_webCfgValueHandler("IPSecX509", "cert_days", ""); %>"> (days)
   </TD>
   </TR>
   <TR>
   <TD width="30%" class="column_title"><% iw_webCfgDescHandler("IPSecX509", "cert_password", ""); %> (4 to 63 characters)</TD>
    <TD width="70%">
    <INPUT type="text" id="iw_IPSecX509_cert_password" name="iw_IPSecX509_cert_password" size="69" maxlength="63" value="<% iw_webCfgValueHandler("IPSecX509", "cert_password", ""); %>">
   </TD>
   </TR>
   <TR>
   <TD width="30%" class="column_title"><% iw_webCfgDescHandler("IPSecX509", "cert_country_name", ""); %></TD>
    <TD width="70%">
    <INPUT type="text" id="iw_IPSecX509_cert_country_name" name="iw_IPSecX509_cert_country_name" size="3" maxlength="2" value="<% iw_webCfgValueHandler("IPSecX509", "cert_country_name", ""); %>">
   </TD>
   </TR>
   <TR>
   <TD width="30%" class="column_title"><% iw_webCfgDescHandler("IPSecX509", "cert_state_name", ""); %></TD>
    <TD width="70%">
    <INPUT type="text" id="iw_IPSecX509_cert_state_name" name="iw_IPSecX509_cert_state_name" size="40" maxlength="31" value="<% iw_webCfgValueHandler("IPSecX509", "cert_state_name", ""); %>">
   </TD>
   </TR>
   <TR>
   <TD width="30%" class="column_title"><% iw_webCfgDescHandler("IPSecX509", "cert_city", ""); %></TD>
    <TD width="70%">
    <INPUT type="text" id="iw_IPSecX509_cert_city" name="iw_IPSecX509_cert_city" size="40" maxlength="31" value="<% iw_webCfgValueHandler("IPSecX509", "cert_city", ""); %>">
   </TD>
   </TR>
   <TR>
   <TD width="30%" class="column_title"><% iw_webCfgDescHandler("IPSecX509", "cert_oragnization_name", ""); %></TD>
    <TD width="70%">
    <INPUT type="text" id="iw_IPSecX509_cert_oragnization_name" name="iw_IPSecX509_cert_oragnization_name" size="40" maxlength="31" value="<% iw_webCfgValueHandler("IPSecX509", "cert_oragnization_name", ""); %>">
   </TD>
   </TR>
   <TR>
   <TD width="30%" class="column_title"><% iw_webCfgDescHandler("IPSecX509", "cert_oragnization_unit", ""); %></TD>
    <TD width="70%">
    <INPUT type="text" id="iw_IPSecX509_cert_oragnization_unit" name="iw_IPSecX509_cert_oragnization_unit" size="40" maxlength="31" value="<% iw_webCfgValueHandler("IPSecX509", "cert_oragnization_unit", ""); %>">
   </TD>
   </TR>
   <TR>
   <TD width="30%" class="column_title"><% iw_webCfgDescHandler("IPSecX509", "cert_common_name", ""); %></TD>
    <TD width="70%">
    <INPUT type="text" id="iw_IPSecX509_cert_common_name" name="iw_IPSecX509_cert_common_name" size="40" maxlength="31" value="<% iw_webCfgValueHandler("IPSecX509", "cert_common_name", ""); %>">
   </TD>
   </TR>
   <TR>
   <TD width="30%" class="column_title"><% iw_webCfgDescHandler("IPSecX509", "cert_email", ""); %></TD>
    <TD width="70%">
    <INPUT type="text" id="iw_IPSecX509_cert_email" name="iw_IPSecX509_cert_email" size="69" maxlength="63" value="<% iw_webCfgValueHandler("IPSecX509", "cert_email", ""); %>">
   </TD>
   </TR>
   <TR>
   <TD>
    <input width="100" type="button" id="gen_root_ca" value="Generate Root CA" onClick="gen_rootca()" />
    <Input type="hidden" name="bkpath" value="/ipsec_x509_gen.asp">
    <input width="100" type="button" id="iw_export_rootca" value="Export Root CA" onClick="export_cert('0', 'x509_root_ca');" />
   </TD>
   </TR>
   <TR><TD></TD></TR>
  </TABLE>
  <TABLE width="100%" id="trust_ca_table">
                <tr>
                        <td class="block_title" width="10%">Name</td>
                        <td class="block_title" width="70%">Subject</td>
                        <td class="block_title" width="20%">Action</td>
                </tr>

  </TABLE>
  <TABLE width="100%" id="local_ca">
   <TR>
   <TD colspan="2"><HR>
   </TD>
   </TR>
   <tr>
    <TD width="25%" class="column_title" colspan="2"><% iw_webSysDescHandler("IPSecX509LocalCertGen", "", "Local Certificate Setting"); %></TD>
   </tr>
   <TR>
   <TD width="30%" class="column_title"><% iw_webCfgDescHandler("IPSecX509", "cert_days", ""); %></TD>
    <TD width="70%">
    <INPUT type="text" id="local_cert_days" name="local_cert_days" size="6" maxlength="5"> (days)
   </TD>
   </TR>
   <TR>
   <TD width="30%" class="column_title"><% iw_webCfgDescHandler("IPSecX509", "cert_password", ""); %> (4 to 63 characters)</TD>
    <TD width="70%">
    <INPUT type="text" id="local_cert_password" name="local_cert_password" size="69" maxlength="63">
   </TD>
   </TR>
   <TR>
   <TD width="30%" class="column_title"><% iw_webCfgDescHandler("IPSecX509", "cert_oragnization_unit", ""); %></TD>
    <TD width="70%">
    <INPUT type="text" id="local_cert_oragnization_unit" name="local_cert_oragnization_unit" size="40" maxlength="31">
   </TD>
   </TR>
   <TR>
   <TD width="30%" class="column_title"><% iw_webCfgDescHandler("IPSecX509", "localcert1name", ""); %></TD>
    <TD width="70%">
    <INPUT type="text" id="local_cert_name" name="local_cert_name" size="40" maxlength="27">
   </TD>
   </TR>
   <TR>
   <TD width="30%" class="column_title"><% iw_webCfgDescHandler("IPSecX509", "cert_email", ""); %></TD>
    <TD width="70%">
    <INPUT type="text" id="local_cert_email" name="local_cert_email" size="69" maxlength="63">
   </TD>
   </TR>
   <TR>
   <TD>
    <input width="100" type="button" id="gen_local_cert" value="Generate Local Certificate" onClick="gen_localcert();" />
   </TD>
   </TR>
   <TR><TD></TD></TR>

  </TABLE>
  <TABLE width="100%" id="local_cert_table">
                <tr>
                        <td class="block_title" width="10%">Name</td>
                        <td class="block_title" width="9%">Certificate Validity (days)</td>
                        <td class="block_title" width="9%">Certificate Password</td>
                        <td class="block_title" width="13%">Organizational Unit</td>
                        <td class="block_title" width="14%">Certificate Name</td>
                        <td class="block_title" width="25%">Email Address</td>
                        <td class="block_title" width="20%">Action</td>
                </tr>

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
