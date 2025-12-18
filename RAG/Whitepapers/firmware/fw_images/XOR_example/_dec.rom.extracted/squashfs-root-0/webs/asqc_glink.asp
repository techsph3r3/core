<HTML>
<HEAD>
	<META http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
	<TITLE>ASQC_GuaranLink</TITLE>
	<LINK href="nport2g.css" rel="stylesheet" type="text/css">
	<% iw_webJSList_get(); %>
	<script>
		var data = <% iw_webGetAsqcGLinkToJSON(); %> ;

		/*
		 * Main()
		 */
		$(document).ready( function() {
			_loadData(data);
		});

		/* Functions */
		function _loadData(data)
		{
#if defined(IWCONFIG_CWAN_MC73X4)
			for ( var i = 0; i < data['asqcGLink'].length; ++i ) {
				if (i < 5)
					$('#asqcGLink' + ( i + 1 )).html(data['asqcGLink'][i]);
				else if (i >= 5 && i < 31)
					$('#asqcGLink' + ( i + 4 )).html(data['asqcGLink'][i]);
				else if (i >= 31)
					$('#asqcGLink' + ( i + 7 )).html(data['asqcGLink'][i]);
			}
#elif defined(IWCONFIG_CWAN_PHS8P)
			for ( var i = 0; i < data['asqcGLink'].length; ++i ) {
				$('#asqcGLink' + ( i + 1 )).html(data['asqcGLink'][i]);
			}
#endif
		}
	</script>
</HEAD>
<BODY>
	<H2>GuaranLink Information (<% iw_webSysValueHandler("uptime", "", ""); %>)</H2>
	<TABLE width="100%">
		<TR><TD width="30%" class="block_title">ISP initial connection check</TD>
			<TD width="20%" class="block_title"></TD>
			<TD width="20%" class="block_title"></TD>
			<TD class="block_title"> </TD></TR>
		
		<TR><TD width="30%" class="column_title">Check point</TD>
			<TD width="20%" class="column_title">Result</TD>
			<TD width="20%" class="column_title">Retry count</TD>
			<TD class="column_title"> Timestamp</TD></TR>
		
		<TR><TD width="30%" class="column_title">Register to network timeout</TD>
			<TD width="20%" id="asqcGLink1"></TD>
			<TD width="20%">N/A</TD>
			<TD id="asqcGLink2"></TD></TR>
				
#if defined(IWCONFIG_CWAN_MC73X4)
		<TR><TD width="30%" class="column_title">DataSession retry</TD>
			<TD width="20%" id="asqcGLink3"></TD>
			<TD width="20%" id="asqcGLink4"></TD>
			<TD id="asqcGLink5"></TD></TR>
#elif defined(IWCONFIG_CWAN_PHS8P)
		<TR><TD width="30%" class="column_title">ATD</TD>
			<TD width="20%" id="asqcGLink3"></TD>
			<TD width="20%" id="asqcGLink4"></TD>
			<TD id="asqcGLink5"></TD></TR>
			
		<TR><TD width="30%" class="column_title">PPP retry</TD>
			<TD width="20%" id="asqcGLink6"></TD>
			<TD width="20%" id="asqcGLink7"></TD>
			<TD id="asqcGLink8"></TD></TR>
#endif
				
		<TR><TD width="30%" class="block_title">Cellular connection alive check</TD>
			<TD width="20%" class="block_title"></TD>
			<TD width="20%" class="block_title"></TD>
			<TD class="block_title"> </TD></TR>
		
		<TR><TD width="30%" class="column_title">Check point</TD>
			<TD width="20%" class="column_title">Result</TD>
			<TD width="20%" class="column_title">Retry count</TD>
			<TD class="column_title"> Timestamp</TD></TR>
				
		<TR><TD width="30%" class="column_title">Idle check</TD>
			<TD width="20%" id="asqcGLink9"></TD>
			<TD width="20%" id="asqcGLink10"> (rxCount)</TD>
			<TD id="asqcGLink11"></TD></TR>
		
		<TR><TD width="30%" class="column_title">DNS lookup host1</TD>
			<TD width="20%" id="asqcGLink12"></TD>
			<TD width="20%" id="asqcGLink13"></TD>
			<TD id="asqcGLink14"></TD></TR>
				
		<TR><TD width="30%" class="column_title">DNS lookup host2</TD>
			<TD width="20%" id="asqcGLink15"></TD>
			<TD width="20%" id="asqcGLink16"></TD>
			<TD id="asqcGLink17"></TD></TR>
				
		<TR><TD width="30%" class="block_title">Packet-level connection check</TD>
			<TD width="20%" class="block_title"></TD>
			<TD width="20%" class="block_title"></TD>
			<TD class="block_title"> </TD></TR>
		
		<TR><TD width="30%" class="column_title">Check point</TD>
			<TD width="20%" class="column_title">Result</TD>
			<TD width="20%" class="column_title">Retry count</TD>
			<TD class="column_title"> Timestamp</TD></TR>
				
		<TR><TD width="30%" class="column_title">DNS lookup host1</TD>
			<TD width="20%" id="asqcGLink18"></TD>
			<TD width="20%" id="asqcGLink19"></TD>
			<TD id="asqcGLink20"></TD></TR>
		
		<TR><TD width="30%" class="column_title">Ping host1</TD>
			<TD width="20%" id="asqcGLink21"></TD>
			<TD width="20%" id="asqcGLink22"></TD>
			<TD id="asqcGLink23"></TD></TR>
				
		<TR><TD width="30%" class="column_title">DNS lookup host2</TD>
			<TD width="20%" id="asqcGLink24"></TD>
			<TD width="20%" id="asqcGLink25"></TD>
			<TD id="asqcGLink26"></TD></TR>
				
		<TR><TD width="30%" class="column_title">Ping host2</TD>
			<TD width="20%" id="asqcGLink27"></TD>
			<TD width="20%" id="asqcGLink28"></TD>
			<TD id="asqcGLink29"></TD></TR>
		
		<TR><TD width="30%" class="block_title">Common alive check</TD>
			<TD width="20%" class="block_title"></TD>
			<TD width="20%" class="block_title"></TD>
			<TD class="block_title"> </TD></TR>
		
		<TR><TD width="30%" class="column_title">Check point</TD>
			<TD width="20%" class="column_title">Result</TD>
			<TD width="20%" class="column_title">Retry count</TD>
			<TD class="column_title"> Timestamp</TD></TR>
				
		<TR><TD width="30%" class="column_title">Register to network timeout</TD>
			<TD width="20%" id="asqcGLink30"></TD>
			<TD width="20%">N/A</TD>
			<TD id="asqcGLink31"></TD></TR>
				
#if defined(IWCONFIG_CWAN_MC73X4)
		<TR><TD width="30%" class="column_title">DataSession retry</TD>
			<TD width="20%" id="asqcGLink32"></TD>
			<TD width="20%" id="asqcGLink33"></TD>
			<TD id="asqcGLink34"></TD></TR>
#elif defined(IWCONFIG_CWAN_PHS8P)
		<TR><TD width="30%" class="column_title">ATD</TD>
			<TD width="20%" id="asqcGLink32"></TD>
			<TD width="20%" id="asqcGLink33"></TD>
			<TD id="asqcGLink34"></TD></TR>
			
		<TR><TD width="30%" class="column_title">PPP retry</TD>
			<TD width="20%" id="asqcGLink35"></TD>
			<TD width="20%" id="asqcGLink36"></TD>
			<TD id="asqcGLink37"></TD></TR>
#endif
		<TR><TD width="30%" class="block_title">Cellular transmission connection check</TD>
			<TD width="20%" class="block_title"></TD>
			<TD width="20%" class="block_title"></TD>
			<TD class="block_title"> </TD></TR>
		
		<TR><TD width="30%" class="column_title">Check point</TD>
			<TD width="20%" class="column_title">Result</TD>
			<TD width="20%" class="column_title">Retry count</TD>
			<TD class="column_title"> Timestamp</TD></TR>
				
		<TR><TD width="30%" class="column_title">Trans check</TD>
			<TD width="20%" id="asqcGLink38"></TD>
			<TD width="20%" id="asqcGLink39"> (rxCount)</TD>
			<TD id="asqcGLink40"></TD></TR>
	</TABLE>
</BODY>
</HTML>
