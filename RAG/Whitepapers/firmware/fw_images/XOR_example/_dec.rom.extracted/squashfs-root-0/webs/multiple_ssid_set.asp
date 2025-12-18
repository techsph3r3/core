<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%
 if ( iw_isset(devIndex) == 0 )
 {
  devIndex = 1;
 }
%>
<html>
 <head>
  <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
  <link href="nport2g.css" rel=stylesheet type=text/css>
  <title><% iw_webSysDescHandler( "BasicWirelessSettingsTree", "", "Basic Wireless Settings" ); %> (Multiple SSID)</title>
  <% iw_webJSList_get(); %>
  <script type="text/javascript">
  <!--
   var maxSSIDCount = <% iw_webGetMaxVapCount(); %>+1 ;
   var vapAry = <% iw_webGetVapBasicInfo(devIndex); %> ;



   var currVapCount = vapAry.length;
   var addSSIDAction = 1;
   var deleteSSIDAction = 2;

   function insertVapRecord(vapIndex, status, ssid, opMode, color){
    var ssidTable = document.getElementById('ssidTable');
    var newRow = ssidTable.insertRow(ssidTable.rows.length);

          newRow.id = newRow.uniqueID;

    //: Status
    newCell = newRow.insertCell(0);
    newCell.className = "column_title";
    newCell.style.backgroundColor = color;
    newCell.innerHTML = status;

    //: ssid
    newCell = newRow.insertCell(1);
    newCell.className = "column_title";
    newCell.style.backgroundColor = color;
    newCell.innerHTML = ssid;

    //: opMode
    newCell = newRow.insertCell(2);
    newCell.className = "column_title";
    newCell.style.backgroundColor = color;
    newCell.innerHTML = iwStrMap(opMode);

    //: action
    newCell = newRow.insertCell(3);
    actionHTML = "	<input type=\"button\" value=\"Edit\" onClick=\"location.href='wireless_basic.asp?devIndex=<% write(devIndex); %>&amp;vapIndex="+(vapIndex)+"'\" \/>";
    if(vapIndex>0){
     actionHTML += "	<input type=\"button\" value=\"Delete\" onClick=\"javascript:deleteSSID("+vapIndex+",'');\" \/>";
    }
    newCell.className = "column_title";
    newCell.style.backgroundColor = color;
    newCell.innerHTML = actionHTML;
   }


   function editPermission()
   {
    var form = document.multiple_ssid_form, i, j = <% iw_websCheckPermission(); %>;
    if(j)
    {
     for(i = 0; i < form.length; i++)
      form.elements[i].disabled = true;
    }
   }


   function iw_onLoad(){
    var color;
    var i ;
    for ( i = 0 ; i < vapAry.length; i++)
    {
     vap = vapAry[i];
     //: vap[0] --> vapIndex
     //: vap[1] --> status
     //: vap[2] --> ssid
     //: vap[3] --> opMode
     if(i%2==0){
      color = "beige";
     }
     else{
      color = "azure";
     }

     insertVapRecord(vap[0], vap[1], vap[2], vap[3], color);
    }

    if(currVapCount>=maxSSIDCount){
     document.getElementById('addSSIDBt').disabled = true;
    }


                  editPermission();


    top.toplogo.location.reload();
   }

   function cancelAddSSID(){
    var ssidTable = document.getElementById('ssidTable');
    ssidTable.deleteRow(ssidTable.rows.length-1);
    document.getElementById('addSSIDBt').disabled = false;
   }

   function deleteSSID(vapIndex, ssid){
    document.multiple_ssid_form.vapIndex.value = vapIndex;
    document.multiple_ssid_form.ssid.value = ssid;
    document.multiple_ssid_form.handle.value = deleteSSIDAction;
    document.multiple_ssid_form.submit();
   }

   function saveNewSSID(){
    var newSSID = document.getElementById('new_ssid').value;
    //: Need to check max VAP count
    //: check duplicate ssid
    newSSID = trim(newSSID);
    if( newSSID.length == 0 )
    {
     alert("SSID cannot be empty.");
     document.getElementById('new_ssid').focus();
     return false;
    }

    if(! isAsciiString(newSSID))
    {
     alert("Invalid SSID: ASCII only");
     document.getElementById('new_ssid').focus();
     return false;
    }

    //: double check vap count!		
    if(currVapCount>=maxSSIDCount){
     alert("Mutlipe SSID could not be larger than " + maxSSIDCount);
     return false;
    }

    // Check duplicated ssid
    for( var i = 0; i < vapAry.length; i++ )
    {
     if( vapAry[i][1] == "Active" && vapAry[i][2] == newSSID )
     {
      alert( "Duplicated SSID : " + newSSID + "." );
      return false;
     }
    }

    document.multiple_ssid_form.ssid.value = newSSID;
    document.multiple_ssid_form.handle.value = addSSIDAction;

    document.multiple_ssid_form.submit();
   }

   function addSSID()
   {
    var ssidTable = document.getElementById('ssidTable');
    var newRow = ssidTable.insertRow(ssidTable.rows.length);
    var inputElement;

    if(vapAry.length%2==0)
    {
      color = "beige";
    }else{
      color = "azure";
    }
          newRow.id = newRow.uniqueID;
    //: Status
    newCell = newRow.insertCell(0);
    newCell.className = "column_title";
    newCell.style.backgroundColor = color;
    newCell.innerHTML = "Inactive";
    //: ssid
    newCell = newRow.insertCell(1);
    newCell.className = "column_title";
    newCell.style.backgroundColor = color;
    //newCell.innerHTML = "<input type=\"text\" id=\"new_ssid\" size=\"38\" maxlength=\"32\" value =\"\" \/>";
    inputElement = document.createElement('input');
    inputElement.type = "text";
    inputElement.id = "new_ssid";
    inputElement.size = 38;
    inputElement.maxlength = 32;
    inputElement.value = ""
    inputElement.onkeydown = function(event){ if(event.keyCode == 13){document.getElementById('SaveBtn').click()} };
    newCell.appendChild(inputElement);
    inputElement.focus();

    //: opMode
    newCell = newRow.insertCell(2);
    newCell.className = "column_title";
    newCell.style.backgroundColor = color;
    newCell.innerHTML = "AP";
    //: action
    newCell = newRow.insertCell(3);
    newCell.className = "column_title";
    newCell.style.backgroundColor = color;
    actionHTML = "	<input type=\"button\" id=\"SaveBtn\" value=\"Save\" onClick=\"javascript:saveNewSSID();\" \/>";
    actionHTML += "	<input type=\"button\" value=\"Cancel\" onClick=\"javascript:cancelAddSSID();\" \/>";
    newCell.innerHTML =actionHTML;
    document.getElementById('addSSIDBt').disabled = true;
   }

  -->
  </script>
 </head>

 <body onLoad="iw_onLoad();">
  <h2><% iw_webSysDescHandler( "BasicWirelessSettingsTree", "", "Basic Wireless Settings" ); %> (Multiple SSID)&nbsp;&nbsp;<% iw_websGetErrorString(); %></h2><br />
  <form name="multiple_ssid_form" method="post" action="/forms/web_setMultipleSSID">
  <table ID="ssidTable" width="100%">
   <tr>
    <td class="block_title" width="100">Status</td>
    <td class="block_title" width="300">SSID</td>
    <td class="block_title" width="150">Operation Mode</td>
    <td class="block_title" width="150">Action</td>
   </tr>

  </table>

  <table width="100%">
   <tr>
    <td colspan="2">
     <hr />
     <span>
      <input type="button" id="addSSIDBt" value="Add SSID" name="Add SSID" onClick="javascript:addSSID();document.getElementById('new_ssid').focus;" />
     </span>
    </td>
   </tr>
  </table>

   <input type="hidden" name="devIndex" value="<% write(devIndex); %>" />
   <input type="hidden" name="vapIndex" value="" />
   <input type="hidden" name="ssid" value="" />
   <input type="hidden" name="handle" value="" />
   <input type="hidden" name="bkpath" value="/multiple_ssid_set.asp?devIndex=<% write(devIndex); %>" />
  </form>

 </body>
</html>
<script language="JavaScript" src="js/jquery-1.5.2.min.js"></script>
<script type="text/javascript">
	$(document).ready(function () {
		var isEditPermission = !<% iw_websCheckPermission(); %>;
		if (isEditPermission == 0) {
			$(":input").attr('disabled','disabled');
		}
	});
</script>
