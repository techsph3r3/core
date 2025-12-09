<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
 <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
 <link href="nport2g.css" rel="stylesheet" type="text/css">
 <title><% iw_webSysDescHandler("NetworkStatusBridgeStatusTree", "", "Bridge Status"); %></title>
 <% iw_webJSList_get(); %>
 <script type="text/javascript" >
 <!--
 function iw_onLoad(){





 }

  var BoardOPMode = new String( '<% iw_webCfgValueMainHandler( "board", "operationMode", "WIRELESS_REDUNDANCY" ); %>' );
  var opMode = new String( "<% iw_webCfgValueHandler( "wlanDevWIFI0", "operationMode", "AP" ); %>" );


 var trBgColor = ["beige", "azure"];
 var bgColorIndex = 0;
 var devNum = 1 ;
 var bridge = <% iw_webGetBridgeStatus();%>;
 -->
 </script>
</head>
<body onLoad = "iw_onLoad()">
 <h2><% iw_webSysDescHandler("NetworkStatusBridgeStatusTree", "", "Bridge Status"); %></h2>
 <script type="text/javascript" >
 <!--


 document.write('<table width="100%">');
 document.write('<tr bgcolor="' + trBgColor[bgColorIndex] + '">');
 document.write('<td width="25%" class="block_title">Interface<\/td>');
 document.write('<td width="75%" class="block_title">MAC Address<\/td>');
 document.write('<\/tr>');

 for(i=0;i<bridge.length;i++){
  document.write('<tr bgcolor="' + trBgColor[(bgColorIndex)%2] +'">');
  document.write('<td width="25%" colspan="' + devNum + '" "class=column_text_no_bg">'+bridge[i].port+"<\/td>");
  document.write('<td width="75%" colspan="' + devNum + '" "class=column_text_no_bg">'+bridge[i].mac+"<\/td>");
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
