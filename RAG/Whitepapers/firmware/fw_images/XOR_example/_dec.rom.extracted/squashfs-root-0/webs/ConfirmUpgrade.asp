<HTML>
<HEAD>
 <META http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
    <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate" />
    <meta http-equiv="Pragma" content="no-cache" />
    <meta http-equiv="Expires" content="0" />
 <LINK href="nport2g.css" rel=stylesheet type=text/css>
 <TITLE>Firmware Upgrade</TITLE>
 <script type="text/javascript"">
 <!--

  var script_info = <% iw_webCheckSize(); %>;


  function check()
  {
   path = document.file_upload.filename.value;
   subname=path.substring(path.lastIndexOf('.')+1,path.length);
   subname_allow=['rom'];
   flag=0;
   for (i in subname_allow)
   {
    if (subname==subname_allow[i])
    {
     flag=1;
    }
   }
   if (flag==0)
   {
    alert('Invalid firmware file. The correct file should be a "*.rom".');
    return false;

   }

   if (script_info=="No")
   {
    alert('Please remove the result of troubleshooting !! ');
    return false;
   }

   if (document.file_upload.filename.value != "")
   {
    document.file_upload.Submit.disabled = true;
    document.getElementById("txmsg").style.display = "";
    return true;
   }
   else
   {
    window.alert("Error! Please specify a file.");
    return false;
   }



  }


  function editPermission()
  {
   var form = document.file_upload, i, j = <% iw_websCheckPermission(); %>;
   if(j)
   {
    for(i = 0; i < form.length; i++)
     form.elements[i].disabled = true;
   }
  }


  function msgLoad()
  {
   document.getElementById("txmsg").style.display = "none";

                 editPermission();

  }
 //-->
 </SCRIPT>
</HEAD>
<BODY onload="msgLoad()">

 <H2><% iw_webSysDescHandler("FirmwareUpgradeTree", "", "Firmware Upgrade"); %>



  <% iw_websGetErrorString(); %></H2>

        <FORM name="file_upload" id="file_upload" method="post" action="/forms/web_fwUpload" enctype="multipart/form-data" onsubmit="return check()">
     <TABLE width="100%">
                  <TR>
              <TD width="25%" class="column_title">Select firmware file</TD>
          <TD width="75%"> <INPUT type="file" name="filename" size="70"></TD>
      </TR>
    <tr>
 <TD colspan="2"><HR>
   <INPUT type="submit" value="Upgrade Firmware and Restart" name="Submit">
 </TD>
 <tr>
 </TABLE>
 <TABLE width="100%" height=30>
  <TR>
    <TD colspan="2"></TD>
  </TR>
 </TABLE>
     <TABLE id=txmsg width="100%">
                  <TR>
              <TD width="100%" class="column_title">Loading file, please wait...</TD>
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
