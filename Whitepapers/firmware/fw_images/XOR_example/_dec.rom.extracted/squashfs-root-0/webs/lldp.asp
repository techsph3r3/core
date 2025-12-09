<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
 <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
 <link href="nport2g.css" rel="stylesheet" type="text/css">

 <title><% iw_webSysDescHandler("NetworkStatusLLDPHeader", "", "LLDP Status"); %></title>
 <% iw_webJSList_get(); %>
 <script type="text/javascript" >
 <!--
 function iw_onLoad(){





 }
 var trBgColor = ["beige", "azure"];
 var bgColorIndex = 0;
 var devNum = 1 ;
 -->
 </script>
</head>
<body onLoad = "iw_onLoad()">
<h2><% iw_webSysDescHandler("NetworkStatusLLDPHeader", "", "LLDP Status"); %></h2>

    <script type="text/javascript" >
 <!--

 document.write('<table width="100%">');
 document.write('<tr>');
 document.write('<td rowspan="2" width="10%" align="center" class="block_title">Interface</td>');
 document.write('<td colspan="5" align="center" class="block_title">Neighbor Information</td>');
 document.write('</tr>');

 document.write('<tr>');
 document.write('<td width="15%" align="center" class="block_title">System Name</td>');
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
