<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
 <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
    <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate" />
    <meta http-equiv="Pragma" content="no-cache" />
    <meta http-equiv="Expires" content="0" />
 <link href="nport2g.css" rel=stylesheet type=text/css>
 <title><% iw_webSysDescHandler("lfpTree", "", "Link Fault Pass-Through"); %></title>
 <% iw_webJSList_get(); %>
 <script type="text/javascript">
 <!--
  var mem_state = <% iw_websMemoryChange(); %>;



  var BoardOpMode = new String( "<% iw_webCfgValueHandler( "board", "operationMode", "AP_CLIENT" ); %>" );


  var VapOpModes = new Array( "<% iw_webCfgValueHandler( "wlanDevWIFI0", "operationMode", "AP" ); %>" );







  function editPermission()
  {
   var form = document.linkFaultPassThrough, i, j = <% iw_websCheckPermission(); %>;
   if(j)
   {
    for(i = 0; i < form.length; i++)
     form.elements[i].disabled = true;
   }
  }


  function iw_OnLoad()
  {
   var i, count;

   count = 0;
   for( i = 0; i < VapOpModes.length; i++ )
   {
    if( VapOpModes[i] == "CLIENT" || VapOpModes[i] == "SLAVE" )
     count++;
    else if( VapOpModes[i] != "DISABLE" )
     count = 100;
   }
   if( BoardOpMode == "WIRELESS_REDUNDANCY" )
    count--;

   if( count != 1 )
   {
    document.getElementById("iw_linkFaultPassThrough_En").disabled = true;
    document.getElementById("iw_linkFaultPassThrough_Dis").disabled = true;
   }

   if( "<% iw_webCfgValueHandler("linkFaultPassThrough", "enable", "ENABLE"); %>" == "ENABLE" )
    document.getElementById("iw_linkFaultPassThrough_En").checked = true;
   else
    document.getElementById("iw_linkFaultPassThrough_Dis").checked = true;


                 editPermission();


   top.toplogo.location.reload();
  }
 //-->
 </script>
</head>
<body onLoad="iw_OnLoad();">
 <h2><% iw_webSysDescHandler("lfpTree", "", "Link Fault Pass-Through"); %>


   (For Client/Slave mode only)



 &nbsp;&nbsp;<% iw_websGetErrorString(); %></h2>
 <form name="linkFaultPassThrough" method="post" action="/forms/iw_webSetParameters">
  <table width=100%>
   <tr>
    <td width="30%" class="column_title"><% iw_webCfgDescHandler("linkFaultPassThrough", "enable", "Link Fault Pass-Through"); %></td>
    <td width="70%">
     <input type="radio" name="iw_linkFaultPassThrough_enable" id="iw_linkFaultPassThrough_En" value="ENABLE" />
     <label for="iw_linkFaultPassThrough_En">Enable</label>
     <input type="radio" name="iw_linkFaultPassThrough_enable" id="iw_linkFaultPassThrough_Dis" value="DISABLE" />
     <label for="iw_linkFaultPassThrough_Dis">Disable</label>
    </td>
   </tr>
   <tr>
    <td colspan="2">
     <hr />
     <input type="submit" value="Submit" name="Submit" />
     <input type="hidden" name="bkpath" value="/LFP.asp" />
    </td>
   </tr>
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
