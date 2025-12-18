<HTML>
<HEAD>
 <META http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
 <META HTTP-EQUIV="Pragma" CONTENT="no-cache">
 <LINK href="nport2g.css" rel=stylesheet type=text/css>
 <TITLE><% iw_webSysDescHandler("WACSettings", "", "WAC Settings"); %></TITLE>
 <% iw_webJSList_get(); %>
 <script type="text/javascript">
       <!--
       var isAP = <% iw_webGetOPmode(); %>;

        function isWACAllowed()
        {
            var formItem, i;

            // For wireless_wac form
            formItem = document.wireless_wac;
            if( isAP == 0 )
            {
                for( i = 0; i < formItem.elements.length; i++ )
                {
                    formItem.elements[i].disabled = true;
                }
                return false;
            }else {
                for( i = 0; i < formItem.elements.length; i++ )
                {
                    formItem.elements[i].disabled = false;
                }
                return true;
            }
        }

        function iw_onWacEnableChange()
        {
            if( "ENABLE" == document.getElementById("iw_ACsettings_managedEnable").value ){
                if( false == isWACAllowed() ){
                    document.getElementById("iw_ACsettings_managedEnable").value = "DISABLE";
                    iw_selectSet(document.wireless_wac.iw_ACsettings_managedEnable, "DISABLE");
                    return;
                }
                document.getElementById("wacArguments").style.display = "";
            } else {
                document.getElementById("wacArguments").style.display = "none";
            }
        }

        function CheckValue(form)
        {
            if( "DISABLE" == document.getElementById("iw_ACsettings_managedEnable").value ){
                return true;
            }

            if( document.getElementById("iw_primaryAC").value == ""){
                alert("<% iw_webCfgDescHandler("primaryAC", "serverIP", ""); %> cannot be empty.");
                return false;
            }
            else {
                if( !verifyIP( document.getElementById("iw_primaryAC"), "<% iw_webCfgDescHandler("primaryAC", "serverIP", ""); %>") )
                {
                    return false;
                }
            }

            if( document.getElementById("iw_backupAC").value == ""){
                alert("<% iw_webCfgDescHandler("primaryAC", "server2IP", ""); %> is empty. Don't have WAC redundancy.");
            }
            else {
                if( !verifyIP( document.getElementById("iw_backupAC"), "<% iw_webCfgDescHandler("primaryAC", "server2IP", ""); %>") )
                {
                    return false;
                }
            }

            document.getElementById("iw_ACsettingsroamingDomain").value = document.getElementById("iw_rd0").value+":"+
            document.getElementById("iw_rd1").value +":"+document.getElementById("iw_rd2").value;

            if(!isRoamDomainaddress(document.getElementById("iw_ACsettingsroamingDomain").value)){
                document.getElementById("iw_rd0").focus();
                return false;
            }
            document.getElementById("iw_ACsettingsroamingDomain").value = RoamDomainaddress(document.getElementById("iw_ACsettingsroamingDomain").value);

            if (document.getElementById("iw_primaryAC").value == document.getElementById("iw_backupAC").value){
                alert("Warning: Primary WAC Address = Backup WAC Address.");
                return false;
            }
        }


        function editPermission()
        {
                var form = document.wireless_wac, i, j = <% iw_websCheckPermission(); %>;
                if(j)
                {
                        for(i = 0; i < form.length; i++)
                                form.elements[i].disabled = true;
                }
        }


        function iw_ChangeOnLoad()
        {
      iw_selectSet(document.wireless_wac.iw_ACsettings_managedEnable, "<% iw_webCfgValueHandler("ACsettings", "managedEnable"  , "DISABLE");  %>");
      iw_onWacEnableChange();


                editPermission();


      top.toplogo.location.reload();
            if(0 == isAP)
      {
                document.getElementById("iw_ACsettings_managedEnable").disabled = true;
       document.getElementByName("Submit").disabled = true;
       document.getElementById("wacArguments").style.display = "none";
      }
        }
        -->
        </script>
</HEAD>
<BODY onLoad="iw_ChangeOnLoad();">
 <H2><% iw_webSysDescHandler("WACSettings", "", "WAC Settings"); %> (AP mode only) <% iw_websGetErrorString(); %></H2>
 <FORM name="wireless_wac" method="post" action="/forms/iw_webSetParameters" onSubmit="return CheckValue(this)">
    <table width="100%">
 <tr>
  <td width="30%" class="column_title"><% iw_webCfgDescHandler("ACsettings", "managedEnable", "WAC enable"); %></td>
  <td width="70%">
   <select size="1" id="iw_ACsettings_managedEnable" name="iw_ACsettings_managedEnable" onChange="iw_onWacEnableChange();">
   <option value="ENABLE">Enable</option>
   <option value="DISABLE">Disable</option>
   </select>
  </td>
 </tr>
    </table>
    <div id="wacArguments">
    <table >
 <tr>
  <td width=30% class="column_title"><% iw_webCfgDescHandler("primaryAC", "serverIP", ""); %></td>
  <td width=70%>
   <input type="text" id="iw_primaryAC" name="iw_primaryAC_serverIP" size="21" maxlength="15" value="<% iw_webCfgValueHandler("primaryAC", "serverIP", ""); %>" />&nbsp;&nbsp;
  </td>
 </tr>
 <tr>
  <td width=30% class="column_title"><% iw_webCfgDescHandler("primaryAC", "server2IP", ""); %></td>
  <td width=70%>
   <input type="text" id="iw_backupAC" name="iw_primaryAC_server2IP" size="21" maxlength="15" value="<% iw_webCfgValueHandler("primaryAC", "server2IP", ""); %>" />&nbsp;&nbsp;
  </td>
 </tr>
 <tr>
  <td width=30% class="column_title">
   <% iw_webCfgDescHandler("ACsettings", "roamingDomain", ""); %>
  </td>
  <td width=70%>FF:90:E8:<%iw_webGetRoamDomain(); %></td>
 </tr>
    </table>
    </div>
 <table>
  <tr>
   <td colspan="2">
   <hr>
   <input type="submit" value="Submit" name="Submit">
   <input type="hidden" name="iw_ACsettings_roamingDomain" id="iw_ACsettingsroamingDomain" />
   <Input type="hidden" name="bkpath" value="/wireless_wac.asp" />
  </td>
  </tr>
 </table>
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
