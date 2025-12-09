#if defined(IWCONFIG_CWAN)
<HTML>
<HEAD>
	<META http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
	<LINK href="nport2g.css" rel="stylesheet" type="text/css">
	<TITLE><% iw_webSysDescHandler("remoteSMSCtrl", "", "Remote SMS Control"); %></TITLE>
	<% iw_webJSList_get(); %>
	<SCRIPT language="JavaScript">
	
	var mem_state = <% iw_websMemoryChange(); %>;
	var confData = <% iw_webGetRemoteSMSCtrlToJSON(); %>;
	var isLoad = false;

	$(document).ready( function(){
		isLoad = true;
		iw_changeStateOnLoad(top);
		/* Config */
		loadStoredConfig();
		/* Event */
		event_blockDisplay('#RmtSMSCtrlBlocker');
		event_authTypeDisplay('#iw_remoteSMSCtrl_rmtSMSAuthType');
		var  nameArr  = new Array('iw_rmtSMSCtlMap2_rmtSMSActive', 'iw_rmtSMSCtlMap2_rmtSMSAck');
		event_ReportBoxBinding(nameArr);
#if defined(IWCONFIG_CWAN_REMOTE_FWUPGRADE)
		var  nameArr2 = new Array('iw_rmtSMSCtlMap3_rmtSMSActive', 'iw_rmtSMSCtlMap3_rmtSMSAck');
		event_ReportBoxBinding(nameArr2);
#endif
		event_formSummit('form');
	});

	function event_blockDisplay( blockName ) {
		$('input[name=iw_remoteSMSCtrl_rmtSMSService]').bind( 'change', function(event) {
			// hide or show
			var isDisable = $('input[name=iw_remoteSMSCtrl_rmtSMSService][value=DISABLE]').attr('checked');
			toggleBlockDisplay( blockName, isDisable);
		});
	}
	
	function event_authTypeDisplay(input){
		$(input).bind( 'change', function (event) {
			var phoDisable = $('select option[value="None"]').attr('selected');
			toggleInputDisable( $('input[name^=iw_remoteSMSCtrl_rmtSMSPhone]'), phoDisable);
		});
	}
	
	function event_formSummit(form) {
		$(form).bind("submit", function() {
			var err = 0;
			err = CheckValue();
			if (err) {
				return false;
			}
			return true;
		});	
	}
	
	function event_ReportBoxBinding( nameArr )
	{
		var idSlt;
		var isChecked;
		var POSTFIX = '_fk';
		for ( var i = 0 ; i < nameArr.length; ++i ) {
			idSlt = $('#' + nameArr[i] + POSTFIX);
			$(idSlt).bind( 'click', function() {
				for ( var j = 0; j < nameArr.length; ++j ) {
					//alert($(this).attr('checked'))
					isChecked = $(this).attr('checked');
					$('#' + nameArr[j] + POSTFIX).attr('checked', isChecked);
					$('input[name=' + nameArr[j] + ']').attr('value', isChecked ? "ENABLE" : "DISABLE");

				}
			});
		
		}
	}
	
	function toggleInputDisable(input, disable) {
		$(input).each( function(index) {
			$(this).attr('disabled', disable);
		});
	}

	function loadStoredConfig() {
		var PREFIX = 'iw_', name;
		var hide;
		var input_type = ""; // = $('input[name=' + name + ']').attr('type') ;
		// Load value
		for ( var sec in confData ) {
			for ( var item in confData[sec] ) {
				name = PREFIX + sec + '_' + item;
				

				if ( $('input[name=' + name + ']').length == 0 ) { // for checkbox
				//if ( typeof( type ) == 'undefined' ) { // for checkbox
					var tryName = name + '_fk';
					if( $('#' + tryName).attr('type') == 'checkbox' ) {
						input_type = 'checkbox';
					}
				}

				value = confData[sec][item]['value'];
				if ( name == 'iw_remoteSMSCtrl_rmtSMSService' ) {
					$('select[name=' + name + '] option[value=' + value + ']').attr('selected', 'selected');
				} else if ( name == "iw_remoteSMSCtrl_rmtSMSAuthType" ) { // select
					$('select[name=' + name + '] option[value=' + value + ']').attr('selected', 'selected');
					toggleInputDisable( $('input[name^=iw_remoteSMSCtrl_rmtSMSPhone]'), value == "None" ? true: false);
				} else if ( input_type == 'checkbox' ) { // set ckeckbox
					var ckname = name + '_fk';
					fixCheckBox(ckname, name, value);
				}
				else { // input
					$('input[name=' + name + ']').val( value );
				}
			}
		}
	};

	function fixCheckBox(ckName, hideName, hideValue) {
		//alert(ckname + " " + hideName)
		var ckInName = '#' + ckName;
		var hideInName = 'input[name="' + hideName + '"]';
		var hideInput =  '<input type="hidden" name="' + hideName + '" value="' + hideValue + '" />';
		
		$(ckInName).after(hideInput); // hook
		
		if ( hideValue == "ENABLE" ) {
		//	alert(ckInName);
			$(ckInName).attr('checked', true);
		}
		// bind ckName event to trigger hideName
		$(ckInName).bind("change", function (event) {
			var boxStats = $(ckInName).attr('checked') ? "ENABLE": "DISABLE";
				$(hideInName).val(boxStats);
			});
		return 0;
	}

	function CheckValue(form)
	{
		var idx;
		var passSlt = $('input[name=iw_remoteSMSCtrl_rmtSMSPassword]');
  		var passLen =  $(passSlt).val().length;
		var err = 0;
		var phoneMinLen = 4, phoneMaxLen = 15;
		
		// check password 
		var allowNull = $('select[name=iw_remoteSMSCtrl_rmtSMSService] option[value=DISABLE]').attr('selected');
		if ( passLen || ! allowNull ) {
			if ( passLen < 4 ) {
				alert("Warning:\r\nPlease enter 4-15 number \"0-9\" \r\nor alphabet \"A-Z\" or \"a-z\" in \"Password\" field.");
				$(passSlt)[0].focus();
				return 1;
			}
				
			if ( ! isAlphaNumericString( $('input[name=iw_remoteSMSCtrl_rmtSMSPassword]').val() ) ) {
				alert("Warning:\r\nPlease enter 4-15 number \"0-9\" \r\nor alphabet \"A-Z\" or \"a-z\" in \"Password\" field.");
				$(passSlt)[0].focus();
				return 1;
			}
		}
		// check phone
		var phoneArr = $('input[name^=iw_remoteSMSCtrl_rmtSMSPhone]');
		var haveFlg = false;
		var j;
		for ( var i = 0; i < $(phoneArr).size(); ++i ) {
			if ( $(phoneArr).get(i).value.length > 0 ) {
#if defined(IWCONFIG_G3470)
				j = i + 1;
				if ( ! isPhoneNumber_without_plus( $(phoneArr)[i].value ) ) {
					alert("Invalid input: \"Caller ID " +j + "\" (" + $(phoneArr)[i].value + ").\nPlease enter 0~9 and \'+\' does not support.");
#else
				if ( ! isPhoneNumber( $(phoneArr)[i].value ) ) {
					alert('Warning:\r\nPlease enter 4-16 number 0-9 in Cellular\" field')
#endif
					$(phoneArr)[i].focus();
					return 1;
				}
				haveFlg = true;
			}
		}
		if ( $('select option[value="Caller_ID"]').attr('selected') ) {
			if ( ! haveFlg ) {
				alert("Caller ID 1 ~ 4  are empty ");
				$(phoneArr)[0].focus();
				return 1;
			}
		}


		return 0;
	}

#if defined(IWCONFIG_CYBER_SECURITY_L1) 
        function editPermission()
        {
                var form = document.RemoteSMSCtrlForm, i, j = <% iw_websCheckPermission(); %>; 
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
	<H2><% iw_webSysDescHandler("remoteSMSCtrl", "", "Remote SMS Control"); %>    <% iw_websGetErrorString(); %></H2>
	<form name="RemoteSMSCtrlForm" method="POST" action="/forms/iw_webSetParameters">
		<table width=100%>
			<tr>
				<td id="title" width="30%" class="column_title"><% iw_webCfgDescHandler("remoteSMSCtrl", "rmtSMSService", "Remote SMS control"); %></td>
				<td width="70%">
					<select name="iw_remoteSMSCtrl_rmtSMSService">
						<option value="ENABLE">Enable</option>
						<option value="DISABLE">Disable</option>
					</select>
				</td>
			</tr>
		</table>
		<DIV id="RmtSMSCtrlBlocker">
		<table width=100%>
			<tr>
				<td width="100%" colspan="2" class="block_title">Configuration</td>
			</tr>
			<tr>
				<td width="30%" class="column_title"><% iw_webCfgDescHandler("remoteSMSCtrl", "rmtSMSPassword", "Password"); %></td>
				<td width=70%><input type="password" name="iw_remoteSMSCtrl_rmtSMSPassword" maxlength="15" size="18" value=""/></td>
			</tr>
			<tr>
				<td width="30%" class="column_title"><% iw_webCfgDescHandler("remoteSMSCtrl", "rmtSMSAuthType", "Auth type"); %></td>
				<td width="70%" colspan="2">
					<select type="select" size="1" name="iw_remoteSMSCtrl_rmtSMSAuthType" id="iw_remoteSMSCtrl_rmtSMSAuthType">
						<option value="Caller_ID">Caller ID</option>
						<option value="None">None</option>
					</select>
				</td>
			</tr>
			<tr>
				<td width="30%" class="column_title"><% iw_webCfgDescHandler("remoteSMSCtrl", "rmtSMSPhone1", "Caller ID 1"); %></td>
				<td width="70%" colspan="2"><input name="iw_remoteSMSCtrl_rmtSMSPhone1" maxlength="15" size="18" value=""/></td>
			</tr>
			<tr>
				<td width="30%" class="column_title"><% iw_webCfgDescHandler("remoteSMSCtrl", "rmtSMSPhone2", "Caller ID 2"); %></td>
				<td width="70%" colspan="2"><input name="iw_remoteSMSCtrl_rmtSMSPhone2" maxlength="15" size="18" value=""/></td>
			</tr>
			<tr>
				<td width="30%" class="column_title"><% iw_webCfgDescHandler("remoteSMSCtrl", "rmtSMSPhone3", "Caller ID 3"); %></td>
				<td width="70%" colspan="2"><input name="iw_remoteSMSCtrl_rmtSMSPhone3" maxlength="15" size="18" value=""/></td>
			</tr>
			<tr>
				<td width="30%" class="column_title"><% iw_webCfgDescHandler("remoteSMSCtrl", "rmtSMSPhone4", "Caller ID 4"); %></td>
				<td width="70%" colspan="2"><input name="iw_remoteSMSCtrl_rmtSMSPhone4" maxlength="15" size="18" value=""/></td>
			</tr>
		</table>
		<table width=100%>
			<tr>
				<td width="20%" class="block_title">Item</td>
				<td width="10%" class="block_title">Action</td>
				<td width="15%" class="block_title">Acknowledge</td>
				<td width="60%" class="block_title">Command</td>
			</tr>
			<tr>
				<td width="20%" class="column_title">Restart</td>
				<td width="10%"><INPUT type="checkbox" id="iw_rmtSMSCtlMap1_rmtSMSActive_fk" value="ENABLE"></td>
				<td width="15%"><INPUT type="checkbox" id="iw_rmtSMSCtlMap1_rmtSMSAck_fk" value="ENABLE"></td>
				<td width="60%">@<I>password</I>@restart</td>
			</tr>
			<tr>
				<td width="20%" class="column_title">Cellular report</td>
				<td width="10%"><INPUT type="checkbox" id="iw_rmtSMSCtlMap2_rmtSMSActive_fk" value="ENABLE"></td>
				<td width="15%"><INPUT type="checkbox" id="iw_rmtSMSCtlMap2_rmtSMSAck_fk" value="ENABLE"></td>
				<td width="60%">@<I>password</I>@cell.report</td>
			</tr>
#if defined(IWCONFIG_CWAN_REMOTE_FWUPGRADE)
			<tr>
				<td width="20%" class="column_title">Upgrade firmware remotely</td>
				<td width="10%"><INPUT type="checkbox" id="iw_rmtSMSCtlMap3_rmtSMSActive_fk" value="ENABLE"></td>
				<td width="15%"><INPUT type="checkbox" id="iw_rmtSMSCtlMap3_rmtSMSAck_fk" value="ENABLE"></td>
				<td width="60%">@<I>password</I>@upgrade<I>@URL</I></td>
			</tr>
#endif
#if defined(IWCONFIG_CWAN_REMOTE_OCM_IPCHANGE)
			<tr>
				<td width="20%" class="column_title">Change OCM IP address</td>
				<td width="10%"><INPUT type="checkbox" id="iw_rmtSMSCtlMap4_rmtSMSActive_fk" value="ENABLE"></td>
				<td width="15%"><INPUT type="checkbox" id="iw_rmtSMSCtlMap4_rmtSMSAck_fk" value="ENABLE"></td>
				<td width="60%">@<I>password</I>@ip.change<I>@IP</I></td>
			</tr>
#endif
#if defined(IWCONFIG_CWAN_REMOTE_CELLULAR_CONNECTION)
			<tr>
				<td width="20%" class="column_title">Start cellular connection</td>
				<td width="10%"><INPUT type="checkbox" id="iw_rmtSMSCtlMap5_rmtSMSActive_fk" value="ENABLE"></td>
				<td width="15%"><INPUT type="checkbox" id="iw_rmtSMSCtlMap5_rmtSMSAck_fk" value="ENABLE"></td>
				<td width="60%">@<I>password</I>@cellular.start</td>
			</tr>
			<tr>
				<td width="20%" class="column_title">Stop cellular connection</td>
				<td width="10%"><INPUT type="checkbox" id="iw_rmtSMSCtlMap6_rmtSMSActive_fk" value="ENABLE"></td>
				<td width="15%"><INPUT type="checkbox" id="iw_rmtSMSCtlMap6_rmtSMSAck_fk" value="ENABLE"></td>
				<td width="60%">@<I>password</I>@cellular.stop</td>
			</tr>
#endif /* IWCONFIG_CWAN_REMOTE_CELLULAR_CONNECTION */
#if defined(IWCONFIG_CWAN_REMOTE_IPSEC_CONNECTION)
			<tr>
				<td width="20%" class="column_title">Start IPSec connection</td>
				<td width="10%"><INPUT type="checkbox" id="iw_rmtSMSCtlMap7_rmtSMSActive_fk" value="ENABLE"></td>
				<td width="15%"><INPUT type="checkbox" id="iw_rmtSMSCtlMap7_rmtSMSAck_fk" value="ENABLE"></td>
				<td width="60%">@<I>password</I>@ipsec.start</td>
			</tr>
			<tr>
				<td width="20%" class="column_title">Stop IPSec connection</td>
				<td width="10%"><INPUT type="checkbox" id="iw_rmtSMSCtlMap8_rmtSMSActive_fk" value="ENABLE"></td>
				<td width="15%"><INPUT type="checkbox" id="iw_rmtSMSCtlMap8_rmtSMSAck_fk" value="ENABLE"></td>
				<td width="60%">@<I>password</I>@ipsec.stop</td>
			</tr>
#endif /* IWCONFIG_CWAN_REMOTE_IPSEC_CONNECTION */
#if defined(IWCONFIG_CWAN_REMOTE_OPENVPN_CONNECTION)
			<tr>
				<td width="20%" class="column_title">Start OpenVPN connection</td>
				<td width="10%"><INPUT type="checkbox" id="iw_rmtSMSCtlMap9_rmtSMSActive_fk" value="ENABLE"></td>
				<td width="15%"><INPUT type="checkbox" id="iw_rmtSMSCtlMap9_rmtSMSAck_fk" value="ENABLE"></td>
				<td width="60%">@<I>password</I>@openvpn.start</td>
			</tr>
			<tr>
				<td width="20%" class="column_title">Stop OpenVPN connection</td>
				<td width="10%"><INPUT type="checkbox" id="iw_rmtSMSCtlMap10_rmtSMSActive_fk" value="ENABLE"></td>
				<td width="15%"><INPUT type="checkbox" id="iw_rmtSMSCtlMap10_rmtSMSAck_fk" value="ENABLE"></td>
				<td width="60%">@<I>password</I>@openvpn.stop</td>
			</tr>
#endif /* IWCONFIG_CWAN_REMOTE_OPENVPN_CONNECTION */
		</table>
		</DIV>
		<br />
		<hr />
	    <input type="hidden" name="bkpath" value="remoteSMSCtrl.asp">
	    <INPUT type="submit" value="Submit" name="submit">
	</form>
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
