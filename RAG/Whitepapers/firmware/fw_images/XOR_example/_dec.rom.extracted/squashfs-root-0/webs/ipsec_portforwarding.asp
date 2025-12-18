<HTML>
<HEAD>
 <META http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
 <LINK href="nport2g.css" rel="stylesheet" type="text/css">
 <TITLE><% iw_webSysDescHandler("IPSecPortForwarding", "Local 1:N NAT", ""); %></TITLE>
 <% iw_webJSList_get(); %>
 <script>

 // Global var
 var CGI_PREFIX = 'iw_ipsecportForwardingMap';
 var STR_PORTFORWARDING_ACTIVE = "active";
 var STR_PORTFORWARDING_PROTO = "protocol";
 var STR_PORTFORWARDING_PUBPORT = "pubPort";
 var STR_PORTFORWARDING_INTERNAL_IP = "internalIP";
 var STR_PORTFORWARDING_INTERNAL_PORT = "internalPort";
 var confData = <% iw_webGetIPSecPortForwardingToJSON(); %>;
 var err = 0;

 $(document).ready( function() {
  // Init Page
  iw_changeStateOnLoad(top);
  createPortForwardingMap();
  iw_fixCheckBoxs($('input[name$=_active]').filter('input[name^=iw_]'));
  // Event handler
  iw_event_selectCheckBoxAll($('input[name="PortForwardingSelAll"]'), $('input[name^=fk_]'));
  /* Check user input when form submmits */
  $('form').bind("submit", function() {
    if ( checkIP(STR_PORTFORWARDING_INTERNAL_IP) ||
       checkPort(STR_PORTFORWARDING_PUBPORT) ||
      checkPort(STR_PORTFORWARDING_INTERNAL_PORT) ||
      rowBindingCheck() ||
      checkSetSameValue(STR_PORTFORWARDING_PUBPORT) ) {
    return false; // form will not process
    }
   return true;
  });

 });

 /* Validation Functions */
 /* Return: 1 is error, 0 is ok */
 function checkIP ( subStr ) {
  var ip;
  for ( var i = 1; i <= confData['rules'].length; ++i ) {
   ip = $('input[name*="' + i + '_' + subStr + '"]')[0];
   if ( ip.value.length && ! verifyIP( ip, 'IP') ) {
    return 1;
   }
  }
  return 0;
 }
 /* Return: 1 is error, 0 is ok */
 function checkPort ( subStr ) {
  var port;
  for ( var i = 1; i <= confData['rules'].length; ++i ) {
   port = $('input[name*="' + i + '_' + subStr + '"]')[0];
   if ( port.value.length && ! isValidNumber(port, 1, 65535, "Port") ) {
    return 1;
   }
  }

  return 0;
 }

 /* Return: 1 is error, 0 is ok */
 function rowBindingCheck () {
  var c1, c2, c3;
  var err;
  for ( var i = 1; i <= confData['rules'].length ; ++i ) {
    c1 = Boolean($('#' + CGI_PREFIX + i + '_' +STR_PORTFORWARDING_PUBPORT )[0].value);
    c2 = Boolean($('#' + CGI_PREFIX + i + '_' +STR_PORTFORWARDING_INTERNAL_IP)[0].value);
    c3 = Boolean($('#' + CGI_PREFIX + i + '_' +STR_PORTFORWARDING_INTERNAL_PORT)[0].value);

   if ( $('input[id^=fk_' + i + ']').attr('checked') ){
    err = ! ( c1 & c2 & c3 );
   } else {
       err = ! ( !(c1 & c2 & c3) ^ (c1 | c2 | c3 ) );
   }
   if ( err ) {
    alert('Warning: exist an invalid input row');
    $('#' + CGI_PREFIX + i + '_' +STR_PORTFORWARDING_PUBPORT )[0].focus();
    return 1;
   }
  }
    return 0;
 }
 /* Return: 1 is error, 0 is ok */
 function checkSetSameValue(subStr) {
    var protoArr = [];
    var portArr = [];
    var err = 0;
    var i = 0;
    var now, next;

    $('input[id$=' + subStr + ']').each( function(index) {
      if ($(this).val() != "") {
   protoArr.push( $('#iw_ipsecportForwardingMap' + (index + 1) + '_protocol')[0] );
   portArr.push( $(this)[0] );
      }
    });

    for ( i = 0; i < protoArr.length - 1; ++i ) {
   now = protoArr[i].value + portArr[i].value;
   next = protoArr[i + 1].value + portArr[i + 1].value;
     if ( now == next ) {
    alert('Warning: exist a same value');
    portArr[i].focus();
    return 1;
   }
    }

    return 0;
 }

 /* When checkbox is disable, it does not send its value

	   A trick is to use a text input to send data instead of checkbox.

	 */
 function fixCheckBoxSend(ck, name) {
  $('#' + ck).after('<input type="hidden" name="'+ name + '" id="' + name + '"  value="DISABLE">');
  $('#' + ck).bind('change', function(event) {
   if ( $('#' + ck + ":checked").length ) {
    $('#' + name ).attr('checked', 'checked');
    $('#' + name ).val("ENABLE");
    $('#' + ck ).val("ENABLE");
   } else {
    $('#' + name ).val("DISABLE");
    $('#' + ck ).val("DISABLE");
   }
  });
 }
 /* Create table and load saved config data */
 function createPortForwardingMap() {
  var vstable = '';
  var prefix = '';
  for ( var i = 1; i <= confData['rules'].length; ++i ) {
   prefix = CGI_PREFIX + i + '_';
   vstable += '<tr>';
   vstable += '<td align="center" width="5%">' + i + '</td>';

   vstable += "<td align=\"center\" width=\"10%\"><input class=\"ruleAct\" type=\"checkbox\" id=\"" + iw_checkboxRealToHidden(prefix + STR_PORTFORWARDING_ACTIVE) + "\" name=\"" + iw_checkboxRealToHidden(prefix + STR_PORTFORWARDING_ACTIVE) + "\" value=\"DISABLE\" ></input></td>";
   vstable += '<input type="hidden" name="'+ prefix + STR_PORTFORWARDING_ACTIVE + '" id="' + prefix + STR_PORTFORWARDING_ACTIVE + '"  value="DISABLE">';
   vstable += '<td width="8%">';
   vstable += '<select name="' + prefix + STR_PORTFORWARDING_PROTO + '" id="' + prefix + STR_PORTFORWARDING_PROTO +'">'
   vstable += '<option value="TCP"> TCP </option>';
   vstable += '<option value="UDP"> UDP </option>';
   vstable += '</select></td>';
   vstable += "<td width=\"12%\"><input type=\"text\" id=\""+ prefix + STR_PORTFORWARDING_PUBPORT + "\" name=\""+ prefix + STR_PORTFORWARDING_PUBPORT + "\" size=\"10\"  maxlength=\"5\" value=\"\"></td>";
   vstable += "<td width=\"20%\"><input type=\"text\" id=\"" + prefix + STR_PORTFORWARDING_INTERNAL_IP + "\" name=\"" + prefix + STR_PORTFORWARDING_INTERNAL_IP + "\"  size=\"20\"  maxlength=\"15\" value=\"\" ></td>";
   vstable += "<td width=\"45%\"><input type=\"text\" id=\"" + prefix + STR_PORTFORWARDING_INTERNAL_PORT + "\" name=\"" + prefix + STR_PORTFORWARDING_INTERNAL_PORT + "\"  size=\"10\"  maxlength=\"5\" value=\"\" ></td>";
   vstable += '</tr>';
  }
  $('#PortForwarding tbody').append(vstable);

  for ( var i = 0, m = i + 1; i < confData['rules'].length; ++i, m = i + 1 ) {
   prefix = CGI_PREFIX + m + '_';
   if ( confData['rules'][i]['active'] == 'ENABLE' ) {
    $('#' + prefix + STR_PORTFORWARDING_ACTIVE ).val(confData['rules'][i]['active']);
    $('#fk_' + 'iw_ipsecportForwardingMap' + m + '_active').attr('checked', 'true');
    $('#fk_' + 'iw_ipsecportForwardingMap' + m + '_active').val('ENABLE');
   }
   $('#' + prefix + STR_PORTFORWARDING_PROTO +' option[value="' + confData['rules'][i]['protocol'] + '"]').attr('selected','selected');

   $('#' + prefix + STR_PORTFORWARDING_PUBPORT ).attr('value', confData['rules'][i]['pubPort']);
   $('#' + prefix + STR_PORTFORWARDING_INTERNAL_IP ).attr('value', confData['rules'][i]['internalIP']);
   $('#' + prefix + STR_PORTFORWARDING_INTERNAL_PORT ).attr('value', confData['rules'][i]['internalPort']);
  }
 }


  function editPermission()
  {
   var form = document.portforwarding, i, j = <% iw_websCheckPermission(); %>;
   if(j)
   {
    for(i = 0; i < form.length; i++)
     form.elements[i].disabled = true;
   }
  }


  function iw_ChangeOnLoad()
         {

                 editPermission();

                 top.toplogo.location.reload();
         }

 </script>
</HEAD>
<BODY onload="iw_ChangeOnLoad();">
 <H2><% iw_webSysDescHandler("IPSecPortForwarding", "Local 1:N NAT", ""); %> <% iw_websGetErrorString(); %> </H2>
 <div id="NATService" >
 <form name="portforwarding" id="portforwarding" method="POST" action="/forms/iw_webSetParameters" >
   <div id="PortForwarding" >
    <table width=100%>
     <thead>
      <tr align="left">
       <th align="center" width="5%" class="block_title">No</th>
       <th align="center" width="10%" class="block_title"><input type="checkbox" name="PortForwardingSelAll">Activate</th>
       <th align="center" width="8%" class="block_title"><% iw_webCfgDescHandler("ipsecportForwardingMap1", "protocol",""); %></th>
       <th width="12%" class="block_title"><% iw_webCfgDescHandler("ipsecportForwardingMap1", "pubPort",""); %></th>
       <th width="20%" class="block_title"><% iw_webCfgDescHandler("ipsecportForwardingMap1", "internalIP",""); %></th>
       <th width="45%" class="block_title"><% iw_webCfgDescHandler("ipsecportForwardingMap1", "internalPort",""); %></th>
      </tr>
     </thead>
     <tbody>
     </tbody>
     <tfoot>
     </tfoot>
    </table>
   </div>
  <hr>
  <input type="submit" value="Submit" name="Submit">
  <Input type="hidden" name="bkpath" value="/ipsec_portforwarding.asp">
 </form>
 </div>
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
