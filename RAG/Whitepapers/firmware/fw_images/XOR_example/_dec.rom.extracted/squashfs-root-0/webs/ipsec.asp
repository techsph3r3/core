<html>
<head>
 <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
 <link href="nport2g.css" rel="stylesheet" type="text/css">
 <TITLE><% iw_webSysDescHandler("IPSecSettings", "", "IPSec Settings"); %></TITLE>
 <% iw_webJSList_get(); %>
 <script type="text/javascript">
 <!--
  var IPSecAry = <% iw_webGetIPSecInfo(); %> ;

  function iw_del(IPSecIndex)
  {

   if (window.confirm('Click OK to load IPSec factory default settings.'))
   {
    document.getElementById("ipsec_index").value=IPSecIndex;
    document.ipsec_setting.action='/forms/webDelIPSec';
    document.ipsec_setting.submit();
   }
  }

  function insertIPSecRecord(IPSecIndex, enable, connname, remotegateway, localsubnetip, remotesubnetip, color){
   var IPSecTable = document.getElementById("IPSecTable");
   var newRow = IPSecTable.insertRow(IPSecTable.rows.length);
         newRow.id = newRow.uniqueID;

   //: Status
   newCell = newRow.insertCell(0);
   newCell.className = "column_title";
   newCell.style.backgroundColor = color;
   newCell.innerHTML = enable;

   //: ssid
   newCell = newRow.insertCell(1);
   newCell.className = "column_title";
   newCell.style.backgroundColor = color;
   newCell.innerHTML = connname;

   //: opMode
   newCell = newRow.insertCell(2);
   newCell.className = "column_title";
   newCell.style.backgroundColor = color;
   newCell.innerHTML = remotegateway;

   //: authType
   newCell = newRow.insertCell(3);
   newCell.className = "column_title";
   newCell.style.backgroundColor = color;
   newCell.innerHTML = localsubnetip;

   newCell = newRow.insertCell(4);
   newCell.className = "column_title";
   newCell.style.backgroundColor = color;
   newCell.innerHTML = remotesubnetip;
   //: action
   newCell = newRow.insertCell(5);
   newCell.className = "column_title";
   newCell.style.backgroundColor = color;
   newCell.innerHTML = "<input type=\"button\" value=\"Edit\" onClick=\"location.href='ipsec_option.asp?IPSecIndex="+IPSecIndex+"'\" /> 	<input type=\"button\" id=\"iw_ipsec_index"+IPSecIndex+"\" value=\"Delete\" onClick=\"iw_del("+IPSecIndex+")\" />";
  }


  function editPermission()
  {
   var form = document.ipsec_setting, i, j = <% iw_websCheckPermission(); %>;
   if(j)
   {
    for(i = 0; i < form.length; i++)
     form.elements[i].disabled = true;
   }
  }


  function iw_onLoad(){
   var i ;
   var color;
   var index;
   var css_index;
   for ( i = 0 ; i < IPSecAry.length ; i++)
   {
    IPSec = IPSecAry[i];
    if(i%2==0){
     color = "beige";
    }
    else{
     color = "azure";
    }

    insertIPSecRecord(IPSec[0], IPSec[1], IPSec[2], IPSec[3], IPSec[4], IPSec[5], color);
    index = "iw_ipsec_index"+IPSec[0];
    css_index = "#"+index;
    if (IPSec[2] == "")
    {
     document.getElementById(index).disabled = true;
     $("#"+index).css(({'color':'gray'}));
    }
   }
   iw_selectSet(document.ipsec_setting.iw_ipsec_enable, "<% iw_webCfgValueHandler("IPSecsetting", "IPSecsettingenable", ""); %>");
   iw_selectSet(document.ipsec_setting.iw_ipsec_nattraversal, "<% iw_webCfgValueHandler("IPSecsetting", "nattraversal", ""); %>");


                 editPermission();


   top.toplogo.location.reload();

  }

  function CheckValue(form)
  {
   return true;
  }
    -->
    </script>
</head>
<body onload="iw_onLoad();">
 <FORM name="ipsec_setting" method="POST" action="" onSubmit="return CheckValue(this)">

 <h2><% iw_webSysDescHandler("IPSecSettings", "", "IPSec Settings"); %> (AP only)



          &nbsp;&nbsp;<% iw_websGetErrorString(); %></h2><br />

 <table ID="IPSecoption" width="100%">
   <TR>
    <TD colspan="2"><HR>
    </TD>
   </TR>
   <TR>
    <TD width="30%" class="column_title"><% iw_webCfgDescHandler("IPSecsetting", "IPSecsettingenable", "IPSec"); %></TD>
    <TD width="70%">
     <SELECT size="1" id="iw_ipsec_enable" name="iw_IPSecsetting_IPSecsettingenable">
                <option value="ENABLE">Enable</option>
                <option value="DISABLE">Disable</option>
                                  </SELECT>
    </TD>
   </TR>
   <TR>
    <TD width="30%" class="column_title"><% iw_webCfgDescHandler("IPSecsetting", "nattraversal", "NAT Traversal"); %></TD>
    <TD width="70%">
     <SELECT size="1" id="iw_ipsec_nattraversal" name="iw_IPSecsetting_nattraversal">
                <option value="ENABLE">Enable</option>
                <option value="DISABLE">Disable</option>
                                  </SELECT>
    </TD>
   </TR>
   <TR>
    <TD colspan="2"><HR>
     <INPUT type="submit" value="Submit" name="Submit" onclick="ipsec_setting.action='/forms/iw_webSetParameters'" >
     <Input type="hidden" name="bkpath" value="/ipsec.asp">
     <Input type="hidden" id="ipsec_index" name="ipsec_index" value="">
    </TD>
   </TR>
 </table>

 <table ID="IPSecTable" width="100%">
  <tr>
   <td class="block_title" width="100">Status</td>
   <td class="block_title" width="150">Name</td>
   <td class="block_title" width="150">Remote Endpoint</td>
   <td class="block_title" width="150">Local Subnet</td>
   <td class="block_title" width="150">Remote Subnet</td>
   <td class="block_title" width="150">Action</td>
  </tr>
 </table>
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
