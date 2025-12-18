<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%
 if ( iw_isset(devIndex) == 0 )
 {
  devIndex = 0;
 }

 if ( iw_isset(vapIndex) == 0 )
 {
  vapIndex = 0;
 }
%>
<html>
<head>
 <link href="nport2g.css" rel="stylesheet" type="text/css">
 <title><% iw_webSysDescHandler("AssociatedClientListTree", "", "Associated Client List"); %></title>
 <% iw_webJSList_get(); %>
 <script type="text/javascript" >
 <!--
  var Wlans = <% iw_webGetRfIndexSSIDarray(0); %>;

  function iw_onLoad()
  {
   var rfindexElement = document.getElementById('devIndex');
   var i, newItem;

   if( 0 == Wlans.length )
   {
    rfindexElement.disabled = true;
   }else
   {
    rfindexElement.disabled = false;
    for( i = 0; i < Wlans.length; i++ )
    {
     newItem = document.createElement("option");
     newItem.value = Wlans[i].devIndex + '_' + Wlans[i].vapIndex;



     newItem.text = 'WLAN (SSID: ' + Wlans[i].ssid + ')';

     rfindexElement.options.add(newItem);
    }

    iw_selectSet( rfindexElement, '<% write(devIndex); %>_<% write(vapIndex); %>' );
    WlanRedir();
   }
  }

  function WlanRedir()
  {
   var rfindexElement = document.getElementById('devIndex');
   var devValue = rfindexElement.options[rfindexElement.selectedIndex].value;
   if( '<% write(devIndex); %>_<% write(vapIndex); %>' != devValue )
    document.location.href='client_list.asp?devIndex='+devValue.split('_')[0]+'&vapIndex='+devValue.split('_')[1];
  }
//#endif
 -->
 </script>
</head>
 <body onLoad = "iw_onLoad();">



 <h2><% iw_webSysDescHandler("AssociatedClientListTree", "", "Associated Client List"); %></h2>

 <form name="clientlist" method="post" action="client_list.asp?devIndex=<% write(devIndex); %>">
  <table width="100%">

   <tr>
    <td width="30%" class="column_title">Show&nbsp;clients&nbsp;for&nbsp;
     <select id="devIndex" name="devIndex" size="1" onChange="document.location.href='client_list.asp?devIndex='+this.options[this.selectedIndex].value.split('_')[0]+'&vapIndex='+this.options[this.selectedIndex].value.split('_')[1];">
     </select>
    </td>
   </tr>
  </table>
  <% iw_webGetClientListData(devIndex, vapIndex); %>
  <table>
   <tr>
       <td>
     <hr>



     <input type="button" name="Refresh" value="Refresh" onClick="window.location.reload()">
     <input type="hidden" name="bkpath" value="/client_list.asp">
    </td>
         </tr>
        </table>
 </form>
</body>
</html>
