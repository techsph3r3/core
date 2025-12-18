<HTML>
<HEAD>
	<META http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
	<LINK href="nport2g.css" rel="stylesheet" type="text/css">
	<TITLE><% iw_webSysDescHandler("GuaranLinkSettingsTree", "", "GuaranLink Settings"); %></TITLE>
	<% iw_webJSList_get(); %>
	<SCRIPT language="JavaScript">
	<!--
		function GLinit(){
			document.getElementById("GLEnable1").checked = "<% iw_webCfgValueHandler("guaranLink", "guaranLinkEnable", "DISABLE"); %>" == "ENABLE" ? true : false;
			document.getElementById("GLEnable0").checked = "<% iw_webCfgValueHandler("guaranLink", "guaranLinkEnable", "DISABLE"); %>" == "ENABLE" ? false : true;
			document.getElementById("ConnCheck1").checked = "<% iw_webCfgValueHandler("guaranLink", "ispEnable", "DISABLE"); %>" == "ENABLE" ? true : false;
			document.getElementById("ConnCheck0").checked = "<% iw_webCfgValueHandler("guaranLink", "ispEnable", "DISABLE"); %>" == "ENABLE" ? false : true;
			document.getElementById("IdleCheck1").checked = "<% iw_webCfgValueHandler("guaranLink", "aliveEnable", "DISABLE"); %>" == "ENABLE" ? true : false;
			document.getElementById("IdleCheck0").checked = "<% iw_webCfgValueHandler("guaranLink", "aliveEnable", "DISABLE"); %>" == "ENABLE" ? false : true;
			document.getElementById("PINGCheck1").checked = "<% iw_webCfgValueHandler("guaranLink", "connectEnable", "DISABLE"); %>" == "ENABLE" ? true : false;
			document.getElementById("PINGCheck0").checked = "<% iw_webCfgValueHandler("guaranLink", "connectEnable", "DISABLE"); %>" == "ENABLE" ? false : true;
			document.getElementById("TransCheck1").checked = "<% iw_webCfgValueHandler("guaranLink", "transEnable", "DISABLE"); %>" == "ENABLE" ? true : false;
			document.getElementById("TransCheck0").checked = "<% iw_webCfgValueHandler("guaranLink", "transEnable", "DISABLE"); %>" == "ENABLE" ? false : true;
			
			GLDisplay();
			IdleCheckDisplay();
			PINGCheckDisplay();
			TransCheckDisplay();	
		}
			
		function GLDisplay(){
			if(document.getElementById("GLEnable1").checked){
				document.getElementById("GLBlock").style.display = "block";			
			}else{
				document.getElementById("GLBlock").style.display = "none";
			}
		}
		
		function CommonDisplay(){
			if(document.getElementById("IdleCheck1").checked || document.getElementById("PINGCheck1").checked){
				document.GLform.PINGHost1.disabled = false;
				document.GLform.PINGHost2.disabled = false;
			}else{
				document.GLform.PINGHost1.disabled = true;
				document.GLform.PINGHost2.disabled = true;
			}
		}
		
		function IdleCheckDisplay(){
			if(document.getElementById("IdleCheck1").checked){
				document.GLform.IdleInterval.disabled = false;
				document.GLform.IdleRetry.disabled = false;
			}else{
				document.GLform.IdleInterval.disabled = true;
				document.GLform.IdleRetry.disabled = true;
			}
			CommonDisplay();
		}
		
		function PINGCheckDisplay(){
			if(document.getElementById("PINGCheck1").checked){
				document.GLform.PINGCheckAction.disabled = false;
				document.GLform.PINGInterval.disabled = false;
				document.GLform.PINGRetry.disabled = false;
			}else{
				document.GLform.PINGCheckAction.disabled = true;
				document.GLform.PINGInterval.disabled = true;
				document.GLform.PINGRetry.disabled = true;
			}
			CommonDisplay();
		}
		
		function TransCheckDisplay(){
			if(document.getElementById("TransCheck1").checked){
				document.GLform.TransInterval.disabled = false;
			}else{
				document.GLform.TransInterval.disabled = true;
			}
			CommonDisplay();
		}

		function GLinputText(name, len, size, value){
			document.write("<INPUT type='text' name='" + name + "' size=" + size + " maxlength=" + len + " id=\"" + name + "\">");
			document.getElementById(name).value = value;
		}
		
		function CheckValueRange(value, min, max, keyword){
			var err=1;
			if(value == "" || value<min || value> max){
				err = 0;
			}else{
				if( /^\d{1,}$/.test(value) )
					err = 1;
				else
					err = 0;
			}
		
			if(( err == 0 ) && keyword!="")
				alert("Invalid input: \"" + keyword + "\" (" + value + ")");
	
			return err;
		}
		
		function CheckValue(form){
			if(document.getElementById("GLEnable0").checked == true){
				return true;
			}
			
			if(document.getElementById("ConnCheck0").checked && document.getElementById("IdleCheck0").checked && document.getElementById("PINGCheck0").checked && document.getElementById("TransCheck0").checked){
				alert("Warning:\r\nPlease select at least one of the GuaranLink check methods.");
				return false;
			}
			
			if(!CheckValueRange(form.RegTimeout.value, 10, 600, "Register to network timeout")){
				form.RegTimeout.focus();
				return false;
			}
			
#if defined(IWCONFIG_CWAN_PHS8P)
			if(!CheckValueRange(form.PPPRetry.value, 1, 5, "PPP retry count")){
				form.PPPRetry.focus();
				return false;
			}
#elif defined(IWCONFIG_CWAN_MC73X4)
			if(!CheckValueRange(form.DATARetry.value, 1, 5, "DATA Session retry count")){
				form.DATARetry.focus();
				return false;
			}
#endif
			
			if(document.getElementById("IdleCheck1").checked || document.getElementById("PINGCheck1").checked){
				if(form.PINGHost1.value.length <= 0 && form.PINGHost2.value.length <= 0){
					alert("Warning: \r\nPlease fill in at least one of the Ping remote hosts.");
					form.PINGHost1.focus();
					return false;
				}
			}	
			
			if(document.getElementById("IdleCheck1").checked == true){
				if(false == CheckValueRange(form.IdleInterval.value, 1, 600, "Cellular idle alive check interval")){
					form.IdleInterval.focus();
					return false;
				}
				if(false == CheckValueRange(form.IdleRetry.value, 1, 5, "Cellular idle alive check retry count")){
					form.IdleRetry.focus();
					return false;
				}
			}
			
			if(document.getElementById("PINGCheck1").checked == true){
				if(false == CheckValueRange(form.PINGInterval.value, 1, 600, "DNS/Ping periodical alive check interval ")){
					form.PINGInterval.focus();
					return false;
				}
				if(false == CheckValueRange(form.PINGRetry.value, 1, 5, "DNS/Ping periodical alive check retry count")){
					form.PINGRetry.focus();
					return false;
				}
			}
			
			if(document.getElementById("TransCheck1").checked == true){
				if(false == CheckValueRange(form.TransInterval.value, 1, 600, "Transmission periodical check interval ")){
					form.TransInterval.focus();
					return false;
				}
			}
			
			if(verifyIPandStr(form.PINGHost1, "") || verifyIPandStr(form.PINGHost2, "")){
				if(document.getElementById("PINGCheck1").checked == true){
					if(document.GLform.PINGCheckAction.value != "DNSandPING"){
						alert("Warning: \r\nIf you fill IP address in the DNS/Ping remote host.\r\nPlease change the Packet-level connection check action to \"DNS and Ping\".");
						form.PINGCheckAction.focus();
						return false;
					}
				}
			}
		}
		
		function iw_formOnLoad(form) 
        {
        	GLinit();
        	
			iw_selectSet(document.GLform.PINGCheckAction, "<%iw_webCfgValueHandler("guaranLink", "connectAction", "DNSandPING");%>"); 
			//window.alert("1. PINGCheckAction.value:" + document.GLform.PINGCheckAction.value);
			//iw_selectSet(document.getElementById("PINGCheckAction"), "<%iw_webCfgValueHandler("guaranLink", "connectAction", "DNSandPING");%>"); 
			//window.alert("2. PINGCheckAction.value:" + (document.getElementById( "PINGCheckAction" ).value);	
			//window.alert("3. PINGCheckAction.iwstr_id:" + "<%iw_webCfgValueHandler("guaranLink", "connectAction", "DNSandPING");%>");
        }

#if defined(IWCONFIG_CYBER_SECURITY_L1) 
        function editPermission()
        {
                var form = document.GLform, i, j = <% iw_websCheckPermission(); %>; 
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
	</SCRIPT>
</HEAD>
<BODY onload="iw_formOnLoad(this);iw_ChangeOnLoad();">
	<H2><% iw_webSysDescHandler("GuaranLinkSettingsTree", "", "GuaranLink Settings"); %>    <% iw_websGetErrorString(); %></H2>
	<FORM name="GLform" method="post" action="/forms/webSetNetworkGuaranLink" onSubmit="return CheckValue(this)">
		<TABLE width=100%>
			<TR><TD width="40%" colspan="2" class="column_title">GuaranLink</TD>
				<TD width="60%" colspan="2">		
					<INPUT type="radio" name="GLEnable" value="ENABLE" checked id="GLEnable1" onclick="GLDisplay()">Enable
					<INPUT type="radio" name="GLEnable" value="DISABLE" id="GLEnable0" onclick="GLDisplay()">Disable
				</TD>
			</TR>
		</TABLE>
		<div id="GLBlock">
		<TABLE width=100%>
			<TR><TD width="100%" colspan="2" class="block_title">Common Settings</TD></TR>
			<TR>
				<TD width="40%" class="column_title">Register to network timeout</TD>
				<TD width="60%"> 
					<INPUT type="text" id="RegTimeout" name="RegTimeout" size="5" maxlength="3" value="<% iw_webCfgValueHandler("guaranLink", "registerTimeout", ""); %>">
						(10 - 600 mins)
					</TD>
			</TR>
#if defined(IWCONFIG_CWAN_PHS8P)
			<TR>
				<TD width="40%" class="column_title">PPP retry count</TD>
				<TD width="60%"> 
					<INPUT type="text" id="PPPRetry" name="PPPRetry" size="5" maxlength="2" value="<% iw_webCfgValueHandler("guaranLink", "pppRetry", ""); %>">
						(1 - 5)
				</TD>
			</TR>
#elif defined(IWCONFIG_CWAN_MC73X4)
			<TR>
				<TD width="40%" class="column_title">Data session retry count</TD>
				<TD width="60%"> 
					<INPUT type="text" id="DATARetry" name="DATARetry" size="5" maxlength="2" value="<% iw_webCfgValueHandler("guaranLink", "dataRetry", ""); %>">
						(1 - 5)
				</TD>
			</TR>
#endif
			<TR>
				<TD width="40%" class="column_title">DNS/Ping remote host 1</TD>
				<TD width="60%"> 
					<INPUT type="text" id="PINGHost1" name="PINGHost1" size="40" maxlength="39" value="<% iw_webCfgValueHandler("guaranLink", "pingHost1", ""); %>">
				</TD>
			</TR>
			<TR>
				<TD width=40% class="column_title">DNS/Ping remote host 2</TD>
				<TD width="60%"> 
					<INPUT type="text" id="PINGHost2" name="PINGHost2" size="40" maxlength="39" value="<% iw_webCfgValueHandler("guaranLink", "pingHost2", ""); %>">
				</TD>
			</TR>
			<TR><TD colspan="2"><B>Warning: "DNS/Ping remote host" are only for "Cellular connection alive check"/"Packet-level connection check".</B></TD>
			<TR><TD colspan="2"><BR></TD>
			<TR><TD width="100%" colspan="2" class="block_title">GuaranLink Check Settings</TD></TR>
			<TR>
				<TD width="40%" class="column_title">ISP initial connection check</TD>
				<TD width="60%" colspan="2">		
					<INPUT type="radio" name="ConnCheck" value="ENABLE" checked id="ConnCheck1">Enable
					<INPUT type="radio" name="ConnCheck" value="DISABLE" id="ConnCheck0">Disable
				</TD>
			</TR>	
			<TR><TD colspan="2"><BR></TD>
			<TR>
				<TD width="40%" class="column_title">Cellular connection alive check</TD>
				<TD width="60%">
					<INPUT type="radio" name="IdleCheck" value="ENABLE" checked id="IdleCheck1" onclick="IdleCheckDisplay()">Enable
					<INPUT type="radio" name="IdleCheck" value="DISABLE" id="IdleCheck0" onclick="IdleCheckDisplay()">Disable
				</TD>
			</TR>
			<TR>
				<TD width=40% class="column_title">Cellular connection alive check interval</TD>
				<TD width="60%"> 
					<INPUT type="text" id="IdleInterval" name="IdleInterval" size="5" maxlength="3" value="<% iw_webCfgValueHandler("guaranLink", "aliveInterval", ""); %>">
					(1 - 600 mins)
				</TD>
			</TR>
			<TR>
				<TD width="40%" class="column_title">Cellular connection alive check retry count</TD>
				<TD width="60%"> 
					<INPUT type="text" id="IdleRetry" name="IdleRetry" size="5" maxlength="1" value="<% iw_webCfgValueHandler("guaranLink", "aliveRetry", ""); %>">
					(1 - 5)
				</TD>
			</TR>
			<TR><TD colspan="2"><BR></TD>
			<TR>
				<TD width="40%" class="column_title">Packet-level connection check</TD>
				<TD width="60%">		
					<INPUT type="radio" name="PINGCheck" value="ENABLE" checked id="PINGCheck1" onclick="PINGCheckDisplay()">Enable
					<INPUT type="radio" name="PINGCheck" value="DISABLE" id="PINGCheck0" onclick="PINGCheckDisplay()">Disable
				</TD>
			</TR>
			<TR>
				<TD width="40%" class="column_title">Packet-level connection check action</TD>
				<TD width="60%">
					<SELECT size="1" id="PINGCheckAction" name="PINGCheckAction">
            				<option value="DNSandPING">DNS and Ping</option> 
							<option value="DNSorPING">DNS or Ping</option>           			
		       	</SELECT> 
				</TD>
			</TR>
			<TR>
				<TD width="40%" class="column_title">Packet-level connection check interval</TD>
				<TD width="60%">
					<INPUT type="text" id="PINGInterval" name="PINGInterval" size="5" maxlength="3" value="<% iw_webCfgValueHandler("guaranLink", "connectInterval", ""); %>">
					(1 - 600 mins)
				</TD>
			</TR>
			<TR>
				<TD width="40%" class="column_title">Packet-level connection check retry count</TD>
				<TD width="60%">
					<INPUT type="text" id="PINGRetry" name="PINGRetry" size="5" maxlength="1" value="<% iw_webCfgValueHandler("guaranLink", "connectRetry", ""); %>">
					(1 - 5)
				</TD>
			</TR>
			<TR><TD colspan="2"><BR></TD>
			<TR>
				<TD width="40%" class="column_title">Transmission connection check</TD>
				<TD width="60%">
					<INPUT type="radio" name="TransCheck" value="ENABLE" checked id="TransCheck1" onclick="TransCheckDisplay()">Enable
					<INPUT type="radio" name="TransCheck" value="DISABLE" id="TransCheck0" onclick="TransCheckDisplay()">Disable
				</TD>
			</TR>
			<TR>
				<TD width=40% class="column_title">Transmission connection alive check interval</TD>
				<TD width="60%"> 
					<INPUT type="text" id="TransInterval" name="TransInterval" size="5" maxlength="3" value="<% iw_webCfgValueHandler("guaranLink", "transInterval", ""); %>">
					(1 - 600 mins)
				</TD>
			</TR>
		</TABLE>
	</DIV>
	<TABLE width=100%>
		<TR><TD colspan="3"><BR><HR><INPUT type="submit" value="Submit" name="Submit"></TD></TR>
	</TABLE>
	<Input type="hidden" name="bkpath" value="/guaranLink.asp">
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
