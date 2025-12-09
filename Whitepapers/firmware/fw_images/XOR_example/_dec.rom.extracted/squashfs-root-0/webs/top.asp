<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
 <title>Logo</title>
 <script type="text/javascript">
 <!--
  function redirect()
  {
   top.main.location="/ConfirmRestart.asp";
  }


  function backToHome()
  {
   top.main.location="/setup_option.asp";
  }

    -->
    </script>
</head>
<body style="margin:0px;" background="logo_b.gif">
 <table cellpadding=0 cellspacing=0 width="100%">
  <tr>



   <td style="border:0px" width="416"><img src="logo_a.gif" border=0 USEMAP="#HomeMap"/></td>



   <td>&nbsp;</td>
   <td style="border:0px" width="341"><% iw_webGetChangecMemIcon(); %></td>
  </tr>
 </table>
 <map NAME="SystemMap">
     <area shape="rect" coords="0,0,600,30" href="javascript:redirect()" />
 </map>

 <map NAME="HomeMap">
    <area shape="rect" coords="0,0,600,60" href="javascript:backToHome()" />
 </map>

</body>
</html>
