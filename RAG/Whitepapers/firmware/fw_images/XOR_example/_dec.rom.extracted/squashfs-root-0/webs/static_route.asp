
<html>
<head>
 <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
    <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate" />
    <meta http-equiv="Pragma" content="no-cache" />
    <meta http-equiv="Expires" content="0" />
 <link href="nport2g.css" rel=stylesheet type=text/css>
 <title>Static Route</title>
 <% iw_webJSList_get(); %>
 <script type="text/javascript">
 <!--
   var mem_state = <% iw_websMemoryChange(); %>;
  var opMode = new String( "<% iw_webCfgValueHandler( "wlanDevWIFI0", "operationMode", "AP" ); %>" );

  function tmpObj( value )
  {
   this.value = value;
  }

  var LanIp = new tmpObj( "<% iw_webCfgValueHandler( "netDevLan", "ipv4Addr", "192.168.127.253" ); %>" );
  var LanMask = new tmpObj( "<% iw_webCfgValueHandler( "netDevLan", "ipv4Mask", "255.255.255.0" ); %>" );
  var WlanIp = new tmpObj( "<% iw_webCfgValueHandler( "netDevWlan", "ipv4Addr", "192.168.128.253" ); %>" );
  var WlanMask = new tmpObj( "<% iw_webCfgValueHandler( "netDevWlan", "ipv4Mask", "255.255.255.0" ); %>" );
  var WlanGateway = new tmpObj( "<% iw_webCfgValueHandler( "netDevWlan", "ipv4GateWay", "" ); %>" );
  var WlanDHCP = new tmpObj( "<% iw_webCfgValueHandler( "netDevWlan", "dhcp", "DISABLE" ); %>" );

  function routeEntry( Active, Dst, Netmask, Gateway, Metric, Interface )
  {
   this.Active = Active;
   this.Dst = Dst;
   this.Netmask = Netmask;
   this.Gateway = Gateway;
   this.Metric = Metric;
   this.Interface = Interface;
  }

  var staticRoute = <% iw_webGetStaticRouteArray(); %>;

  function selall()
  {
   var selStatus = document.getElementById('SelAll').checked;
   var formElements = document.forms['static_route'].elements;
   for( i = 0; i < formElements.length; i++ )
   {
    formElement = formElements[i];
    if( formElement.type == 'checkbox' &&
     formElement.id.match(/Active[0-9]*/) )
     formElement.checked = selStatus;
   }
  }

  function iw_onSubmit()
  {
   var formElements = document.forms['static_route'].elements;
   var elementName, ipElement, maskElement, gatewayElement, tmpElement, elementIndex;
   for( i = 0; i < formElements.length; i++ )
   {
    formElement = formElements[i];
    if( formElement.type == 'checkbox' &&
     formElement.id.match(/Active[0-9]*/) )
    {
     elementIndex = formElement.id.replace(/Active([0-9]*)/, "$1");

     elementName = "iw_staticRoute" + elementIndex + "_enable";
     document.getElementsByName(elementName)[0].value = (formElement.checked?"ENABLE":"DISABLE");

     if( formElement.checked )
     {
      elementName = "Dst" + elementIndex;
      tmpElement = document.getElementById(elementName);
      ipElement = tmpElement;
      if( !verifyMulticastIP( tmpElement, "<% iw_webCfgDescHandler("staticRoute1", "ipv4DstAddr", "Destination"); %> " + elementIndex) )
      {
       alert("<% iw_webCfgDescHandler("staticRoute1", "ipv4DstAddr", "Destination"); %> " + " is multicast IP: " + tmpElement.value + "");
       tmpElement.focus();
                return false;
            }
                        if( !verifyReservedIP( tmpElement, "<% iw_webCfgDescHandler("staticRoute1", "ipv4DstAddr", "Destination"); %> " + elementIndex) )
                        {
                            tmpElement.focus();
                            return false;
                        }

                     elementName = "Netmask" + elementIndex;
      tmpElement = document.getElementById(elementName);
      maskElement = tmpElement;

                        if( !verifyNetmask( tmpElement, "<% iw_webCfgDescHandler("staticRoute1", "ipv4Netmask", "Netmask"); %> " + elementIndex) )
                        {
                            tmpElement.focus();
                            return false;
                        }

                        if( !isValidIpMaskPair( ipElement, maskElement, "Entry " + elementIndex ) )
                        {
                            ipElement.focus();
                            return false;
                        }

      elementName = "Gateway" + elementIndex;
      tmpElement = document.getElementById(elementName);
      gatewayElement = tmpElement;
                        if( !verifyIP( tmpElement, "<% iw_webCfgDescHandler("staticRoute1", "ipv4Gateway", "Gateway"); %> " + elementIndex) )
                        {
                            tmpElement.focus();
                            return false;
                        }

      elementName = "Interface" + elementIndex;
      tmpElement = document.getElementById(elementName);
      if( tmpElement.options[tmpElement.selectedIndex].value == "LAN" &&
       gatewayElement.value.length > 0 &&
       !isSameSubnet( LanIp, LanMask, gatewayElement, "Entry " + elementIndex ) )
      {
                            window.alert("Gateway need to be in the same subnet with device LAN interface.")
       gatewayElement.focus();
                            return false;
      }

         if( WlanDHCP.value == "DISABLE" &&
                            tmpElement.options[tmpElement.selectedIndex].value == "WLAN" &&
       gatewayElement.value.length > 0 &&
       !isSameSubnet( WlanIp, WlanMask, gatewayElement, "Entry " + elementIndex ) )
      {
                            window.alert("Gateway need to be in the same subnet with device WLAN interface.")
       gatewayElement.focus();
                            return false;
      }

      elementName = "Metric" + elementIndex;
      tmpElement = document.getElementById(elementName);
      if( !isValidNumber( tmpElement, 0, 32766, "<% iw_webCfgDescHandler("staticRoute1", "metric", "Metric"); %>") )
      {
       tmpElement.focus();
       return false;
      }
     }
    }
   }

   return true;
  }

  function ActiveChange()
  {
   var selStatus = true;
   var formElements = document.forms['static_route'].elements;

   if( opMode != "CLIENT-ROUTER" )
   {
    for( i = 0; i < formElements.length; i++ )
    {
     formElements[i].disabled = true;
    }
   }else
   {
    for( i = 0; i < formElements.length; i++ )
    {
     formElement = formElements[i];
     if( formElement.type == 'checkbox' &&
      formElement.id.match(/Active[0-9]*/) )
      if( !formElement.checked )
      {
       selStatus = false;
       break;
      }
    }
    document.getElementById('SelAll').checked = selStatus;
   }
  }


  function editPermission()
  {
   var form = document.static_route, i, j = <% iw_websCheckPermission(); %>;
   if(j)
   {
    for(i = 0; i < form.length; i++)
     form.elements[i].disabled = true;
   }
  }


  function iw_onLoad()
  {
   ActiveChange();

                 editPermission();

   top.toplogo.location.reload();
  }
        //-->
    </script>
</head>
<body onLoad="iw_onLoad();">

 <h2><% iw_webSysDescHandler( "StaticRouteTree", "", "Static Route" ); %> (For Client-Router mode only)&nbsp;&nbsp;<% iw_websGetErrorString(); %></h2>

 <form name="static_route" method="post" action="/forms/iw_webSetParameters" onSubmit="return iw_onSubmit();">
 <table width="100%">

 <tr><td colspan="2" class="block_seperator"></td></tr>
 <tr align="left">
  <td width="5%" align="center" class="block_title">No.</td>
  <td width="10%" align="center" class="block_title"><input type="checkbox" id="SelAll" onclick="selall();" /><% iw_webCfgDescHandler("staticRoute1", "enable", "Active"); %></td>
  <td width="20%" class="block_title"><% iw_webCfgDescHandler("staticRoute1", "ipv4DstAddr", "Destination"); %></td>
  <td width="20%" class="block_title"><% iw_webCfgDescHandler("staticRoute1", "ipv4Netmask", "Netmask"); %></td>
  <td width="20%" class="block_title"><% iw_webCfgDescHandler("staticRoute1", "ipv4Gateway", "Gateway"); %></td>
  <td width="10%" class="block_title"><% iw_webCfgDescHandler("staticRoute1", "metric", "Metric"); %></td>
  <td width="15%" class="block_title"><% iw_webCfgDescHandler("staticRoute1", "interface", "Interface"); %></td>
 </tr>
<script type="text/javascript">
<!--
 var i, routeIndex;
 for( i = 0; i < staticRoute.length; i++ )
 {
  routeIndex = i+1;
  document.write( '<tr><td align="center">' + routeIndex + '<\/td>');
  document.write( '<td align="center"><input type="checkbox" id="Active' + routeIndex + '" onClick="ActiveChange();"' + ((staticRoute[i].Active=='ENABLE'?' checked ':'')) + '\/><\/td>' );
  document.write( '<td><input type="text" maxlength="15" size="18" id="Dst' + routeIndex + '" name="iw_staticRoute' + routeIndex + '_ipv4DstAddr" value="' + staticRoute[i].Dst + '" \/><\/td>' );
  document.write( '<td><input type="text" maxlength="15" size="18" id="Netmask' + routeIndex + '" name="iw_staticRoute' + routeIndex + '_ipv4Netmask" value="' + staticRoute[i].Netmask + '" \/><\/td>' );
  document.write( '<td><input type="text" maxlength="15" size="18" id="Gateway' + routeIndex + '" name="iw_staticRoute' + routeIndex + '_ipv4Gateway" value="' + staticRoute[i].Gateway + '" \/><\/td>' );
  document.write( '<td><input type="text" maxlength="4" size="5" id="Metric' + routeIndex + '" name="iw_staticRoute' + routeIndex + '_metric" value="' + staticRoute[i].Metric + '" \/><\/td>' );
  document.write( '<td><select size="1" id="Interface' + routeIndex + '" name="iw_staticRoute' + routeIndex + '_interface" >');
  document.write( '<option value="LAN"' + (staticRoute[i].Interface=='LAN'?' selected ':'') + '>LAN<\/option>' );
  document.write( '<option value="WLAN"' + (staticRoute[i].Interface=='WLAN'?' selected ':'') + '>WLAN<\/option><\/select><\/td><\/tr>' );
 }
//-->
</script>
 <tr>
  <td colspan="7">
   <hr>
   <input type="submit" value="Submit" name="Submit">
   <input type="hidden" name="bkpath" value="/static_route.asp">
<script type="text/javascript">
<!--
 var i, routeIndex;
 for( i = 0; i < staticRoute.length; i++ )
 {
  routeIndex = i+1;
  document.write( '<input type="hidden" name="iw_staticRoute' + routeIndex + '_enable" value="' + staticRoute[i].Active + '" />' );
 }
//-->
</script>
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
