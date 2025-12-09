<HTML>
<HEAD>
 <META http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
    <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate" />
    <meta http-equiv="Pragma" content="no-cache" />
    <meta http-equiv="Expires" content="0" />
 <LINK href="nport2g.css" rel=stylesheet type=text/css>
 <TITLE><% iw_webSysDescHandler("ConfigurationImportTree", "", "Configuration Import"); %></TITLE>
 <% iw_webJSList_get(); %>
 <SCRIPT type="text/javascript">
 <!--
  function check()
  {
   if (document.conf.config.value != "")
   {
    document.conf.Import.disabled = true;
   }
   else
   {
    window.alert("Please select a configuration file.");
    return false;
   }
   return true;
  }

  function Backup()
  {
   document.location.href='config.ini?web';




  }


  function exportMIBFunc()
  {

   document.location.href="MOXA-AWK3131A-MIB.my";



  }



  function editPermission()
  {
   var form = document.confsetting, form1 = document.conf, form2= document.skipConf,j = <% iw_websCheckPermission(); %>;
   if(j)
   {
    for(i = 0; i < form.length; i++)
     form.elements[i].disabled = true;
    for(i = 0; i < form1.length; i++)
     form1.elements[i].disabled = true;
    for(i = 0; i < form2.length; i++)
     form2.elements[i].disabled = true;
   }
  }


  var mem_state = <% iw_websMemoryChange(); %>;
  function iw_ChangeOnLoad()
  {
   iw_configOnLoad();


                 editPermission();


   top.toplogo.location = "./top.asp?time="+new Date();
   top.toplogo.location.reload();



  }


  function exportABC01Func()
  {
   var http_req = false;
   var allElements = document.all || document.getElementsByTagName('input');
   http_req = iw_inithttpreq();

   if (!http_req )
   {
    alert('Cannot create httpreq instance.');
         return false;
   }

   var sendData = "";
   http_req.open( "GET", "/forms/web_exportABC01", true );

      http_req.setRequestHeader( "Content-type", "application/x-www-form-urlencoded" );
   http_req.setRequestHeader( "Content-length", sendData.length );

      document.getElementById("exportABC01").value = "Exporting..."
      for( var k=0, elm; elm=allElements[k++]; )
   {
    elm.disabled = true;
   }

      http_req.send( sendData );

      http_req.onreadystatechange = function()
      {
       if(http_req.readyState == 4)
    {
     http_req.onreadystatechange = function() {};

     document.getElementById("exportABC01").value = "Export Configuration"
     iw_ChangeOnLoad();
        for( var k=0, elm; elm=allElements[k++]; )
     {
      elm.disabled = false;
     }

     if(http_req.status == 200)
     {
      alert('ABC-01 configuration file successfully exported.');
      return true;
     }

     alert('Failed to export ABC-01 configuration file.');
     return false;
    }
      };

      return true;
  }

  function importABC01Func()
  {
   var http_req = false;
   var allElements = document.all || document.getElementsByTagName('input');
   http_req = iw_inithttpreq();

   if (!http_req )
   {
    alert('Cannot create httpreq instance.');
         return false;
   }

   var sendData = "";
   http_req.open( "GET", "/forms/web_importABC01", true );

      http_req.setRequestHeader( "Content-type", "application/x-www-form-urlencoded" );
   http_req.setRequestHeader( "Content-length", sendData.length );

   document.getElementById("importABC01").value = "Importing..."
      for( var k=0, elm; elm=allElements[k++]; )
   {
    elm.disabled = true;
   }

      http_req.send( sendData );

      http_req.onreadystatechange = function()
      {
       if(http_req.readyState == 4)
    {
     http_req.onreadystatechange = function() {};

     document.getElementById("importABC01").value = "Import Configuration";
     iw_ChangeOnLoad();
        for( var k=0, elm; elm=allElements[k++]; )
     {
      elm.disabled = false;
     }

     if(http_req.status == 200)
     {
      alert('ABC-01 configuration file successfully imported.');
      return true;
     }

     alert('Failed to import ABC-01 configuration file.');
     return false;
    }
      };

      return true;
  }
  $(document).ready(function(){
   document.getElementById('iw_config_encryptEnable1').onchange = disablefield;
   document.getElementById('iw_config_encryptEnable0').onchange = disablefield;
  });
  function disablefield()
  {
   if ( document.getElementById('iw_config_encryptEnable1').checked == true ){
    document.getElementById('iw_configEncrypt_password').disabled = true;
   }else if (document.getElementById('iw_config_encryptEnable0').checked == true ){
    document.getElementById('iw_configEncrypt_password').disabled = false;
   }
  }
  function iw_configOnLoad()
  {
   if ("<% iw_webCfgValueHandler("configEncrypt", "enable", "DISABLE"); %>" == "ENABLE")
    document.confsetting.iw_config_encryptEnable0.checked = true;
   else{
    document.getElementById('iw_config_encryptEnable1').checked = true;
    document.getElementById('iw_config_encryptEnable0').checked = false;
    document.getElementById('iw_configEncrypt_password').disabled = true;
   }
  }
  function checkSetting()
  {
   if (document.getElementById('iw_config_encryptEnable0').checked == true && document.getElementById('iw_configEncrypt_password').value =='') {
    alert("Error! Password should not be blank.");
    return false;
   }
   return true ;
  }

 //-->
 </SCRIPT>
</HEAD>
<BODY onLoad="iw_ChangeOnLoad();">
 <H2><% iw_webSysDescHandler("ConfigurationImExportTree", "", "Configuration Import Export"); %> <% iw_websGetErrorString(); %></H2>

 <FORM name="confsetting" method="POST" action="/forms/iw_webSetConfigEncryptionParameters" onsubmit="return checkSetting()">

  <H2><% iw_webSysDescHandler("ConfigEncryptionSettingTree", "", "Configuration File Encryption Setting (Excluding ABC-01)"); %> <% iw_websGetErrorString(); %></H2>
  <table width="100%">
   <tr>
    <TD width="25%" class="column_title">
                    <% iw_webCfgDescHandler("configEncrypt", "enable", "HTTP console"); %>
    </TD>
                <TD width="75%" colspan="2">
     <INPUT type="radio" name="iw_configEncrypt_enable" value="ENABLE" id="iw_config_encryptEnable0" checked><label for="iw_config_encryptEnable0">Enable</label>
     <INPUT type="radio" name="iw_configEncrypt_enable" value="DISABLE" id="iw_config_encryptEnable1"><label for="iw_config_encryptEnable1">Disable</label>
    </TD>
   </tr>
   <tr>
    <TD width="25%" class="column_title">
                    <% iw_webCfgDescHandler("configEncrypt", "password", "Password"); %>
    </TD>
    <TD width="75%">
     <INPUT type="password" name="iw_configEncrypt_password" id="iw_configEncrypt_password" size="40" maxlength="31" value = "<% iw_webCfgValueHandler("configEncrypt", "password", ""); %>">
    </TD>
   </tr>
   <tr>
     <TD colspan="2"><HR>
     <INPUT type="submit" value="Apply" name="Submit">
     </TD>
       <Input type="hidden" name="bkpath" value="/ConfirmConfImp.asp">
   </tr>
  </table>
 </FORM>

 <FORM name="conf" method="POST" action="/forms/web_cfgImport" enctype="multipart/form-data" onsubmit="return check()">
  <TABLE width="100%">
   <tr>
    <TD width="25%" class="column_title" colspan="2"><% iw_webSysDescHandler("ConfigurationImportTree", "", "Configuration Export"); %></TD>
   </tr>
   <TR>
    <TD width="25%" class="column_title">Select configuration file</TD>
    <TD width="75%"><INPUT type="file" name="config" size="70"></TD>
   </TR>
   <TR>
    <TD colspan="2"><HR>
    <INPUT type="submit" value="Import Configuration" name="Import">
     <!-- IE 6.0 will send file data without begin boundary if there is no Submit field sent (Submit is disabled in check())
          So we send a HIDDEN field to patch this bug //-->
     <INPUT type="hidden" name="PatchIEBug" value="Patch">
     <INPUT type="hidden" name="Interface" value="web">
    </TD>
   </TR>

   <TR>
    <TD width="25%" class="column_title" colspan="2"><BR /><BR /><% iw_webSysDescHandler("ConfigurationExportTree", "", "Configuration Export"); %></TD>
   </TR>
   <TR>
    <TD colspan="2"><HR>
     <INPUT type="button" name="Export" value="Export Configuration" onClick="Backup()">
    </TD>
   </TR>

   <TR>
    <TD width="25%" class="column_title" colspan="2"><BR /><BR />ABC-01 Configuration Import</TD>
   </TR>
   <TR>
    <TD colspan="2"><HR>
     <input type="button" id="importABC01" value="Import Configuration" onClick="importABC01Func();" />
    </TD>
   </TR>
   <TR>
    <TD width="25%" class="column_title" colspan="2"><BR /><BR />ABC-01 Configuration Export</TD>
   </TR>
   <TR>
    <TD colspan="2"><HR>
     <input type="button" id="exportABC01" value="Export Configuration" onClick="exportABC01Func();" />
    </TD>
   </TR>

   <TR>
    <TD width="25%" class="column_title" colspan="2"><BR /><BR />SNMP MIB file Export</TD>
   </TR>
   <TR>
    <TD colspan="2"><HR>
     <input type="button" id="exportMIB" value="Export MIB" onClick="exportMIBFunc();" />
    </TD>
   </TR>
  </TABLE>
 </FORM>
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
