<!DOCTYPE html PUBLIC "-//W3C//DTD html 4.01 Transitional//EN">
<html>
<head>
    <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate" />
    <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate" />
    <meta http-equiv="Pragma" content="no-cache" />
    <meta http-equiv="Expires" content="0" />
 <link href="nport2g.css" rel="stylesheet" type="text/css">
 <title><% iw_webSysDescHandler("DoutStatusTree", "", "Relay Status"); %></title>
 <% iw_webJSList_get(); %>
 <script type="text/javascript">
  var supportPoe = <% iw_webIsSupportPoe(); %>;

  var tbl = new Array(<% iw_webGetRelayAckEventStatus(); %>);
  var statusStr = new Array("---", "Alarm", "Alarm (Acked)");
  var colorCounter = 0;

  function dout_turnoff(str)
  {
   document.relaystatus.ack.value = str;
   document.relaystatus.submit();
  }

  function genDoutRow( doutIndex, doutDscr )
  {
   var rowColor = colorCounter % 2 == 0 ? 'beige' : 'azure';
   colorCounter++;
   document.write('<tr style="background-color: ' + rowColor + ';">');
   document.write('<td width=50% class="column_title" style="background-color: ' + rowColor + ';">' + doutDscr + '<\/td>');
   document.write('<td width=25%>' + statusStr[tbl[doutIndex]] + '<\/td>');
   document.write('<td width=25%><input type="button" value="Acknowledge Event"');
   if(tbl[doutIndex] != 1)
    document.write(" disabled");
   document.write(' onclick="dout_turnoff(' + doutIndex +');" \/><\/td>');
   document.write('<\/tr>');
  }
 </script>
</head>
<body>
 <h2><% iw_webSysDescHandler("DoutStatusTree", "", "Relay Status"); %></h2>
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
   document.write("<input type='checkbox' id='ref5' checked onclick='check_referesh()' \/><label for='ref5'>Auto Update<\/label>");
   check_referesh();
  }

  document.write('<form name="relaystatus" action="/forms/iw_webSetRelayAckEvnet" method="POST"><table width="100%"><tr><td width="100%" colspan="3" class="block_title"><% iw_webSysDescHandler("DoutStatusTree", "", "Relay Status"); %><\/td><\/tr>');

  genDoutRow( 0, "<% iw_webCfgDescHandler("relayAction", "power1Off", "Power1 On to Off"); %>" );


  genDoutRow( 1, "<% iw_webCfgDescHandler("relayAction", "power2Off", "Power2 On to Off"); %>" );


  if( supportPoe )
   genDoutRow( 2, "<% iw_webCfgDescHandler("relayAction", "poeOff", "POE On to Off"); %>" );


  genDoutRow( 3, "<% iw_webCfgDescHandler("relayAction", "DI1On2Off", "DI1 On to Off"); %>" );
  genDoutRow( 4, "<% iw_webCfgDescHandler("relayAction", "DI1Off2On", "DI1 Off to On"); %>" );
  genDoutRow( 5, "<% iw_webCfgDescHandler("relayAction", "DI2On2Off", "DI2 On to Off"); %>" );
  genDoutRow( 6, "<% iw_webCfgDescHandler("relayAction", "DI2Off2On", "DI2 Off to On"); %>" );
  genDoutRow( 8, "<% iw_webCfgDescHandler("relayAction", "lan1linkOn", "Link ON"); %>" );
  genDoutRow( 7, "<% iw_webCfgDescHandler("relayAction", "lan1linkOff", "Link OFF"); %>" );


  document.write('<\/table><input type="hidden" name="ack" \/><input type="hidden" name="bkpath" value="/relay_state.asp" \/><\/form>');
 </script>
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
