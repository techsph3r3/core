<html>
<head>
        <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
        <link href="nport2g.css" rel="stylesheet" type="text/css">
        <TITLE><% iw_webSysDescHandler("GPSSerialSetting", "", "GPS Serial Modes"); %></TITLE>
  <% iw_webJSList_get(); %>
        <script type="text/javascript">
 <!--
  function CheckValue()
  {
   var form = document.opmode;
   {
     var i;
     alphanum = " ";
     for (i=0; i <form.RasppDestHost1.value.length; i++)
     {
      if ((form.RasppDestHost1.value.charAt(i)) == " ")
      {
       return false;
      }
     }
     if( !isValidNumber(form.RasppTcpAlive, 0, 99, "<% iw_webCfgDescHandler("gpscomsetting", "tcpalive", "TCP alive check time"); %>") ){
      form.RasppTcpAlive.focus();
      return false;
     }

     if (form.iw_gps_com.value == "Reverse RealCOM")
     {
      if (form.RasppDestHost1.value == "") {
       alert("You should at least specify one host to connect.");
       form.RasppDestHost1.focus();
       return false;
      }

      if( !isValidNumber(form.RasppDestDataPort1, 1, 65535, "Destination TCP port") ){
       form.RasppDestDataPort1.focus();
       return false;
      }

      if( !isValidNumber(form.RasppDestCmdPort1, 1, 65535, "Destination Cmd port") ){
       form.RasppDestCmdPort1.focus();
       return false;
      }

      if( !isValidNumber(form.RasppLocalDataPort1, 0, 65535, "Designated local TCP port 1") ){
       form.RasppLocalDataPort1.focus();
       return false;
      }

      if( !isValidNumber(form.RasppLocalCmdPort1, 0, 65535, "Designated local cmd port 1") ){
       form.RasppLocalCmdPort1.focus();
       return false;
      }
     }

   }
   form.submit();
   return true;
  }


         function iw_change()
                {
                        var type = document.getElementById("iw_gps_com").options[document.getElementById("iw_gps_com").selectedIndex].value;
                        if (type == "Reverse RealCOM")
                        {
                                document.getElementById("opmodeTableId").disabled = false;
                                document.getElementById("opmodeTableId").style.display = "";

    document.getElementById("RasppDestHost1").value = "<% iw_webCfgValueHandler("gpscomsetting", "dstHost1", "");%>";
    document.getElementById("RasppDestDataPort1").value = "<% iw_webCfgValueHandler("gpscomsetting", "dstDataPort1", "");%>";
    document.getElementById("RasppDestCmdPort1").value = "<% iw_webCfgValueHandler("gpscomsetting", "dstCmdPort1", "");%>";
    document.getElementById("RasppLocalCmdPort1").value = "<% iw_webCfgValueHandler("gpscomsetting", "localCmd_port1", "");%>";
    document.getElementById("RasppLocalDataPort1").value = "<% iw_webCfgValueHandler("gpscomsetting", "localData_port1", "");%>";
                        }
                        else
                        {
                                document.getElementById("opmodeTableId").disabled = true;
                                document.getElementById("opmodeTableId").style.display = "none";
                        }
         }
  function iw_gpsonchange()
  {
                        var enable = document.getElementById("iw_gps_gpsEnable").options[document.getElementById("iw_gps_gpsEnable").selectedIndex].value;
   if (enable == "ENABLE")
   {
    document.getElementById("gpsserial").disabled = false;
    document.getElementById("gpsserial").style.display = "block";
    document.getElementById("opmodeTableId").disabled = false;
    document.getElementById("opmodeTableId").style.display = "block";
    iw_selectSet(document.opmode.iw_gps_enable, "<% iw_webCfgValueHandler("gpscomsetting", "enable", ""); %>");
    iw_selectSet(document.opmode.iw_gps_com, "<% iw_webCfgValueHandler("gpscomsetting", "mode", ""); %>");
    iw_change();
   }
   else
   {
    document.getElementById("gpsserial").disabled = true;
    document.getElementById("gpsserial").style.display = "none";
    document.getElementById("opmodeTableId").disabled = true;
    document.getElementById("opmodeTableId").style.display = "none";
   }


  }


  function editPermission()
  {
   var form = document.opmode, i, j = <% iw_websCheckPermission(); %>;
   if(j)
   {
    for(i = 0; i < form.length; i++)
     form.elements[i].disabled = true;
   }
  }


  function iw_onLoad(){
   var gpsenable = "<% iw_webCfgValueHandler("gps", "gpsEnable", ""); %>";
   iw_selectSet(document.opmode.iw_gps_gpsEnable, "<% iw_webCfgValueHandler("gps", "gpsEnable", ""); %>");
   iw_selectSet(document.opmode.iw_gps_enable, "<% iw_webCfgValueHandler("gpscomsetting", "enable", ""); %>");
   iw_selectSet(document.opmode.iw_gps_com, "<% iw_webCfgValueHandler("gpscomsetting", "mode", ""); %>");
   if (gpsenable == "ENABLE")
   {
    document.getElementById("gpsserial").disabled = false;
    document.getElementById("gpsserial").style.display = "";
    document.getElementById("opmodeTableId").disabled = false;
    document.getElementById("opmodeTableId").style.display = "";
    iw_change();
   }
   else
   {
    document.getElementById("gpsserial").disabled = true;
    document.getElementById("gpsserial").style.display = "none";
    document.getElementById("opmodeTableId").disabled = true;
    document.getElementById("opmodeTableId").style.display = "none";
   }


                 editPermission();


   top.toplogo.location.reload();
  }
 // -->
 </SCRIPT>
</HEAD>
<BODY onLoad="iw_onLoad();">
  <H2><% iw_webSysDescHandler("GPSSettingsTree", "", "GPS Settings"); %> <% iw_websGetErrorString(); %></H2>
 <FORM id="submitForm" name="opmode" method="POST" action="/forms/iw_webSetParameters">
 <TABLE id="gpsoption" width="100%">
                        <TR>
                                <TD id="title" width="30%" class="column_title"><% iw_webCfgDescHandler("gps", "gpsEnable", "GPS"); %></TD>
                                <TD width="70%">
                                        <select id="iw_gps_gpsEnable" name="iw_gps_gpsEnable" onchange='iw_gpsonchange();'>
                                                <option value="ENABLE">Enable</option>
                                                <option value="DISABLE">Disable</option>
                                        </select>
                                </TD>
                        </TR>
  </TABLE>
 <TABLE id="gpsserial" width="100%">
   <TR>
                                <TD width="100%" colspan="2" class="block_title">GPS Serial Mode</TD>
                        </TR>


         <TR>
                                <TD width="30%" class="column_title"><% iw_webCfgDescHandler("gpscomsetting", "enable", "Enable"); %></TD>
                                <TD width="70%">

                       <SELECT size="1" id="iw_gps_enable" name="iw_gpscomsetting_enable">
                                        <option value="ENABLE">Enable</option>
                                        <option value="DISABLE">Disable</option>
                                  </SELECT>

          </TD>
         </TR>
         <TR>
                                <TD width="30%" class="column_title"><% iw_webCfgDescHandler("gpscomsetting", "mode", "Mode"); %></TD>
                                <TD width="70%">

                       <SELECT size="1" id="iw_gps_com" name="iw_gpscomsetting_mode" onchange='iw_change();'>
                                        <option value="RealCOM">RealCOM</option>
                                        <option value="Reverse RealCOM">Reverse RealCOM</option>
                                  </SELECT>

          </TD>
         </TR>
   <TD width="30%" class="column_title"><% iw_webCfgDescHandler("gpscomsetting", "tcpalive", "TCP alive check time"); %></TD>
   <TD width="70%">
   <input type="text" id="RasppTcpAlive" name="iw_gpscomsetting_tcpalive" size="2" maxlength="2" value="<% iw_webCfgValueHandler("gpscomsetting", "tcpalive", "");%>">(0 - 99 min)
   </TD>
   </TR>
  </TABLE>
  <TABLE id="opmodeTableId" width="100%">
      <TR>
       <TD width="30%" class="column_title">
        <% iw_webCfgDescHandler("gpscomsetting", "dstHost1", "Destination address"); %> 1
       </TD>
       <TD colspan="2">
        <TABLE>
         <TR>
          <TD width=45% rowspan=2>
           <input type="text" name="iw_gpscomsetting_dstHost1" size="45" maxlength="40"
             id="RasppDestHost1"
                            value="<% iw_webCfgValueHandler("gpscomsetting", "dstHost1", "");%>">
          </TD>
          <TD>
           &nbsp;
           <% iw_webCfgDescHandler( "gpscomsetting", "dstDataPort1", "TCP port"); %>
           &nbsp;&nbsp;
           <INPUT type="text" size="6" maxlength="5"
                         id="RasppDestDataPort1"
                            name="iw_gpscomsetting_dstDataPort1"
                            value="<% iw_webCfgValueHandler("gpscomsetting", "dstDataPort1", "63950");%>">
          </TD>
         </TR>
         <TR>
          <TD>
           &nbsp;
           <% iw_webCfgDescHandler( "gpscomsetting", "dstCmdPort1", "Cmd port"); %>
           &nbsp;
           <INPUT type="text" size="6" maxlength="5"
                         id="RasppDestCmdPort1"
                            name="iw_gpscomsetting_dstCmdPort1"
                            value="<% iw_webCfgValueHandler("gpscomsetting", "dstCmdPort1", "63966");%>">
          </TD>
         </TR>
        </TABLE>
       </TD>
      </TR>
    <TR>
     <TD width="30%" class="column_title">
      <% iw_webCfgDescHandler( "gpscomsetting", "localData_port1", "Designated local TCP port "); %> 1
     </TD>
     <TD colspan="2">
      <INPUT type="text"
       size="6" maxlength="5" value="0"
                   id="RasppLocalDataPort1"
                      name="iw_gpscomsetting_localData_port1"
                      value="<% iw_webCfgValueHandler("gpscomsetting", "localData_port1", "0");%>">
     </TD>
    </TR>
    <TR>
     <TD width="30%" class="column_title">
      <% iw_webCfgDescHandler( "gpscomsetting", "localCmd_port1", "Designated local cmd port "); %> 1
     </TD>
     <TD colspan="2">
      <INPUT type="text"
       size="6" maxlength="5" value="0"
                   id="RasppLocalCmdPort1"
                      name="iw_gpscomsetting_localCmd_port1"
                      value="<% iw_webCfgValueHandler("gpscomsetting", "localCmd_port1", "");%>">
     </TD>
    </TR>
  </TABLE>
      <tr>
  <TD colspan="2"><HR>
  <INPUT type="button" value="Submit" name="Submit" onClick="CheckValue()">
  <Input type="hidden" name="bkpath" value="/gpsSerial.asp">
  </TD>
  </tr>
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
