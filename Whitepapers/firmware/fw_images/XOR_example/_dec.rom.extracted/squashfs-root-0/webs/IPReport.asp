<HTML>
<HEAD>
	<META http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
	<META HTTP-EQUIV="Pragma" CONTENT="no-cache">
	<LINK href="nport2g.css" rel=stylesheet type=text/css>
	<TITLE><% iw_webSysDescHandler("IPReportSettingsTree", "", "Auto IP Report Settings"); %></TITLE>
	<% iw_webJSList_get(); %>
	<script type="text/javascript">
	<!--
		function CheckValue(form)
		{
			if( ! isValidNumber(form.iw_ipReport_ipReportPort, 1, 65535, "Report to UDP port") )
			{
				form.iw_ipReport_ipReportPort.focus();
				return false;
			}	
			if( ! isValidNumber(form.iw_ipReport_ipReportUpdatePeriod, 1, 65535, "Report period") )
			{
				form.iw_ipReport_ipReportUpdatePeriod.focus();
				return false;
			}		
			return true;
		}
		
		function iw_formOnLoad(form) 
        {
                ;               
        }

#if defined(IWCONFIG_CYBER_SECURITY_L1) 
        function editPermission()
        {
                var form = document.network, i, j = <% iw_websCheckPermission(); %>; 
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
    </Script>
</HEAD>
<BODY onLoad="iw_formOnLoad(this);iw_ChangeOnLoad();">
	<H2><% iw_webSysDescHandler("IPReportSettingsTree", "", "Auto IP Report Settings"); %>    <% iw_websGetErrorString(); %></H2>
	<FORM name="network" method="post" action="/forms/webSetNetworkIPReport" onSubmit="return CheckValue(this)">
		<TABLE width="100%">
			<TR>
				<TD width="100%" colspan="2" class="block_title">Configuration</TD>
			</TR>
			<TR>
				<TD width="30%" class="column_title"><% iw_webCfgDescHandler("ipReport", "ipReportHostname", "Send Auto IP report to host"); %></TD>
				<TD width="70%">
					<INPUT type="text" id="iw_ipReport_ipReportHostname" name="iw_ipReport_ipReportHostname" size="40" maxlength="39" value="<% iw_webCfgValueHandler("ipReport", "ipReportHostname", ""); %>">
				</TD>
			</TR>
			<TR>
				<TD width="30%" class="column_title"><% iw_webCfgDescHandler("ipReport", "ipReportPort", "Send Auto IP report to UDP port"); %></TD>
				<TD width="70%">
					<INPUT type="text" id="iw_ipReport_ipReportPort" name="iw_ipReport_ipReportPort" size="8" maxlength="5" value="<% iw_webCfgValueHandler("ipReport", "ipReportPort", ""); %>">
				</TD>
			</TR>
			<TR>
				<TD width="30%" class="column_title"><% iw_webCfgDescHandler("ipReport", "ipReportUpdatePeriod", "Reporting interval"); %></TD>
				<TD width="70%">
					<INPUT type="text" id="iw_ipReport_ipReportUpdatePeriod" name="iw_ipReport_ipReportUpdatePeriod" size="8" maxlength="5" value="<% iw_webCfgValueHandler("ipReport", "ipReportUpdatePeriod", ""); %>">
						(1 - 65535 mins)
				</TD>
			</TR>
			<TR>
				<TD colspan="2"><BR><HR>
					<INPUT type="submit" name="Submit" value="Submit">
					<Input type="hidden" name="bkpath" value="/IPReport.asp">
				</TD>
			</TR>
		</TABLE>
		
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
