<HTML>
<HEAD>
    <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate" />
    <meta http-equiv="Pragma" content="no-cache" />
    <meta http-equiv="Expires" content="0" />
 <LINK href="nport2g.css" rel="stylesheet" type="text/css">
 <% iw_webJSList_get(); %>
 <TITLE><% iw_webSysDescHandler("LinkProtectionStatusTree", "", "Link-protection Status"); %></TITLE>
</HEAD>
<BODY>
 <H2><% iw_webSysDescHandler("LinkProtectionStatusTree", "", "Link-protection Status"); %></H2>
 <script type="text/javascript">
  function do_referesh()
  {
   if(document.getElementById("ref5").checked)
   document.location.reload();
  }
  function check_referesh()
  {
   if(document.getElementById("ref5").checked)
    window.setTimeout("do_referesh()", 10000);
  }
  if(window.setTimeout)
  {
   document.write("<INPUT type='checkbox' id='ref5' checked onclick='check_referesh()'><label for='ref5'>Auto Update</label>");
   check_referesh();
  }
 </SCRIPT>
 <TABLE width="100%">
  <TR class="column_title_bg">
   <TD colspan="2" class="block_title">AeroLink Protection Status</TD>
  </TR>

  <script type="text/javascript">
   var vstat = <% iw_webSysValueHandler("virstate", "", ""); %>;
   var color;
   var statusStr = new Array("Init", "Discover", "Idle", "Nego", "Backup", "Active", "Change", "N/A" );

   var bgColorIndicator = 0;
   var bgColorArray = ["beige", "azure"];
   function addStatusRow( Title, State )
   {
    document.write("<tr style=\"background-color: " + bgColorArray[bgColorIndicator] + ";\">");
    document.write("<td width=\"30%\" class=\"column_title\" style=\"background-color: " + bgColorArray[bgColorIndicator] + ";\">" + Title + "</td>");
    document.write("<td width=\"70%\">" + State + " </td>");
    document.write("</tr>");
    bgColorIndicator = 1 - bgColorIndicator;
   }

   addStatusRow( "Current state", statusStr[vstat-1] + " (Init/Discover/Idle/Nego/Backup/Active/Change)" );
  </SCRIPT>
 </TABLE>
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
