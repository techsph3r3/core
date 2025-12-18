<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
 <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
    <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate" />
    <meta http-equiv="Pragma" content="no-cache" />
    <meta http-equiv="Expires" content="0" />
 <link href="nport2g.css" rel="stylesheet" type="text/css">
 <title><% iw_webSysDescHandler("EmailEventTree", "", "E-mail Event Types"); %></title>
 <% iw_webJSList_get(); %>
 <script type="text/javascript">
 <!--


  var supportPoe = <% iw_webIsSupportPoe(); %>;

  var colorCounter = 0;

  function CheckValue(form)
  {
   var i;
   for(i = 0; i < form.length; i++)
   {
    if(form.elements[i].type == "checkbox" &&
     form.elements[i].id.match(/^emailAction_[a-zA-Z0-9]*/))
    {
     document.getElementsByName('iw_'+form.elements[i].id)[0].value = form.elements[i].checked ? "ENABLE" : "DISABLE";
    }
   }
  }

  function selall()
  {
   for(i = 0; i < document.email_event.length; i++)
   {
    if(document.email_event.elements[i].type == "checkbox" &&
     document.email_event.elements[i].id.match(/^emailAction_[a-zA-Z0-9]*/))
    {
     document.email_event.elements[i].checked = document.email_event.SelAll.checked;
    }
   }
  }

  function genRow( Dscr, Id )
  {
   var rowColor = colorCounter % 2 == 0 ? 'beige' : 'azure';
   colorCounter++;

   document.write('<tr style="background-color: ' + rowColor + ';">');
   document.write('<td width=10% align="left" class="column_title" style="background-color: ' + rowColor + ';">' + Dscr + '<\/td>');
   document.write('<td width=10% align="left" class="column_text_no_bg" style="background-color: ' + rowColor + ';"><input type="checkbox" id="' + Id + '" \/>Active<\/td>');
   document.write('<\/tr>');
  }

  function genHiddenValue( Name, Value )
  {
   document.write('<input type="hidden" name="' + Name + '" value="' + Value + '" \/>');
  }

        function iw_email_eventOnLoad()
  {
   iw_checkedSet(document.email_event.emailAction_coldStart, "<% iw_webCfgValueHandler("emailAction", "coldStart", "DISABLE");%>");
   iw_checkedSet(document.email_event.emailAction_warmStart, "<% iw_webCfgValueHandler("emailAction", "warmStart", "DISABLE");%>");

   iw_checkedSet(document.email_event.emailAction_power1Off, "<% iw_webCfgValueHandler("emailAction", "power1Off", "DISABLE");%>");
   iw_checkedSet(document.email_event.emailAction_power1On, "<% iw_webCfgValueHandler("emailAction", "power1On", "DISABLE");%>");


   iw_checkedSet(document.email_event.emailAction_power2Off, "<% iw_webCfgValueHandler("emailAction", "power2Off", "DISABLE");%>");
   iw_checkedSet(document.email_event.emailAction_power2On, "<% iw_webCfgValueHandler("emailAction", "power2On", "DISABLE");%>");


   if( supportPoe )
   {
    iw_checkedSet(document.email_event.emailAction_poeOff, "<% iw_webCfgValueHandler("emailAction", "poeOff", "DISABLE");%>");
    iw_checkedSet(document.email_event.emailAction_poeOn, "<% iw_webCfgValueHandler("emailAction", "poeOn", "DISABLE");%>");
   }

   iw_checkedSet(document.email_event.emailAction_configChange, "<% iw_webCfgValueHandler("emailAction", "configChange", "DISABLE");%>");




   iw_checkedSet(document.email_event.emailAction_cAuthFail, "<% iw_webCfgValueHandler("emailAction", "cAuthFail", "DISABLE");%>");

   iw_checkedSet(document.email_event.emailAction_DI1On2Off, "<% iw_webCfgValueHandler("emailAction", "DI1On2Off", "DISABLE");%>");
   iw_checkedSet(document.email_event.emailAction_DI1Off2On, "<% iw_webCfgValueHandler("emailAction", "DI1Off2On", "DISABLE");%>");
   iw_checkedSet(document.email_event.emailAction_DI2On2Off, "<% iw_webCfgValueHandler("emailAction", "DI2On2Off", "DISABLE");%>");
   iw_checkedSet(document.email_event.emailAction_DI2Off2On, "<% iw_webCfgValueHandler("emailAction", "DI2Off2On", "DISABLE");%>");

   iw_checkedSet(document.email_event.emailAction_lan1linkOn, "<% iw_webCfgValueHandler("emailAction", "lan1linkOn", "DISABLE");%>");
   iw_checkedSet(document.email_event.emailAction_lan1linkOff, "<% iw_webCfgValueHandler("emailAction", "lan1linkOff", "DISABLE");%>");
  }


        function editPermission()
        {
                var form = document.email_event, i, j = <% iw_websCheckPermission(); %>;
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

 //-->
 </script>
</head>
<body onLoad="iw_email_eventOnLoad();iw_ChangeOnLoad();">
 <h2><% iw_webSysDescHandler("EmailEventTree", "", "E-mail Event Types"); %> <% iw_websGetErrorString(); %></h2>
 <script type="text/javascript">
 <!--
  document.write('<form name="email_event" method="POST" action="/forms/iw_webSetParameters" onSubmit="return CheckValue(this)">');
  document.write('<table width="100%">');
  document.write('<tr align="left">');
  document.write('<td width="10%" align="left" class="block_title">Event Type<\/td>');
        document.write('<td width="10%" align="left" class="block_title"><input type="checkbox" id="SelAll" onclick="selall();" \/>Enable Notification<\/td>');
  //document.write('<td width="10%" align="left" class="block_title">Enable Notification<\/td>');
  document.write('<\/tr>');

  genRow( "<% iw_webCfgDescHandler("emailAction", "coldStart", "Cold start"); %>", "emailAction_coldStart" );
  genRow( "<% iw_webCfgDescHandler("emailAction", "warmStart", "Warm start"); %>", "emailAction_warmStart" );

  genRow( "<% iw_webCfgDescHandler("emailAction", "power1Off", "Power 1 transition (On-->Off)"); %>", "emailAction_power1Off" );
  genRow( "<% iw_webCfgDescHandler("emailAction", "power1On", "Power 1 transition (Off-->On)"); %>", "emailAction_power1On" );


  genRow( "<% iw_webCfgDescHandler("emailAction", "power2Off", "Power 2 transition (On-->Off)"); %>", "emailAction_power2Off" );
  genRow( "<% iw_webCfgDescHandler("emailAction", "power2On", "Power 2 transition (Off-->On)"); %>", "emailAction_power2On" );


  if( supportPoe )
  {
   genRow( "<% iw_webCfgDescHandler("emailAction", "poeOff", "PoE transition (On-->Off)"); %>", "emailAction_poeOff" );
   genRow( "<% iw_webCfgDescHandler("emailAction", "poeOn", "PoE transition (Off-->On)"); %>", "emailAction_poeOn" );
  }

  genRow( "<% iw_webCfgDescHandler("emailAction", "configChange", "Configuration changed"); %>", "emailAction_configChange" );




  genRow( "<% iw_webCfgDescHandler("emailAction", "cAuthFail", "Console authentication failure"); %>", "emailAction_cAuthFail" );

  genRow( "<% iw_webCfgDescHandler("emailAction", "DI1On2Off", "DI 1 transition (On-->Off)"); %>", "emailAction_DI1On2Off" );
  genRow( "<% iw_webCfgDescHandler("emailAction", "DI1Off2On", "DI 1 transition (Off-->On)"); %>", "emailAction_DI1Off2On" );
  genRow( "<% iw_webCfgDescHandler("emailAction", "DI2On2Off", "DI 2 transition (On-->Off)"); %>", "emailAction_DI2On2Off" );
  genRow( "<% iw_webCfgDescHandler("emailAction", "DI2Off2On", "DI 2 transition (Off-->On)"); %>", "emailAction_DI2Off2On" );

  genRow( "<% iw_webCfgDescHandler("emailAction", "lan1linkOn", "LAN link on"); %>", "emailAction_lan1linkOn" );
  genRow( "<% iw_webCfgDescHandler("emailAction", "lan1linkOff", "LAN link off"); %>", "emailAction_lan1linkOff" );
  document.write('<\/table>');
  document.write('<hr \/>');
  document.write('<input type="submit" value="Submit" name="Submit" \/>');
  genHiddenValue( "iw_emailAction_coldStart", "DISABLE" );
  genHiddenValue( "iw_emailAction_warmStart", "DISABLE" );

  genHiddenValue( "iw_emailAction_power1Off", "DISABLE" );
  genHiddenValue( "iw_emailAction_power1On", "DISABLE" );


  genHiddenValue( "iw_emailAction_power2Off", "DISABLE" );
  genHiddenValue( "iw_emailAction_power2On", "DISABLE" );


  if( supportPoe )
  {
   genHiddenValue( "iw_emailAction_poeOff", "DISABLE" );
   genHiddenValue( "iw_emailAction_poeOn", "DISABLE" );
  }

  genHiddenValue( "iw_emailAction_configChange", "DISABLE" );





  genHiddenValue( "iw_emailAction_cAuthFail", "DISABLE" );

  genHiddenValue( "iw_emailAction_DI1On2Off", "DISABLE" );
  genHiddenValue( "iw_emailAction_DI1Off2On", "DISABLE" );
  genHiddenValue( "iw_emailAction_DI2On2Off", "DISABLE" );
  genHiddenValue( "iw_emailAction_DI2Off2On", "DISABLE" );

  genHiddenValue( "iw_emailAction_lan1linkOn", "DISABLE" );
  genHiddenValue( "iw_emailAction_lan1linkOff", "DISABLE" );
  genHiddenValue( "bkpath", "/email_event.asp" );
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
