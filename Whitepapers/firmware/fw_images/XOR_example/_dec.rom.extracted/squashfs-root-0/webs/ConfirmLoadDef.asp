<HTML>
<HEAD>
    <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate" />
    <meta http-equiv="Pragma" content="no-cache" />
    <meta http-equiv="Expires" content="0" />
 <LINK href="nport2g.css" rel="stylesheet" type="text/css">
 <TITLE><% iw_webSysDescHandler("LoadFactoryDefaultTree", "", "Load Factory Default"); %> <% iw_websGetErrorString(); %></TITLE>
 <script type="text/javascript">
 <!--

  function editPermission()
  {
   var form = document.loaddefault, i, j = <% iw_websCheckPermission(); %>;
   if(j)
   {
    for(i = 0; i < form.length; i++)
     form.elements[i].disabled = true;
   }
  }


  function iw_onLoad()
  {

                 editPermission();

                 top.toplogo.location.reload();
  }

  function check()
  {
   var loadDefault = window.confirm('Click OK to load factory default settings.');
   document.getElementById('Activate').disabled = loadDefault;
   return loadDefault;
  }
 </SCRIPT>
</HEAD>
<BODY onload="iw_onLoad();">
 <H2><% iw_webSysDescHandler("LoadFactoryDefaultTree", "", "Load Factory Default"); %></H2>
 <FORM name="loaddefault" method="GET" action="/forms/web_SetLoadDef" onsubmit="return check(this)">
  <TABLE width="100%">
   <TR>
    <TD width="100%" class="block_title">Reset to Factory Default Values</TD>
   </TR>
  </TABLE>
  <P> Click <B>"System Reset"</B> to immediately restart the system to factory default values.</P>
  <HR>
  <INPUT type="submit" id="Activate" name="Activate" value="System Reset">
  <Input type="hidden" name="bkpath" value="/ConfirmLoadDef.asp">
 </FORM>
</BODY>
</HTML>
<script language="JavaScript" src="js/jquery-1.5.2.min.js"></script>
<script type="text/javascript">
	$(document).ready(function () {
		var isEditPermission = !<% iw_websCheckPermission(); %>;
		if (isEditPermission == 0) {
			$(":input").attr('disabled','disabled');
		}
	});
</script>
