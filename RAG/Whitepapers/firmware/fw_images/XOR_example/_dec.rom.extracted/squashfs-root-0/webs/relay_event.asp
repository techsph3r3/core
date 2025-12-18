<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
 <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
    <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate" />
    <meta http-equiv="Pragma" content="no-cache" />
    <meta http-equiv="Expires" content="0" />
 <link href="nport2g.css" rel="stylesheet" type="text/css">
 <title><% iw_webSysDescHandler("RelayEventTree", "", "Relay Event Types"); %></title>
 <% iw_webJSList_get(); %>
 <script type="text/javascript">
 <!--
  var supportPoe = <% iw_webIsSupportPoe(); %>;

  var colorCounter = 0;

  function CheckValue(form)
  {
   var i, j=0;
   for(i = 0; i < form.length; i++)
   {
    if(form.elements[i].type == "checkbox" &&
     form.elements[i].id.match(/^relayAction_[a-zA-Z0-9]*/))
    {
     document.getElementsByName('iw_'+form.elements[i].id)[0].value = form.elements[i].checked ? "ENABLE" : "DISABLE";
    }
   }
  }

        function checkMutuxOnChange()
        {
         var MutuxPair = [

      "relayAction_DI1On2Off", "relayAction_DI1Off2On"
              ,"relayAction_DI2On2Off", "relayAction_DI2Off2On",

              "relayAction_lan1linkOn", "relayAction_lan1linkOff"







              ];

         var i, j;
         for( i = 0; i < MutuxPair.length; i++ )
         {
          j = (i % 2 == 0 ? i+1 : i-1);

          if( document.getElementById( MutuxPair[i] ).checked )
          {
           document.getElementById( MutuxPair[i] ).disabled = false;
           document.getElementById( MutuxPair[j] ).disabled = true;
          }else
          {
           document.getElementById( MutuxPair[j] ).disabled = false;
          }
         }
  }

  function genRow( Dscr, Id, mutexCheck )
  {
   var rowColor = colorCounter % 2 == 0 ? 'beige' : 'azure';
   colorCounter++;

   document.write('<tr style="background-color: ' + rowColor + ';">');
   document.write('<td width=10% align="left" class="column_title" style="background-color: ' + rowColor + ';">' + Dscr + '<\/td>');
   document.write('<td width=10% align="left" class="column_text_no_bg" style="background-color: ' + rowColor + ';"><input type="checkbox" id="' + Id + '" ' + (mutexCheck ? "onclick=\"checkMutuxOnChange();\"" : "") + '\/>Active<\/td>');
   document.write('<\/tr>');
  }

  function genHiddenValue( Name, Value )
  {
   document.write('<input type="hidden" name="' + Name + '" value="' + Value + '" \/>');
  }

        function iw_relay_eventOnLoad()
        {

   iw_checkedSet(document.relay_event.relayAction_power1Off, "<% iw_webCfgValueHandler("relayAction", "power1Off", "DISABLE");%>");


   iw_checkedSet(document.relay_event.relayAction_power2Off, "<% iw_webCfgValueHandler("relayAction", "power2Off", "DISABLE");%>");


   if( supportPoe )
   {
    iw_checkedSet(document.relay_event.relayAction_poeOff, "<% iw_webCfgValueHandler("relayAction", "poeOff",	"DISABLE");%>");
   }


   iw_checkedSet(document.relay_event.relayAction_DI1On2Off, "<% iw_webCfgValueHandler("relayAction", "DI1On2Off", "DISABLE");%>");
   iw_checkedSet(document.relay_event.relayAction_DI1Off2On, "<% iw_webCfgValueHandler("relayAction", "DI1Off2On", "DISABLE");%>");
   iw_checkedSet(document.relay_event.relayAction_DI2On2Off, "<% iw_webCfgValueHandler("relayAction", "DI2On2Off", "DISABLE");%>");
   iw_checkedSet(document.relay_event.relayAction_DI2Off2On, "<% iw_webCfgValueHandler("relayAction", "DI2Off2On", "DISABLE");%>");

   iw_checkedSet(document.relay_event.relayAction_lan1linkOn, "<% iw_webCfgValueHandler("relayAction", "lan1linkOn", "DISABLE");%>");
   iw_checkedSet(document.relay_event.relayAction_lan1linkOff, "<% iw_webCfgValueHandler("relayAction", "lan1linkOff", "DISABLE");%>");
   checkMutuxOnChange();
  }


  function editPermission()
  {
   var form = document.relay_event, i, j = <% iw_websCheckPermission(); %>;
   if(j)
   {
    for(i = 0; i < form.length; i++)
     form.elements[i].disabled = true;
   }
  }


  var mem_state = <% iw_websMemoryChange(); %>;
  function iw_ChangeOnLoad()
  {


                 editPermission();


   top.toplogo.location.reload();
  }

  function selall()
        {
            for(i = 0; i < document.relay_event.length; i++)
            {
                if(document.relay_event.elements[i].type == "checkbox" &&
                    document.relay_event.elements[i].id.match(/^relayAction_[a-zA-Z0-9]*/))
                {
                    document.relay_event.elements[i].checked = document.relay_event.SelAll.checked;
                }
            }
        }
    -->
    </script>
</head>
<body onLoad="iw_relay_eventOnLoad();iw_ChangeOnLoad();">
 <h2><% iw_webSysDescHandler("RelayEventTree", "", "Relay Event Types"); %> <% iw_websGetErrorString(); %></h2>
 <script type="text/javascript">
 <!--
  document.write('<form name="relay_event" method="POST" action="/forms/iw_webSetParameters" onSubmit="return CheckValue(this)">');
  document.write('<table width="100%">');
  document.write('<tr align="left">');
  document.write('<td width="10%" align="left" class="block_title">Event Type<\/td>');
  document.write('<td width="10%" align="left" class="block_title"><input type="checkbox" id="SelAll" onclick="selall();" \/>Enable Notification<\/td>');
  document.write('<\/tr>');

  genRow( "<% iw_webCfgDescHandler("relayAction", "power1Off", "Power 1 transition (On-->Off)"); %>", "relayAction_power1Off", 0 );


  genRow( "<% iw_webCfgDescHandler("relayAction", "power2Off", "Power 2 transition (On-->Off)"); %>", "relayAction_power2Off", 0 );


  if( supportPoe )
  {
   genRow( "<% iw_webCfgDescHandler("relayAction", "poeOff", "PoE transition (On-->Off)"); %>", "relayAction_poeOff", 0 );
  }


  genRow( "<% iw_webCfgDescHandler("relayAction", "DI1On2Off", "DI 1 transition (On-->Off)"); %>", "relayAction_DI1On2Off", 1 );
  genRow( "<% iw_webCfgDescHandler("relayAction", "DI1Off2On", "DI 1 transition (Off-->On)"); %>", "relayAction_DI1Off2On", 1 );
  genRow( "<% iw_webCfgDescHandler("relayAction", "DI2On2Off", "DI 2 transition (On-->Off)"); %>", "relayAction_DI2On2Off", 1 );
  genRow( "<% iw_webCfgDescHandler("relayAction", "DI2Off2On", "DI 2 transition (Off-->On)"); %>", "relayAction_DI2Off2On", 1 );

  genRow( "<% iw_webCfgDescHandler("relayAction", "lan1linkOn", "LAN link on"); %>", "relayAction_lan1linkOn", 1 );
  genRow( "<% iw_webCfgDescHandler("relayAction", "lan1linkOff", "LAN link off"); %>", "relayAction_lan1linkOff", 1 );
  document.write('<\/table>');
  document.write('<hr \/>');
  document.write('<input type="submit" value="Submit" name="Submit" \/>');

  genHiddenValue( "iw_relayAction_power1Off", "DISABLE" );


  genHiddenValue( "iw_relayAction_power2Off", "DISABLE" );


  if( supportPoe )
  {
   genHiddenValue( "iw_relayAction_poeOff", "DISABLE" );
  }


  genHiddenValue( "iw_relayAction_DI1On2Off", "DISABLE" );
  genHiddenValue( "iw_relayAction_DI1Off2On", "DISABLE" );
  genHiddenValue( "iw_relayAction_DI2On2Off", "DISABLE" );
  genHiddenValue( "iw_relayAction_DI2Off2On", "DISABLE" );

  genHiddenValue( "iw_relayAction_lan1linkOn", "DISABLE" );
  genHiddenValue( "iw_relayAction_lan1linkOff", "DISABLE" );
  genHiddenValue( "bkpath", "/relay_event.asp" );
  document.write('<\/form>');
 -->
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
