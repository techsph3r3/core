<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
 <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
 <link href="nport2g.css" rel="stylesheet" type="text/css">
 <title><% iw_webSysDescHandler("RstpStatusTree", "", "RSTP Status"); %></title>
 <% iw_webJSList_get(); %>
 <script type="text/javascript">
 <!--
  var rstpInfoArray = <% iw_webGetRSTPinfo("status"); %>;

        function iw_rstpOnLoad()
        {
         var rstpTable = document.getElementById("rstpTable");
         var newRow, newCell, inputElement, i, color, optionElement, j;

   for( i = 0; i < rstpInfoArray.length; i++ )
   {
    newRow = rstpTable.insertRow(rstpTable.rows.length);
          newRow.id = newRow.uniqueID;

    if( i%2 == 0 )
     color = "beige";
    else
     color = "azure";

    // Port Name
    newCell = newRow.insertCell(0);
    newCell.style.backgroundColor = color;
    newCell.align = "left";
    if( (i+1) < 10 )
     newCell.innerHTML = "&nbsp;&nbsp;";
    newCell.innerHTML += (i+1) + "&nbsp;&nbsp;&nbsp;" + rstpInfoArray[i].portName;

    // Enable
    newCell = newRow.insertCell(1);
    newCell.style.backgroundColor = color;
    newCell.align = "center";
    newCell.innerHTML = rstpInfoArray[i].isEnable == 1 ? "Enable" : "Disable";

    // Port Prioirty
    newCell = newRow.insertCell(2);
    newCell.style.backgroundColor = color;
    newCell.align = "center";
    newCell.innerHTML = rstpInfoArray[i].portPrioirty;

    // Path Cost
    newCell = newRow.insertCell(3);
    newCell.style.backgroundColor = color;
    newCell.align = "center";
    newCell.innerHTML = rstpInfoArray[i].portPathCost;

    // Edge Port
    newCell = newRow.insertCell(4);
    newCell.style.backgroundColor = color;
    newCell.align = "center";
    newCell.innerHTML = rstpInfoArray[i].isEdge == 1 ? "Enable" : "Disable";

    // Status
    newCell = newRow.insertCell(5);
    newCell.style.backgroundColor = color;
    newCell.align = "center";
    newCell.innerHTML = rstpInfoArray[i].portStatus;
   }
  }

        var mem_state = <% iw_websMemoryChange(); %>;
        function iw_ChangeOnLoad()
       {
                    top.toplogo.location.reload();
       }
    -->
    </Script>
</head>
<body onLoad="iw_rstpOnLoad();iw_ChangeOnLoad();">
 <h2><% iw_webSysDescHandler("RstpStatusTree", "", "RSTP Status"); %></h2>
 <table width="100%">
 <tr>
  <td width="30%" class="column_title"><% iw_webSysDescHandler("RstpStatus", "", "RSTP status"); %></td>
  <td width="70%"><% iw_webGetRSTPStatus(); %></td>
 </tr>
 <tr>
  <td width="30%" class="column_title"><% iw_webCfgDescHandler("stpBridge", "priority", "Bridge priority"); %></td>
  <td width="70%"><% iw_webCfgValueMainHandler("stpBridge", "priority", "32768"); %></td>
 </tr>
 <tr>
  <td width="30%" class="column_title"><% iw_webCfgDescHandler("stpBridge", "helloTime", "Hello time"); %></td>
  <td width="70%"><% iw_webCfgValueMainHandler("stpBridge", "helloTime", "2"); %> seconds</td>
 </tr>
 <tr>
  <td width="30%" class="column_title"><% iw_webCfgDescHandler("stpBridge", "forwardDelay", "Forwarding delay"); %></td>
  <td width="70%"><% iw_webCfgValueMainHandler("stpBridge", "forwardDelay", "15"); %> seconds</td>
 </tr>
 <tr>
  <td width="30%" class="column_title"><% iw_webCfgDescHandler("stpBridge", "maxAgeTime", "Max. age"); %></td>
  <td width="70%"><% iw_webCfgValueMainHandler("stpBridge", "maxAgeTime", "20"); %> seconds</td>
 </tr>
 <tr>
  <td width="30%"></td>
  <td width="70%"></td>
 </tr>
 <tr>
  <td width="30%"></td>
  <td width="70%"></td>
 </tr>
 </table>
 <table width="100%" id="rstpTable">
 <tr align="left">
  <td style="width:250px" align="center" class="block_title">No.</td>
  <td style="width:250px" align="center" class="block_title">Enable RSTP</td>
  <td style="width:250px" align="center" class="block_title">Port Priority</td>
  <td style="width:250px" align="center" class="block_title">Port Cost</td>
  <td style="width:250px" align="center" class="block_title">Edge Port</td>
  <td style="width:250px" align="center" class="block_title">Status</td>
 </tr>
 </table><hr>
</body>
</html>
