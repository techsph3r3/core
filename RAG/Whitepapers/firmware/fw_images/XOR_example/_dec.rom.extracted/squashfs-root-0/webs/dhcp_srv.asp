
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
 <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
    <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate" />
    <meta http-equiv="Pragma" content="no-cache" />
    <meta http-equiv="Expires" content="0" />
 <link href="nport2g.css" rel="stylesheet" type="text/css" />
 <title><% iw_webSysDescHandler("DHCPServerTree", "", "DHCP Server"); %></title>
 <% iw_webJSList_get(); %>
 <script type="text/javascript">
 <!--
 var dhcpSrv_checkIpConfig = <%iw_webDhcpSrvCheckIpConfig();%>;
 var dhcp_value = new String("<%iw_webCfgValueHandler("netDev1", "dhcp", "DISABLE");%>");
 var i;

 function IPstr2Var( IPstr )
 {
  var addr = parseInt(IPstr.split("."));
  if( addr.length != 4 )
   return -1;
  return addr[0] << 24 | addr[1] << 16 | addr[2] << 8 | addr[3] ;
 }

 function CheckValue(form)
 {
  if(document.getElementById("iw_dhcpSrv_enable").selectedIndex == 0)
  {
   var opMode = new String("<% iw_webCfgValueHandler( "wlanDevWIFI0", "operationMode", "AP" ); %>");
   if( dhcpSrv_checkIpConfig && (dhcp_value.match("DISABLE")==null))
   {
    alert("When IP configuration is set to DHCP mode, it is not allowed to enable DHCP server at the same time.");
    form.iw_dhcpSrv_enable.selectedIndex=1;
    form.iw_dhcpSrv_enable.focus();
    return false;
   }
   if( opMode != "AP" && opMode != "CLIENT-ROUTER" )
   {

    alert("DHCP server is valid only in AP/Client-Router mode.");





    form.iw_dhcpSrv_enable.selectedIndex=1;
    form.iw_dhcpSrv_enable.focus();
    return false;
   }



   if(form.iw_dhcpSrv_ipv4GateWay.value.length<7 )
   {
    alert("Invalid input: \"<% iw_webCfgDescHandler("dhcpSrv", "ipv4GateWay", ""); %>\" (" + form.iw_dhcpSrv_ipv4GateWay.value + ")");
    form.iw_dhcpSrv_ipv4GateWay.focus();
    return false;
   }
   if( !verifyIP(form.iw_dhcpSrv_ipv4GateWay, "<% iw_webCfgDescHandler("dhcpSrv", "ipv4GateWay", ""); %>") ){
    return false;
   }

   if(form.iw_dhcpSrv_ipv4NetMask.value.length<7 )
   {
    alert("Invalid input: \"<% iw_webCfgDescHandler("dhcpSrv", "ipv4NetMask", ""); %>\" (" + form.iw_dhcpSrv_ipv4NetMask.value + ")");
    form.iw_dhcpSrv_ipv4NetMask.focus();
    return false;
   }

   if( !verifyNetmask(form.iw_dhcpSrv_ipv4NetMask, "<% iw_webCfgDescHandler("dhcpSrv", "ipv4NetMask", ""); %>") ){
    return false;
   }

   if( !verifyIP(form.iw_dhcpSrv_ipv4FirstDNS, "<% iw_webCfgDescHandler("dhcpSrv", "ipv4FirstDNS", ""); %>") ){
    return false;
   }
   if( !verifyIP(form.iw_dhcpSrv_ipv4SecondaryDNS, "<% iw_webCfgDescHandler("dhcpSrv", "ipv4SecondaryDNS", ""); %>") ){
    return false;
   }

   if(form.iw_dhcpSrv_ipv4StartAddr.value.length<7)
   {
    alert("Invalid input: \"<% iw_webCfgDescHandler("dhcpSrv", "ipv4StartAddr", ""); %>\" (" + form.iw_dhcpSrv_ipv4StartAddr.value + ")");
    form.iw_dhcpSrv_ipv4StartAddr.focus();
    return false;
   }
   if( !verifyIP(form.iw_dhcpSrv_ipv4StartAddr, "<% iw_webCfgDescHandler("dhcpSrv", "ipv4StartAddr", ""); %>") ){
    return false;
   }

   if( !verifyMulticastIP(form.iw_dhcpSrv_ipv4StartAddr, "<% iw_webCfgDescHandler("dhcpSrv", "ipv4StartAddr", ""); %>") ){
    alert("<% iw_webCfgDescHandler("dhcpSrv", "ipv4StartAddr", ""); %> " + " is multicast IP: " + form.iw_dhcpSrv_ipv4StartAddr.value + "");
    return false;
   }
   if( !verifyReservedIP(form.iw_dhcpSrv_ipv4StartAddr, "<% iw_webCfgDescHandler("dhcpSrv", "ipv4StartAddr", ""); %>") ){
    return false;
   }
   if( !verifyBroadcastIP(form.iw_dhcpSrv_ipv4StartAddr, form.iw_dhcpSrv_ipv4NetMask, "<% iw_webCfgDescHandler("dhcpSrv", "ipv4StartAddr", ""); %>") ){
    return false;
   }

   if( !verifyStartIP(form.iw_dhcpSrv_ipv4StartAddr, "<% iw_webCfgDescHandler("dhcpSrv", "ipv4StartAddr", ""); %>") ){
    return false;
   }
   if( !isValidNumber(form.iw_dhcpSrv_maxClient, 1, 128, "<% iw_webCfgDescHandler("dhcpSrv", "maxClient", ""); %>") ){
    return false;
   }
   if( !isSameSubnet(form.iw_dhcpSrv_ipv4StartAddr, form.iw_dhcpSrv_ipv4NetMask, form.iw_dhcpSrv_ipv4GateWay) ){
                window.alert("DHCP start IP need to be in the same subnet with DHCP gateway.")
    return false;
   }
   if( !isValidDHCPMaxNo(form.iw_dhcpSrv_maxClient, form.iw_dhcpSrv_ipv4StartAddr, 1, 254, "<% iw_webCfgDescHandler("dhcpSrv", "maxClient", ""); %>") ){
    return false;
   }

   if( !isValidNumber(form.iw_dhcpSrv_leaseTimeMinute, 2, 14400, "<% iw_webCfgDescHandler("dhcpSrv", "leaseTimeMinute", ""); %>") ){



    return false;
   }
  }

  var addrList = [], macList = [];
  var m=0, n=0;
  var mac_arr;
  for(i = 0; i < form.length; i++)
  {
   if(form.elements[i].value.length > 0)
   {
    if (form.elements[i].id.match(/^dhcpSrvMap[0-9]{1,2}_enable/))
    {
     if(form.elements[i].checked)
     {
      if (form.elements[i+1].value.length < 7)
      {
       alert("The IP address cannot be empty.");
       form.elements[i+1].focus();
       return false;
      }
      else if (form.elements[i+2].value.length < 17)
      {
       alert("The MAC address cannot be empty.");
       form.elements[i+2].focus();
       return false;
      }
      document.getElementsByName('iw_'+form.elements[i].id)[0].value = "ENABLE";
     }else
     {
      document.getElementsByName('iw_'+form.elements[i].id)[0].value = "DISABLE";
     }
    }

    if(form.elements[i].name.match(/iw_dhcpSrvMap[0-9]{1,2}_ipv4Addr/) )
    {
     if(!verifyIP(form.elements[i], "IP"))
     {
      form.elements[i].focus();
      return false;
     }

     for( m = 0; m < addrList.length; m++ )
     {
      if( form.elements[i].value == form.elements[ addrList[m] ].value )
      {
       alert( 'IP address Duplicated' );
       form.elements[i].focus();
       return false;
      }
     }

     addrList[ m ] = i;
    }

    if (form.elements[i].name.match(/iw_dhcpSrvMap[0-9]{1,2}_mac/))
    {
     if(!isMACaddress(form.elements[i].value))
     {
      form.elements[i].focus();
      return false;
     }

     mac_arr = form.elements[i].value.split(":");
     if( parseInt(mac_arr[0], 16) & 1 )
     {
      alert( "Multicast MAC address is not allowed." );
      form.elements[i].focus();
      return false;
     }

     for( m = 0; m < macList.length; m++ )
     {
      if( form.elements[i].value == form.elements[ macList[m] ].value )
      {
       alert( 'MAC address Duplicated' );
       form.elements[i].focus();
       return false;
      }
     }

     macList[ m ] = i;
    }
   }
  }
 }

 function selall()
 {
  for(i = 0; i < document.dhcpsrv.length; i++)
  {
   if(document.dhcpsrv.elements[i].id.match(/^dhcpSrvMap[0-9]{1,2}_enable/))
   {
    if(document.dhcpsrv.SelAll.checked == true)
     document.dhcpsrv.elements[i].checked = true;
    else
     document.dhcpsrv.elements[i].checked = false;
   }
  }
 }
    function iw_dhcpsrvOnLoad()
    {
  iw_selectSet(document.dhcpsrv.iw_dhcpSrv_enable, "<% iw_webCfgValueHandler("dhcpSrv", "enable"  , "ENABLE");  %>");
  iw_checkedSet(document.dhcpsrv.dhcpSrvMap1_enable, "<% iw_webCfgValueHandler("dhcpSrvMap1", "enable"  , "ENABLE");  %>");
  iw_checkedSet(document.dhcpsrv.dhcpSrvMap2_enable, "<% iw_webCfgValueHandler("dhcpSrvMap2", "enable"  , "ENABLE");  %>");
  iw_checkedSet(document.dhcpsrv.dhcpSrvMap3_enable, "<% iw_webCfgValueHandler("dhcpSrvMap3", "enable"  , "ENABLE");  %>");
  iw_checkedSet(document.dhcpsrv.dhcpSrvMap4_enable, "<% iw_webCfgValueHandler("dhcpSrvMap4", "enable"  , "ENABLE");  %>");
  iw_checkedSet(document.dhcpsrv.dhcpSrvMap5_enable, "<% iw_webCfgValueHandler("dhcpSrvMap5", "enable"  , "ENABLE");  %>");
  iw_checkedSet(document.dhcpsrv.dhcpSrvMap6_enable, "<% iw_webCfgValueHandler("dhcpSrvMap6", "enable"  , "ENABLE");  %>");
  iw_checkedSet(document.dhcpsrv.dhcpSrvMap7_enable, "<% iw_webCfgValueHandler("dhcpSrvMap7", "enable"  , "ENABLE");  %>");
  iw_checkedSet(document.dhcpsrv.dhcpSrvMap8_enable, "<% iw_webCfgValueHandler("dhcpSrvMap8", "enable"  , "ENABLE");  %>");
  iw_checkedSet(document.dhcpsrv.dhcpSrvMap9_enable, "<% iw_webCfgValueHandler("dhcpSrvMap9", "enable"  , "ENABLE");  %>");
  iw_checkedSet(document.dhcpsrv.dhcpSrvMap10_enable, "<% iw_webCfgValueHandler("dhcpSrvMap10", "enable"  , "ENABLE");  %>");
  iw_checkedSet(document.dhcpsrv.dhcpSrvMap11_enable, "<% iw_webCfgValueHandler("dhcpSrvMap11", "enable"  , "ENABLE");  %>");
  iw_checkedSet(document.dhcpsrv.dhcpSrvMap12_enable, "<% iw_webCfgValueHandler("dhcpSrvMap12", "enable"  , "ENABLE");  %>");
  iw_checkedSet(document.dhcpsrv.dhcpSrvMap13_enable, "<% iw_webCfgValueHandler("dhcpSrvMap13", "enable"  , "ENABLE");  %>");
  iw_checkedSet(document.dhcpsrv.dhcpSrvMap14_enable, "<% iw_webCfgValueHandler("dhcpSrvMap14", "enable"  , "ENABLE");  %>");
  iw_checkedSet(document.dhcpsrv.dhcpSrvMap15_enable, "<% iw_webCfgValueHandler("dhcpSrvMap15", "enable"  , "ENABLE");  %>");
  iw_checkedSet(document.dhcpsrv.dhcpSrvMap16_enable, "<% iw_webCfgValueHandler("dhcpSrvMap16", "enable"  , "ENABLE");  %>");
    }


        function editPermission()
        {
                var form = document.dhcpsrv, i, j = <% iw_websCheckPermission(); %>;
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

 //-->
 </script>
</head>
<body onload="iw_dhcpsrvOnLoad();iw_ChangeOnLoad();">


 <h2><% iw_webSysDescHandler("DHCPServerTree", "", "DHCP Server"); %> (For AP/Client-Router mode only) <% iw_websGetErrorString(); %></h2>
 <form name="dhcpsrv" method="POST" action="/forms/iw_webSetParameters" onSubmit="return CheckValue(this)">
     <table width="100%">
  <tr>
        <td width="30%" class="column_title"><% iw_webCfgDescHandler("dhcpSrv", "enable", "DHCP server"); %></td>
     <td width="70%">
          <select size="1" id="iw_dhcpSrv_enable" name="iw_dhcpSrv_enable">
          <option value="ENABLE">Enable</option>
    <option value="DISABLE">Disable</option>
             </select>
     </td>
     </tr>
     <tr>
            <td width="30%" class="column_title"><% iw_webCfgDescHandler("dhcpSrv", "ipv4GateWay", "Default gateway"); %></td>
            <td width="70%">
         <input type="text" id="iw_dhcpSrv_ipv4GateWay" name="iw_dhcpSrv_ipv4GateWay" size="20" maxlength="15" value="<% iw_webCfgValueHandler("dhcpSrv", "ipv4GateWay", ""); %>" />
         </td>
     </tr>
     <tr>
         <td width="30%" class="column_title"><% iw_webCfgDescHandler("dhcpSrv", "ipv4NetMask", "Subnet mask"); %></td>
   <td width="70%">
            <input type="text" id="iw_dhcpSrv_ipv4NetMask" name="iw_dhcpSrv_ipv4NetMask" size="20" maxlength="15" value="<% iw_webCfgValueHandler("dhcpSrv", "ipv4NetMask", ""); %>" />
   </td>
     </tr>
     <tr>
         <td width="30%" class="column_title"><% iw_webCfgDescHandler("dhcpSrv", "ipv4FirstDNS", "Primary DNS server"); %></td>
            <td width="70%">
            <input type="text" id="iw_dhcpSrv_ipv4FirstDNS" name="iw_dhcpSrv_ipv4FirstDNS" size="20" maxlength="15" value="<% iw_webCfgValueHandler("dhcpSrv", "ipv4FirstDNS", ""); %>" />
            </td>
         </tr>
     <tr>
         <td width="30%" class="column_title"><% iw_webCfgDescHandler("dhcpSrv", "ipv4SecondaryDNS", "Secondary DNS server"); %></td>
            <td width="70%">
            <input type="text" id="iw_dhcpSrv_ipv4SecondaryDNS" name="iw_dhcpSrv_ipv4SecondaryDNS" size="20" maxlength="15" value="<% iw_webCfgValueHandler("dhcpSrv", "ipv4SecondaryDNS", ""); %>" />
            </td>
         </tr>
     <tr>
         <td width="30%" class="column_title"><% iw_webCfgDescHandler("dhcpSrv", "ipv4StartAddr", "Starting IP address"); %></td>
            <td width="70%">
            <input type="text" id="iw_dhcpSrv_ipv4StartAddr" name="iw_dhcpSrv_ipv4StartAddr" size="20" maxlength="15" value="<% iw_webCfgValueHandler("dhcpSrv", "ipv4StartAddr", ""); %>" />
            </td>
     </tr>
     <tr>
         <td width="30%" class="column_title"><% iw_webCfgDescHandler("dhcpSrv", "maxClient", "Maximum number of users"); %></td>
            <td width="70%">
            <input type="text" id="iw_dhcpSrv_maxClient" name="iw_dhcpSrv_maxClient" size="5" maxlength="3" value="<% iw_webCfgValueHandler("dhcpSrv", "maxClient", ""); %>" />
            </td>
     </tr>
     <tr>
         <td width="30%" class="column_title"><% iw_webCfgDescHandler("dhcpSrv", "leaseTime", "Client lease time"); %></td>
            <td width="70%">

            <input type="text" id="iw_dhcpSrv_leaseTimeMinute" name="iw_dhcpSrv_leaseTimeMinute" size="5" maxlength="5" value="<% iw_webCfgValueHandler("dhcpSrv", "leaseTimeMinute", ""); %>" />(2 to 14400 minutes)



            </td>
     </tr>
  </table>
 <br />
 <h2><% iw_webSysDescHandler("StaticDHCPServerTree", "", "Static DHCP Mapping"); %></h2>
  <table width="100%">
  <tr align="left">
   <td width="5%" align="center" class="block_title">No.</td>
   <td width="10%" align="center" class="block_title"><input type="checkbox" id="SelAll" onclick="selall();" />Active</td>
   <td width="25%" class="block_title">IP Address</td>
   <td width="35%" class="block_title">MAC Address</td>
  </tr>
  <tr>
   <td width="5%" align="center">1</td>
   <td width="10%" align="center"><input type="checkbox" id="dhcpSrvMap1_enable" value="DISABLE" /></td>
   <td width="25%" ><input type="text" name="iw_dhcpSrvMap1_ipv4Addr" size="20" maxlength="15" value="<% iw_webCfgValueHandler("dhcpSrvMap1", "ipv4Addr", ""); %>" /></td>
   <td width="35%" ><input type="text" name="iw_dhcpSrvMap1_mac" size="22" maxlength="17" value="<% iw_webCfgValueHandler("dhcpSrvMap1", "mac", ""); %>" /></td>
  </tr>
  <tr>
   <td width="5%" align="center">2</td>
   <td width="10%" align="center"><input type="checkbox" id="dhcpSrvMap2_enable" value="DISABLE" /></td>
   <td width="25%" ><input type="text" name="iw_dhcpSrvMap2_ipv4Addr" size="20" maxlength="15" value="<% iw_webCfgValueHandler("dhcpSrvMap2", "ipv4Addr", ""); %>" /></td>
   <td width="35%" ><input type="text" name="iw_dhcpSrvMap2_mac" size="22" maxlength="17" value="<% iw_webCfgValueHandler("dhcpSrvMap2", "mac", ""); %>" /></td>
  </tr>
  <tr>
   <td width="5%" align="center">3</td>
   <td width="10%" align="center"><input type="checkbox" id="dhcpSrvMap3_enable" value="DISABLE" /></td>
   <td width="25%" ><input type="text" name="iw_dhcpSrvMap3_ipv4Addr" size="20" maxlength="15" value="<% iw_webCfgValueHandler("dhcpSrvMap3", "ipv4Addr", ""); %>" /></td>
   <td width="35%" ><input type="text" name="iw_dhcpSrvMap3_mac" size="22" maxlength="17" value="<% iw_webCfgValueHandler("dhcpSrvMap3", "mac", ""); %>" /></td>
  </tr>
  <tr>
   <td width="5%" align="center">4</td>
   <td width="10%" align="center"><input type="checkbox" id="dhcpSrvMap4_enable" value="DISABLE" /></td>
   <td width="25%" ><input type="text" name="iw_dhcpSrvMap4_ipv4Addr" size="20" maxlength="15" value="<% iw_webCfgValueHandler("dhcpSrvMap4", "ipv4Addr", ""); %>" /></td>
   <td width="35%" ><input type="text" name="iw_dhcpSrvMap4_mac" size="22" maxlength="17" value="<% iw_webCfgValueHandler("dhcpSrvMap4", "mac", ""); %>" /></td>
  </tr>
  <tr>
   <td width="5%" align="center">5</td>
   <td width="10%" align="center"><input type="checkbox" id="dhcpSrvMap5_enable" value="DISABLE" /></td>
   <td width="25%" ><input type="text" name="iw_dhcpSrvMap5_ipv4Addr" size="20" maxlength="15" value="<% iw_webCfgValueHandler("dhcpSrvMap5", "ipv4Addr", ""); %>" /></td>
   <td width="35%" ><input type="text" name="iw_dhcpSrvMap5_mac" size="22" maxlength="17" value="<% iw_webCfgValueHandler("dhcpSrvMap5", "mac", ""); %>" /></td>
  </tr>
  <tr>
   <td width="5%" align="center">6</td>
   <td width="10%" align="center"><input type="checkbox" id="dhcpSrvMap6_enable" value="DISABLE" /></td>
   <td width="25%" ><input type="text" name="iw_dhcpSrvMap6_ipv4Addr" size="20" maxlength="15" value="<% iw_webCfgValueHandler("dhcpSrvMap6", "ipv4Addr", ""); %>" /></td>
   <td width="35%" ><input type="text" name="iw_dhcpSrvMap6_mac" size="22" maxlength="17" value="<% iw_webCfgValueHandler("dhcpSrvMap6", "mac", ""); %>" /></td>
  </tr>
  <tr>
   <td width="5%" align="center">7</td>
   <td width="10%" align="center"><input type="checkbox" id="dhcpSrvMap7_enable" value="DISABLE" /></td>
   <td width="25%" ><input type="text" name="iw_dhcpSrvMap7_ipv4Addr" size="20" maxlength="15" value="<% iw_webCfgValueHandler("dhcpSrvMap7", "ipv4Addr", ""); %>" /></td>
   <td width="35%" ><input type="text" name="iw_dhcpSrvMap7_mac" size="22" maxlength="17" value="<% iw_webCfgValueHandler("dhcpSrvMap7", "mac", ""); %>" /></td>
  </tr>
  <tr>
   <td width="5%" align="center">8</td>
   <td width="10%" align="center"><input type="checkbox" id="dhcpSrvMap8_enable" value="DISABLE" /></td>
   <td width="25%" ><input type="text" name="iw_dhcpSrvMap8_ipv4Addr" size="20" maxlength="15" value="<% iw_webCfgValueHandler("dhcpSrvMap8", "ipv4Addr", ""); %>" /></td>
   <td width="35%" ><input type="text" name="iw_dhcpSrvMap8_mac" size="22" maxlength="17" value="<% iw_webCfgValueHandler("dhcpSrvMap8", "mac", ""); %>" /></td>
  </tr>
  <tr>
   <td width="5%" align="center">9</td>
   <td width="10%" align="center"><input type="checkbox" id="dhcpSrvMap9_enable" value="DISABLE" /></td>
   <td width="25%" ><input type="text" name="iw_dhcpSrvMap9_ipv4Addr" size="20" maxlength="15" value="<% iw_webCfgValueHandler("dhcpSrvMap9", "ipv4Addr", ""); %>" /></td>
   <td width="35%" ><input type="text" name="iw_dhcpSrvMap9_mac" size="22" maxlength="17" value="<% iw_webCfgValueHandler("dhcpSrvMap9", "mac", ""); %>" /></td>
  </tr>
  <tr>
   <td width="5%" align="center">10</td>
   <td width="10%" align="center"><input type="checkbox" id="dhcpSrvMap10_enable" value="DISABLE" /></td>
   <td width="25%" ><input type="text" name="iw_dhcpSrvMap10_ipv4Addr" size="20" maxlength="15" value="<% iw_webCfgValueHandler("dhcpSrvMap10", "ipv4Addr", ""); %>" /></td>
   <td width="35%" ><input type="text" name="iw_dhcpSrvMap10_mac" size="22" maxlength="17" value="<% iw_webCfgValueHandler("dhcpSrvMap10", "mac", ""); %>" /></td>
  </tr>
  <tr>
   <td width="5%" align="center">11</td>
   <td width="10%" align="center"><input type="checkbox" id="dhcpSrvMap11_enable" value="DISABLE" /></td>
   <td width="25%" ><input type="text" name="iw_dhcpSrvMap11_ipv4Addr" size="20" maxlength="15" value="<% iw_webCfgValueHandler("dhcpSrvMap11", "ipv4Addr", ""); %>" /></td>
   <td width="35%" ><input type="text" name="iw_dhcpSrvMap11_mac" size="22" maxlength="17" value="<% iw_webCfgValueHandler("dhcpSrvMap11", "mac", ""); %>" /></td>
  </tr>
  <tr>
   <td width="5%" align="center">12</td>
   <td width="10%" align="center"><input type="checkbox" id="dhcpSrvMap12_enable" value="DISABLE" /></td>
   <td width="25%" ><input type="text" name="iw_dhcpSrvMap12_ipv4Addr" size="20" maxlength="15" value="<% iw_webCfgValueHandler("dhcpSrvMap12", "ipv4Addr", ""); %>" /></td>
   <td width="35%" ><input type="text" name="iw_dhcpSrvMap12_mac" size="22" maxlength="17" value="<% iw_webCfgValueHandler("dhcpSrvMap12", "mac", ""); %>" /></td>
  </tr>
  <tr>
   <td width="5%" align="center">13</td>
   <td width="10%" align="center"><input type="checkbox" id="dhcpSrvMap13_enable" value="DISABLE" /></td>
   <td width="25%" ><input type="text" name="iw_dhcpSrvMap13_ipv4Addr" size="20" maxlength="15" value="<% iw_webCfgValueHandler("dhcpSrvMap13", "ipv4Addr", ""); %>" /></td>
   <td width="35%" ><input type="text" name="iw_dhcpSrvMap13_mac" size="22" maxlength="17" value="<% iw_webCfgValueHandler("dhcpSrvMap13", "mac", ""); %>" /></td>
  </tr>
  <tr>
   <td width="5%" align="center">14</td>
   <td width="10%" align="center"><input type="checkbox" id="dhcpSrvMap14_enable" value="DISABLE" /></td>
   <td width="25%" ><input type="text" name="iw_dhcpSrvMap14_ipv4Addr" size="20" maxlength="15" value="<% iw_webCfgValueHandler("dhcpSrvMap14", "ipv4Addr", ""); %>" /></td>
   <td width="35%" ><input type="text" name="iw_dhcpSrvMap14_mac" size="22" maxlength="17" value="<% iw_webCfgValueHandler("dhcpSrvMap14", "mac", ""); %>" /></td>
  </tr>
  <tr>
   <td width="5%" align="center">15</td>
   <td width="10%" align="center"><input type="checkbox" id="dhcpSrvMap15_enable" value="DISABLE" /></td>
   <td width="25%" ><input type="text" name="iw_dhcpSrvMap15_ipv4Addr" size="20" maxlength="15" value="<% iw_webCfgValueHandler("dhcpSrvMap15", "ipv4Addr", ""); %>" /></td>
   <td width="35%" ><input type="text" name="iw_dhcpSrvMap15_mac" size="22" maxlength="17" value="<% iw_webCfgValueHandler("dhcpSrvMap15", "mac", ""); %>" /></td>
  </tr>
  <tr>
   <td width="5%" align="center">16</td>
   <td width="10%" align="center"><input type="checkbox" id="dhcpSrvMap16_enable" value="DISABLE" /></td>
   <td width="25%" ><input type="text" name="iw_dhcpSrvMap16_ipv4Addr" size="20" maxlength="15" value="<% iw_webCfgValueHandler("dhcpSrvMap16", "ipv4Addr", ""); %>" /></td>
   <td width="35%" ><input type="text" name="iw_dhcpSrvMap16_mac" size="22" maxlength="17" value="<% iw_webCfgValueHandler("dhcpSrvMap16", "mac", ""); %>" /></td>
  </tr>
        <tr>
            <td colspan="4">
            <hr />
   <input type="submit" value="Submit" name="Submit">
    <input type="hidden" name="iw_dhcpSrvMap1_enable" value="DISABLE" />
    <input type="hidden" name="iw_dhcpSrvMap2_enable" value="DISABLE" />
    <input type="hidden" name="iw_dhcpSrvMap3_enable" value="DISABLE" />
    <input type="hidden" name="iw_dhcpSrvMap4_enable" value="DISABLE" />
    <input type="hidden" name="iw_dhcpSrvMap5_enable" value="DISABLE" />
    <input type="hidden" name="iw_dhcpSrvMap6_enable" value="DISABLE" />
    <input type="hidden" name="iw_dhcpSrvMap7_enable" value="DISABLE" />
    <input type="hidden" name="iw_dhcpSrvMap8_enable" value="DISABLE" />
    <input type="hidden" name="iw_dhcpSrvMap9_enable" value="DISABLE" />
    <input type="hidden" name="iw_dhcpSrvMap10_enable" value="DISABLE" />
    <input type="hidden" name="iw_dhcpSrvMap11_enable" value="DISABLE" />
    <input type="hidden" name="iw_dhcpSrvMap12_enable" value="DISABLE" />
    <input type="hidden" name="iw_dhcpSrvMap13_enable" value="DISABLE" />
    <input type="hidden" name="iw_dhcpSrvMap14_enable" value="DISABLE" />
    <input type="hidden" name="iw_dhcpSrvMap15_enable" value="DISABLE" />
    <input type="hidden" name="iw_dhcpSrvMap16_enable" value="DISABLE" />
          <input type="hidden" name="bkpath" value="/dhcp_srv.asp" />
            </td>
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
