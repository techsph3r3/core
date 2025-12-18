<HTML>
<HEAD>
	<META http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
	<LINK href="nport2g.css" rel="stylesheet" type="text/css">
	<TITLE><% iw_webSysDescHandler("CellularWANSettingsTree", "", "Cellular WAN Settings"); %></TITLE>
	<% iw_webJSList_get(); %>
	<SCRIPT language="JavaScript">
	<!--
		function getObj(x) {
			if (document.getElementById) return (document.getElementById(x)) ? document.getElementById(x) : false;
			return false;
		}
	
		function isValidNumberNoWarn(inpString, minvalue, maxvalue, str)
		{
			if (!getObj) return;

			var err=1;

			if( inpString.value == "" || inpString.value < minvalue || inpString.value > maxvalue )
				err = 0;
			else
			{
				if( /^\d{1,}$/.test(inpString.value) )
					err = 1;
				else
					err = 0;
			}

			if( err == 0 )
			{
				alert("Invalid input: \"" + str + "\".\n4 to 8 digits only.");
				inpString.focus();
			}

			return err;
		}		

#if defined (IWCONFIG_CWAN)
#if defined (IWCONFIG_CWAN_MC73X4)
		<%iw_webCellularMC73x4();%>
#elif defined (IWCONFIG_CWAN_PHS8P)
		function checkValue(form)
		{
			if (!getObj) return;

			if( form.UsedSIMSlot.value == 0 || form.UsedSIMSlot.value == 2){
				if(form.pin1.value.length > 0 && (form.pin1.value.length < 4 || !isValidNumberNoWarn(form.pin1, 0, 99999999, "SIM 1 PIN")) ){
					if(form.pin1.value.length < 4)
						alert("Invalid input: \"SIM 1 PIN\".\nNeeds 4 to 8 digits.");
					form.pin1.focus();
					return false;
				}

				if(form.WANPrefer1.checked && form.ConnCtrl1.value == 2 && form.RemoteHost1.value.length <= 0){
					alert("Please fill \"SIM 1 Ping remote host\".");
					form.RemoteHost1.focus();
					return false;
				}
			}
		
#if defined(IWCONFIG_CWAN_DUAL_SIM)
			if( form.UsedSIMSlot.value == 1 || form.UsedSIMSlot.value == 2){
				if(form.pin2.value.length > 0 && (form.pin2.value.length < 4 || !isValidNumberNoWarn(form.pin2, 0, 99999999, "SIM 2 PIN")) ){
					if(form.pin2.value.length < 4)
						 alert("Invalid input: \"SIM 2 PIN\"\nNeeds 4 to 8 digits.");
					form.pin2.focus();
					return false;
				}
				
				if(form.ConnCtrl2.value == 2 && form.RemoteHost2.value.length <= 0){
					alert("Please fill \"SIM 2 Ping remote host\".");
					form.RemoteHost2.focus();
					return false;
				}
			}
#endif /* IWCONFIG_CWAN_DUAL_SIM */

			return true;
		}
		
		function updatePINGDisplay1(){
			if (!getObj) return;
			document.getElementById("RemoteHost1").disabled= (document.getElementById("ConnCtrl1").value == "ALWAYSON") ? true : false;
		}
		
#if defined(IWCONFIG_CWAN_DUAL_SIM)
		function updatePINGDisplay2(){
			if (!getObj) return;
			document.getElementById("RemoteHost2").disabled= (document.getElementById("ConnCtrl2").value == "ALWAYSON") ? true : false;
		}
#endif /* IWCONFIG_CWAN_DUAL_SIM */
	
#if defined(IWCONFIG_ENABLE_CELLULAR_CONNECT_CONTROL)	
		function updateConnCond(){	
			if (!getObj) return;

			if(getObj("WANPrefer0").checked){
				document.getElementById("ConnCtrl1").disabled = true;	
				document.getElementById("RemoteHost1").disabled = true;
#if defined(IWCONFIG_CWAN_DUAL_SIM)
				document.getElementById("ConnCtrl2").disabled = true;	
				document.getElementById("RemoteHost2").disabled = true;
#endif /* IWCONFIG_CWAN_DUAL_SIM */
			}else{
				document.getElementById("ConnCtrl1").disabled = false;
				updatePINGDisplay1();
#if defined(IWCONFIG_CWAN_DUAL_SIM)
				document.getElementById("ConnCtrl2").disabled = false;	
				updatePINGDisplay2();
#endif /* IWCONFIG_CWAN_DUAL_SIM */
			}			
		}
#endif /* IWCONFIG_ENABLE_CELLULAR_CONNECT_CONTROL */

#if defined(IWCONFIG_ENABLE_CELLULAR_CONNECT_CONTROL)
		function updateServiceDisplay(){
			updateConnCond();
		}
#endif /* IWCONFIG_ENABLE_CELLULAR_CONNECT_CONTROL */

		function updatePPPConfig(){	
			if (!getObj) return;

			//fang- SIM 1
			if(getObj("PPPConfig1_1").checked){
				document.getElementById("ATD1").disabled = false;
				document.getElementById("PPPAuth1").disabled = false;
			}else{
				document.getElementById("ATD1").disabled = true;	
				document.getElementById("PPPAuth1").disabled = true;
			}

#if defined(IWCONFIG_CWAN_DUAL_SIM)
			//fang- SIM 2
			if(getObj("PPPConfig2_1").checked){
				document.getElementById("ATD2").disabled = false;
				document.getElementById("PPPAuth2").disabled = false;
			}else{
				document.getElementById("ATD2").disabled = true;	
				document.getElementById("PPPAuth2").disabled = true;
			}	
#endif /* IWCONFIG_CWAN_DUAL_SIM */
		}

		function initPPPConfig() {
			if (!getObj) return;
			
			//fang- SIM 1
			getObj("PPPConfig1_1").checked=( "<% iw_webCfgValueHandler("cellularWAN", "sim1PPPConfig", "DISABLE"); %>" == "ENABLE" ? true : false);
			getObj("PPPConfig1_0").checked=( "<% iw_webCfgValueHandler("cellularWAN", "sim1PPPConfig", "DISABLE"); %>" == "ENABLE" ? false : true);

#if defined(IWCONFIG_CWAN_DUAL_SIM)
			//fang- SIM 2
			getObj("PPPConfig2_1").checked=( "<% iw_webCfgValueHandler("cellularWAN", "sim2PPPConfig", "DISABLE"); %>" == "ENABLE" ? true : false);
			getObj("PPPConfig2_0").checked=( "<% iw_webCfgValueHandler("cellularWAN", "sim2PPPConfig", "DISABLE"); %>" == "ENABLE" ? false : true);
#endif /* IWCONFIG_CWAN_DUAL_SIM */
		}
		
		function initCellular() {
			if (!getObj) return;
			getObj("tcpZip1_1").checked=( "<% iw_webCfgValueHandler("cellularWAN", "sim1TCPZip", "DISABLE"); %>" == "ENABLE" ? true : false);
			getObj("tcpZip1_0").checked=( "<% iw_webCfgValueHandler("cellularWAN", "sim1TCPZip", "DISABLE"); %>" == "ENABLE" ? false : true);
			
#if defined(IWCONFIG_CWAN_DUAL_SIM)
			getObj("tcpZip2_1").checked=( "<% iw_webCfgValueHandler("cellularWAN", "sim2TCPZip", "DISABLE"); %>" == "ENABLE" ? true : false);
			getObj("tcpZip2_0").checked=( "<% iw_webCfgValueHandler("cellularWAN", "sim2TCPZip", "DISABLE"); %>" == "ENABLE" ? false : true);
#endif /* IWCONFIG_CWAN_DUAL_SIM */
		}
#if defined(IWCONFIG_ENABLE_CELLULAR_CONNECT_CONTROL)	
		function initNAT() {
			if (!getObj) return;
			
			getObj("WANPrefer0").checked= ( "<% iw_webCfgValueHandler("cellularWAN", "wanPreference", "CELLULAR"); %>" == "ETHERNET" ? false : true);
			getObj("WANPrefer1").checked= ( "<% iw_webCfgValueHandler("cellularWAN", "wanPreference", "CELLULAR"); %>" == "ETHERNET" ? true : false);
		}
#endif /* IWCONFIG_ENABLE_CELLULAR_CONNECT_CONTROL */
		
		function initPage(){
			if (!getObj) return;
			
			initCellular();
			UsedSIMSlotDisplay();
#if defined(IWCONFIG_ENABLE_CELLULAR_CONNECT_CONTROL)
			initNAT();
			updateConnCond();
#endif
			initPPPConfig();
			updatePPPConfig();
		}
		
		function UsedSIMSlotDisplay(){
			var usedSIM;
			usedSIM = document.getElementById("UsedSIMSlot").value;
			if(usedSIM == "SIM1"){
				document.getElementById("SIM1Block").style.display = "block";
#if defined(IWCONFIG_CWAN_DUAL_SIM)
				document.getElementById("SIM2Block").style.display = "none";
#endif /* IWCONFIG_CWAN_DUAL_SIM */
			}else if(usedSIM == "SIM2"){
				document.getElementById("SIM1Block").style.display = "none";
#if defined(IWCONFIG_CWAN_DUAL_SIM)
				document.getElementById("SIM2Block").style.display = "block";
#endif /* IWCONFIG_CWAN_DUAL_SIM */
			}else{
				document.getElementById("SIM1Block").style.display = "block";
#if defined(IWCONFIG_CWAN_DUAL_SIM)
				document.getElementById("SIM2Block").style.display = "block";
#endif /* IWCONFIG_CWAN_DUAL_SIM */
			}
		}

		function editParam1(page){
			remote = window.open("", "", "width=550, height=350");
			remote.location.href = page + "?DestIP=" + document.gsmgprs.RemoteHost1.value;
			if( remote.opener == null)
				remote.opener = window;
		}
		
		function editParam2(page){
			remote = window.open("", "", "width=550, height=350");
			remote.location.href = page + "?DestIP=" + document.gsmgprs.RemoteHost2.value;
			if( remote.opener == null)
				remote.opener = window;
		}
		
		function iw_formOnLoad(form) 
        {
        	initPage();
        	
			iw_selectSet(document.gsmgprs.UsedSIMSlot, "<%iw_webCfgValueHandler("cellularWAN", "dualSIM", "SIM1");%>"); 
			//window.alert("1. UsedSIMSlot.value:" + document.gsmgprs.UsedSIMSlot.value);
			
			//SIM 1
			iw_selectSet(document.gsmgprs.Band1, "<%iw_webCfgValueHandler("cellularWAN", "sim1Band", "AUTO");%>"); 
			iw_selectSet(document.gsmgprs.PPPAuth1, "<%iw_webCfgValueHandler("cellularWAN", "sim1PPPAuth", "AUTO");%>"); 
			iw_selectSet(document.gsmgprs.ConnCtrl1, "<%iw_webCfgValueHandler("cellularWAN", "sim1ConnCtl", "ALWAYSON");%>"); 

#if defined(IWCONFIG_CWAN_DUAL_SIM)			
			//SIM 2
			iw_selectSet(document.gsmgprs.Band2, "<%iw_webCfgValueHandler("cellularWAN", "sim2Band", "AUTO");%>"); 
			iw_selectSet(document.gsmgprs.PPPAuth2, "<%iw_webCfgValueHandler("cellularWAN", "sim2PPPAuth", "AUTO");%>"); 
			iw_selectSet(document.gsmgprs.ConnCtrl2, "<%iw_webCfgValueHandler("cellularWAN", "sim2ConnCtl", "ALWAYSON");%>");
#endif /* IWCONFIG_CWAN_DUAL_SIM */
			iw_ChangeOnLoad();
			UsedSIMSlotDisplay();
        }

#if defined(IWCONFIG_CYBER_SECURITY_L1) 
		function editPermission()
		{
			var form = document.gsmgprs, i, j = <% iw_websCheckPermission(); %>; 
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
        
		//-->
	</SCRIPT>
</HEAD>
<BODY onload="iw_formOnLoad(this);">
	<H2><% iw_webSysDescHandler("CellularWANSettingsTree", "", "Cellular WAN Settings"); %>    <% iw_websGetErrorString(); %></H2>
	<FORM name="gsmgprs" method="post" action="/forms/webSetNetworkCellularWAN" onSubmit="return CheckValue(this)">
		<TABLE width="100%">
			<TR>
				<TD width="100%" colspan="2" class="block_title">Cellular WAN Configuration</TD>
			</TR>
			<TR>
				<TD width="30%" class="column_title">Used SIM</TD>
				<TD width="70%">
					<SELECT size="1" name="UsedSIMSlot" id="UsedSIMSlot" onChange="UsedSIMSlotDisplay();">
						<option value="SIM1">SIM 1</option> 
#if defined(IWCONFIG_CWAN_DUAL_SIM)
						<option value="SIM2">SIM 2</option> 
						<option value="DualSIM">Dual SIM</option>
#endif /* IWCONFIG_CWAN_DUAL_SIM */ 
					</SELECT>&nbsp;&nbsp;<B>Please ensure inserting SIM card into right slot.</B>
				</TD>
			</TR>
#if defined(IWCONFIG_ENABLE_CELLULAR_CONNECT_CONTROL)
			<TR>
				<TD width="30%" class="column_title">WAN preference</TD>
				<TD width="70%">
					<INPUT type="radio" name="WANPrefer" value="CELLULAR" id="WANPrefer0" onclick="updateServiceDisplay();"><label for="WANPrefer0">Cellular</label>
					<INPUT type="radio" name="WANPrefer" value="ETHERNET" id="WANPrefer1" checked onclick="updateServiceDisplay();"><label for="WANPrefer1">Ethernet</label>
				</TD>
			</TR> 
#endif /* IWCONFIG_ENABLE_CELLULAR_CONNECT_CONTROL */
		</TABLE>
		<div id="SIM1Block">
		<TABLE width=100%>
			<TR>
				<TD width="100%" colspan="2" class="block_title">SIM 1 Configuration</TD>
			</TR>
			<TR>
			<TR>
				<TD width=30% class="column_title">SIM 1 PIN</TD>
				<TD width=70%>
					<INPUT type="password" id="pin1" name="pin1" size="8" maxlength="7" value = "<% iw_webCfgValueHandler("cellularWAN", "sim1PIN", ""); %>">
				</TD>
			</TR>
			<TR>
				<TD width=30% class="column_title">SIM 1 Band</TD>
				<TD width="70%">
					<SELECT size="1" name="Band1" id="Band1">
						<option value="GSM850MHz">GSM 850 MHz</option> 
						<option value="GSM900MHz">GSM 900 MHz</option> 
						<option value="GSM1800MHz">GSM 1800 MHz</option>
						<option value="GSM1900MHz">GSM 1900 MHz</option>
						<option value="WCDMA800MHz">WCDMA 800 MHz</option>
						<option value="WCDMA850MHz">WCDMA 850 MHz</option>
#if defined(IWCONFIG_CWAN_PH8)
						<option value="WCDMA1700MHz_AWS">WCDMA 1700 MHz (AWS)</option>
#endif /* IWCONFIG_CWAN_PH8 */
						<option value="WCDMA1900MHz">WCDMA 1900 MHz</option>
						<option value="WCDMA2100MHz">WCDMA 2100 MHz</option>
						<option value="GSM850_1900MHz">GSM 850/1900 MHz</option>
						<option value="GSM900_1800MHz">GSM 900/1800 MHz</option>
						<option value="GSM900_1900MHz">GSM 900/1900 MHz</option>
						<option value="GSM850_1800MHz">GSM 850/1800 MHz</option>
						<option value="GSM900_1800_WCDMA2100MHz">GSM 900/1800+WCDMA 2100 MHz</option>
						<option value="GSM850_1900_WCDMA850_1900MHz">GSM 850/1900+WCDMA 850/1900 MHz</option>
						<option value="GSM900_1800_WCDMA_1900_2100MHz">GSM 900/1800+WCDMA 1900/2100 MHz</option>
						<option value="AUTO">Auto</option>
					</SELECT>
				</TD>
			</TR>
			<TR>
				<TD width="30%" class="column_title">SIM 1 PPP Config</TD>
				<TD width="70%">		
					<INPUT type="radio" name="PPPConfig1" value="ENABLE" checked id="PPPConfig1_1" onclick="updatePPPConfig()">Enable
					<INPUT type="radio" name="PPPConfig1" value="DISABLE" id="PPPConfig1_0" onclick="updatePPPConfig()">Disable
				</TD>
			</TR>
			<TR>
				<TD width="30%" class="column_title">SIM 1 ATD</TD>
				<TD width="70%">
					<INPUT type="text" id="ATD1" name="ATD1" size="32" maxlength="31" value="<% iw_webCfgValueHandler("cellularWAN", "sim1ATD", ""); %>">
					(Default: *99***1#)
				</TD>
			</TR>
			<TR>
				<TD width="30%" class="column_title">SIM 1 PPP Authentication</TD>
				<TD width="70%">
					<SELECT size="1" name="PPPAuth1" id="PPPAuth1">
						<option value="AUTO">Auto</option> 
						<option value="PAP">PAP</option> 
						<option value="CHAP">CHAP</option>
					</SELECT>
				</TD>
			</TR>
			<TR>
				<TD width="30%" class="column_title">SIM 1 Username</TD>
				<TD width="70%">
					<INPUT type="text" id="PPPPAPID1" name="PPPPAPID1" size="32" maxlength="31" value="<% iw_webCfgValueHandler("cellularWAN", "sim1Username", ""); %>">
				</TD>
			</TR>
			<TR>
				<TD width="30%" class="column_title">SIM 1 Password</TD>
				<TD width="70%">
					<INPUT type="password" id="PPPPAPPass1" name="PPPPAPPass1" size="32" maxlength="31" value = "<% iw_webCfgValueHandler("cellularWAN", "sim1Password", ""); %>">
				</TD>
			</TR>
			<TR>
				<TD width="30%" class="column_title">SIM 1 APN</TD>
				<TD width="70%">
					<INPUT type="text" id="apn1" name="apn1" size="40" maxlength="39" value="<% iw_webCfgValueHandler("cellularWAN", "sim1APN", ""); %>">
				</TD>
			</TR>
			<TR>
				<TD width=30% class="column_title">SIM 1 TCP/IP compression</TD>
				<TD width=70%>
					<INPUT type="radio" name="tcpZip1" value="ENABLE" id="tcpZip1_1"><label for="tcpZip1_1">Enable</label>&nbsp;
					<INPUT type="radio" name="tcpZip1" value="DISABLE" id="tcpZip1_0" checked><label for="tcpZip1_0">Disable</label>
				</TD>
			</TR>
#if defined(IWCONFIG_ENABLE_CELLULAR_CONNECT_CONTROL)
			<TR>
				<TD width="30%" class="column_title">SIM 1 Connection control</TD>
				<TD width="70%">
					<SELECT size="1" name="ConnCtrl1" id="ConnCtrl1" onChange="updatePINGDisplay1();">
						<option value="ALWAYSON">Always On/None</option> 
						<option value="REMOTEHOSTFAIL">Remote Host Fail/Remote Host Recovered</option>
					</SELECT>
				</TD>
			</TR>
			<TR>
				<TD width=30% class="column_title">SIM 1 Ping remote host</TD>
				<TD width=70%>
					<INPUT type="text" id="RemoteHost1" name="RemoteHost1" size="40" maxlength="39" value="<% iw_webCfgValueHandler("cellularWAN", "sim1RemoteHost", ""); %>">
				<INPUT type="button" name="PingHost1" onclick="editParam1('Ping.htm')" value="Ping Test">
				</TD>
			</TR>
#endif /* IWCONFIG_ENABLE_CELLULAR_CONNECT_CONTROL */
		</TABLE>
		</div>
#if defined(IWCONFIG_CWAN_DUAL_SIM)
		<div id="SIM2Block">
		<TABLE width=100%>
			<TR>
				<TD width="100%" colspan="2" class="block_title">SIM 2 Configuration</TD>
			</TR>
			<TR>
			<TR>
				<TD width=30% class="column_title">SIM 2 PIN</TD>
				<TD width=70%>
					<INPUT type="password" id="pin2" name="pin2" size="8" maxlength="7" value = "<% iw_webCfgValueHandler("cellularWAN", "sim2PIN", ""); %>">
				</TD>
			</TR>
			<TR>
				<TD width=30% class="column_title">SIM 2 Band</TD>
				<TD width="70%">
					<SELECT size="1" name="Band2" id="Band2">
						<option value="GSM850MHz">GSM 850 MHz</option> 
						<option value="GSM900MHz">GSM 900 MHz</option> 
						<option value="GSM1800MHz">GSM 1800 MHz</option>
						<option value="GSM1900MHz">GSM 1900 MHz</option>
						<option value="WCDMA800MHz">WCDMA 800 MHz</option>
						<option value="WCDMA850MHz">WCDMA 850 MHz</option>
#if defined(IWCONFIG_CWAN_PH8)
						<option value="WCDMA1700MHz_AWS">WCDMA 1700 MHz (AWS)</option>
#endif 
						<option value="WCDMA1900MHz">WCDMA 1900 MHz</option>
						<option value="WCDMA2100MHz">WCDMA 2100 MHz</option>
						<option value="GSM850_1900MHz">GSM 850/1900 MHz</option>
						<option value="GSM900_1800MHz">GSM 900/1800 MHz</option>
						<option value="GSM900_1900MHz">GSM 900/1900 MHz</option>
						<option value="GSM850_1800MHz">GSM 850/1800 MHz</option>
						<option value="GSM900_1800_WCDMA2100MHz">GSM 900/1800+WCDMA 2100 MHz</option>
						<option value="GSM850_1900_WCDMA850_1900MHz">GSM 850/1900+WCDMA 850/1900 MHz</option>
						<option value="GSM900_1800_WCDMA_1900_2100MHz">GSM 900/1800+WCDMA 1900/2100 MHz</option>
						<option value="AUTO">Auto</option>
					</SELECT>
				</TD>
			</TR>
			<TR>
				<TD width="30%" class="column_title">SIM 2 PPP Config</TD>
				<TD width="70%">		
					<INPUT type="radio" name="PPPConfig2" value="ENABLE" checked id="PPPConfig2_1" onclick="updatePPPConfig()">Enable
					<INPUT type="radio" name="PPPConfig2" value="DISABLE" id="PPPConfig2_0" onclick="updatePPPConfig()">Disable
				</TD>
			</TR>
			<TR>
				<TD width="30%" class="column_title">SIM 2 ATD</TD>
				<TD width="70%">
					<INPUT type="text" id="ATD2" name="ATD2" size="32" maxlength="31" value="<% iw_webCfgValueHandler("cellularWAN", "sim2ATD", ""); %>">
					(Default: *99***1#)
				</TD>
			</TR>
			<TR>
				<TD width="30%" class="column_title">SIM 2 PPP Authentication</TD>
				<TD width="70%">
					<SELECT size="1" name="PPPAuth2" id="PPPAuth2">
						<option value="AUTO">Auto</option> 
						<option value="PAP">PAP</option> 
						<option value="CHAP">CHAP</option>
					</SELECT>
				</TD>
			</TR>
			<TR>
				<TD width="30%" class="column_title">SIM 2 Username</TD>
				<TD width="70%">
					<INPUT type="text" id="PPPPAPID2" name="PPPPAPID2" size="32" maxlength="31" value="<% iw_webCfgValueHandler("cellularWAN", "sim2Username", ""); %>">
				</TD>
			</TR>
			<TR>
				<TD width="30%" class="column_title">SIM 2 Password</TD>
				<TD width="70%">
					<INPUT type="password" id="PPPPAPPass2" name="PPPPAPPass2" size="32" maxlength="31" value = "<% iw_webCfgValueHandler("cellularWAN", "sim2Password", ""); %>">
				</TD>
			</TR>
			<TR>
				<TD width="30%" class="column_title">SIM 2 APN</TD>
				<TD width="70%">
					<INPUT type="text" id="apn2" name="apn2" size="40" maxlength="39" value="<% iw_webCfgValueHandler("cellularWAN", "sim2APN", ""); %>">
				</TD>
			</TR>
			<TR>
				<TD width=30% class="column_title">SIM 2 TCP/IP compression</TD>
				<TD width=70%>
					<INPUT type="radio" name="tcpZip2" value="ENABLE" id="tcpZip2_1"><label for="tcpZip2_1">Enable</label>&nbsp;
					<INPUT type="radio" name="tcpZip2" value="DISABLE" id="tcpZip2_0" checked><label for="tcpZip2_0">Disable</label>
				</TD>
			</TR>
			<TR>
#if defined(IWCONFIG_ENABLE_CELLULAR_CONNECT_CONTROL)
				<TD width="30%" class="column_title">SIM 2 Connection control</TD>
				<TD width="70%">
					<SELECT size="1" name="ConnCtrl2" id="ConnCtrl2" onChange="updatePINGDisplay2();">
						<option value="ALWAYSON">Always On/None</option> 
						<option value="REMOTEHOSTFAIL">Remote Host Fail/Remote Host Recovered</option>
					</SELECT>
				</TD>
			</TR>
			<TR>
				<TD width=30% class="column_title">SIM 2 Ping remote host</TD>
				<TD width=70%>
					<INPUT type="text" id="RemoteHost2" name="RemoteHost2" size="40" maxlength="39" value="<% iw_webCfgValueHandler("cellularWAN", "sim2RemoteHost", ""); %>">
				<INPUT type="button" name="PingHost2" onclick="editParam2('Ping.htm');" value="Ping Test">
				</TD>
			</TR>
#endif /* IWCONFIG_ENABLE_CELLULAR_CONNECT_CONTROL */
		</TABLE>
		</div>
#endif /* IWCONFIG_CWAN_DUAL_SIM */
		<TABLE width=100%>
			<TR>
				<TD colspan="1" align="left"><B>Warning: When plugging in GSM/GPRS/EDGE capable SIM card, please select related band to get better performance!</B></TD>
			</TR>
		</TABLE>
		<TABLE width=100%>
			<TR>
				<TD colspan="5">
					<BR><HR>
					<INPUT type="submit" value="Submit" name="Submit">
				</TD>
			</TR>
		</TABLE>
		<Input type="hidden" name="bkpath" value="/cellular.asp">
	</FORM>
</BODY>
</HTML>
#else
#error Please define Cellular module
#endif
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
