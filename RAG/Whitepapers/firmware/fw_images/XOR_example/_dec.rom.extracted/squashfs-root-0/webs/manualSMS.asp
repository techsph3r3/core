#if defined(IWCONFIG_CWAN)
<HTML>
<HEAD>
	<LINK href="nport2g.css" rel="stylesheet" type="text/css">
	<TITLE>Tool - Manual SMS</TITLE>
	<% iw_webJSList_get(); %>
	<SCRIPT language="JavaScript">
		var maxChr 	 = 160;
		var nowChr	 = 0;
		var testText = "";
		var data 	 = <% iw_webGetManualSMSToJSON(); %>;
		

		function sms_reload() {
			document.location.reload();
		}

		$(document).ready( function() {
			_loadData(data);
			iw_changeStateOnLoad(top);	
			formCheck();
		});

		function _loadData(data)
		{
			var obj = jQuery.parseJSON(data);
			var row;
			var sms_no, time, phone, stat;
			
				$("#manual_sms_status_table").empty();
			for ( var i = 0; i < obj.contents.length; ++i ) {
				sms_no = obj.contents[i].idx;
				time   = obj.contents[i].time;
				phone  = obj.contents[i].phone;
				stat   = obj.contents[i].stat;
				$("#manual_sms_status_table").append("<TR><TD width=%5>" + sms_no + "</TD><TD width=%20>" + time + "</TD><TD width=%20>" + phone + "</TD><TD>" + stat + "</TD></TR>");
				if (stat == "WAITING" || stat == "SENDING")
					setTimeout("sms_reload()", 3000);
			}
		}
		
		function formCheck ()
		{
			$('form').bind("submit", function() {
				if ( ! CheckValue() ) {
					return false; // form will not be executed
				}
				return true;
			});
		}
		
		function initialInfo(){
			var remainChr;
			remainChr = maxChr - nowChr;
			document.getElementById("info").innerHTML="(Max. " + maxChr + " characters)" + "<BR>Characters remaining: " + remainChr;
		}

		function count(field, value){
			var tmpChr, remainChr, i;
			var specialChr = "^{}\\~|[]\n";
			var rc;
			
			tmpChr = value.length;
					
			nowChr = tmpChr;
			for(i=0; i<tmpChr; i++){			
				if(specialChr.indexOf(value.charAt(i)) >= 0){
					nowChr++;
				}
			}

			if(nowChr > maxChr){
				field.value=field.value.substring(0,maxChr - (nowChr - tmpChr));
				alert("Warning: The length is too long. (max=" + maxChr + ")");
			}
			
			if(nowChr >= maxChr)
				remainChr = 0;
			else
				remainChr = maxChr - tmpChr - (nowChr - tmpChr);
				
			document.getElementById("info").innerHTML="(Max. " + maxChr + " characters)" + "<BR>Characters remaining: " + remainChr;
		}

		function CheckValue(){
			var tmp, tmpLen, nowLen, i;
			var specialChr = "^{}\\~|[]";
			
			tmp = $('input[name=Phone]')[0];
			if( tmp.value.length == 0){
				alert("Phone number is empty.");
				tmp.focus();
				return false;
			}
			
#if defined(IWCONFIG_G3470)
			if( !isPhoneNumber_without_plus(tmp.value) ){
				alert("Invalid input: \"Phone number\" (" + tmp.value + ").\nPlease enter 0~9 and \'+\' does not support.");
#else
			if( !isPhoneNumber(tmp.value) ){
				alert("Invalid input: \"Phone number\" (" + tmp.value + ")");
#endif
				tmp.focus();
				return false;
			}

			tmp = document.getElementById("SMSWebContent");
			tmpLen = tmp.value.length;
			if(tmpLen == 0){
				alert("SMS content is empty.");
				tmp.focus();
				return false;
			}
			
			nowLen = tmpLen;
			for(i=0; i<tmpLen; i++){
				if(specialChr.indexOf(tmp.value.charAt(i)) >= 0){
					nowLen++;
				}
			}
			
			if(nowLen > maxChr){
				alert("Warning: The length is too long. (max=" + maxChr + ")");
				tmp.focus();
				return false;
			}	
	
			document.getElementById("SMSContent").value = document.getElementById("SMSWebContent").value;
			return true;
		}

#if defined(IWCONFIG_CYBER_SECURITY_L1) 
		function editPermission()
		{
			var form = document.manual_sms, i, j = <% iw_websCheckPermission(); %>; 
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
	<H2><% iw_webSysDescHandler("ManualSMSTree", "", "Manual SMS"); %><% iw_websGetErrorString(); %></H2>
	<FORM name="manual_sms" method="POST" action="/forms/webSetSystemSendSMS">
		<TABLE width="100%">
			<TR>
				<TD width="100%" colspan="2" class="block_title">Manual Sending SMS Settings</TD>
			</TR>
			<TR>
				<TD width="25%" class="column_title">Phone number</TD>
				<TD width="75%">
					<input name="Phone" maxlength="15" size="18"/>
                </TD>
			</TR>
			<TR>
				<TD width="25%" class="column_title">SMS content<DIV id="info"></DIV>
					<SCRIPT language="JavaScript">initialInfo();</SCRIPT>
				</TD>
				<TD>
					<TEXTAREA id="SMSWebContent" name="SMSWebContent" rows="4" cols="70" maxlength="160" WRAP=PHYSICAL style="overflow-x:hidden" onChange="count(this, this.value)" onKeyup="count(this, this.value)"></TEXTAREA>
				</TD>
			</TR>
			<TR>
				<TD width="25%"> </TD>
				<TD align="left">
					<B>Note: Special characters such as '^', '\', '|', '~', '[', ']', '{', and '}' require two bytes.</B>
				</TD>
			</TR>	
		</TABLE>
		<TR><INPUT type="submit" name="Submit" value="Submit"></TR>
		<Input type="hidden" name="bkpath" value="manualSMS.asp">
		<Input type="hidden" id="SMSContent"name="SMSContent">
	</FORM>
	<TABLE width="100%" id="manual_sms_status_table">
		<TR>
			<TD width="100%" colspan="4" class="block_title">Sending Result</TD>
		</TR>
		<TR>
			<TD width="5%" class="column_title">No.</TD>
			<TD width="20%" class="column_title">Time</TD>
			<TD width="20%" class="column_title">To</TD>
			<TD class="column_title">Result</TD>
		<TR>
	</TABLE>
</BODY>
</HTML>
#endif /* IWCONFIG_CWAN */
<script type="text/javascript">
	$(document).ready(function () {
		var isEditPermission = !<% iw_websCheckPermission(); %>;
		if (isEditPermission == 0) {
			$(":input").attr('disabled','disabled');
		}
	});
</script>
