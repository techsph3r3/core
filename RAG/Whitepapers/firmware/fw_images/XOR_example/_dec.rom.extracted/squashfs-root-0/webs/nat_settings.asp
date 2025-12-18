<HTML>
<HEAD>
 <META http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
    <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate" />
    <meta http-equiv="Pragma" content="no-cache" />
    <meta http-equiv="Expires" content="0" />
 <LINK href="nport2g.css" rel=stylesheet type=text/css>
 <TITLE><% iw_webSysDescHandler("NATSettingTree", "", "NAT Settings"); %></TITLE>
 <% iw_webJSList_get(); %>
 <script type="text/javascript">
<!--

 var opMode = new String( "<% iw_webCfgValueHandler( "wlanDevWIFI0", "operationMode", "AP" ); %>" );



 function portForwardingEntry( Active, Protocol, WANPort, LANIP, LANPort )
 {
  this.Active = Active;
  this.Protocol = Protocol;
  this.WANPort = WANPort,
  this.LANIP = LANIP;
  this.LANPort = LANPort;
 }

 var portForwarding = <% iw_webGetPortForwardingArray(); %>;

 function selall()
 {
  var selStatus = document.getElementById('SelAll').checked;
  var formElements = document.forms['natSettings'].elements;

  for( i = 0; i < formElements.length; i++ )
  {
   formElement = formElements[i];
   if( formElement.type == 'checkbox' &&
     formElement.id.match(/Active[0-9]*/) )
   {
    formElement.checked = selStatus;
   }
  }
 }

 function iw_onChange_portForwarding()
 {
  var formElements = document.forms['natSettings'].elements;

  for( i = 0; i < formElements.length; i++ )
  {
   formElement = formElements[i];
   if( (formElement.name.match("portForwarding") && !formElement.name.match("portForwardingservice")) ||
     formElement.id.match(/Active[0-9]*/) ||
     formElement.id.match("SelAll") )
   {
    if( document.natSettings.iw_portForwardingservice_portForwardingserviceEnable.value == "ENABLE" ) {
     formElement.disabled = false;
    } else {
     formElement.disabled = true;
    }
   }
  }
 }

 function ActiveChange()
 {
  var selStatus = true;
  var formElements = document.forms['natSettings'].elements;

  for( i = 0; i < formElements.length; i++ )
  {
   formElement = formElements[i];
   if( formElement.type == 'checkbox' &&
     formElement.id.match(/Active[0-9]*/) &&
     (!formElement.checked) )
   {
    selStatus = false;
    break;
   }
  }
  document.getElementById('SelAll').checked = selStatus;
 }


 function iw_onSubmit(form)
 {

  var formElements = document.forms['natSettings'].elements;
                var elementName, tmpElement, elementIndex, cmpName, cmpElement, cmpIndex;

  for( i = 0; i < formElements.length; i++ )
  {
   var formElement = formElements[i];
   if(formElement.type == 'checkbox' && formElement.id.match(/Active[0-9]*/) )
   for(j = i + 5; j < formElements.length; j++){
    var sameIP = 0;
                         var sameWANPort = 0;
    var cmpformElement = formElements[j];

    if( cmpformElement.type == 'checkbox' && cmpformElement.id.match(/Active[0-9]*/))
    {
     elementIndex = formElements[i].id.replace(/Active([0-9]*)/, "$1");
     cmpIndex = cmpformElement.id.replace(/Active([0-9]*)/, "$1");

     elementName = "iw_portForwarding" + elementIndex + "_enable";
     cmpName = "iw_portForwarding" + cmpIndex + "_enable";
     document.getElementsByName(cmpName)[0].value = (cmpformElement.checked?"ENABLE":"DISABLE");
     document.getElementsByName(elementName)[0].value = (formElement.checked?"ENABLE":"DISABLE");

     elementName = "LANIP" + elementIndex;
     cmpName = "LANIP" + cmpIndex;
     tmpElement = document.getElementById(elementName);
     cmpElement = document.getElementById(cmpName);
     if( !verifyIP( tmpElement, "<% iw_webCfgDescHandler("portForwarding1", "lanIP", "LAN IP"); %> " + elementIndex) )
     {
      tmpElement.focus();
      return false;
     }
     sameIP = isSameIP(tmpElement, cmpElement);
     elementName = "LANPort" + elementIndex;
     cmpName = "LANPort" + cmpIndex;
     tmpElement = document.getElementById(elementName);
     cmpElement = document.getElementById(cmpName);

     if( tmpElement.value != "" && !isValidPort( tmpElement, "<% iw_webCfgDescHandler("portForwarding1", "lanPort", "LAN Port"); %>") )
     {
      tmpElement.focus();
      return false;
     }
     /*

					if(tmpElement.value == cmpElement.value && sameIP == 1){

						alert("Can't set same IP with same LAN Port.");

						cmpElement.focus();

						return false;

					}

					*/
     elementName = "WANPort" + elementIndex;
     cmpName = "WANPort" + cmpIndex;
     cmpElement = document.getElementById(cmpName);
     tmpElement = document.getElementById(elementName);
     if( cmpElement.value != "" && !isValidPort( cmpElement, "<% iw_webCfgDescHandler("portForwarding1", "wanPort", "WAN Port"); %>"))
     {
      cmpElement.focus();
      return false;
     }
     // Check if there are two rules with same protocol and WAN port
     if((tmpElement.value == cmpElement.value) && cmpElement.value != "")
      sameWANPort=1;
     elementName = "Protocol" + elementIndex;
     cmpName = "Protocol" + cmpIndex;
     cmpElement = document.getElementById(cmpName);
     tmpElement = document.getElementById(elementName);
     if(tmpElement.value == cmpElement.value && sameWANPort == 1){
      alert("Can't set same Protocol with same WAN Port.");
      cmpElement.focus();
      return false;
     }
    }
   }
  }

  return true;
 }


        function editPermission()
        {
                var form = document.natSettings, i, j = <% iw_websCheckPermission(); %>;
                if(j)
                {
                        for(i = 0; i < form.length; i++)
                                form.elements[i].disabled = true;
                }
        }


 function iw_onLoad()
 {

  iw_selectSet(document.natSettings.iw_nat_natEnable, "<% iw_webCfgValueHandler("nat", "natEnable", "DISABLE");  %>");


  iw_selectSet(document.natSettings.iw_portForwardingservice_portForwardingserviceEnable, "<% iw_webCfgValueHandler("portForwardingservice", "portForwardingserviceEnable", "DISABLE");  %>");


  if( opMode != "CLIENT-ROUTER" )
  {
   var formElements = document.forms['natSettings'].elements;
   for( i = 0; i < formElements.length; i++ )
   {
    formElements[i].disabled = true;
   }
  }

  else
  {
   iw_onChange_portForwarding();
   ActiveChange();
  }







                editPermission();


  top.toplogo.location.reload();
 }
-->
 </Script>
</HEAD>
<BODY onLoad="iw_onLoad();">

 <H2><% iw_webSysDescHandler("NATSettingTree", "", "NAT Settings"); %> (For Client-Router mode only)&nbsp;&nbsp;<% iw_websGetErrorString(); %></H2>



 <FORM name="natSettings" method="post" action="/forms/iw_webSetParameters" onSubmit="return iw_onSubmit(this)">

 <table width="100%">
 <tr>
  <td width="30%" class="column_title"><% iw_webCfgDescHandler("nat", "natEnable", "Nat enable"); %></td>
  <td width="70%">
   <select size="1" id="iw_nat_natEnable" name="iw_nat_natEnable">
    <option value="ENABLE">Enable</option>
    <option value="DISABLE">Disable</option>
   </select>
  </td>
 </tr>
    </table>


 <table width="100%">
 <tr>
  <td width="30%" class="column_title">Port forwarding</td>
  <td width="70%">
   <select size="1" id="iw_portForwardingservice_portForwardingserviceEnable" name="iw_portForwardingservice_portForwardingserviceEnable" onChange="iw_onChange_portForwarding();">
    <option value="ENABLE">Enable</option>
    <option value="DISABLE">Disable</option>
   </select>
  </td>
 </tr>
    </table>
 <TABLE width="100%">
 <TR align="left">
  <TD width="10%" align="center" class="block_title">No.</TD>
  <TD width="15%" align="center" class="block_title"><INPUT type="checkbox" id="SelAll" onclick="selall()";>Active</TD>
  <TD width="15%" class="block_title"><% iw_webCfgDescHandler("portForwarding1", "protocol",""); %></TD>
  <TD width="15%" class="block_title"><% iw_webCfgDescHandler("portForwarding1", "wanPort",""); %></TD>
  <TD width="15%" class="block_title"><% iw_webCfgDescHandler("portForwarding1", "lanIP",""); %></TD>
  <TD width="30%" class="block_title"><% iw_webCfgDescHandler("portForwarding1", "lanPort",""); %></TD>
 </TR>
<script type="text/javascript">
<!--
 var i, portForwardingIndex;
 for( i = 0; i < portForwarding.length; i++ )
 {
  portForwardingIndex = i+1;
  document.write( '<tr><td align="center">' + portForwardingIndex + '<\/td>');
  document.write( '<td align="center"><input type="checkbox" id="Active' + portForwardingIndex + '" onClick="ActiveChange();"' + ((portForwarding[i].Active=='ENABLE'?' checked ':'')) + '\/><\/td>' );
  document.write( '<td><select id="Protocol' + portForwardingIndex + '" name="iw_portForwarding' + portForwardingIndex + '_protocol" size="1" \/>' );
  document.write( '<option value="TCP" ' + (portForwarding[i].Protocol=='TCP'?' selected ':'') + ' >TCP<\/option>' );
  document.write( '<option value="UDP" ' + (portForwarding[i].Protocol=='UDP'?' selected ':'') + ' >UDP<\/option><\/select><\/td>' );
  document.write( '<td><input type="text" id="WANPort' + portForwardingIndex + '" name="iw_portForwarding' + portForwardingIndex + '_wanPort" value="' + portForwarding[i].WANPort + '" \/><\/td>' );
  document.write( '<td><input type="text" id="LANIP' + portForwardingIndex + '" name="iw_portForwarding' + portForwardingIndex + '_lanIP" value="' + portForwarding[i].LANIP + '" \/><\/td>' );
  document.write( '<td><input type="text" id="LANPort' + portForwardingIndex + '" name="iw_portForwarding' + portForwardingIndex + '_lanPort" value="' + portForwarding[i].LANPort + '" \/><\/td>' );
  document.write( '<\/tr>');
 }
//-->
</script>
 </TABLE>


 <hr>
 <input type="submit" id="Submit" name="Submit" value="Submit">
 <Input type="hidden" name="bkpath" value="/nat_settings.asp" />

<script type="text/javascript">
<!--
 var i, portForwardingIndex;
 for( i = 0; i < portForwarding.length; i++ )
 {
  portForwardingIndex = i+1;
  document.write( '<input type="hidden" name="iw_portForwarding' + portForwardingIndex + '_enable" value="' + portForwarding[i].Active + '" />' );
 }
//-->
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
