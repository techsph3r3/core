<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
 <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
 <link href="nport2g.css" rel=stylesheet type=text/css>
 <title><% iw_webSysDescHandler("StormProtectionTree", "", "Storm Protection"); %></title>
 <% iw_webJSList_get(); %>
 <script type="text/javascript">
 <!--
  var mem_state = <% iw_websMemoryChange(); %>;

  function iw_stormProtectionEnable(enable)
  {
   if( enable )
   {
    document.getElementById("stormMultiFlood").style.display = "";
   }else
   {
    document.getElementById("stormMultiFlood").style.display = "none";
   }
  }


  function editPermission()
  {
   var form = document.stormProtection, i, j = <% iw_websCheckPermission(); %>;
   if(j)
   {
    for(i = 0; i < form.length; i++)
     form.elements[i].disabled = true;
   }
  }


  function iw_ChangeOnLoad()
  {
   if( "<% iw_webCfgValueHandler("stormProtection", "stormProtectionLoopDetection", "ENABLE"); %>" == "ENABLE" )
    document.stormProtection.iw_stormProtectionLoopDetection_En.checked = true;
   else
    document.stormProtection.iw_stormProtectionLoopDetection_Dis.checked = true;


                 editPermission();


   top.toplogo.location.reload();
  }
 //-->
 </script>
</head>
<body onLoad="iw_ChangeOnLoad();">
 <h2><% iw_webSysDescHandler("StormProtectionTree", "", "Storm Protection error"); %> <% iw_websGetErrorString(); %></h2>
 <form name="stormProtection" method="post" action="/forms/iw_webSetParameters">
  <table width=100%>
   <tr>
    <td colspan="2">
     <hr />
     <input type="submit" value="Submit" name="Submit" />
     <input type="hidden" name="bkpath" value="/storm_protection.asp" />
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
