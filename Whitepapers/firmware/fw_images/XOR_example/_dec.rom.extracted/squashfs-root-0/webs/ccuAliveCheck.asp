<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
 <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
 <link href="nport2g.css" rel=stylesheet type=text/css>
 <title><% iw_webSysDescHandler("ccuAliveCheck", "", "CCU Alive Check Setting"); %></title>
 <% iw_webJSList_get(); %>
 <script type="text/javascript">
 <!--
  var mem_state = <% iw_websMemoryChange(); %>;
  var BoardOpMode = new String( "<% iw_webCfgValueHandler( "board", "operationMode", "WIRELESS_REDUNDANCY" ); %>" );





  //#warn "Unknown Product"


  function iw_OnLoad()
  {
   iw_selectSet(document.ccuAliveCheck.iw_ccuAliveCheck_enable, "<% iw_webCfgValueHandler("ccuAliveCheck", "enable"  , "ENABLE");  %>");
   top.toplogo.location.reload();
  }

  function uploadLandingPageGIF( )
  {
   // check the file type		
   path = document.lpGifFileUpload.gifFilename.value;
   filename=path.substring(path.lastIndexOf('\\')+1,path.length);
   if( path == "" || filename != 'landingPage.gif' ){
    window.alert('Error! Please specify "landingPage.gif" file.');
    return false;
   }
  }

  function uploadLandingPageHtm()
  {
   // check the file type		
   path = document.lpHtmFileUpload.htmFilename.value;
   filename=path.substring(path.lastIndexOf('\\')+1,path.length);
   if( path == "" || filename != 'landingPage.htm' ){
    window.alert('Error! Please specify "landingPage.htm" file.');
    return false;
   }
  }

 //-->
 </script>
</head>
<body onLoad="iw_OnLoad();">
 <h2><% iw_webSysDescHandler("ccuAliveCheck", "", "CCU Alive Check Setting"); %>
 &nbsp;&nbsp;<% iw_websGetErrorString(); %></h2>
 <form name="ccuAliveCheck" method="post" action="/forms/iw_webSetParameters">
  <table width=100%>
   <tr>
    <td width="30%" class="column_title"><% iw_webCfgDescHandler("ccuAliveCheck", "enable", ""); %></td>
    <td width="70%">
    <select size="1" id="iw_ccuAliveCheck_enable" name="iw_ccuAliveCheck_enable">
     <option value="ENABLE">Enable</option>
     <option value="DISABLE">Disable</option>
    </select>
    </td>
   </tr>
   <tr>
    <td width="30%" class="column_title" valign="top"><% iw_webCfgDescHandler("ccuAliveCheck", "ccuPingHost", ""); %></td>
    <td width="70%">
     <input type="text" id="iw_ccuPingHost" name="iw_ccuAliveCheck_ccuPingHost" size="20" maxlength="15" value="<% iw_webCfgValueHandler("ccuAliveCheck", "ccuPingHost", ""); %>" />
    </td>
   </tr>
   <tr>
    <td width="30%" class="column_title" valign="top"><% iw_webCfgDescHandler("ccuAliveCheck", "ccuPingTimeout", ""); %></td>
    <td width="70%">
     <input type="text" id="iw_ccuPingTimeout" name="iw_ccuAliveCheck_ccuPingTimeout" size="6" maxlength="1" value="<% iw_webCfgValueHandler("ccuAliveCheck", "ccuPingTimeout", ""); %>" />&nbsp;&nbsp;(1~5 seconds)
    </td>
   </tr>
   <tr>
    <td width="30%" class="column_title" valign="top"><% iw_webCfgDescHandler("ccuAliveCheck", "ccuPingPollInterval", ""); %></td>
    <td width="70%">
     <input type="text" id="iw_ccuPingPollInterval" name="iw_ccuAliveCheck_ccuPingPollInterval" size="6" maxlength="1" value="<% iw_webCfgValueHandler("ccuAliveCheck", "ccuPingPollInterval", ""); %>" />&nbsp;&nbsp;(1~5 seconds)
    </td>
   </tr>
   <tr>
    <td width="30%" class="column_title" valign="top"><% iw_webCfgDescHandler("ccuAliveCheck", "ccuPingNumberOfAttempts", ""); %></td>
    <td width="70%">
     <input type="text" id="iw_ccuPingNumberOfAttempts" name="iw_ccuAliveCheck_ccuPingNumberOfAttempts" size="6" maxlength="2" value="<% iw_webCfgValueHandler("ccuAliveCheck", "ccuPingNumberOfAttempts", ""); %>" />&nbsp;&nbsp;(1~10 times)
    </td>
   </tr>
   <tr>
    <td width="30%" class="column_title" valign="top"><% iw_webCfgDescHandler("ccuAliveCheck", "ccuRebootCount", ""); %></td>
    <td width="70%">
     <input type="text" id="iw_ccuRebootCount" name="iw_ccuAliveCheck_ccuRebootCount" size="6" maxlength="1" value="<% iw_webCfgValueHandler("ccuAliveCheck", "ccuRebootCount", ""); %>" />&nbsp;&nbsp;(0~5 times)
    </td>
   </tr>
   <tr>
    <td width="30%" class="column_title" valign="top"><% iw_webCfgDescHandler("ccuAliveCheck", "ccuStationDHCPServer", ""); %></td>
    <td width="70%">
     <input type="text" id="iw_ccuPingHost" name="iw_ccuAliveCheck_ccuStationDHCPServer" size="20" maxlength="15" value="<% iw_webCfgValueHandler("ccuAliveCheck", "ccuStationDHCPServer", ""); %>" />
    </td>
   </tr>
   <tr>
    <td colspan="2">
     <hr />
     <input type="submit" value="Submit" name="Submit" />
     <input type="hidden" name="bkpath" value="/ccuAliveCheck.asp" />
    </td>
   </tr>
  </table>
 </form>
 <FORM name="lpHtmFileUpload" method="post" action="/forms/web_landingPageHtmUpload" enctype="multipart/form-data" onsubmit="return uploadLandingPageHtm()">
  <TABLE width="100%">
  <TR>
   <TD width="25%" class="column_title" colspan="2"><BR /><BR />Web Page Import<HR></TD>
  </TR>
  <TR>
   <TD width="25%" class="column_title">Select web page </TD>
   <TD width="75%"> <INPUT type="file" name="htmFilename" size="70"></TD>
  </TR>
  <TR>
   <TD colspan="2">
   <INPUT type="submit" value="Upload File" name="Submit">
   </TD>
  <TR>
  </TABLE>
 </FORM>

 <FORM name="lpGifFileUpload" method="post" action="/forms/web_landingPageGifUpload" enctype="multipart/form-data" onsubmit="return uploadLandingPageGIF()">
  <table>
              <TR>
    <TD width="25%" class="column_title" colspan="2"><BR /><BR />GIF File Import<HR></TD>
   </TR>
   <TR>
               <TD width="25%" class="column_title">Select gif file </TD>
               <TD width="75%"> <INPUT type="file" name="gifFilename" size="70"></TD>
              </TR>
              <TR>
    <TD colspan="2">
     <INPUT type="submit" value="Upload File" name="uploadGif">
    </TD>
   </TR>
  </table>
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
