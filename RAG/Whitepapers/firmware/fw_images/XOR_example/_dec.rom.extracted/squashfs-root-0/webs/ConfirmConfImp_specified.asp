<HTML>
<HEAD>
 <META http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
 <LINK href="nport2g.css" rel=stylesheet type=text/css>
 <TITLE><% iw_webSysDescHandler("ConfigurationImportTree", "", "Configuration Import"); %></TITLE>
 <% iw_webJSList_get(); %>
 <SCRIPT type="text/javascript">
 <!--

     var skip_config = "";

     function takeAction()
     {
      var ret = true;


  if( document.conf.iw_conf_action.value == "IMPORT_FILE" )
  {
   importConf();
  } else if( document.conf.iw_conf_action.value == "IMPORT_ABC01" )
  {
   importABC01Func();
  } else if( document.conf.iw_conf_action.value == "EXPORT_FILE" )
  {
   exportConf();
  } else if( document.conf.iw_conf_action.value == "EXPORT_ABC01" )
  {
   exportABC01Func();
  } else if( document.conf.iw_conf_action.value == "EXPORT_MIB" )
  {
   exportMIBFunc();
  }
  else
  {
   alert("Unknown action");
   ret = false;
  }

  return ret;
     }

     function selall()
     {
      for(i = 0; i < document.conf.length; i++)
  {
   if(document.conf.elements[i].value.length > 0
      && document.conf.elements[i].name.match("iw_skipConf_") )
   {
    if(document.conf.SelAll.checked == true)
     document.conf.elements[i].checked = true;
    else
     document.conf.elements[i].checked = false;
   }
  }
     }

     function importConf()
     {
      if (document.conf.config.value == "")
  {
   window.alert("Error! Please specify a file.");
   return false;
  }

  var fd = new FormData();
  fd.append("fileToUpload", document.conf.config.files[0]);
  var xhr = new XMLHttpRequest();
  xhr.open("POST", "/forms/web_cfgImport");
  xhr.send(fd);

  return true;

     }

  function exportConf()
  {
   skip_config_get();
   if( skip_config == "")
   {
           document.location.href='config.ini' ;
   } else
   {
    document.location.href='config.ini?' + skip_config ;
   }

  }


  function exportMIBFunc()
  {

   document.location.href="MOXA-AWK3131A-MIB.my";



  }



  function editPermission()
  {
   var form = document.conf, i, j = <% iw_websCheckPermission(); %>;
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

   // Init: allow to import/export all configuration
   document.conf.SelAll.checked = true;
   selall();

   // Init: action
   document.conf.iw_conf_action.value = "IMPORT_FILE";
  }

  function skip_config_get()
  {
   if( document.conf.iw_skipConf_clientIsolation.checked == true)
   {
    skip_config = "skip_clientIso=1";
   } else
   {
    skip_config = "skip_clientIso=0";
   }
   return skip_config;
  }

  function exportABC01Func()
  {
   var http_req = false;
   http_req = iw_inithttpreq();

   if (!http_req )
   {
    alert('Cannot create httpreq instance.');
         return false;
   }

   var sendData = "";
   skip_config_get();
   if( skip_config == "")
   {
    http_req.open( "GET", "/forms/web_exportABC01", true );
   } else
   {
    http_req.open( "GET", "/forms/web_exportABC01?" + skip_config, true );
   }

      http_req.setRequestHeader( "Content-type", "application/x-www-form-urlencoded" );
   http_req.setRequestHeader( "Content-length", sendData.length );

      document.getElementById("take_action").value = "Exporting..."

      http_req.send( sendData );

      http_req.onreadystatechange = function()
      {
       if(http_req.readyState == 4)
    {
     http_req.onreadystatechange = function() {};

     document.getElementById("take_action").value = "Take action"

     if(http_req.status == 200)
     {
      alert('ABC-01 export success.');
      return true;
     }

     alert('ABC-01 export failed.');
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

   skip_config_get();

   if (!http_req )
   {
    alert('Cannot create httpreq instance.');
          return false;
   }

   var sendData = "";
   if( skip_config == "" )
   {
    http_req.open( "GET", "/forms/web_importABC01" + skip_config, true );
   } else
   {
    http_req.open( "GET", "/forms/web_importABC01?" + skip_config, true );
   }
      http_req.setRequestHeader( "Content-type", "application/x-www-form-urlencoded" );
   http_req.setRequestHeader( "Content-length", sendData.length );

   document.getElementById("take_action").value = "Importing..."
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

     document.getElementById("take_action").value = "Take action";
     iw_ChangeOnLoad();
        for( var k=0, elm; elm=allElements[k++]; )
     {
      elm.disabled = false;
     }

     if(http_req.status == 200)
     {
      alert('ABC-01 import success.');
      return true;
     }

     alert('ABC-01 import failed.');
     return false;
    }
      };

      return true;
  }
  function check()
  {
   if( document.conf.iw_conf_action.value == "IMPORT_FILE" )
   {
    alert("import config");
    if (document.conf.config.value != "")
    {
     document.conf.Import.disabled = true;
     return true;
    } else
    {
     window.alert("Error! Please specify a file.");
     return false;
    }

   }
   else if( document.conf.iw_conf_action.value == "EXPORT_FILE" )
   {
    alert("export config");
    exportConf();
    return false;
   }
  }
 //-->
 </SCRIPT>
</HEAD>
<BODY onLoad="iw_ChangeOnLoad();">
  <FORM name="conf" method="POST" action="/forms/web_cfgImport" enctype="multipart/form-data" onsubmit="return check()">
    <H2><% iw_webSysDescHandler("ConfigurationImExportTree", "", "Configuration Import Export"); %> <% iw_websGetErrorString(); %></H2>

    <TABLE width="100%">
      <TR>
 <TD width="30%" class="column_title">Action</TD>
     <TD width="70%">
          <SELECT size="1" id="iw_conf_action" name="iw_conf_action">
            <option value="IMPORT_FILE">Import from file</option>
     <option value="IMPORT_ABC01">Import from ABC-01</option>
     <option value="EXPORT_FILE">Export to file</option>
     <option value="EXPORT_ABC01">Export to ABC-01</option>
     <option value="EXPORT_MIB">Export MIB file</option>
   </SELECT>
       </TD>
      </TR>
      <TR>
 <TD width="25%" class="column_title">Select configuration file</TD>
 <TD width="75%"><INPUT type="file" name="config" size="70"></TD>
      </TR>
      <TR>
 <TD colspan="2"><HR>
   <INPUT type="button" value="Take action" name="take_action" onClick="takeAction();">
      </TR>
    </TABLE>

    <H2><BR><BR>Skipped configuration</H2>
    <TABLE width="100%">
      <tr>
 <TD class="column_text_no_bg" colspan="2">Tips: The selected configuration will not be imported/exported.</TD>
      </tr>
      <TR align="left">
 <TD width="10%" align="center" class="block_title"><INPUT type="checkbox" name="SelAll" id="SelAll" onclick="selall()";>Active</TD>
 <TD width="90%" class="block_title">Configuration</TD>
      </TR>
      <TR align="left">
 <TD width="10%" align="center"><INPUT type="checkbox" name="iw_skipConf_clientIsolation" id="iw_skipConf_clientIsolation"></TD>
 <TD width="90%" align="left">Client isolation</TD>
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
