<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%
 var certSection;

 if ( iw_isset(index) == 0 )
 {
  index = 1;
 }

 if ( index==2 )
 {
  wifiSection = "wlanDevWIFI1";
  certSection = "certWlan1";
  rfindex = 1;
 }else
 {
  wifiSection = "wlanDevWIFI0";
  certSection = "certWlan";
  rfindex = 0;
 }
%>
<html>
<head>
 <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
    <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate" />
    <meta http-equiv="Pragma" content="no-cache" />
    <meta http-equiv="Expires" content="0" />
 <link href="nport2g.css" rel="stylesheet" type="text/css" />
 <title>



  <% iw_webSysDescHandler("WLANCertificateSettingsTree", "", "WLAN Certificate Settings"); %></title>
 <% iw_webJSList_get(); %>
 <script type="text/javascript">
 <!--
  // Platform-independent part
   var mem_state = <% iw_websMemoryChange(); %>;

   // Platform-dependent part
  function iw_onSubmit()
  {
   var form = document.wireless_advan;

  }




  var VAPopMode = new String("<% iw_webCfgValueHandler( wifiSection,	"operationMode",	"AP" ); %>");


  function editPermission()
  {
   var form = document.cfile, i, j = <% iw_websCheckPermission(); %>;
   if(j)
   {
    for(i = 0; i < form.length; i++)
     form.elements[i].disabled = true;
   }
  }


  function iw_onLoad()
  {
   var formItem, ctrlItem, newItem, i;

   // For wireless_basic form
   formItem = document.cfile;




   if( VAPopMode == "SNIFFER" )
   {
    for( i = 0; i < formItem.elements.length; i++ )
    {
     formItem.elements[i].disabled = true;
    }
   }

   iw_onChange();


                editPermission();


   // CAUSION : This line must be executed in <body onLoad()>
   top.toplogo.location.reload();
  }

  function iw_onChange()
  {
   var formItem, ctrlItem, newItem, i, selIndex;
  }

        -->
    </script>
</head>
<body onLoad="iw_onLoad();">

 <h2>



  <% iw_webSysDescHandler("WLANCertificateSettingsTree", "", "WLAN Certificate Settings"); %>&nbsp;&nbsp;<% iw_websGetErrorString(); %></h2>

 <form name="cfile" method="post" action="/forms/web_certUpload" enctype="multipart/form-data" onSubmit="return onSubmig();">
 <table width="100%">
 <tr>
  <td width=30% class="column_title">
   <% iw_webCfgDescHandler( certSection, "privatePass", "Certificate private password" ); %>
  </td>
  <td width=70%>
   <input type="password" id="iw_privatePass" name="iw_privatePass" size="37" maxlength="31" value = "<% iw_webCfgValueHandler(certSection, "privatePass", ""); %>" />
  </td>
 </tr>
 <tr>
  <td width=30% class="column_title">Select certificate/key file</td>
  <td width=70%>
   <input type="file" name="certFile" size="70" />
  </td>
 </tr>
 <tr>
  <td colspan="2">
    <hr />
    <input type="submit" value="Submit" name="Submit" />
    <input type="hidden" name="bkpath" value="/wireless_cert.asp?index=<% write(index); %>" />
    <input type="hidden" name="certSection" value="<% write(certSection); %>" />
    <input type="hidden" name="rfindex" value="<% write(rfindex); %>" />
  </td>
 </tr>
 </table>

 <br />
 <table>
   <TR class="column_title_bg">
  <TD colspan="2" class="block_title">Status</TD>
   </TR>

   <script type="text/javascript">
  var bgColorIdx = 0;
  var bgColorArray = ["beige", "azure"];
  function addStatusRow( Title, State )
  {
   document.write("<tr style=\"background-color: " + bgColorArray[bgColorIdx] + ";\">");
     document.write("<td width=\"30%\" class=\"column_title\" style=\"background-color: " + bgColorArray[bgColorIdx] + ";\">" + Title + "</td>");
   document.write("<td width=\"70%\">" + State + " </td>");
   document.write("</tr>");
   bgColorIdx = 1 - bgColorIdx;
  }

  addStatusRow("<% iw_webCfgDescHandler( certSection, "issueTo", "Certificate issued to" ); %>", "<% iw_webCfgValueHandler( certSection, "issueTo", "N/A" );  %>");
  addStatusRow("<% iw_webCfgDescHandler( certSection, "issueBy", "Certificate issued by" ); %>", "<% iw_webCfgValueHandler( certSection, "issueBy", "N/A" );  %>");
  addStatusRow("<% iw_webCfgDescHandler( certSection, "expireDate", "Certificate expiration date" ); %>", "<% iw_webCfgValueHandler( certSection, "expireDate", "N/A" );  %>");
   </SCRIPT>
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
