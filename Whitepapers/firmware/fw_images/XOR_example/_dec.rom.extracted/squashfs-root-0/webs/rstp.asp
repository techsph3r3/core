<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
 <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
 <link href="nport2g.css" rel="stylesheet" type="text/css">
 <title><% iw_webSysDescHandler("RstpSettingTree", "", "RSTP Settings"); %></title>
 <% iw_webJSList_get(); %>
 <script type="text/javascript">
 <!--
  var rstpInfoArray = <% iw_webGetRSTPinfo(); %>;

  function CheckValue(form)
  {
   var i, j=0, k=0;
   if( !isValidNumber(form.iw_stpBridge_helloTime, 1, 10, "<% iw_webCfgDescHandler("stpBridge", "helloTime", ""); %>") ){
                return false;
            }
   if( !isValidNumber(form.iw_stpBridge_forwardDelay, 4, 30, "<% iw_webCfgDescHandler("stpBridge", "forwardDelay", ""); %>") ){
                return false;
            }
   if( !isValidNumber(form.iw_stpBridge_maxAgeTime, 6, 40, "<% iw_webCfgDescHandler("stpBridge", "maxAgeTime", ""); %>") ){
                return false;
            }
   if( (2*(parseInt(form.iw_stpBridge_helloTime.value) +1)) > parseInt(form.iw_stpBridge_maxAgeTime.value)){
    alert("Invalid Max age and Hello time value.\nPlease make sure the following condition is satisfied.\n\n      2 * (Hello time + 1 sec) <= Max age <= 2 * (Forwarding delay - 1 sec)");
    form.iw_stpBridge_helloTime.focus();
    return false;
   }

   if( (2*(parseInt(form.iw_stpBridge_forwardDelay.value) -1)) < parseInt(form.iw_stpBridge_maxAgeTime.value)){
    alert("Invalid Max age and Forward delay value.\nPlease make sure the following condition is satisfied.\n\n      2 * (Hello time + 1 sec) <= Max age <= 2 * (Forwarding delay - 1 sec)");
    form.iw_stpBridge_forwardDelay.focus();
    return false;
   }

   for(i = 0; i < (form.elements.length); i++)
   {
    if (form.elements[i].name.match("pathCost"))
    {
     if(form.elements[i].value.length > 0)
     {
      if(!isValidNumber(form.elements[i], 1, 200000000, "Port cost"))
      {
       form.elements[i].focus();
       return false;
      }
     }
    }
   }

   for(i = 0; i < form.length; i++)
   {
    if( form.elements[i].name.match(/^stpPort[a-zA-Z0-9]*_enable/) || form.elements[i].name.match(/^stpPort[a-zA-Z0-9]*_edgePort/) )
    {
     if(form.elements[i].checked)
      document.getElementById('iw_' + form.elements[i].name).value = "ENABLE";
     else
      document.getElementById('iw_' + form.elements[i].name).value = "DISABLE";
    }
   }
  }

  function selall_rstp()
  {
   for(i = 0; i < document.rstp.length; i++)
   {
    if(document.rstp.elements[i].name.match(/^stpPort[a-zA-Z0-9]*_enable/))
    {
     if(document.rstp.SelAllRstp.checked == true)
      document.rstp.elements[i].checked = true;
     else
      document.rstp.elements[i].checked = false;
    }
   }
  }

  function selall_port()
  {
   for(i = 0; i < document.rstp.length; i++)
   {
    if(document.rstp.elements[i].name.match(/^stpPort[a-zA-Z0-9]*_edgePort/))
    {
     if(document.rstp.SelAllPort.checked == true)
      document.rstp.elements[i].checked = true;
     else
      document.rstp.elements[i].checked = false;
    }
   }
  }

        function iw_rstpOnLoad()
        {
         var rstpTable = document.getElementById("rstpTable");
         var newRow, newCell, inputElement, i, color, optionElement, j, textNode;

            iw_selectSet(document.rstp.iw_stpBridge_priority, "<% iw_webCfgValueHandler("stpBridge", "priority", "32768"); %>");

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
    inputElement = document.createElement('input');
    inputElement.type = "checkbox";
    newCell.appendChild(inputElement);
    inputElement.name = rstpInfoArray[i].sectionName + "_enable";
    inputElement.checked = rstpInfoArray[i].isEnable == 1 ? true : false;

    // Hidden object for enable
    inputElement = document.createElement('input');
    inputElement.type = "hidden";
    document.getElementById("rstpForm").appendChild(inputElement);
    inputElement.name = "iw_" + rstpInfoArray[i].sectionName + "_enable";
    inputElement.id = inputElement.name;
    inputElement.value = rstpInfoArray[i].isEnable == 1 ? "ENABLE" : "DISABLE";

    // Port Prioirty
    newCell = newRow.insertCell(2);
    newCell.style.backgroundColor = color;
    inputElement = document.createElement('select');
    newCell.appendChild(inputElement);
    inputElement.name = "iw_" + rstpInfoArray[i].sectionName + "_priority";
    inputElement.id = inputElement.name;
    inputElement.size = 1;
    inputElement = document.getElementById("iw_" + rstpInfoArray[i].sectionName + "_priority");
    for( j = 0; j <= 240; j += 16 )
    {
     optionElement = document.createElement('option');
     inputElement.appendChild(optionElement);
     textNode = document.createTextNode(j);
     optionElement.appendChild(textNode);
     optionElement.setAttribute("value", j);
     if( j == rstpInfoArray[i].portPrioirty )
      optionElement.selected = true;
    }

    // Path Cost
    newCell = newRow.insertCell(3);
    newCell.style.backgroundColor = color;
    inputElement = document.createElement('input');
    inputElement.type = "text";
    newCell.appendChild(inputElement);
    inputElement.name = "iw_" + rstpInfoArray[i].sectionName + "_pathCost";
    inputElement.size = 14;
    inputElement.maxlength = 9;
    inputElement.value = rstpInfoArray[i].portPathCost;

    // Edge Port
    newCell = newRow.insertCell(4);
    newCell.style.backgroundColor = color;
    newCell.align = "center";
    inputElement = document.createElement('input');
    inputElement.type = "checkbox";
    newCell.appendChild(inputElement);
    inputElement.name = rstpInfoArray[i].sectionName + "_edgePort";
    inputElement.checked = rstpInfoArray[i].isEdge == 1 ? true : false;

    // Hidden object for edge port
    inputElement = document.createElement('input');
    inputElement.type = "hidden";
    document.getElementById("rstpForm").appendChild(inputElement);
    inputElement.name = "iw_" + rstpInfoArray[i].sectionName + "_edgePort";
    inputElement.id = inputElement.name;
    inputElement.value = rstpInfoArray[i].isEdge == 1 ? "ENABLE" : "DISABLE";
   }


   var isAP = new String("<% iw_webCfgValueHandler("wlanDevWIFI0", "operationMode", "ENABLE"); %>");

   if ( isAP != "MASTER" && isAP != "SLAVE" ) {
    var form = document.rstp, i = 0;
    for(i = 0; i < form.length; i++)
     form.elements[i].disabled = true;
   }


  }


        function editPermission()
        {
                var form = document.rstp, i, j = <% iw_websCheckPermission(); %>;
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
    -->
    </Script>
</head>
<body onLoad="iw_rstpOnLoad();iw_ChangeOnLoad();">
  <h2><% iw_webSysDescHandler("RstpSettingTree", "", "RSTP Settings"); %>
 (WLAN is for Master/Slave only)






 <% iw_websGetErrorString(); %></h2>
 <form name="rstp" id="rstpForm" method="POST" action="/forms/iw_webSetParameters" onSubmit="return CheckValue(this)">
  <table width="100%">
  <tr>
   <td width="30%" class="column_title"><% iw_webCfgDescHandler("stpBridge", "priority", "Bridge priority"); %></td>
   <td width="70%">
      <select id="iw_stpBridge_priority" name="iw_stpBridge_priority" size="1">
    <option value="0" >0</option>
    <option value="4096" >4096</option>
    <option value="8192" >8192</option>
    <option value="12288" >12288</option>
    <option value="16384" >16384</option>
    <option value="20480" >20480</option>
    <option value="24576" >24576</option>
    <option value="28672" >28672</option>
    <option value="32768" >32768</option>
    <option value="36864" >36864</option>
    <option value="40960" >40960</option>
    <option value="45056" >45056</option>
    <option value="49152" >49152</option>
    <option value="53248" >53248</option>
    <option value="57344" >57344</option>
    <option value="61440" >61440</option>
   </select></td>
  </tr>
  <tr>
   <td width="30%" class="column_title"><% iw_webCfgDescHandler("stpBridge", "helloTime", "Hello time"); %></td>
   <td width="70%">
      <input type="text" name="iw_stpBridge_helloTime" size="4" maxlength="2" value="<% iw_webCfgValueHandler("stpBridge", "helloTime", "2"); %>" /> (1 to 10 seconds)
   </td>
  </tr>
  <tr>
   <td width="30%" class="column_title"><% iw_webCfgDescHandler("stpBridge", "forwardDelay", "Forwarding delay"); %></td>
   <td width="70%">
       <input type="text" name="iw_stpBridge_forwardDelay" size="4" maxlength="2" value="<% iw_webCfgValueHandler("stpBridge", "forwardDelay", "15"); %>" /> (4 to 30 seconds)
   </td>
  </tr>
  <tr>
   <td width="30%" class="column_title"><% iw_webCfgDescHandler("stpBridge", "maxAgeTime", "Max. age"); %></td>
   <td width="70%">
       <input type="text" name="iw_stpBridge_maxAgeTime" size="4" maxlength="2" value="<% iw_webCfgValueHandler("stpBridge", "maxAgeTime", "20"); %>" /> (6 to 40 seconds)
   </td>
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
   <td style="width:250px" align="center" class="block_title"><input type="checkbox" id="SelAllRstp" onclick="selall_rstp();" />Enable RSTP</td>
   <td style="width:250px" class="block_title">Port Priority</td>
   <td style="width:250px" class="block_title">Port Cost</td>
   <td style="width:250px" align="center" class="block_title"><input type="checkbox" id="SelAllPort" onclick="selall_port();" />Edge Port</td>
  </tr>
  </table><hr>

  <input type="submit" value="Submit" name="Submit" />
  <input type="hidden" name="bkpath" value="/rstp.asp" />
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
