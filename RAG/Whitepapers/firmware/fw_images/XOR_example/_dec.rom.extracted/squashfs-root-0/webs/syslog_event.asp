<HTML>
<HEAD>
 <META http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
    <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate" />
    <meta http-equiv="Pragma" content="no-cache" />
    <meta http-equiv="Expires" content="0" />
 <LINK href="nport2g.css" rel="stylesheet" type="text/css">
 <TITLE><% iw_webSysDescHandler("SysLogEventTree", "", "Syslog Event Types"); %></TITLE>
 <% iw_webJSList_get(); %>
 <script type="text/javascript">
 <!--
  function CheckValue(form)
  {
   var i, j=0;
var ena = new Array(document.syslog_event.iw_sysLog_system, document.syslog_event.iw_sysLog_network, document.syslog_event.iw_sysLog_config,
document.syslog_event.iw_sysLog_power

 , document.syslog_event.iw_sysLog_din


 , document.syslog_event.iw_sysLog_rssiReport




  );

   /* Get operation mode */
   var opMode = new String("<% iw_webCfgValueHandler( "wlanDevWIFI0", "operationMode", "AP" ); %>");
   /* If "AP" | "MASTER" isAP = true " */
            var isAP = (opMode == "AP" || opMode == "MASTER") ? true : false;

   if( isAP && document.syslog_event.MM6.checked == true )
   {
    alert("When Operation Mode is set to AP mode, it is not allowed to enable RSSI report events at the same time.");
    /* Set check is disable */
    iw_checkedSet(document.syslog_event.MM6, "<% "DISABLE" ;%>");
    return false;
   }

   for(i = 0; i < form.length; i++)
   {
    if(form.elements[i].value.length > 0 )
    {
     if(form.elements[i].name.match("MM"))
     {
      if(form.elements[i].checked)
       ena[j].value = "ENABLE";
      else
       ena[j].value = "DISABLE";
      j+=1;
     }
    }
   }
  }
        function iw_syslog_eventOnLoad()
        {
             iw_checkedSet(document.syslog_event.MM1, "<% iw_webCfgValueHandler("sysLog", "system", "DISABLE");%>");
             iw_checkedSet(document.syslog_event.MM2, "<% iw_webCfgValueHandler("sysLog", "network", "DISABLE");%>");
    iw_checkedSet(document.syslog_event.MM3, "<% iw_webCfgValueHandler("sysLog", "config", "DISABLE");%>");
             iw_checkedSet(document.syslog_event.MM4, "<% iw_webCfgValueHandler("sysLog", "power", "DISABLE");%>");

             iw_checkedSet(document.syslog_event.MM5, "<% iw_webCfgValueHandler("sysLog", "din", "DISABLE");%>");


   iw_checkedSet(document.syslog_event.MM6, "<% iw_webCfgValueHandler("sysLog", "rssiReport", "DISABLE");%>");




  }


  function editPermission()
  {
   var form = document.syslog_event, i, j = <% iw_websCheckPermission(); %>;
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
  function selall()
        {
            for(i = 0; i < document.syslog_event.length; i++)
            {
                if(document.syslog_event.elements[i].type == "checkbox" &&
                    document.syslog_event.elements[i].id.match(/^MM[a-zA-Z0-9]*/))
                {
                    document.syslog_event.elements[i].checked = document.syslog_event.SelAll.checked;
                }
            }
        }
    -->
    </Script>
</HEAD>
<BODY onLoad="iw_syslog_eventOnLoad();iw_ChangeOnLoad();">
 <H2><% iw_webSysDescHandler("SysLogEventTree", "", "Syslog Event Types"); %> <% iw_websGetErrorString(); %></H2>
 <FORM name="syslog_event" method="POST" action="/forms/iw_webSetParameters" onSubmit="return CheckValue(this)">
  <TABLE width="100%">
   <TR>

    <TD width="10%" align="left" class="block_title" >Event Type</TD>
    <TD width="10%" align="left" class="block_title" ><input type="checkbox" id="SelAll" onclick="selall();"/>Enable Logging</TD>
   </TR>
   <TR>
    <TD width="10%" align="left" class="column_title" style="background-color: beige;"><% iw_webCfgDescHandler("sysLog", "system", "System-related events"); %></TD>
    <TD width="10%" align="left" class="column_text_no_bg" style="background-color: beige;"><INPUT type="checkbox" id="MM1" name="MM1" value="DISABLE">Active</TD>
   </TR>
   <TR>
    <TD width="10%" align="left" class="column_title" style="background-color: azure;"><% iw_webCfgDescHandler("sysLog", "network", "Network-related events"); %></TD>
    <TD width="10%" align="left" class="column_text_no_bg" style="background-color: azure;"><INPUT type="checkbox" id="MM2" name="MM2" value="DISABLE">Active</TD>
   </TR>
   <TR>
    <TD width="10%" align="left" class="column_title" style="background-color: beige;"><% iw_webCfgDescHandler("sysLog", "config", "Config-related events"); %></TD>
    <TD width="10%" align="left" class="column_text_no_bg" style="background-color: beige;"><INPUT type="checkbox" id="MM3" name="MM3" value="DISABLE">Active</TD>
   </TR>
   <TR>
    <TD width="10%" align="left" class="column_title" style="background-color: azure;"><% iw_webCfgDescHandler("sysLog", "power", "Power events"); %></TD>
    <TD width="10%" align="left" class="column_text_no_bg" style="background-color: azure;"><INPUT type="checkbox" id="MM4" name="MM4" value="DISABLE">Active</TD>
   </TR>

   <TR>
    <TD width="10%" align="left" class="column_title" style="background-color: beige;"><% iw_webCfgDescHandler("sysLog", "din", "DI events"); %></TD>
    <TD width="10%" align="left" class="column_text_no_bg" style="background-color: beige;"><INPUT type="checkbox" id="MM5" name="MM5" value="DISABLE">Active</TD>
   </TR>


            <TR>
    <TD align="left" class="column_title" style="background-color: azure;"><% iw_webCfgDescHandler("sysLog", "rssiReport", "RSSI report events"); %></TD>
    <TD align="left" class="column_text_no_bg" style="background-color: azure;"><INPUT type="checkbox" id="MM6" name="MM6" value="DISABLE">Active</TD>
   </TR>







  </TABLE><hr>
   <INPUT type="submit" value="Submit" name="Submit">
<INPUT type="hidden" name="iw_sysLog_system" value="DISABLE">
<INPUT type="hidden" name="iw_sysLog_network" value="DISABLE">
<INPUT type="hidden" name="iw_sysLog_config" value="DISABLE">
<INPUT type="hidden" name="iw_sysLog_power" value="DISABLE">

<INPUT type="hidden" name="iw_sysLog_din" value="DISABLE">


<INPUT type="hidden" name="iw_sysLog_rssiReport" value="DISABLE">





  <Input type="hidden" name="bkpath" value="/syslog_event.asp">
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
