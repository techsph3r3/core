#if defined(IWCONFIG_CWAN)
<HTML>
<HEAD>
	<LINK href="nport2g.css" rel="stylesheet" type="text/css">
	<TITLE>SMS Alert</TITLE>
	<% iw_webJSList_get(); %>
	<SCRIPT language="JavaScript">
		var PREFIX = 'iw_smsAlert_';
		var INPUT_NAME = PREFIX + 'smsAlertPhone';

		$(document).ready( function() {
			loadStoredConfig();
			iw_changeStateOnLoad(top);	
			formCheck();
		});
		
		function formCheck ()
		{
			$('form').bind("submit", function() {
				 if ( ! CheckValue() ) {
					return false; // form will not be executed
				 }
				return true;
			});
		}

		function loadStoredConfig() 
		{
			$('input[name=' + INPUT_NAME + '1]').val( '<% iw_webCfgValueHandler("smsAlert", "smsAlertPhone1", ""); %>' );
			$('input[name=' + INPUT_NAME + '2]').val( '<% iw_webCfgValueHandler("smsAlert", "smsAlertPhone2", ""); %>' );
			$('input[name=' + INPUT_NAME + '3]').val( '<% iw_webCfgValueHandler("smsAlert", "smsAlertPhone3", ""); %>' );
			$('input[name=' + INPUT_NAME + '4]').val( '<% iw_webCfgValueHandler("smsAlert", "smsAlertPhone4", ""); %>' );
		}

		function CheckValue()
		{
			var inObj;
			for ( var i = 1; i <= 4; i++) {
				inObj = $('input[name=' + INPUT_NAME + i + ']')[0];
				if ( ! isPhoneNumber( inObj.value ) ) {
					alert("Invalid input: \"Phone number " + i + "\" (" + inObj.value + ")");
					inObj.focus();
					return false;
				}
			}
			return true;
		}

#if defined(IWCONFIG_CYBER_SECURITY_L1) 
        function editPermission()
        {
                var form = document.autowarn_sms, i, j = <% iw_websCheckPermission(); %>; 
                if(j)
                {
                        for(i = 0; i < form.length; i++)
                                form.elements[i].disabled = true;
                }
        }
#endif /* IWCONFIG_CYBER_SECURITY_L1 */
        
        function iw_OnLoad()
        {
#if defined(IWCONFIG_CYBER_SECURITY_L1)
                editPermission();
#endif /* IWCONFIG_CYBER_SECURITY_L1 */
                top.toplogo.location.reload();
        }  

	</SCRIPT>
</HEAD>

<BODY onload="iw_OnLoad();">
	<H2><% iw_webSysDescHandler("SMSSetingsTree", "", "SMS Alert Settings"); %>   <% iw_websGetErrorString(); %></H2>
	<FORM name="autowarn_sms" method="POST" action="/forms/iw_webSetParameters">
		<TABLE width="100%">
			<TR>
				<TD width='25%' class='column_title'><% iw_webCfgDescHandler("smsAlert", "smsAlertPhone1", "To phone number 1"); %></TD>
				<TD width='75%'>
					<input name="iw_smsAlert_smsAlertPhone1" maxlength="15" size="18" />
				</TD>
			</TR>		
			<TR>
				<TD width="25%" class="column_title"><% iw_webCfgDescHandler("smsAlert", "smsAlertPhone2", "To phone number 2"); %></TD>
				<TD width="75%">
					<input name="iw_smsAlert_smsAlertPhone2" maxlength="15" size="18" />
				</TD>
			</TR>
			<TR>
				<TD width="25%" class="column_title"><% iw_webCfgDescHandler("smsAlert", "smsAlertPhone3", "To phone number 3"); %></TD>
				<TD width="75%">
					<input name="iw_smsAlert_smsAlertPhone3" maxlength="15" size="18" />
				</TD>
			</TR>
			<TR>
				<TD width="25%" class="column_title"><% iw_webCfgDescHandler("smsAlert", "smsAlertPhone4", "To phone number 4"); %></TD>
				<TD width="75%">
					<input name="iw_smsAlert_smsAlertPhone4" maxlength="15" size="18" />
				</TD>
			</TR>	
#if defined(IW_SMS_FORMAT)
			<TR>
				<TD width="30%" class="column_title"><% iw_webCfgDescHandler("smsAlert", "smsAlertFormat", "Encode format"); %></TD>
				<TD width="70%" colspan="2">
					<SELECT size="1" name="iw_smsAlert_smsAlertFormat">
						<option name="ASCII" value="ASCII" selected>Text ASCII (7 bits)</option>
					</SELECT>
				</TD>
			</TR>
#endif /* IW_SMS_FORMAT */	
			<TR>
				<TD colspan="2"><BR><HR>
					<INPUT type="submit" name="Submit" value="Submit">
				</TD>
			</TR>
		</TABLE>
		<Input type="hidden" name="bkpath" value="SMS_phone.asp">
	</FORM>
</BODY>
</HTML>
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
