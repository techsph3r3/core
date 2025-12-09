<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
 <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
 <link href="nport2g.css" rel="stylesheet" type="text/css">

 <title><% iw_webSysDescHandler("NetworkStatusTree", "", "Network Status"); %></title>
 <% iw_webJSList_get(); %>
 <script type="text/javascript" >
 <!--
 function iw_onLoad(){





 }


 var trBgColor = ["beige", "azure"];
 var bgColorIndex = 0;
 var devNum = 1 ;
 var arptable =<% iw_webGetArpTable(); %>
 var bridge = <% iw_webGetBridgeStatus();%>;
 var routetable =<% iw_webGetRoutingTable(); %>
 -->
 </script>
</head>
<body onLoad = "iw_onLoad()">
   <h2><% iw_webSysDescHandler("NetworkStatusTree", "", "Network Status"); %></h2>
  <div>
  <table width="100%">
  <tr valign="middle" height="35">
  <td width="100" align="center" class="column_title_network_choosebg"><a href="/network_status.asp" onclick="">All</a></td>
    <td width="170" align="center" class="column_title_networkbg"><a href="/arp.asp" onclick="">Arp Table</a></td>
    <td width="170" align="center" class="column_title_networkbg"><a href="/bridge_status.asp" onclick="">Bridge Status</a></td>
    <td width="170" align="center" class="column_title_networkbg"><a href="/routing.asp" onclick="">Routing Table</a></td>
    <td width="170" align="center" class="column_title_networkbg"><a href="/lldp.asp" onclick="">LLDP Status</a></td>
    <td class="column_title_networkbg"></td>
    </tr>
 <tr valign="middle" height="3">
  <td class="column_title_network_choosebg" colspan="5"></td>
    </table>
    </div>
  <script type="text/javascript" >
 <!--

 document.write('<H3><% iw_webSysDescHandler("NetworkStatusArpTableHeader", "", "Arp Table"); %> &raquo;</H3>');

 document.write('<table width="100%">');
 document.write('<tr bgcolor="' + trBgColor[bgColorIndex] + '">');
 document.write('<td width="25%" class="block_title">IP address<\/td>');
 document.write('<td width="75%" class="block_title">Mac address<\/td>');
 document.write('<\/tr>');

 for(i=0;i<arptable.length;i++){
  document.write('<tr bgcolor="' + trBgColor[(bgColorIndex)%2] +'">');
  document.write('<td width="25%" colspan="' + devNum + '" "class=column_text_no_bg">'+arptable[i].ip+"<\/td>");
  document.write('<td width="70%" colspan="' + devNum + '" "class=column_text_no_bg">'+arptable[i].mac+"<\/td>");
  document.write('<\/tr>');
  bgColorIndex = 1 + bgColorIndex;
 }

 document.write('</table>');

 document.write('<BR><BR>');

 document.write('<H3><% iw_webSysDescHandler("BridgeStatusTree", "", "Bridge Status"); %>&raquo;</H3>');
 bgColorIndex = 0;

 document.write('<table width="100%">');
 document.write('<tr bgcolor="' + trBgColor[bgColorIndex] + '">');
 document.write('<td width="25%" class="block_title">Interface<\/td>');
 document.write('<td width="75%" class="block_title">Mac address<\/td>');
 document.write('<\/tr>');

 for(i=0;i<bridge.length;i++){
  document.write('<tr bgcolor="' + trBgColor[(bgColorIndex)%2] +'">');
  document.write('<td width="25%" colspan="' + devNum + '" "class=column_text_no_bg">'+bridge[i].port+"<\/td>");
  document.write('<td width="75%" colspan="' + devNum + '" "class=column_text_no_bg">'+bridge[i].mac+"<\/td>");
  document.write('<\/tr>');
  bgColorIndex = 1 + bgColorIndex;
 }
 document.write('</table>');



 document.write('<H3><% iw_webSysDescHandler("NetworkStatusRoutingTableHeader", "", "Routing Table"); %> &raquo;</H3>');

 bgColorIndex = 0;
 document.write('<table width="100%">');
 document.write('<tr bgcolor="' + trBgColor[bgColorIndex] + '">');
 document.write('<td width="25%" class="block_title">Destination<\/td>');
 document.write('<td width="25%" class="block_title">Gateway<\/td>');
 document.write('<td width="25%" class="block_title">Mask<\/td>');
 document.write('<td width="25%" class="block_title">Interface<\/td>');
 document.write('<\/tr>');

 for(i=0;i<routetable.length;i++){
  document.write('<tr bgcolor="' + trBgColor[(bgColorIndex)%2] +'">');
  document.write('<td width="25%" colspan="' + devNum + '" "class=column_text_no_bg">'+routetable[i].destination+"<\/td>");
  document.write('<td width="25%" colspan="' + devNum + '" "class=column_text_no_bg">'+routetable[i].gateway+"<\/td>");
  document.write('<td width="25%" colspan="' + devNum + '" "class=column_text_no_bg">'+routetable[i].mask+"<\/td>");
  document.write('<td width="25%" colspan="' + devNum + '" "class=column_text_no_bg">'+"*<\/td>");
  document.write('<\/tr>');
  bgColorIndex = 1 + bgColorIndex;
 }


 document.write('</table>');

 document.write('<BR><BR>');

 document.write('<H3><% iw_webSysDescHandler("NetworkStatusLLDPHeader", "", "LLDP Status"); %> &raquo;</H3>');

 document.write('<table width="100%">');
 document.write('<tr>');
 document.write('<td width="10%"></td>');
 document.write('<td colspan="5" align="center" class="block_title">Neighbor Information</td>');

 document.write('<tr>');
 document.write('<td width="10%" align="center" class="block_title">Interface</td>');
 document.write('<td width="15%" align="center" class="block_title">System name</td>');
 document.write('<td width="15%" align="center" class="block_title">ID</td>');
 document.write('<td width="15%" align="center" class="block_title">IP</td>');
 document.write('<td width="15%" align="center" class="block_title">Port</td>');
    document.write('<td width="30%" align="center" class="block_title">Port Description</td>');

    document.write('</tr>');
    <% iw_webGetLLDPStatus(); %>


 document.write('</table>');
 document.write('<HR>');
  -->
 </script>

  <input type="button" name="Refresh" value="Refresh" onClick="window.location.reload()">

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
