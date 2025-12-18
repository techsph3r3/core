#if defined(IWCONFIG_CWAN)
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
	<link href="nport2g.css" rel="stylesheet" type="text/css">
	<title><% iw_webSysDescHandler("SMSEventTree", "", "SMS Event Types"); %></title>
	<% iw_webJSList_get(); %>
	<script type="text/javascript">
	<!--
#if defined (IWCONFIG_AWK_PLAT_AR934x) || defined (IWCONFIG_AWK_PLAT_AR7240) || defined (AWK3121) || (AWK4121) || (AWK3131) || (AWK4131)
#undef LAN_PORT_2
#elif defined (AWK5222) || (AWK6222) ||  (AWK5232) || (AWK6232)
#define LAN_PORT_2
#else
#error LAN port status required
#endif
#if (IWCONFIG_LAN_PORT_NUM == 4)
#define LAN_PORT_4
#endif /* IWCONFIG_LAN_PORT_NUM */

		var colorCounter = 0;

		function CheckValue(form)
		{
			var	i;
			for(i = 0; i < form.length; i++)
			{
				if(form.elements[i].type == "checkbox" &&
					form.elements[i].id.match(/^smsAction_[a-zA-Z0-9]*/))
				{
					document.getElementsByName('iw_'+form.elements[i].id)[0].value = form.elements[i].checked ? "ENABLE" : "DISABLE";
				}
			}
		}

		function selall()
		{
			for(i = 0; i < document.sms_event.length; i++)
			{
				if(document.sms_event.elements[i].type == "checkbox" &&
					document.sms_event.elements[i].id.match(/^smsAction_[a-zA-Z0-9]*/))
				{
					document.sms_event.elements[i].checked = document.sms_event.SelAll.checked;
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

       	function iw_sms_eventOnLoad()
    	{
			iw_checkedSet(document.sms_event.smsAction_coldStart,		"<% iw_webCfgValueHandler("smsAction", "coldStart", "DISABLE");%>");
			iw_checkedSet(document.sms_event.smsAction_warmStart,		"<% iw_webCfgValueHandler("smsAction", "warmStart", "DISABLE");%>");
#if defined(IWCONFIG_HAVE_PWR1)
			iw_checkedSet(document.sms_event.smsAction_power1Off,		"<% iw_webCfgValueHandler("smsAction", "power1Off", "DISABLE");%>");
			iw_checkedSet(document.sms_event.smsAction_power1On,		"<% iw_webCfgValueHandler("smsAction", "power1On", "DISABLE");%>");
#endif
#if defined(IWCONFIG_HAVE_PWR2)
			iw_checkedSet(document.sms_event.smsAction_power2Off,		"<% iw_webCfgValueHandler("smsAction", "power2Off", "DISABLE");%>");
			iw_checkedSet(document.sms_event.smsAction_power2On,		"<% iw_webCfgValueHandler("smsAction", "power2On", "DISABLE");%>");
#endif
#if defined(IWCONFIG_HAVE_POE)
			iw_checkedSet(document.sms_event.smsAction_poeOff,	"<% iw_webCfgValueHandler("smsAction", "poeOff", "DISABLE");%>");
			iw_checkedSet(document.sms_event.smsAction_poeOn,		"<% iw_webCfgValueHandler("smsAction", "poeOn", "DISABLE");%>");
#endif /* IWCONFIG_HAVE_POE */
			iw_checkedSet(document.sms_event.smsAction_configChange,	"<% iw_webCfgValueHandler("smsAction", "configChange", "DISABLE");%>");
            iw_checkedSet(document.sms_event.smsAction_ipChange,    "<% iw_webCfgValueHandler("smsAction", "ipChange", "DISABLE");%>");
            iw_checkedSet(document.sms_event.smsAction_passwordChange,  "<% iw_webCfgValueHandler("smsAction", "passwordChange", "DISABLE");%>");
			iw_checkedSet(document.sms_event.smsAction_cAuthFail,		"<% iw_webCfgValueHandler("smsAction", "cAuthFail", "DISABLE");%>");
#if !defined(IWAUTOCONF_INCLUDED) || defined(IWCONFIG_HAVE_DI)
			iw_checkedSet(document.sms_event.smsAction_DI1On2Off,		"<% iw_webCfgValueHandler("smsAction", "DI1On2Off", "DISABLE");%>");
			iw_checkedSet(document.sms_event.smsAction_DI1Off2On,		"<% iw_webCfgValueHandler("smsAction", "DI1Off2On", "DISABLE");%>");
			iw_checkedSet(document.sms_event.smsAction_DI2On2Off,		"<% iw_webCfgValueHandler("smsAction", "DI2On2Off", "DISABLE");%>");
			iw_checkedSet(document.sms_event.smsAction_DI2Off2On,		"<% iw_webCfgValueHandler("smsAction", "DI2Off2On", "DISABLE");%>");
#endif /* IWCONFIG_HAVE_DI */
			iw_checkedSet(document.sms_event.smsAction_lan1linkOn,	"<% iw_webCfgValueHandler("smsAction", "lan1linkOn", "DISABLE");%>");
			iw_checkedSet(document.sms_event.smsAction_lan1linkOff,	"<% iw_webCfgValueHandler("smsAction", "lan1linkOff", "DISABLE");%>");
#if defined (LAN_PORT_2)
			iw_checkedSet(document.sms_event.smsAction_lan2linkOn,	"<% iw_webCfgValueHandler("smsAction", "lan2linkOn", "DISABLE");%>");
			iw_checkedSet(document.sms_event.smsAction_lan2linkOff,	"<% iw_webCfgValueHandler("smsAction", "lan2linkOff", "DISABLE");%>");
#elif defined (LAN_PORT_4)
			iw_checkedSet(document.sms_event.smsAction_lan2linkOn,	"<% iw_webCfgValueHandler("smsAction", "lan2linkOn", "DISABLE");%>");
			iw_checkedSet(document.sms_event.smsAction_lan2linkOff,	"<% iw_webCfgValueHandler("smsAction", "lan2linkOff", "DISABLE");%>");
			iw_checkedSet(document.sms_event.smsAction_lan3linkOn,	"<% iw_webCfgValueHandler("smsAction", "lan3linkOn", "DISABLE");%>");
			iw_checkedSet(document.sms_event.smsAction_lan3linkOff,	"<% iw_webCfgValueHandler("smsAction", "lan3linkOff", "DISABLE");%>");
			iw_checkedSet(document.sms_event.smsAction_lan4linkOn,	"<% iw_webCfgValueHandler("smsAction", "lan4linkOn", "DISABLE");%>");
			iw_checkedSet(document.sms_event.smsAction_lan4linkOff,	"<% iw_webCfgValueHandler("smsAction", "lan4linkOff", "DISABLE");%>");
#endif
			iw_checkedSet(document.sms_event.smsAction_cellCloseTemp,   "<% iw_webCfgValueHandler("smsAction", "cellCloseTemp", "DISABLE");%>");
		}

#if defined(IWCONFIG_CYBER_SECURITY_L1) 
		function editPermission()
		{
			var form = document.sms_event, i, j = <% iw_websCheckPermission(); %>; 
			if(j)
			{
				for(i = 0; i < form.length; i++)
					form.elements[i].disabled = true;
			}
		}
#endif /* IWCONFIG_CYBER_SECURITY_L1 */

		var mem_state = <% iw_websMemoryChange(); %>;
		function iw_ChangeOnLoad()
		{
#if defined(IWCONFIG_CYBER_SECURITY_L1)
	                editPermission();
#endif /* IWCONFIG_CYBER_SECURITY_L1 */
			top.toplogo.location.reload();
		}
    -->
    </script>
</head>
<body onLoad="iw_sms_eventOnLoad();iw_ChangeOnLoad();">
	<h2><% iw_webSysDescHandler("SMSEventTree", "", "SMS Event Types"); %>    <% iw_websGetErrorString(); %></h2>
	<script type="text/javascript">
	<!--
		document.write('<form name="sms_event" method="POST" action="/forms/iw_webSetParameters" onSubmit="return CheckValue(this)">');
		document.write('<table width="100%">');
		document.write('<tr align="left">');
		document.write('<td width="10%" align="left" class="block_title">Event<\/td>');
		document.write('<td width="10%" align="left" class="block_title"><input type="checkbox" id="SelAll" onclick="selall();" \/>Enable Notification<\/td>');
		document.write('<\/tr>');

		genRow( "<% iw_webCfgDescHandler("smsAction", "coldStart", "Cold start"); %>", "smsAction_coldStart" );
		genRow( "<% iw_webCfgDescHandler("smsAction", "warmStart", "Warm start"); %>", "smsAction_warmStart" );
#if defined(IWCONFIG_HAVE_PWR1)
		genRow( "<% iw_webCfgDescHandler("smsAction", "power1Off", "Power 1 transition (On-->Off)"); %>", "smsAction_power1Off" );
		genRow( "<% iw_webCfgDescHandler("smsAction", "power1On", "Power 1 transition (Off-->On) "); %>", "smsAction_power1On" );
#endif
#if defined(IWCONFIG_HAVE_PWR2)
		genRow( "<% iw_webCfgDescHandler("smsAction", "power2Off", "Power 2 transition (On-->Off)"); %>", "smsAction_power2Off" );
		genRow( "<% iw_webCfgDescHandler("smsAction", "power2On", "Power 2 transition (Off-->On) "); %>", "smsAction_power2On" );
#endif
#if defined(IWCONFIG_HAVE_POE)
		genRow( "<% iw_webCfgDescHandler("smsAction", "poeOff", "PoE transition (On-->Off)"); %>", "smsAction_poeOff" );
		genRow( "<% iw_webCfgDescHandler("smsAction", "poeOn", "PoE transition (Off-->On) "); %>", "smsAction_poeOn" );
#endif /* IWCONFIG_HAVE_POE */
		genRow( "<% iw_webCfgDescHandler("smsAction", "configChange", "Configuration changed"); %>", "smsAction_configChange" );
		genRow( "<% iw_webCfgDescHandler("smsAction", "ipChange", "IP changed"); %>", "smsAction_ipChange" );
		genRow( "<% iw_webCfgDescHandler("smsAction", "passwordChange", "Password changed"); %>", "smsAction_passwordChange" );
		genRow( "<% iw_webCfgDescHandler("smsAction", "cAuthFail", "Console authentication failure"); %>", "smsAction_cAuthFail" );
#if !defined(IWAUTOCONF_INCLUDED) || defined(IWCONFIG_HAVE_DI)
		genRow( "<% iw_webCfgDescHandler("smsAction", "DI1On2Off", "DI 1 transition (On-->Off)"); %>", "smsAction_DI1On2Off" );
		genRow( "<% iw_webCfgDescHandler("smsAction", "DI1Off2On", "DI 1 transition (Off-->On)"); %>", "smsAction_DI1Off2On" );
		genRow( "<% iw_webCfgDescHandler("smsAction", "DI2On2Off", "DI 2 transition (On-->Off)"); %>", "smsAction_DI2On2Off" );
		genRow( "<% iw_webCfgDescHandler("smsAction", "DI2Off2On", "DI 2 transition (Off-->On)"); %>", "smsAction_DI2Off2On" );
#endif /* IWCONFIG_HAVE_DI */
		genRow( "<% iw_webCfgDescHandler("smsAction", "lan1linkOn", "LAN link on"); %>", "smsAction_lan1linkOn" );
		genRow( "<% iw_webCfgDescHandler("smsAction", "lan1linkOff", "LAN link off"); %>", "smsAction_lan1linkOff" );
#if defined (LAN_PORT_2)
		genRow( "<% iw_webCfgDescHandler("smsAction", "lan2linkOn", "LAN link on"); %>", "smsAction_lan2linkOn" );
		genRow( "<% iw_webCfgDescHandler("smsAction", "lan2linkOff", "LAN link off"); %>", "smsAction_lan2linkOff" );
#elif defined (LAN_PORT_4)
		genRow( "<% iw_webCfgDescHandler("smsAction", "lan2linkOn", "LAN link on"); %>", "smsAction_lan2linkOn" );
		genRow( "<% iw_webCfgDescHandler("smsAction", "lan2linkOff", "LAN link off"); %>", "smsAction_lan2linkOff" );
		genRow( "<% iw_webCfgDescHandler("smsAction", "lan3linkOn", "LAN link on"); %>", "smsAction_lan3linkOn" );
		genRow( "<% iw_webCfgDescHandler("smsAction", "lan3linkOff", "LAN link off"); %>", "smsAction_lan3linkOff" );
		genRow( "<% iw_webCfgDescHandler("smsAction", "lan4linkOn", "LAN link on"); %>", "smsAction_lan4linkOn" );
		genRow( "<% iw_webCfgDescHandler("smsAction", "lan4linkOff", "LAN link off"); %>", "smsAction_lan4linkOff" );
#endif
       genRow( "<% iw_webCfgDescHandler("smsAction", "cellCloseTemp", "Cellular close temperature range"); %>", "smsAction_cellCloseTemp" );
		document.write('</table>');
		document.write('<hr \/>');
		document.write('<input type="submit" value="Submit" name="Submit" \/>');
		genHiddenValue( "iw_smsAction_coldStart", "DISABLE" );
		genHiddenValue( "iw_smsAction_warmStart", "DISABLE" );
#if defined(IWCONFIG_HAVE_PWR1)
		genHiddenValue( "iw_smsAction_power1Off", "DISABLE" );
		genHiddenValue( "iw_smsAction_power1On", "DISABLE" );
#endif
#if defined(IWCONFIG_HAVE_PWR2)
		genHiddenValue( "iw_smsAction_power2Off", "DISABLE" );
		genHiddenValue( "iw_smsAction_power2On", "DISABLE" );
#endif
#if defined(IWCONFIG_HAVE_POE)
		genHiddenValue( "iw_smsAction_poeOff", "DISABLE" );
		genHiddenValue( "iw_smsAction_poeOn", "DISABLE" );
#endif /* IWCONFIG_HAVE_POE */
		genHiddenValue( "iw_smsAction_configChange", "DISABLE" );
		genHiddenValue( "iw_smsAction_ipChange", "DISABLE" );
		genHiddenValue( "iw_smsAction_passwordChange", "DISABLE" );
		genHiddenValue( "iw_smsAction_cAuthFail", "DISABLE" );
#if !defined(IWAUTOCONF_INCLUDED) || defined(IWCONFIG_HAVE_DI)
		genHiddenValue( "iw_smsAction_DI1On2Off", "DISABLE" );
		genHiddenValue( "iw_smsAction_DI1Off2On", "DISABLE" );
		genHiddenValue( "iw_smsAction_DI2On2Off", "DISABLE" );
		genHiddenValue( "iw_smsAction_DI2Off2On", "DISABLE" );
#endif /* IWCONFIG_HAVE_DI */
		genHiddenValue( "iw_smsAction_lan1linkOn", "DISABLE" );
		genHiddenValue( "iw_smsAction_lan1linkOff", "DISABLE" );
#if defined (LAN_PORT_2)
		genHiddenValue( "iw_smsAction_lan2linkOn", "DISABLE" );
		genHiddenValue( "iw_smsAction_lan2linkOff", "DISABLE" );
#elif defined (LAN_PORT_4)
		genHiddenValue( "iw_smsAction_lan2linkOn", "DISABLE" );
		genHiddenValue( "iw_smsAction_lan2linkOff", "DISABLE" );
		genHiddenValue( "iw_smsAction_lan3linkOn", "DISABLE" );
		genHiddenValue( "iw_smsAction_lan3linkOff", "DISABLE" );
		genHiddenValue( "iw_smsAction_lan4linkOn", "DISABLE" );
		genHiddenValue( "iw_smsAction_lan4linkOff", "DISABLE" );
#endif
        genHiddenValue( "iw_smsAction_cellCloseTemp", "DISABLE" );
		genHiddenValue( "bkpath", "/SMS_event.asp" );
		document.write('<\/form>');
	-->
    </script>
</body>
</html>
#endif /* IWCONFIG_CWAN */
<script language="JavaScript" src="js/jquery-1.5.2.min.js"></script>
<script type="text/javascript">
	$(document).ready(function () {
		var isEditPermission = !<% iw_websCheckPermission(); %>;
		if (isEditPermission == 0) {
			$(":input").attr('disabled','disabled');
		}
	});
</script>
