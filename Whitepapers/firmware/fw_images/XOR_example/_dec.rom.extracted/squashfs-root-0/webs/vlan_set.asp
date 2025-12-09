<!--This page is only for AWK-3121 and AWK-4121-->
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<HTML>
<HEAD>
 <META http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate" />
    <meta http-equiv="Pragma" content="no-cache" />
    <meta http-equiv="Expires" content="0" />
 <LINK href="nport2g.css" rel="stylesheet" type="text/css">
 <TITLE>VLAN Settings</TITLE>
 <% iw_webJSList_get(); %>
 <SCRIPT type="text/javascript">
 <!--
  var boardOpMode = "<% iw_webCfgValueHandler( "board", "operationMode", "WIRELESS_REDUNDANCY" ); %>";

  //[ ----------- Declare javascript VLANInfo class  --------------------
  function VLANInfo(section, port, pvid, vlanTaggedAry, tagEnable){
   this.section = section;
   this.port = port; //: LAN, WLAN, WDS
   this.pvid = pvid;
   this.taggedAry = vlanTaggedAry;
   this.tagEnable = tagEnable;
  }
  //] ----------- Declare javascript VLANInfo class  --------------------
  function getVlanTaggedStr(vlanTaggedAry){
   var i = 0;
   var vlanTagged = "";
   for( i = 0 ; i < vlanTaggedAry.length ; i++){
    var tagged = vlanTaggedAry[i];
    if(tagged == 0){ continue; }
    if(vlanTagged.length > 0 ){
     vlanTagged += ",";
    }
    vlanTagged += tagged;
   }
   return vlanTagged;
  }

  function isValidValue( item ,value){
   var pvid = value;
   if(isNaN(pvid)){
    alert(item + " must be an integer from 1 ~ 4094.");
    return false;
   }
   if( pvid <= 0 || pvid > 4094 ){
    alert(item + " must be an integer from 1 ~ 4094.");
    return false;
   }
   return true;
  }

  function isValidVID(obj, vlanInfo){
   var pvid = obj.value;
   pvid = trim(pvid);
   if(pvid==""){
    alert("PVID of " + vlanInfo.port + " must be an integer from 1 ~ 4094.");
    obj.value = "1";
    obj.focus();
    return false;
   }
   if( isValidValue("PVID of " + vlanInfo.port, pvid) == false){
    obj.value = "";
    obj.focus();
    return false;
   }
   return true;
  }

  function isValidTagged(pvidObj, obj, vlanInfo){
   var taggedStr = obj.value;
   var taggedAry = taggedStr.split(',');
   var tagCounter = 0;
   for(var i = 0 ; i < taggedAry.length ; i++){
    var tagged = taggedAry[i];
    if( tagged.length == 0 )
     continue;
    if(isValidValue("VLAN Tagged of " + vlanInfo.port,tagged)==false){
     taggedAry[i] = 0;
     obj.value = getVlanTaggedStr(taggedAry);
     obj.focus();
     return false;
    }

    if( pvidObj.value == tagged )
    {
     alert( "PVID of " + vlanInfo.port + " should not be included in VLAN tagged list." );
     pvidObj.focus();
     return false;
    }

    for( var j = 0; j < taggedAry.length ; j++ )
    {
     if( i != j && tagged == taggedAry[j] )
     {
      alert( "Duplicated VLAN tag : " + tagged + " in VLAN tagged list of " + vlanInfo.port + ".");
      obj.focus();
      return false;
     }
    }
    tagCounter++;
   }
   if( tagCounter > 32 )
   {
    alert( "Only 32 tagged VLANs are allowed in VLAN tagged list of " + vlanInfo.port + "." );
    obj.focus();
    return false;
   }
   return true;
  }

  function insertVLANRecord(vlanInfo, color){
   var vlanSettingsTable = document.getElementById('vlanSettingsTable');
   var newRow = vlanSettingsTable.insertRow(vlanSettingsTable.rows.length);
         newRow.id = newRow.uniqueID;
   //: Port
   statusCell = newRow.insertCell(0);
   statusCell.innerHTML = "<td class='column_title' style='"+color+"'>"+vlanInfo.port+"<\/td>";
   //: PVID
   ssidCell = newRow.insertCell(1);
   var pvidHtml = "";
   pvidHtml+="<td class='column_title' style='"+color+"'>";
   pvidHtml+="<input  type='text' id='"+vlanInfo.section+"_pvid' name='"+vlanInfo.section+"_pvid' size='16'  maxlength='5' value='"+vlanInfo.pvid+"' onchange='javascript:isValidVID(this);' " + ( (vlanInfo.section == "wlan2VLAN" && boardOpMode == "WIRELESS_REDUNDANCY") ? "disabled=\"disabled\"" : "") + " \/>";
   pvidHtml+="<\/td>";
   ssidCell.innerHTML = pvidHtml;

   //: VLAN Tagged
   opModeCell = newRow.insertCell(2);
   var vlanTaggedHtml = "";
   var vlanTaggedStr = getVlanTaggedStr(vlanInfo.taggedAry);
   vlanTaggedHtml += "<td class='column_title' style='"+color+"'>";
   vlanTaggedHtml+="<input type='text' id='"+vlanInfo.section+"_vlanTag' name='"+vlanInfo.section+"_vlanTag' size='100'  maxlength='200' value='"+vlanTaggedStr+"' onchange='javascript:isValidTagged(this);' " + (vlanInfo.tagEnable == false | (vlanInfo.section == "wlan2VLAN" && boardOpMode == "WIRELESS_REDUNDANCY") ? "disabled=\"disabled\"" : "") + " \/>";
   vlanTaggedHtml += "<\/td>";
   opModeCell.innerHTML = vlanTaggedHtml;
  }
  var vlanArray = <% iw_webGetVLANInfos();%>


  function editPermission()
  {
   var form = document.vlan_set, i, j = <% iw_websCheckPermission(); %>;
   if(j)
   {
    for(i = 0; i < form.length; i++)
     form.elements[i].disabled = true;
   }
  }


  function iw_onLoad(){
   var color;
   for(var i = 0 ; i < vlanArray.length; i ++){
    var vlanInfo = vlanArray[i];
    if(i%2==0){
     color = "background-color:beige;";
    }
    else{
     color = "background-color:azure;";
    }

    insertVLANRecord( vlanInfo, color);
   }
   if(vlanArray.length <=0){
    document.all.managementVID.disabled = true;
    document.all.Submit.disabled = true;
   }

                 editPermission();

   top.toplogo.location.reload();
  }

  function iw_onSubmit(){
   for(var i = 0 ; i < vlanArray.length; i ++){
    var vlanInfo = vlanArray[i];
    var pvid = document.getElementById(vlanInfo.section+"_pvid");
    var vlanTagged = document.getElementById(vlanInfo.section+"_vlanTag");

    if(isValidVID(pvid, vlanInfo)==false){
     return false;;
    }

    if ( ! isValidValue ("Management VLAN ID", $('input[name=managementVID]').val())) {
     return false;
    }

    if(isValidTagged(pvid, vlanTagged, vlanInfo)==false){
     return false;
    }
   }
   return true;
  }
    -->
    </Script>
</HEAD>
<BODY onload="iw_onLoad();">
 <H2><% iw_webSysDescHandler("VLANSettingsTree", "", "VLAN Settings"); %> <% iw_webGet_SupportOpmode_VLAN(); %>&nbsp;&nbsp;<% iw_websGetErrorString(); %></H2>
  <FORM name="vlan_set" method="post" action="/forms/web_setVLAN" onSubmit="return iw_onSubmit();" />
  <table width="100%">
   <tr>
    <td width="30%" class="column_title"><% iw_webCfgDescHandler("managementVID", "vid", "Management VLAN ID"); %>:</td>
    <td width="70%">
     <input type='text' name='managementVID' size='16' maxlength='5' value='<% iw_webGetVLANManagementVID(); %>' onchange='javascript:isValidVID(this);'/>
    </td>
   </tr>
  </table>

  <TABLE ID="vlanSettingsTable" width="100%">
   <tr>
    <td class="block_title" width="15%">Port</td>
    <td class="block_title" width="10%"><% iw_webCfgDescHandler("wlan1VLAN", "pvid", "PVID"); %></td>
    <td class="block_title" width="50%"><% iw_webCfgDescHandler("wlan1VLAN", "vlanTag0", "VLAN Tagged"); %>&nbsp;(Use commas to separate VLAN tags)</td>
   </tr>
  </TABLE>

  <table width="100%">
  <tr>
   <td colspan="2">
    <hr />
    <span>
     <input type="submit" value="Submit" name="Submit" />
     <input type="hidden" name="bkpath" value="/vlan_set.asp" />
    </span>
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
