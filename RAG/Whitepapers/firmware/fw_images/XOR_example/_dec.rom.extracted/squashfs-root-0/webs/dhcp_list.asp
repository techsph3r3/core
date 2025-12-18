<HTML>
<HEAD>
    <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate" />
    <meta http-equiv="Pragma" content="no-cache" />
    <meta http-equiv="Expires" content="0" />
 <LINK href="nport2g.css" rel="stylesheet" type="text/css">
 <% iw_webJSList_get(); %>
 <TITLE><% iw_webSysDescHandler("DHCPClientListTree", "", "DHCP Client List"); %></TITLE>
</HEAD>
 <script type="text/javascript">
 <!--
  function scroll_to_latest(e)
  {
   e.scrollTop = e.scrollHeight;
  }

  function Backup()
        {
         document.location.href='dhcp_list.log' ;
        }
 -->
 </SCRIPT>
 <H2><% iw_webSysDescHandler("DHCPClientListTree", "", "DHCP Client List"); %></H2>
<BODY onLoad = "scroll_to_latest(document.dhcplist.Log)">
 <FORM name="dhcplist" method="POST">
  <Table width="100%">
   <TR>
    <TD>
     <TEXTAREA name="Log" rows="20" cols="100" READONLY><% iw_webGetDHCPListData(); %></TEXTAREA>
    </TD>
   </TR>
  <TR>
         <TD>
  <HR>
  <INPUT type="button" name="SelectAll" value="Select All" onClick="this.form.Log.focus(); this.form.Log.select();">
  <INPUT type="button" name="Export" value="Export Log" onClick="Backup()";>
  <INPUT type="button" name="Refresh" value="Refresh" onClick="window.location.reload()">
  <Input type="hidden" name="bkpath" value="/dhcp_list.asp">
   </TD>
         </TR>
         </Table>
 </FORM>
</BODY>
</HTML>
