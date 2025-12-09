<HTML>
<HEAD>
	<META http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
	<TITLE>ASQC Cell Info</TITLE>
	<LINK href="nport2g.css" rel="stylesheet" type="text/css">
	<% iw_webJSList_get(); %>
	<script>
		var data = <% iw_webGetAsqcCellToJSON(); %> ;

		/*
		 * Main()
		 */
		$(document).ready( function() {
			_loadData(data);
		});

		/* Functions */
		function _loadData(data)
		{
			for ( var i = 0; i < data['asqcCell'].length; ++i ) {
				$('#asqcCell' + ( i + 1 )).html(data['asqcCell'][i]);
			}
		}
	</script>
</HEAD>
<BODY>
	<H2>Welcome to OnCell Series.</H2>
	<H2>Cell. Info.</H2>
	<TABLE width="100%">
		<TR bgcolor="beige">
			<TD width="20%" class="column_title_no_bg">C-WAN IP</TD>
			<TD width="20%" class="column_text_no_bg" id="asqcCell1"></TD>
			<TD width="60" class="column_title_no_bg"></TD>
		</TR>
		<TR bgcolor="azure">
			<TD width="20%" class="column_title_no_bg">CREG</TD>
			<TD width="20%" class="column_text_no_bg" id="asqcCell2"></TD>
			<TD width="60" class="column_title_no_bg">0: No register/ 1: Register to home network/ 2: search for new operator/<BR>
				3: registration denied/	4: Unknow/ 5: roaming</TD>
		</TR>
		<TR bgcolor="beige">
			<TD width="20%" class="column_title_no_bg">RSSI</TD>
			<TD width="20%" class="column_text_no_bg" id="asqcCell3"></TD>
			<TD width="60" class="column_title_no_bg"></TD>
		</TR>
#if defined(IWCONFIG_CWAN_MC73X4)
		<TR bgcolor="azure">
			<TD width="20%" class="column_title_no_bg">PSINFO</TD>
			<TD width="20%" class="column_text_no_bg" id="asqcCell4"></TD>
			<TD width="60" class="column_title_no_bg">0: No attach/ 1: PS attach</TD>
		</TR>
#endif
#if defined(IWCONFIG_CWAN_PHS8P)
		<TR bgcolor="azure">
			<TD width="20%" class="column_title_no_bg">PSINFO</TD>
			<TD width="20%" class="column_text_no_bg" id="asqcCell4"></TD>
			<TD width="60" class="column_title_no_bg">0: no camp/ 1: GPRS available/ 2: camp GPRS/ 3: EDGE available/ 4: camp EDGE/<BR>
				5: WCDMA available/ 6: camp WCDMA/ 7: HSDPA available/ 8: camp HSDPA/<BR>
				9: HSPA available/ 10: camp HSPA</TD>
		</TR>
#endif
		<TR bgcolor="beige">
			<TD width="20%" class="column_title_no_bg">PIN</TD>
			<TD width="20%" class="column_text_no_bg" id="asqcCell5"></TD>
			<TD width="60" class="column_title_no_bg"></TD>
		</TR>
		<TR bgcolor="azure">
			<TD width="20%" class="column_title_no_bg">SIM Flag</TD>
			<TD width="20%" class="column_text_no_bg" id="asqcCell6"></TD>
			<TD width="60" class="column_title_no_bg">[Flag]&nbsp;&nbsp;<BR>0: Default SIM flag(SIM1 and SIM2 without fault)&nbsp;&nbsp;<BR> 
				2: SIM1 with fault&nbsp;&nbsp;<BR>4: SIM2 with fault&nbsp;&nbsp;<BR>6: SIM1 and SIM2 with fault&nbsp;&nbsp;</TD>
		</TR>
#if defined(IWCONFIG_CWAN_MC73X4)
		<TR bgcolor="azure">
			<TD width="20%" class="column_title_no_bg">Radio INFO</TD>
			<TD width="20%" class="column_text_no_bg" id="asqcCell7"></TD>
			<TD width="60" class="column_title_no_bg">0: No service/ 1: CDMA 1xRTT/ 2: CDMA 1xEV-DO/ 3: AMPS (Unsupported)/ 4: GSM/<BR>
				5: UMTS/ 6: WLAN/ 7: GPS/ 8: LTE</TD>
		</TR>
		<TR bgcolor="azure">
			<TD width="20%" class="column_title_no_bg">data bearer</TD>
			<TD width="20%" class="column_text_no_bg" id="asqcCell8"></TD>
			<TD width="60" class="column_title_no_bg">0: UNKNOWN/ 1: CDMA 1X/ 2: EV-DO Rev 0/ 3: GPRS/ 4: WCDMA/<BR>
				5: EV-DO Rev A/ 6: EDGE/ 7: HSDPA and WCDMA/ 8: WCDMA and HSUPA/<BR> 
				9: HSDPA and HSUPA/ 10: LTE/ 11: EV-DO Rev A EHRPD/ 12: HSDPA+ and WCDMA/<BR> 
				13: HSDPA+ and HSUPA/ 14: DC_HSDPA+ and WCDMA/ 15: DC_HSDPA+ and HSUPA</TD>
		</TR>
#endif
		<TR bbgcolor="beige">
			<TD width="20%" class="column_title_no_bg">up time</TD>
			<TD width="20%" class="column_text_no_bg"><% iw_webSysValueHandler("uptime", "", ""); %></TD>
			<TD width="60" class="column_title_no_bg"></TD>
		</TR>
	</TABLE>
</BODY>
</HTML>
