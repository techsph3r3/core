<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
 <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
 <link href="nport2g.css" rel="stylesheet" type="text/css">

 <title><% iw_webSysDescHandler("NetworkStatusRoutingTableHeader", "", "Routing table"); %></title>
 <% iw_webJSList_get(); %>
 <script type="text/javascript" >
 <!--
 function iw_onLoad(){





 }

 var trBgColor = ["beige", "azure"];
 var bgColorIndex = 0;
 var devNum = 1 ;
 var routetable =<% iw_webGetRoutingTable(); %>


 var Wlans = <% iw_webGetWirelessStatusArray(0,0); %>;

 -->
 </script>
</head>
<body onLoad = "iw_onLoad()">
 <h2><% iw_webSysDescHandler("NetworkStatusRoutingTableHeader", "", "Routing table"); %></h2>
 <script type="text/javascript" >
 <!--
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

  if(iwStrMap(Wlans[0].opmode) == 'Client-Router')
   document.write('<td width="25%" colspan="' + devNum + '" "class=column_text_no_bg">'+routetable[i].inface+"<\/td>");
  else
   document.write('<td width="25%" colspan="' + devNum + '" "class=column_text_no_bg">'+"*<\/td>");

  document.write('<\/tr>');
  bgColorIndex = 1 + bgColorIndex;
 }


 document.write('</table>');
 document.write('<HR>');
 -->
 </script>

  <input type="button" name="Refresh" value="Refresh" onClick="window.location.reload()">

</body>
</html>
