<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%
        var IPSecSection;



 IPSecSection = "IPSec" + IPSecIndex;
%>

<HTML>
<HEAD>
 <META http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
    <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate" />
    <meta http-equiv="Pragma" content="no-cache" />
    <meta http-equiv="Expires" content="0" />
 <LINK href="nport2g.css" rel="stylesheet" type="text/css">
 <TITLE>IPSec Configuration</TITLE>
 <% iw_webJSList_get(); %>
 <script type="text/javascript">
 <!--

 function check_key_file(value)
 {
  var ret = 1;
  $.ajax({url:'/forms/webCheckKey', type: 'GET', async: false, data: 'index=<% write(IPSecIndex);%>&enc_type='+value, success: function(data) {
    if (value == "rsa_local_private")
    {
     if (data == "RSA_LOCAL_PRIVATE_OK")
     {
      document.getElementById("export_private_key").disabled = false;
      $("#export_private_key").css(({'color':'menutext'}));
      document.getElementById("export_public_key").disabled = false;
      $("#export_public_key").css(({'color':'menutext'}));
      ret = 0;
     }
     else
     {
      document.getElementById("export_private_key").disabled = true;
      $("#export_private_key").css(({'color':'gray'}));
      document.getElementById("export_public_key").disabled = true;
      $("#export_public_key").css(({'color':'gray'}));
      ret = 1;
     }
    }
    else if (value == "rsa_remote_public")
    {
     if (data == "RSA_REMOTE_PUBLIC_OK")
      ret = 0;
     else
      ret = 1;
    }
   }
  });
  return ret;
 }

 function get_key(value)
 {
  $.get("/forms/webGetKey",{index: "<% write(IPSecIndex);%>", enc_type: value}, function(data) {
   if (value == "rsa_local_private")
    document.getElementById("local_private_keyarea").value=data;
   else if (value == "rsa_remote_public")
    document.getElementById("remote_public_keyarea").value=data;
  });
 }

 function gen_local_public()
 {
  $.get("/forms/webGenLocalPublicKey",{index: "<% write(IPSecIndex);%>"}, function(data) {
   if (data == "OK")
   {
    document.getElementById("export_public_key").disabled = false;
    $("#export_public_key").css(({'color':'menutext'}));
   }

  });
 }

 function gen_private()
 {
  document.getElementById("iw_ipsec_authenticationalg").disabled = true;
  $("#iw_ipsec_authenticationalg").css(({'color':'gray'}));
  document.getElementById("export_private_key").disabled = true;
  $("#export_private_key").css(({'color':'gray'}));
  document.getElementById("gen_priavte_key").disabled = true;
  $("#gen_priavte_key").css(({'color':'gray'}));

  document.getElementById("file_private").disabled = true;
  $("#file_private").css(({'color':'gray'}));
  document.getElementById("import_private_key").disabled = true;
  $("#import_private_key").css(({'color':'gray'}));
  document.getElementById("export_public_key").disabled = true;
  $("#export_public_key").css(({'color':'gray'}));
  document.getElementById("file_public").disabled = true;
  $("#file_public").css(({'color':'gray'}));
  document.getElementById("import_public_key").disabled = true;
  $("#import_public_key").css(({'color':'gray'}));

  document.getElementById("gen_priavte_key_font").style.display = "block";
  $.get("/forms/webGenRSA",{index: "<% write(IPSecIndex);%>"}, function(data) {
   document.getElementById("gen_priavte_key").disabled = false;
   document.getElementById("gen_priavte_key_font").style.display = "none";
   $("#gen_priavte_key").css(({'color':'menutext'}));
   get_key("rsa_local_private");
   gen_local_public();
   check_key_file("rsa_local_privae");
   document.getElementById("iw_ipsec_authenticationalg").disabled = false;
   $("#iw_ipsec_authenticationalg").css(({'color':'menutext'}));
   document.getElementById("export_private_key").disabled = false;
   $("#export_private_key").css(({'color':'menutext'}));
   document.getElementById("file_private").disabled = false;
   $("#file_private").css(({'color':'menutext'}));
   document.getElementById("import_private_key").disabled = false;
   $("#import_private_key").css(({'color':'menutext'}));
   document.getElementById("export_public_key").disabled = false;
   $("#export_public_key").css(({'color':'menutext'}));
   document.getElementById("file_public").disabled = false;
   $("#file_public").css(({'color':'menutext'}));
   document.getElementById("import_public_key").disabled = false;
   $("#import_public_key").css(({'color':'menutext'}));
  });

 }

 function export_private()
 {
  var ipsec_index = "index=<% write(IPSecIndex);%>";
  document.location.href='ipsec_rsa.private?' + ipsec_index;
 }

 function export_public()
 {
  var ipsec_index = "index=<% write(IPSecIndex);%>";
  document.location.href='ipsec_rsa.public?' + ipsec_index;
 }

 function upload_file(value)
 {
  var file_id;
  if (value == "rsa_local_private")
  {
   if (document.ipsec_option.file_private.value == "")
   {
    window.alert("Error! Please specify a file.");
    return false;
   }
   file_id = "file_private";
  }
  else if (value == "rsa_remote_public")
  {
   if (document.ipsec_option.file_public.value == "")
   {
    window.alert("Error! Please specify a file.");
    return false;
   }
   file_id = "file_public";
  }

  $.ajaxFileUpload(
  {
   url: '/forms/webUploadKey?index=<% write(IPSecIndex);%>&enc_type='+value,
   secureuri: false,
   fileElementId: file_id,
   dataType: 'txt',
   success: function(data)
   {
    if (data == "rsa_local_private")
    {
     get_key("rsa_local_private");
     check_key_file("rsa_local_private");
     gen_local_public();
    }
    else if (data == "file_error")
    {
     alert("File is error!");
    }
    else if (data == "file_too_big")
    {
     alert("File size is too big!");
    }
    else if (data == "rsa_remote_public")
    {
     get_key("rsa_remote_public");

    }
   }
  }

  );

 }

 function verifyname(name)
 {
  var i;
  alphanum1 = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
  alphanum2 = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-_.";
  ret = 1;

  if (alphanum1.indexOf(name.charAt(0)) < 0)
  {
   ret = 0;
   return ret;
  }
  for (i=0; i <name.length; i++)
  {
   if (alphanum2.indexOf(name.charAt(i)) < 0)
   {
    ret = 0;
    break;
   }
  }
  return ret;
 }

 function verifyrightkey(key)
 {
  var i;
  alphanum1 = " ";
  ret = 1;


  if (key.substr(0,15) != "rightrsasigkey=")
  {
   alert("Must start with \"rightrsasigkey=\"");
   ret = 0;
   return ret;
  }

  for (i = 0; i < key.length; i++)
  {
   if (alphanum1.indexOf(key.charAt(i)) == 0)
   {
    alert("Key string can not have space");
    ret = 0;
    return ret;
   }
  }

  if (!isAsciiString(key.substr(15)))
  {
   alert("ASCII only");
   ret = 0
   return ret;
  }

  return ret;
 }

 function verifyid(id, str)
 {
  var regex = /^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$/;
  var ret=1;

  if( 0 == id.value.length ){
   return ret;
  }

  if( regex.test(id.value) )
  {
   var parts = id.value.split(".");
   var a = parseInt(parts[0]);
   var b = parseInt(parts[1]);
   var c = parseInt(parts[2]);
   var d = parseInt(parts[3]);

   // ip over 255
   if(a > 255 || b > 255 || c > 255 || d > 255)
   ret = 0;

   // 0.0.0.0
   if(a+b+c+d == 0)
   ret = 0;
   // 255.255.255.255
   if(a+b+c+d == 255*4)
   ret = 0;
  }
  else
   ret = 0;

  if( ret == 0 )
  {
   if (id.value.charAt(0) == '@' && id.value.length > 1)
   {
    var i;
    alphanum = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.!@#$%^&*()_+?><-";
    ret = 1;
    for (i=1; i <id.value.length; i++)
    {
     if (alphanum.indexOf(id.value.charAt(i)) < 0)
     {
      ret = 0
      break;
     }
    }
   }
  }

  if (ret == 0)
  {
   alert("Invalid input: \"" + str + "\" (" + id.value + ")");
   alert("If set Local/Remote ID, it's format is IP or string that start with @ like a.b.c.d or @myvpn.com");
   id.focus();
  }
  return ret;
 }

  function CheckValue()
  {
   var form = document.ipsec_option;
   var authtype = document.getElementById("iw_ipsec_authenticationalg").options[document.getElementById("iw_ipsec_authenticationalg").selectedIndex].value;
   var conntype = document.getElementById("iw_ipsec_conntype").options[document.getElementById("iw_ipsec_conntype").selectedIndex].value;






   var i;
   var ipsec_name = [
    "<% iw_webCfgValueHandler("IPSec1", "connname", ""); %>",
    "<% iw_webCfgValueHandler("IPSec2", "connname", ""); %>",
    "<% iw_webCfgValueHandler("IPSec3", "connname", ""); %>",
    "<% iw_webCfgValueHandler("IPSec4", "connname", ""); %>",
    "<% iw_webCfgValueHandler("IPSec5", "connname", ""); %>",
   ];

   var ipsec_remoteid = [
    "<% iw_webCfgValueHandler("IPSec1", "remoteid", ""); %>",
    "<% iw_webCfgValueHandler("IPSec2", "remoteid", ""); %>",
    "<% iw_webCfgValueHandler("IPSec3", "remoteid", ""); %>",
    "<% iw_webCfgValueHandler("IPSec4", "remoteid", ""); %>",
    "<% iw_webCfgValueHandler("IPSec5", "remoteid", ""); %>",
   ];



                        if(form.iw_ipsec_name.value.length <= 0)
   {
                                alert("<% iw_webCfgDescHandler(IPSecSection, "connname", ""); %> cannot be empty.");
                                form.iw_ipsec_name.focus();
                                return false;
                        }
   if(!verifyname(form.iw_ipsec_name.value))
   {
    alert("Name not in correct format, must be a-z, A-Z, 0-9, -, _, .");
    return false;
   }

   for (i = 1; i < 6; i++)
   {
    if (i == <% write(IPSecIndex); %>)
    {
     continue;
    }

    if (form.iw_ipsec_name.value == ipsec_name[i-1])
    {
     alert("Connection Name is same as rule " + i + ".");
     return false;
    }
   }

   if (conntype == "Site to Site")
   {
    if(form.iw_ipsec_remotegateway.value.length<7 )
    {
     alert("Invalid input: \"<% iw_webCfgDescHandler(IPSecSection, "remotegateway", ""); %>\" (" + form.iw_ipsec_remotegateway.value + ")");
     form.iw_ipsec_remotegateway.focus();
     return false;
    }

    if( !verifyIP(form.iw_ipsec_remotegateway, "<% iw_webCfgDescHandler(IPSecSection, "remotegateway", ""); %>") ){
     return false;
    }
   }


   if(form.iw_ipsec_localsubnetip.value.length<7 )
   {
    alert("Invalid input: \"<% iw_webCfgDescHandler(IPSecSection, "localsubnetip", ""); %>\" (" + form.iw_ipsec_localsubnetip.value + ")");
    form.iw_ipsec_localsubnetip.focus();
    return false;
   }
   if( !verifyIP(form.iw_ipsec_localsubnetip, "<% iw_webCfgDescHandler(IPSecSection, "localsubnetip", ""); %>") ){
    return false;
   }
   if(form.iw_ipsec_localsubnetmask.value.length<7 )
   {
    alert("Invalid input: \"<% iw_webCfgDescHandler(IPSecSection, "localsubnetmask", ""); %>\" (" + form.iw_ipsec_localsubnetmask.value + ")");
    form.iw_ipsec_localsubnetmask.focus();
    return false;
   }

   if( !verifyNetmask(form.iw_ipsec_localsubnetmask, "<% iw_webCfgDescHandler(IPSecSection, "localsubnetmask", ""); %>") ){
    return false;
   }
   if (authtype == "RSA Signature")
   {
    if(form.iw_ipsec_localid.value.length <= 0)
    {
     alert("When you choose RSA Signature, local/remote ID cannot be empty.");
     form.iw_ipsec_localid.focus();
     return false;
    }
    if(form.iw_ipsec_remoteid.value.length <= 0)
    {
     alert("When you choose RSA Signature, local/remote ID cannot be empty.");
     form.iw_ipsec_remoteid.focus();
     return false;
    }
   }
   if( !verifyid(form.iw_ipsec_localid, "<% iw_webCfgDescHandler(IPSecSection, "localid", ""); %>") ){
    return false;
   }


   if(form.iw_ipsec_remotesubnetip.value.length<7 )
   {
    alert("Invalid input: \"<% iw_webCfgDescHandler(IPSecSection, "remotesubnetip", ""); %>\" (" + form.iw_ipsec_remotesubnetip.value + ")");
    form.iw_ipsec_remotesubnetip.focus();
    return false;
   }

   if( !verifyIP(form.iw_ipsec_remotesubnetip, "<% iw_webCfgDescHandler(IPSecSection, "remotesubnetip", ""); %>") ){
    return false;
   }


   if(form.iw_ipsec_remotesubnetmask.value.length<7 )
   {
    alert("Invalid input: \"<% iw_webCfgDescHandler(IPSecSection, "remotesubnetmask", ""); %>\" (" + form.iw_ipsec_remotesubnetmask.value + ")");
    form.iw_ipsec_remotesubnetmask.focus();
    return false;
   }

   if( !verifyNetmask(form.iw_ipsec_remotesubnetmask, "<% iw_webCfgDescHandler(IPSecSection, "remotesubnetmask", ""); %>") ){
    return false;
   }

   if( !verifyid(form.iw_ipsec_remoteid, "<% iw_webCfgDescHandler(IPSecSection, "remoteid", ""); %>") ){
    return false;
   }

   if (authtype == "RSA Signature")
   {
    for (i = 1; i < 6; i++)
    {
     if (i == <% write(IPSecIndex); %>)
     {
      continue;
     }

     if (form.iw_ipsec_remoteid.value == ipsec_remoteid[i-1])
     {
      alert("Remote ID is same as rule " + i + ".");
      return false;
     }
    }
   }

   if (authtype == "Pre-shared Key")
   {
    if(form.iw_ipsec_psk.value.length <= 0)
    {
     alert("<% iw_webCfgDescHandler(IPSecSection, "psk", ""); %> cannot be empty.");
     form.iw_ipsec_psk.focus();
     return false;
    }

    if ( !isAsciiString(form.iw_ipsec_psk.value)){
     alert("Invalid <% iw_webCfgDescHandler(IPSecSection, "psk", ""); %> : ASCII only");
     return false;
    }
   }
   else if (authtype == "RSA Signature")
   {
    if (check_key_file("rsa_local_private") == 1)
    {
     alert("Local private key does not exist!!");
     form.local_private_keyarea.focus();
     return false;
    }

    if (check_key_file("rsa_remote_public") == 1)
    {
     alert("Remote public key does not exist!!");
     form.remote_public_keyarea.focus();
     return false;
    }
   }

   if (form.iw_ipsec_key_retry.value.length <= 0)
   {
                                alert("<% iw_webCfgDescHandler(IPSecSection, "key_retry", ""); %> cannot be empty.");
                                form.iw_ipsec_key_retry.focus();
                                return false;
   }

   if (!isValidNumber(form.iw_ipsec_key_retry, 0, 99999, "<% iw_webCfgDescHandler(IPSecSection, "key_retry", ""); %> (0-99999)"))
   {
    return false;
   }

   if (form.iw_ipsec_ike_lifetime.value.length <= 0)
   {
                                alert("<% iw_webCfgDescHandler(IPSecSection, "ike_lifetime", ""); %> cannot be empty.");
                                form.iw_ipsec_ike_lifetime.focus();
                                return false;
   }

   if (!isValidNumber(form.iw_ipsec_ike_lifetime, 1, 14400, "<% iw_webCfgDescHandler(IPSecSection, "ike_lifetime", ""); %> (1 - 14400)"))
   {
    return false;
   }

   if (form.iw_ipsec_rekey_margin.value.length <= 0)
   {
                                alert("<% iw_webCfgDescHandler(IPSecSection, "rekey_margin", ""); %> cannot be empty.");
                                form.iw_ipsec_rekey_margin.focus();
                                return false;
   }

   if (!isValidNumber(form.iw_ipsec_rekey_margin, 1, 14400, "<% iw_webCfgDescHandler(IPSecSection, "rekey_margin", ""); %> (1 - 14400)"))
   {
    return false;
   }

   if (form.iw_ipsec_rekey_fuzz.value.length <= 0)
   {
                                alert("<% iw_webCfgDescHandler(IPSecSection, "rekey_fuzz", ""); %> cannot be empty.");
                                form.iw_ipsec_rekey_fuzz.focus();
                                return false;
   }

   if (!isValidNumber(form.iw_ipsec_rekey_fuzz, 0, 999, "<% iw_webCfgDescHandler(IPSecSection, "rekey_fuzz", ""); %>"))
   {
    return false;
   }

   if (form.iw_ipsec_sa_lifetime.value.length <= 0)
   {
                                alert("<% iw_webCfgDescHandler(IPSecSection, "sa_lifetime", ""); %> cannot be empty.");
                                form.iw_ipsec_sa_lifetime.focus();
                                return false;
   }

   if (!isValidNumber(form.iw_ipsec_sa_lifetime, 1, 14400, "<% iw_webCfgDescHandler(IPSecSection, "sa_lifetime", ""); %> (1 - 14400)"))
   {
    return false;
   }

   if (form.iw_ipsec_dpd_delay.value.length <= 0)
   {
                                alert("<% iw_webCfgDescHandler(IPSecSection, "dpd_delay", ""); %> cannot be empty.");
                                form.iw_ipsec_dpd_delay.focus();
                                return false;
   }

   if (!isValidNumber(form.iw_ipsec_dpd_delay, 0, 99999, "<% iw_webCfgDescHandler(IPSecSection, "dpd_delay", ""); %>"))
   {
    return false;
   }

   if (form.iw_ipsec_dpd_timeout.value.length <= 0)
   {
                                alert("<% iw_webCfgDescHandler(IPSecSection, "dpd_timeout", ""); %> cannot be empty.");
                                form.iw_ipsec_dpd_timeout.focus();
                                return false;
   }

   if (!isValidNumber(form.iw_ipsec_dpd_timeout, 0, 99999, "<% iw_webCfgDescHandler(IPSecSection, "dpd_timeout", ""); %>"))
   {
    return false;
   }


   document.getElementById("iw_ipsec_startupmode").disabled = false;
   form.submit();
  }

  function iw_IPSecOnLoad()
  {
   var conntype = "<% iw_webCfgValueHandler(IPSecSection, "conntype", ""); %>";






   var auth_type = "<% iw_webCfgValueHandler(IPSecSection, "authenticationalg", ""); %>";
   iw_selectSet(document.ipsec_option.iw_ipsec_enable, "<% iw_webCfgValueHandler(IPSecSection, "IPSecenable", "DISABLE"); %>");
   iw_selectSet(document.ipsec_option.iw_ipsec_conntype, "<% iw_webCfgValueHandler(IPSecSection, "conntype", ""); %>");
   iw_selectSet(document.ipsec_option.iw_ipsec_startupmode, "<% iw_webCfgValueHandler(IPSecSection, "startupmode", ""); %>");
   if (conntype == "Site to Site(Any)")
   {
    document.getElementById("iw_ipsec_startupmode").disabled = true;
    document.getElementById("iw_ipsec_remotegateway").disabled = true;
   }
   document.getElementById("gen_priavte_key_font").style.display = "none";

   if (auth_type == "X.509")
   {
    iw_selectSet(document.ipsec_option.iw_ipsec_local_cert, "<% iw_webCfgValueHandler(IPSecSection, "local_cert", ""); %>");
    iw_selectSet(document.ipsec_option.iw_ipsec_remote_cert, "<% iw_webCfgValueHandler(IPSecSection, "remote_cert", ""); %>");
   }

   iw_selectSet(document.ipsec_option.iw_ipsec_operationmode, "<% iw_webCfgValueHandler(IPSecSection, "operationmode", ""); %>");
   iw_selectSet(document.ipsec_option.iw_ipsec_authenticationalg, "<% iw_webCfgValueHandler(IPSecSection, "authenticationalg", ""); %>");
   iw_selectSet(document.ipsec_option.iw_ipsec_ph1_encryptalg, "<% iw_webCfgValueHandler(IPSecSection, "ph1_encryptalg", ""); %>");
   iw_selectSet(document.ipsec_option.iw_ipsec_ph1_hashalg, "<% iw_webCfgValueHandler(IPSecSection, "ph1_hashalg", ""); %>");
   iw_selectSet(document.ipsec_option.iw_ipsec_dhgroup, "<% iw_webCfgValueHandler(IPSecSection, "dhgroup", ""); %>");

   iw_selectSet(document.ipsec_option.iw_ipsec_pfs, "<% iw_webCfgValueHandler(IPSecSection, "pfs", ""); %>");
   iw_selectSet(document.ipsec_option.iw_ipsec_ph2_encryptalg, "<% iw_webCfgValueHandler(IPSecSection, "ph2_encryptalg", ""); %>");
   iw_selectSet(document.ipsec_option.iw_ipsec_ph2_hashalg, "<% iw_webCfgValueHandler(IPSecSection, "ph2_hashalg", ""); %>");
   iw_selectSet(document.ipsec_option.iw_ipsec_dpd_action, "<% iw_webCfgValueHandler(IPSecSection, "dpd_action", ""); %>");

   iw_onAUTHchange();



   $("#iw_ipsec_conntype").change(function(){
       var value = this.value
    if( value == "Site to Site(Any)" ){
     document.getElementById("iw_ipsec_startupmode").selectedIndex=1;
     document.getElementById("iw_ipsec_startupmode").value="Wait for connection";
     document.getElementById("iw_ipsec_startupmode").disabled = true;
     document.getElementById("iw_ipsec_remotegateway").disabled = true;
     $("#iw_ipsec_startupmode").css(({'color':'gray'}));
    }
    else
    {
     document.getElementById("iw_ipsec_startupmode").disabled = false;
     document.getElementById("iw_ipsec_remotegateway").disabled = false;
     iw_selectSet(document.ipsec_option.iw_ipsec_startupmode, "<% iw_webCfgValueHandler(IPSecSection, "startupmode", ""); %>");
     $("#iw_ipsec_startupmode").css(({'color':'menutext'}));
    }
   })
  }


  function editPermission()
  {
   var form = document.ipsec_option, i, j = <% iw_websCheckPermission(); %>;
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

  function iw_onIPSecchange()
  {
   var conntype = document.getElementById("iw_ipsec_conntype").options[document.getElementById("iw_ipsec_conntype").selectedIndex].value;
   if (conntype == "Site to Site(Any)")
   {
    document.getElementById("iw_ipsec_startupmode").selectedIndex=1;
    document.getElementById("iw_ipsec_startupmode").value="Wait for connection";
    document.getElementById("iw_ipsec_startupmode").disabled = true;
   }
   else
   {
    document.getElementById("iw_ipsec_startupmode").disabled = false;
    iw_selectSet(document.ipsec_option.iw_ipsec_startupmode, "<% iw_webCfgValueHandler(IPSecSection, "startupmode", ""); %>");
   }
  }

  function iw_onAUTHchange()
  {
   var authtype = document.getElementById("iw_ipsec_authenticationalg").options[document.getElementById("iw_ipsec_authenticationalg").selectedIndex].value;
   if (authtype == "Pre-shared Key")
   {
    document.getElementById("iw_ipsec_psk").disabled = false;
    document.getElementById("iw_ipsec_psk").style.display = "";
    document.getElementById("rsa").style.display = "none";
    document.getElementById("rsakey").disabled = true;
    document.getElementById("rsakey").style.display = "none";
    document.getElementById("private_key").disabled = true;
    document.getElementById("private_key").style.display = "none";
    document.getElementById("gen_priavte_key").disabled = true;
    document.getElementById("gen_priavte_key").style.display = "none";
    document.getElementById("export_private_key").disabled = true;
    document.getElementById("export_private_key").style.display = "none";
    document.getElementById("file_private_key").disabled = true;
    document.getElementById("file_private_key").style.display = "none";
    document.getElementById("import_private_key").disabled = true;
    document.getElementById("import_private_key").style.display = "none";
    document.getElementById("local_private_key").disabled = true;
    document.getElementById("local_private_key").style.display = "none";
    document.getElementById("local_private_keyarea").disabled = true;
    document.getElementById("local_private_keyarea").style.display = "none";
    document.getElementById("public_key").disabled = true;
    document.getElementById("public_key").style.display = "none";
    document.getElementById("export_public_key").disabled = true;
    document.getElementById("export_public_key").style.display = "none";
    document.getElementById("file_public_key").disabled = true;
    document.getElementById("file_public_key").style.display = "none";
    document.getElementById("import_public_key").disabled = true;
    document.getElementById("import_public_key").style.display = "none";
    document.getElementById("remote_public_key").disabled = true;
    document.getElementById("remote_public_key").style.display = "none";
    document.getElementById("remote_public_keyarea").disabled = true;
    document.getElementById("remote_public_keyarea").style.display = "none";
    document.getElementById("x509").style.display = "none";
    document.getElementById("local_cert").disabled = true;
    document.getElementById("local_cert").style.display = "none";
    document.getElementById("iw_ipsec_local_cert").disabled = true;
    document.getElementById("iw_ipsec_local_cert").style.display = "none";
    document.getElementById("remote_cert").disabled = true;
    document.getElementById("remote_cert").style.display = "none";
    document.getElementById("iw_ipsec_remote_cert").disabled = true;
    document.getElementById("iw_ipsec_remote_cert").style.display = "none";
   }
   else if (authtype == "RSA Signature")
   {
    document.getElementById("iw_ipsec_psk").disabled = true;
    document.getElementById("iw_ipsec_psk").style.display = "none";
    document.getElementById("rsa").style.display = "block";
    document.getElementById("rsakey").disabled = false;
    document.getElementById("rsakey").style.display = "";
    document.getElementById("private_key").disabled = false;
    document.getElementById("private_key").style.display = "";
    document.getElementById("gen_priavte_key").disabled = false;
    document.getElementById("gen_priavte_key").style.display = "";
    document.getElementById("export_private_key").disabled = false;
    document.getElementById("export_private_key").style.display = "";
    document.getElementById("file_private_key").disabled = false;
    document.getElementById("file_private_key").style.display = "";
    document.getElementById("import_private_key").disabled = false;
    document.getElementById("import_private_key").style.display = "";
    document.getElementById("local_private_key").disabled = false;
    document.getElementById("local_private_key").style.display = "";
    document.getElementById("local_private_keyarea").disabled = false;
    document.getElementById("local_private_keyarea").style.display = "";
    document.getElementById("public_key").disabled = false;
    document.getElementById("public_key").style.display = "";
    document.getElementById("export_public_key").disabled = false;
    document.getElementById("export_public_key").style.display = "";
    document.getElementById("file_public_key").disabled = false;
    document.getElementById("file_public_key").style.display = "";
    document.getElementById("import_public_key").disabled = false;
    document.getElementById("import_public_key").style.display = "";
    document.getElementById("remote_public_key").disabled = false;
    document.getElementById("remote_public_key").style.display = "";
    document.getElementById("remote_public_keyarea").disabled = false;
    document.getElementById("remote_public_keyarea").style.display = "";
    document.getElementById("x509").style.display = "none";
    document.getElementById("local_cert").disabled = true;
    document.getElementById("local_cert").style.display = "none";
    document.getElementById("iw_ipsec_local_cert").disabled = true;
    document.getElementById("iw_ipsec_local_cert").style.display = "none";
    document.getElementById("remote_cert").disabled = true;
    document.getElementById("remote_cert").style.display = "none";
    document.getElementById("iw_ipsec_remote_cert").disabled = true;
    document.getElementById("iw_ipsec_remote_cert").style.display = "none";
    get_key("rsa_local_private");
    get_key("rsa_remote_public");
    check_key_file("rsa_local_private");
   }
   else
   {
    document.getElementById("iw_ipsec_psk").disabled = true;
    document.getElementById("iw_ipsec_psk").style.display = "none";
    document.getElementById("rsa").style.display = "none";
    document.getElementById("rsakey").disabled = true;
    document.getElementById("rsakey").style.display = "none";
    document.getElementById("private_key").disabled = true;
    document.getElementById("private_key").style.display = "none";
    document.getElementById("gen_priavte_key").disabled = true;
    document.getElementById("gen_priavte_key").style.display = "none";
    document.getElementById("export_private_key").disabled = true;
    document.getElementById("export_private_key").style.display = "none";
    document.getElementById("file_private_key").disabled = true;
    document.getElementById("file_private_key").style.display = "none";
    document.getElementById("import_private_key").disabled = true;
    document.getElementById("import_private_key").style.display = "none";
    document.getElementById("local_private_key").disabled = true;
    document.getElementById("local_private_key").style.display = "none";
    document.getElementById("local_private_keyarea").disabled = true;
    document.getElementById("local_private_keyarea").style.display = "none";
    document.getElementById("public_key").disabled = true;
    document.getElementById("public_key").style.display = "none";
    document.getElementById("export_public_key").disabled = true;
    document.getElementById("export_public_key").style.display = "none";
    document.getElementById("file_public_key").disabled = true;
    document.getElementById("file_public_key").style.display = "none";
    document.getElementById("import_public_key").disabled = true;
    document.getElementById("import_public_key").style.display = "none";
    document.getElementById("remote_public_key").disabled = true;
    document.getElementById("remote_public_key").style.display = "none";
    document.getElementById("remote_public_keyarea").disabled = true;
    document.getElementById("remote_public_keyarea").style.display = "none";
    document.getElementById("x509").style.display = "block";
    document.getElementById("local_cert").disabled = false;
    document.getElementById("local_cert").style.display = "";
    document.getElementById("iw_ipsec_local_cert").disabled = false;
    document.getElementById("iw_ipsec_local_cert").style.display = "";
    document.getElementById("remote_cert").disabled = false;
    document.getElementById("remote_cert").style.display = "";
    document.getElementById("iw_ipsec_remote_cert").disabled = false;
    document.getElementById("iw_ipsec_remote_cert").style.display = "";
   }
  }
    -->
    </Script>
</HEAD>
<BODY onload="iw_IPSecOnLoad();iw_ChangeOnLoad();">
 <FORM name="ipsec_option" method="POST" action="/forms/iw_webSetParameters">
 <H2><% iw_webSysDescHandler("TunnelSetting", "", "Tunnel Settings"); %> <% iw_websGetErrorString(); %></H2>
  <TABLE width="100%">
   <TR>
    <TD width="30%" class="column_title"><% iw_webCfgDescHandler(IPSecSection, "IPSecenable", "IPsec Settings"); %></TD>
    <TD width="70%">
     <SELECT size="1" id="iw_ipsec_enable" name="iw_<% write(IPSecSection); %>_IPSecenable">
                <option value="ENABLE">Enable</option>
                <option value="DISABLE">Disable</option>
                                  </SELECT>
    </TD>
   </TR>
   <TR>
    <TD width="30%" class="column_title"><% iw_webCfgDescHandler(IPSecSection, "connname", "Connection name"); %></TD>
    <TD width="70%">
    <INPUT type="text" id="iw_ipsec_name" name="iw_<% write(IPSecSection); %>_connname" size="20" maxlength="19" value = "<% iw_webCfgValueHandler(IPSecSection, "connname", ""); %>"> (Must begin with an alphabet)</TD>
   </TR>
   <TR>
    <TD width="30%" class="column_title"><% iw_webCfgDescHandler(IPSecSection, "conntype", "Connection type"); %></TD>
    <TD width="70%">
     <SELECT size="1" id="iw_ipsec_conntype" name="iw_<% write(IPSecSection); %>_conntype">
     <option value="Site to Site">Site to Site</option>
     <option value="Site to Site(Any)">Site to Site(Any)</option>
                                  </SELECT>
    </TD>
   </TR>
   <TR>
    <TD width="30%" class="column_title"><% iw_webCfgDescHandler(IPSecSection, "startupmode", "Start in initial"); %></TD>
    <TD width="70%">
     <SELECT size="1" id="iw_ipsec_startupmode" name="iw_<% write(IPSecSection); %>_startupmode">
                <option value="Start in initial">Start in Initial</option>
                <option value="Wait for connection">Wait for Connection</option>
                                  </SELECT>
    </TD>
   </TR>
          <TR>
    <TD width="30%" class="column_title"><% iw_webCfgDescHandler(IPSecSection, "remotegateway", ""); %></TD>
    <TD width="70%">
                <INPUT type="text" id="iw_ipsec_remotegateway" name="iw_<% write(IPSecSection); %>_remotegateway" size="20" maxlength="15" value="<% iw_webCfgValueHandler(IPSecSection, "remotegateway", ""); %>">
               </TD>
              </TR>
          <TR>
    <TD width="30%" class="column_title"><% iw_webCfgDescHandler(IPSecSection, "localsubnetip", ""); %></TD>
    <TD width="70%">
                <INPUT type="text" id="iw_ipsec_localsubnetip" name="iw_<% write(IPSecSection); %>_localsubnetip" size="20" maxlength="15" value="<% iw_webCfgValueHandler(IPSecSection, "localsubnetip", ""); %>">
               </TD>
              </TR>
          <TR>
    <TD width="30%" class="column_title"><% iw_webCfgDescHandler(IPSecSection, "localsubnetmask", ""); %></TD>
    <TD width="70%">
                <INPUT type="text" id="iw_ipsec_localsubnetmask" name="iw_<% write(IPSecSection); %>_localsubnetmask" size="20" maxlength="15" value="<% iw_webCfgValueHandler(IPSecSection, "localsubnetmask", ""); %>">
               </TD>
              </TR>
          <TR>
    <TD width="30%" class="column_title"><% iw_webCfgDescHandler(IPSecSection, "localid", ""); %></TD>
    <TD width="70%">
                <INPUT type="text" id="iw_ipsec_localid" name="iw_<% write(IPSecSection); %>_localid" size="20" maxlength="15" value="<% iw_webCfgValueHandler(IPSecSection, "localid", ""); %>">
               </TD>
              </TR>
          <TR>
    <TD width="30%" class="column_title"><% iw_webCfgDescHandler(IPSecSection, "remotesubnetip", ""); %></TD>
    <TD width="70%">
                <INPUT type="text" id="iw_ipsec_remotesubnetip" name="iw_<% write(IPSecSection); %>_remotesubnetip" size="20" maxlength="15" value="<% iw_webCfgValueHandler(IPSecSection, "remotesubnetip", ""); %>">
               </TD>
              </TR>
          <TR>
    <TD width="30%" class="column_title"><% iw_webCfgDescHandler(IPSecSection, "remotesubnetmask", ""); %></TD>
    <TD width="70%">
                <INPUT type="text" id="iw_ipsec_remotesubnetmask" name="iw_<% write(IPSecSection); %>_remotesubnetmask" size="20" maxlength="15" value="<% iw_webCfgValueHandler(IPSecSection, "remotesubnetmask", ""); %>">
               </TD>
              </TR>
          <TR>
    <TD width="30%" class="column_title"><% iw_webCfgDescHandler(IPSecSection, "remoteid", ""); %></TD>
    <TD width="70%">
                <INPUT type="text" id="iw_ipsec_remoteid" name="iw_<% write(IPSecSection); %>_remoteid" size="20" maxlength="15" value="<% iw_webCfgValueHandler(IPSecSection, "remoteid", ""); %>">
               </TD>
              </TR>
  </TABLE>
   <TR>
   <TD colspan="2"><HR>
   </TD>

 <H2><% iw_webSysDescHandler("ISAKMPPhase1", "", "Key Exchange (Phase1)"); %></H2>
  <TABLE width="100%">
   <TR>
    <TD width="30%" class="column_title"><% iw_webCfgDescHandler(IPSecSection, "operationmode", "Operation mode"); %></TD>
    <TD width="70%">
     <SELECT size="1" id="iw_ipsec_operationmode" name="iw_<% write(IPSecSection); %>_operationmode">
                <option value="Main">Main</option>
                <option value="Aggressive">Aggressive</option>
                                  </SELECT>
    </TD>
   </TR>
   <TR>
    <TD width="30%" class="column_title"><% iw_webCfgDescHandler(IPSecSection, "authenticationalg", "Authentication mode"); %></TD>
    <TD width="70%">
     <SELECT size="1" id="iw_ipsec_authenticationalg" name="iw_<% write(IPSecSection); %>_authenticationalg" onchange='iw_onAUTHchange();'>
                <option value="Pre-shared Key">Pre-shared Key</option>
                <option value="RSA Signature">RSA Signature</option>
                <option value="X.509">X.509</option>
                <INPUT type="text" id="iw_ipsec_psk" name="iw_<% write(IPSecSection); %>_psk" size="32" maxlength="64" value="<% iw_webCfgValueHandler(IPSecSection, "psk", ""); %>">
                                  </SELECT>
    </TD>
   </TR>
   </TABLE>
   <div id="rsa">
   <TABLE width="100%">
   <tr>
                                <TD id="rsakey" width="40%" class="column_title" colspan="3">RSA key</TD>
                        </tr>

   <TR>
   <TD id="private_key" rowspan="5" width="30%" class="column_title">Local</TD>
   <TR>
   <TD width="30%">
   <input align="center" width="100" type="button" id="gen_priavte_key" value="Generate Local Private Key" onClick="gen_private();" />
   <input align="center" width="100" type="button" id="export_private_key" value="Export Local Private Key" onClick="export_private();" />
   </TD>
   <TD width="100%">
   <font align="left" id="gen_priavte_key_font" color="red">Private key is generating...</font>
   </TD>
   </TR>
   <TR>
                                <TD colspan="2" id="file_private_key" width="100%" class="column_title">Select private key file for local<INPUT align ="center" id="file_private" type="file" name="file_private" size="70"></TD>
                        </TR>
   <TR>
   <TD colspan="2"><input id="import_private_key" align="center" width="100" type="button" value="Import Local Private Key" onClick="upload_file('rsa_local_private');" /></TD>
   </TR>
   </TR>
   </TABLE>

   <TABLE width="100%">
   <TR>
   <TD rowspan="10" id="local_private_key" name="local_private_key" class="column_title">Local private key</TD>
   </TR>
   <TR>
   <TD align="center"><TEXTAREA id="local_private_keyarea" rows="10" cols="100" READONLY></TEXTAREA></TD>
   </TR>
   </TABLE>
   <TABLE width="100%">
   <TR>
   <TD id="public_key" rowspan="4" width="30%" class="column_title">Remote</TD>
   <TR>
   <TD>
   <input align="center" width="100" type="button" id="export_public_key" value="Export Local Public Key" onClick="export_public();" />
   </TD>
   </TR>
   <TR>
                                <TD id="file_public_key" width="100%" class="column_title">Select remote public key file<INPUT align ="center" type="file" id="file_public" name="file_public" size="70"></TD>
                        </TR>
   <TR>
   <TD>
   <input align="center" width="100" type="button" id="import_public_key" value="Import Remote Public Key" onClick="upload_file('rsa_remote_public');" />
   </TD>
   </TR>
   </TABLE>
   <TABLE width="100%">
   <TR>
   <TD rowspan="10" id="remote_public_key" name="remote_public_key" class="column_title">Remote public key</TD>
   </TR>
   <TR>
   <TD align="center"><TEXTAREA id="remote_public_keyarea" rows="5" cols="100" READONLY></TEXTAREA></TD>
   </TR>
   </TABLE>
   </div>

   <div id="x509">
   <TABLE width="100%">
          <TR>
   <TD width="30%" id="local_cert" name="local_cert" class="column_title"><% iw_webCfgDescHandler(IPSecSection, "local_cert", ""); %></TD>
   <TD width="70%">
    <SELECT size="1" id="iw_ipsec_local_cert" name="iw_<% write(IPSecSection); %>_local_cert">
    <%iw_webCertOption("local_cert");%>
    </SELECT>
   </TD>
              </TR>
          <TR>
   <TD width="30%" id="remote_cert" name="remote_cert" class="column_title"><% iw_webCfgDescHandler(IPSecSection, "remote_cert", ""); %></TD>
   <TD width="70%">
    <SELECT size="1" id="iw_ipsec_remote_cert" name="iw_<% write(IPSecSection); %>_remote_cert">
    <%iw_webCertOption("remote_cert");%>
    </SELECT>
   </TD>
              </TR>
   </TABLE>
   </div>

   <TABLE width="100%">
   <TR>
    <TD width="30%" class="column_title"><% iw_webCfgDescHandler(IPSecSection, "ph1_encryptalg", "Encryption Algorithm"); %></TD>
    <TD width="70%">
     <SELECT size="1" id="iw_ipsec_ph1_encryptalg" name="iw_<% write(IPSecSection); %>_ph1_encryptalg">
                <option value="DES">DES</option>
                <option value="IPSEC_3DES">3DES</option>
                <option value="AES">AES-128</option>
                <option value="AES192">AES-192</option>
                <option value="AES256">AES-256</option>
                                  </SELECT>
    </TD>
   </TR>
   <TR>
    <TD width="30%" class="column_title"><% iw_webCfgDescHandler(IPSecSection, "ph1_hashalg", "Hash Algorithm"); %></TD>
    <TD width="70%">
     <SELECT size="1" id="iw_ipsec_ph1_hashalg" name="iw_<% write(IPSecSection); %>_ph1_hashalg">
                <option value="MD5">MD5</option>
                <option value="SHA-1">SHA-1</option>
                                  </SELECT>
    </TD>
   </TR>
   <TR>
    <TD width="30%" class="column_title"><% iw_webCfgDescHandler(IPSecSection, "dhgroup", "DH Group"); %></TD>
    <TD width="70%">
     <SELECT size="1" id="iw_ipsec_dhgroup" name="iw_<% write(IPSecSection); %>_dhgroup">
                <option value="DH-2">DH-2</option>
                <option value="DH-5">DH-5</option>
                                  </SELECT>
    </TD>
   </TR>
          <TR>
    <TD width="30%" class="column_title"><% iw_webCfgDescHandler(IPSecSection, "key_retry", ""); %></TD>
    <TD width="70%">
                <INPUT type="text" id="iw_ipsec_key_retry" name="iw_<% write(IPSecSection); %>_key_retry" size="5" maxlength="5" value="<% iw_webCfgValueHandler(IPSecSection, "key_retry", ""); %>"> (0:forever)
               </TD>
              </TR>
          <TR>
    <TD width="30%" class="column_title"><% iw_webCfgDescHandler(IPSecSection, "ike_lifetime", ""); %></TD>
    <TD width="70%">
                <INPUT type="text" id="iw_ipsec_ike_lifetime" name="iw_<% write(IPSecSection); %>_ike_lifetime" size="5" maxlength="5" value="<% iw_webCfgValueHandler(IPSecSection, "ike_lifetime", ""); %>"> min.
               </TD>
              </TR>
          <TR>
    <TD width="30%" class="column_title"><% iw_webCfgDescHandler(IPSecSection, "rekey_margin", ""); %></TD>
    <TD width="70%">
                <INPUT type="text" id="iw_ipsec_rekey_margin" name="iw_<% write(IPSecSection); %>_rekey_margin" size="5" maxlength="5" value="<% iw_webCfgValueHandler(IPSecSection, "rekey_margin", ""); %>"> min.
               </TD>
              </TR>
          <TR>
    <TD width="30%" class="column_title"><% iw_webCfgDescHandler(IPSecSection, "rekey_fuzz", ""); %></TD>
    <TD width="70%">
                <INPUT type="text" id="iw_ipsec_rekey_fuzz" name="iw_<% write(IPSecSection); %>_rekey_fuzz" size="5" maxlength="3" value="<% iw_webCfgValueHandler(IPSecSection, "rekey_fuzz", ""); %>"> %
               </TD>
              </TR>
  </TABLE>
   <TR>
   <TD colspan="2"><HR>
   </TD>
 <H2><% iw_webSysDescHandler("ISAKMPPhase2", "", "Data Exchange (Phase1)"); %></H2>
  <TABLE width="100%">
   <TR>
    <TD width="30%" class="column_title"><% iw_webCfgDescHandler(IPSecSection, "pfs", "Perfect Forward Secrecy"); %></TD>
    <TD width="70%">
     <SELECT size="1" id="iw_ipsec_pfs" name="iw_<% write(IPSecSection); %>_pfs">
                <option value="ENABLE">Enable</option>
                <option value="DISABLE">Disable</option>
                                  </SELECT>
    </TD>
   </TR>
          <TR>
    <TD width="30%" class="column_title"><% iw_webCfgDescHandler(IPSecSection, "sa_lifetime", ""); %></TD>
    <TD width="70%">
                <INPUT type="text" id="iw_ipsec_sa_lifetime" name="iw_<% write(IPSecSection); %>_sa_lifetime" size="5" maxlength="5" value="<% iw_webCfgValueHandler(IPSecSection, "sa_lifetime", ""); %>"> min.
               </TD>
              </TR>
   <TR>
    <TD width="30%" class="column_title"><% iw_webCfgDescHandler(IPSecSection, "ph2_encryptalg", "Encryption Algorithm"); %></TD>
    <TD width="70%">
     <SELECT size="1" id="iw_ipsec_ph2_encryptalg" name="iw_<% write(IPSecSection); %>_ph2_encryptalg">
                <option value="DES">DES</option>
                <option value="IPSEC_3DES">3DES</option>
                <option value="AES">AES-128</option>
                <option value="AES192">AES-192</option>
                <option value="AES256">AES-256</option>
                                  </SELECT>
    </TD>
   </TR>
   <TR>
    <TD width="30%" class="column_title"><% iw_webCfgDescHandler(IPSecSection, "ph2_hashalg", "Hash Algorithm"); %></TD>
    <TD width="70%">
     <SELECT size="1" id="iw_ipsec_ph2_hashalg" name="iw_<% write(IPSecSection); %>_ph2_hashalg">
                <option value="MD5">MD5</option>
                <option value="SHA-1">SHA-1</option>
                                  </SELECT>
    </TD>
   </TR>
  </TABLE>
   <TR>
   <TD colspan="2"><HR>
   </TD>
 <H2><% iw_webSysDescHandler("DeadPeerDetection", "", "Dead Peer Detection"); %></H2>
  <TABLE width="100%">
   <TR>
    <TD width="30%" class="column_title"><% iw_webCfgDescHandler(IPSecSection, "dpd_action", ""); %></TD>
    <TD width="70%">
     <SELECT size="1" id="iw_ipsec_dpd_action" name="iw_<% write(IPSecSection); %>_dpd_action">
                <option value="DPD_DISABLE">Disable</option>
                <option value="DPD_HOLD">Hold</option>
                <option value="DPD_CLEAR">Clear</option>
                <option value="DPD_RESTART">Restart</option>
                <option value="DPD_RESTART_BY_PEER">Restart by Peer</option>
                                  </SELECT>
    </TD>
   </TR>
          <TR>
    <TD width="30%" class="column_title"><% iw_webCfgDescHandler(IPSecSection, "dpd_delay", ""); %></TD>
    <TD width="70%">
                <INPUT type="text" id="iw_ipsec_dpd_delay" name="iw_<% write(IPSecSection); %>_dpd_delay" size="5" maxlength="5" value="<% iw_webCfgValueHandler(IPSecSection, "dpd_delay", ""); %>"> seconds
               </TD>
              </TR>
          <TR>
    <TD width="30%" class="column_title"><% iw_webCfgDescHandler(IPSecSection, "dpd_timeout", ""); %></TD>
    <TD width="70%">
                <INPUT type="text" id="iw_ipsec_dpd_timeout" name="iw_<% write(IPSecSection); %>_dpd_timeout" size="5" maxlength="5" value="<% iw_webCfgValueHandler(IPSecSection, "dpd_timeout", ""); %>"> seconds
               </TD>
              </TR>
  </TABLE>
  <TABLE>
   <TR>
    <TD colspan="2"><HR>
     <INPUT type="button" value="Submit" name="Submit" onClick="CheckValue();">
     <Input type="hidden" name="bkpath" value="/ipsec_option.asp?IPSecIndex=<% write(IPSecIndex); %>">
     <input type="hidden" name="IPSecSection" value="<% write(IPSecSection); %>">
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
