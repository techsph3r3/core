<HTML>
<HEAD>
 <LINK href="nport2g.css" rel="stylesheet" type="text/css">
 <TITLE><% iw_webSysDescHandler("LogoutTree", "", "Logout"); %></TITLE>
 <% iw_webJSList_get(); %>
 <script type="text/javascript">
 <!--







 // -->
 </SCRIPT>
</HEAD>
<BODY>
 <H2><% iw_webSysDescHandler("LogoutTree", "", "Logout"); %> <% iw_websGetErrorString(); %></H2>
 <P>
  Click <B>Logout</B> to log out of the web console.
 </P>

 <FORM name="Logout"method="GET" action="/forms/web_SetLogout">



  <TABLE width="100%">
   <TR>
    <TD colspan="2"><HR>
      <INPUT type="submit" value="Logout">
      <Input type="hidden" name="bkpath" value="/Logout.asp">
    </TD>
   </TR>
  </TABLE>
 </FORM>
</BODY>
</HTML>
