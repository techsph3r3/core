<HTML>
<HEAD>
 <META http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
    <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate" />
    <meta http-equiv="Pragma" content="no-cache" />
    <meta http-equiv="Expires" content="0" />
 <LINK href="nport2g.css" rel=stylesheet type=text/css>
 <TITLE><% iw_webSysDescHandler("NetworkSettingsTree", "", "Network Settings"); %></TITLE>
 <% iw_webJSList_get(); %>
 <SCRIPT>
<!--
//: ------------------------- Initial Setting -------------------------

  var apMode = new String("<% iw_webCfgValueHandler("wlanDevWIFI0", "operationMode", "AP"); %>");


  var dhcp_srv = new String("<%iw_webCfgValueHandler("dhcpSrv", "enable", "DISABLE");%>");



 function networkEntry( entryName, entryInterface, dhcp, ip, netmask, gateway, dns1, dns2 )



 {
  this.entryName = entryName;
  this.entryInterface = entryInterface;

  this.dhcp = dhcp;

  this.ip = ip ;
  this.netmask = netmask;
  this.gateway = gateway;
  this.dns1 = dns1;
  this.dns2 = dns2;
 }
 function dummyObj( value )
 {
  this.value = value;
 }

 var index;
 var networkSettings = <% iw_webGetNetworkSettings(); %>;
 var dnsValid = new Array();
 var gatewayValid = new Array();
 for (index = 0; index < networkSettings.length; index++)
 {
  dnsValid[index] = (networkSettings[index].dns1 != null && networkSettings[index].dns2 != null )?true:false;
  gatewayValid[index] = (networkSettings[index].gateway != "DISABLE" )?true:false;
 }
//: ------------------------- End Setting -------------------------
        function CheckValue(form)
        {
         var dummyIp = new dummyObj(null), dummyNetmask = new dummyObj(null), dummyGateway = new dummyObj(null);
   var dummyDhcp = new dummyObj(null);
      var msg = null, errorElement = null;
   var checkEntry, checkDnsValid, checkGatewayValid;
   var form_value;

         for( index = 0; index < networkSettings.length; index++ )
      {
       checkEntry = networkSettings[index];
          checkDnsValid = dnsValid[index];
          checkGatewayValid = gatewayValid[index];


    form_name = "iw_"+checkEntry.entryName+"_dhcp";
    dummyDhcp = document.getElementById(form_name);
    if ( checkDnsValid && dummyDhcp != null && dummyDhcp.value == "ENABLE" )
          {





     if( dhcp_srv.match("DISABLE")==null )

     {
      alert("When DHCP server is enabled, it is not allowed to set to DHCP mode in IP address assignment.");
      errorElement = "iw_"+checkEntry.entryName+"_dhcp";
                  break;
     }


     form_name = "iw_"+checkEntry.entryName+"_ipv4dns1";
              dummyIp = document.getElementById(form_name);
     if( dummyIp.value.length != 0 && dummyIp.value.length < 7 )
                    {
                        msg = "IP cannot be empty.";
                        errorElement = "iw_"+checkEntry.entryName+"_ipv4Addr";
                        break;
                    }

              if( !verifyIP( dummyIp, "<% iw_webCfgDescHandler("netDev1", "ipv4dns1", ""); %>") )
              {
                  errorElement = "iw_"+checkEntry.entryName+"_ipv4dns1";
                  break;
              }

     form_name = "iw_"+checkEntry.entryName+"_ipv4dns2";
              dummyIp = document.getElementById(form_name);
     if( dummyIp.value.length != 0 && dummyIp.value.length < 7 )
                    {
                        msg = "IP cannot be empty.";
                        errorElement = "iw_"+checkEntry.entryName+"_ipv4Addr";
                        break;
                    }

              if( !verifyIP( dummyIp, "<% iw_webCfgDescHandler("netDev1", "ipv4dns2", ""); %>") )
              {
                  errorElement = "iw_"+checkEntry.entryName+"_ipv4dns2";
                  break;
              }

       } else

          {
     /* Get the form IP address */
     form_name = "iw_"+checkEntry.entryName+"_ipv4Addr";
     dummyIp = document.getElementById(form_name);
              if( dummyIp.value.length < 7 )
              {
                  msg = "IP cannot be empty.";
                  errorElement = "iw_"+checkEntry.entryName+"_ipv4Addr";
                  break;
              }

           if( !verifyIP( dummyIp, "<% iw_webCfgDescHandler("netDev1", "ipv4Addr", ""); %>") )
              {
                  errorElement = "iw_"+checkEntry.entryName+"_ipv4Addr";
                  break;
              }

              if( !verifyMulticastIP( dummyIp, "<% iw_webCfgDescHandler("netDev1", "ipv4Addr", ""); %>") )
              {
                  alert("<% iw_webCfgDescHandler("netDev1", "ipv4Addr", ""); %>" + " is multicast IP: " + dummyIp.value + "");
                  errorElement = "iw_"+checkEntry.entryName+"_ipv4Addr";
                  break;
              }

              if( !verifyReservedIP( dummyIp, "<% iw_webCfgDescHandler("netDev1", "ipv4Addr", ""); %>") )
              {
                  errorElement = "iw_"+checkEntry.entryName+"_ipv4Addr";
                  break;
              }

     /* Netmask */
     form_name = "iw_"+checkEntry.entryName+"_ipv4Mask";
              dummyNetmask = document.getElementById(form_name);
              if( !verifyNetmask( dummyNetmask, "<% iw_webCfgDescHandler("netDev1", "ipv4Mask", ""); %>") )
              {
                  errorElement = "iw_"+checkEntry.entryName+"_ipv4Mask";
                  break;
              }

              if( !verifyBroadcastIP( dummyIp, dummyNetmask, "<% iw_webCfgDescHandler("netDev1", "ipv4Addr", ""); %>") )
              {
                  errorElement = "iw_"+checkEntry.entryName+"_ipv4Mask";
                  break;
              }

        if( checkGatewayValid )
        {
      form_name = "iw_"+checkEntry.entryName+"_ipv4GateWay";
      dummyGateway = document.getElementById(form_name);
      if( !verifyIP( dummyGateway, "<% iw_webCfgDescHandler("netDev1", "ipv4GateWay", ""); %>") )
      {
          errorElement = "iw_"+checkEntry.entryName+"_ipv4GateWay";
          break;
      }

      if ( dummyGateway.value.length > 0)
      {
          if( !isSameSubnet( dummyIp, dummyNetmask, dummyGateway ) )
          {
        msg = "IP address and Gateway are not at the same subnet.";
        errorElement = "iw_"+checkEntry.entryName+"_ipv4GateWay";
        break;
          }
      }
        }
          }
   }

      if( errorElement != null )
      {
          if( msg != null )
              alert( msg );
          document.getElementById(errorElement).focus();
          return false;
      }
      return true;
  }

        function iw_dhcpSet(x)
  {
   var currentDnsValid = dnsValid[x];
   var currentGatewayValid = gatewayValid[x];


   if (!currentDnsValid && apMode == "CLIENT_ROUTER")
   { //: netDevLan => item: ipv4Addr, ipv4Mask  	
    return;
   }


   var disableState = currentDnsValid & document.getElementById( "iw_"+ networkSettings[x].entryName +"_dhcp" ).value == "ENABLE" ? true : false;



   document.getElementById( "iw_"+ networkSettings[x].entryName +"_ipv4Addr" ).disabled = disableState;
   document.getElementById( "iw_"+ networkSettings[x].entryName +"_ipv4Mask" ).disabled = disableState;
   if (currentGatewayValid)
   {
    document.getElementById( "iw_"+ networkSettings[x].entryName +"_ipv4GateWay" ).disabled = disableState;
   }
  }

        function iw_formOnLoad(form)
        {
         for( index = 0; index < networkSettings.length; index++ )
   {

    if( index > 0 && apMode != "CLIENT_ROUTER" )
    {
     break;
    }

    iw_dhcpSet( index );
   }
        }


        function editPermission()
        {
                var form = document.network, i, j = <% iw_websCheckPermission(); %>;
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
</HEAD>
<BODY onLoad="iw_formOnLoad(this);iw_ChangeOnLoad();">
 <H2><% iw_webSysDescHandler("NetworkSettingsTree", "", "Network Settings"); %> <% iw_websGetErrorString(); %></H2>
 <FORM name="network" method="post" action="/forms/iw_webSetParameters" onSubmit="return CheckValue(this)">
<script type="text/javascript">

 var idx;
 for( idx = 0; idx < networkSettings.length; idx++ )
 {
  document.write( '<table width="100%">' );
  if (networkSettings[idx].entryInterface != "")
  {
   document.write( '<tr  id="iw_interface' + idx + '"><td width="100%" class="block_title">' + networkSettings[idx].entryInterface + '<\/td>' );
   document.write( '</table>' );
   document.write( '<table width="100%">' );
  }
  document.write( '<\/tr>' );

  if(dnsValid[idx])
  {

   document.write( '<tr id="setDhcp' + idx + '" style="display:' + (dnsValid[idx]?'':'none') + '"><td width="30%" class="column_title"><% iw_webCfgDescHandler("netDev1", "dhcp", "IP configuration"); %><\/td>' );
   document.write( '<td width="70%"><select id="iw_' + networkSettings[idx].entryName + '_dhcp" name="iw_' + networkSettings[idx].entryName + '_dhcp" onChange="iw_dhcpSet('+idx+');">' );
   document.write( '<option value="ENABLE" ' + (networkSettings[idx].dhcp=="ENABLE"?'selected':'') + '>DHCP<\/option>' );
   document.write( '<option value="DISABLE" ' + (networkSettings[idx].dhcp=="DISABLE"?'selected':'') + '>Static<\/option>' );
   document.write( '<\/select><\/td><\/tr>' );

  }

  document.write( '<tr><td width="30%" class="column_title"><% iw_webCfgDescHandler("netDev1", "ipv4Addr", "IP address"); %><\/td>' );
  document.write( '<td width="70%"><input type="text" id="iw_' + networkSettings[idx].entryName + '_ipv4Addr" name="iw_' + networkSettings[idx].entryName + '_ipv4Addr" size="20" maxlengh="15" value="' + networkSettings[idx].ip + '" \/>' );
  document.write( '<\/td><\/tr>' );

  document.write( '<tr><td width="30%" class="column_title"><% iw_webCfgDescHandler("netDev1", "ipv4Mask", "Netmask"); %><\/td>' );
  document.write( '<td width="70%"><input type="text" id="iw_' + networkSettings[idx].entryName + '_ipv4Mask" name="iw_' + networkSettings[idx].entryName + '_ipv4Mask" size="20" maxlengh="15" value="' + networkSettings[idx].netmask + '" \/>' );
  document.write( '<\/td><\/tr>' );
  if(gatewayValid[idx])
  {
   document.write( '<tr id="setGateway' + idx + '"><td width="30%" class="column_title"><% iw_webCfgDescHandler("netDev1", "ipv4GateWay", "Netmask"); %><\/td>' );
   document.write( '<td width="70%"><input type="text" id="iw_' + networkSettings[idx].entryName + '_ipv4GateWay" name="iw_' + networkSettings[idx].entryName + '_ipv4GateWay" size="20" maxlengh="15" value="' + networkSettings[idx].gateway + '" \/>' );
   document.write( '<\/td><\/tr>' );
  }

  if(dnsValid[idx])
  {
   document.write( '<tr id="setDns1' + idx + '" style="display:' + (dnsValid[idx]?'':'none') + '"><td width="30%" class="column_title"><% iw_webCfgDescHandler("netDev1", "ipv4dns1", "Primary DNS server"); %><\/td>' );
   document.write( '<td width="70%"><input type="text" id="iw_' + networkSettings[idx].entryName + '_ipv4dns1" name="iw_' + networkSettings[idx].entryName + '_ipv4dns1" size="20" maxlengh="15" value="' + networkSettings[idx].dns1 + '" \/>' );
   document.write( '<\/td><\/tr>' );

   document.write( '<tr id="setDns2' + idx + '" style="display:' + (dnsValid[idx]?'':'none') + '"><td width="30%" class="column_title"><% iw_webCfgDescHandler("netDev1", "ipv4dns2", "Secondary DNS server"); %><\/td>' );
   document.write( '<td width="70%"><input type="text" id="iw_' + networkSettings[idx].entryName + '_ipv4dns2" name="iw_' + networkSettings[idx].entryName + '_ipv4dns2" size="20" maxlengh="15" value="' + networkSettings[idx].dns2 + '" \/>' );
   document.write( '<\/td><\/tr>' );
  }
  document.write( '</table>' );
 }

 document.write( '<table width="100%">' );
 document.write( '<tr><td colspan="2"><hr \/>' );
 document.write( '<input type="submit" value="Submit" name="Submit" \/>' );
 document.write( '<input type="hidden" name="bkpath" value="/network_basic.asp" \/>' );
 document.write( '<\/td><\/tr><\/table>' );
</script>
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
