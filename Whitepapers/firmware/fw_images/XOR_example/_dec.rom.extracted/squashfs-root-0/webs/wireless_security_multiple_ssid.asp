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
    <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate" />
    <meta http-equiv="Pragma" content="no-cache" />
    <meta http-equiv="Expires" content="0" />
 <link href="nport2g.css" rel="stylesheet" type="text/css">
 <TITLE><% iw_webSysDescHandler("SecuritySettingsTree", "", "Security Settings"); %> (Multiple SSID)</TITLE>
 <% iw_webJSList_get(); %>
 <script type="text/javascript">
 <!--
  var vapAry = <% iw_webGetVapSecurityInfo(devIndex); %> ;

  function insertVapRecord(vapIndex, status, ssid, opMode, authType, color){
   var ssidTable = document.getElementById("ssidTable");
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

   //: authType
   newCell = newRow.insertCell(3);
   newCell.className = "column_title";
   newCell.style.backgroundColor = color;
   newCell.innerHTML = authType;

   //: action
   newCell = newRow.insertCell(4);
   newCell.className = "column_title";
   newCell.style.backgroundColor = color;
   newCell.innerHTML = "<input type=\"button\" value=\"Edit\" onClick=\"location.href='wireless_security.asp?index=<% write(devIndex); %>&amp;vapIndex="+vapIndex+"'\" />";
  }

  function iw_onLoad(){
   var i ;
   var color;
   for ( i = 0 ; i < vapAry.length; i++)
   {
    vap = vapAry[i];
    //: vap[0] --> vapIndex
    //: vap[1] --> status
    //: vap[2] --> ssid
    //: vap[3] --> opMode
    //: vap[4] --> authType
    if(i%2==0){
     color = "beige";
    }
    else{
     color = "azure";
    }

    insertVapRecord(vap[0], vap[1], vap[2], vap[3], vap[4], color);
   }

   top.toplogo.location.reload();

  }
    -->
    </script>
</head>
<body onload="iw_onLoad();">
 <h2><% iw_webSysDescHandler("SecuritySettingsTree", "", "Security Settings"); %>

          (Multiple SSID)

          &nbsp;&nbsp;<% iw_websGetErrorString(); %></h2><br />
 <table ID="ssidTable" width="100%">
  <tr>
   <td class="block_title" width="100">Status</td>
   <td class="block_title" width="300">SSID</td>
   <td class="block_title" width="150">Operation Mode</td>
   <td class="block_title" width="150">Security Mode</td>
   <td class="block_title" width="100">Action</td>
  </tr>
 </table>

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
