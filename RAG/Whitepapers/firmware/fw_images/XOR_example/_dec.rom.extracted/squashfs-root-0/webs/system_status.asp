<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
 <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
 <link href="nport2g.css" rel="stylesheet" type="text/css">
 <title><% iw_webSysDescHandler("SystemStatusTree", "", "System Status"); %></title>
 <% iw_webJSList_get(); %>
 <script type="text/javascript" >
 <!--
 function iw_onLoad(){





 }
 var devNum = 1 ;
 var trBgColor = ["beige", "azure"];
 var bgColorIndex = 0;
 var memstatus = <% iw_webGetMemInfo();%> ;
 var cpuusage = <% iw_webGetCPUInfo();%> ;
 -->
 </script>
</head>
<body onLoad = "iw_onLoad()">
  <h2><% iw_webSysDescHandler("SystemStatusTree", "", "System Status"); %></h2>
  <script type="text/javascript" >
 <!--
 document.write('<table width="100%">');
 document.write('<tr>');
 document.write('<td width="100%" colspan="3" class="block_title"><% iw_webSysDescHandler("SystemStatusMemInfoHeader", "", "Memory Info"); %> </td>');
 document.write('</tr>');

 document.write('<tr bgcolor="' + trBgColor[bgColorIndex] + '">');
 document.write('<td width="5%" class="column_title_no_bg">Total<\/td>');
 document.write('<td width="25%" class="column_title_no_bg">(KB)<\/td>');
 document.write('<td width="70%" colspan="' + devNum + '" "class=column_text_no_bg">'+memstatus[0].total+"<\/td>");
 document.write('<\/tr>');
 bgColorIndex = 1 - bgColorIndex;

 document.write('<tr bgcolor="' + trBgColor[bgColorIndex] + '">');
 document.write('<td width="5%" class="column_title_no_bg">Used<\/td>');
 document.write('<td width="25%" class="column_title_no_bg">(KB)<\/td>');
 document.write('<td width="70%" colspan="' + devNum + '" "class=column_text_no_bg">'+memstatus[0].used+"<\/td>");
 document.write('<\/tr>');
 bgColorIndex = 1 - bgColorIndex;

 document.write('<tr bgcolor="' + trBgColor[bgColorIndex] + '">');
 document.write('<td width="5%" class="column_title_no_bg">Free<\/td>');
 document.write('<td width="25%" class="column_title_no_bg">(KB)<\/td>');
 document.write('<td width="70%" colspan="' + devNum + '" "class=column_text_no_bg">'+memstatus[0].free+"<\/td>");
 document.write('<\/tr>');
 bgColorIndex = 1 - bgColorIndex;
    document.write('<tr  bgcolor="'+trBgColor[bgColorIndex]+'">');
 document.write('<td width="100%" colspan="11" class="block_title"><% iw_webSysDescHandler("SystemStatusCPUInfoHeader", "", "CPU Info"); %> </td>');
 document.write('</tr>');
 bgColorIndex = 0 ;
 document.write('<tr bgcolor="' + trBgColor[bgColorIndex] + '">');
 document.write('<td width="5%" class="column_title_no_bg">Usage<\/td>');
 document.write('<td width="25%" class="column_title_no_bg">(%)<\/td>');
 document.write('<td width="70%" colspan="' + devNum + '"class="column_text_no_bg">'+cpuusage+'<\/td>');
 document.write('</table>');
 document.write('<BR>');
  -->
 </script>

 <input type="button" name="Refresh" value="Refresh" onClick="window.location.reload()">





 </body>
</html>
