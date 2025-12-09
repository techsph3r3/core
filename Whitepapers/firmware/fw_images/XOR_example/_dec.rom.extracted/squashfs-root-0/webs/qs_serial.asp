<!DOCTYPE html>
<html>


<head>
<meta charset="utf-8">
<meta http-equiv="X-UA-Compatible" content="IE=edge">
<title>Qicuk Setup</title>
<link rel="stylesheet" href="quickSetup.css">
<% iw_webJSList_get(); %>
<script>
<!--
 var serial_baud_rate = [ <% web_serialBaudRateGet(); %> ];

 function serial_op_change()
 {
  var op_mode = $('input[name=serial_op]:checked').val();

  if( op_mode == "REAL_COM")
  {
   $("#qs_serial_op_tcp").hide();
   $("#qs_serial_op_udp").hide();
  } else if( op_mode == "TCP" )
  {
   $("#qs_serial_op_tcp").show();
   $("#qs_serial_op_udp").hide();
  } else if( op_mode == "UDP" )
  {
   $("#qs_serial_op_tcp").hide();
   $("#qs_serial_op_udp").show();
  }
 }

 function serial_op_tcp_change()
 {
  if( $('input[name=tcpclient]:checked').val() == "TCP_CLIENT")
  {
   $("#qs_serial_op_tcp_client").show();
   $("#qs_serial_op_tcp_server").hide();
  } else
  {
   $("#qs_serial_op_tcp_client").hide();
   $("#qs_serial_op_tcp_server").show();
  }

 }

 function onload_serial_op()
 {
  var config_serial_op = "<% iw_qsCfgVal_get("serialOpMode1", "operationMode"); %>";

  if( config_serial_op == "TCP_SERVER" || config_serial_op == "TCP_CLIENT")
  {
   $('input[name=serial_op]')
    .filter("[value='TCP']").attr("checked","checked");
  } else
  {
   $('input[name=serial_op]').filter("[value='" + config_serial_op + "']").attr("checked","checked");
  }

  serial_op_change();
 }

 function serial_enable_change()
 {
  var on_off = $('input[name=serial_enable]:checked').val();

  if( on_off == "ENABLE")
  {
   $("#qsArea_serial_op").show();
   $("#qsArea_serial_basic").show();
  } else
  {
   $("#qsArea_serial_op").hide();
   $("#qsArea_serial_basic").hide();
  }
 }

 $(function()
 {

  // onLoad: Quick Setup MAP
  qs_nav_init("<% iw_qsCfgVal_get("wlanDevWIFI0", "operationMode"); %>");

  // onLoad: Serial op mode
  onload_serial_op();

  // onLoad: Serial on/off
  if( "<% iw_qsCfgVal_get("serialOpMode1", "application"); %>" == "DISABLE" )
   $('input[name=serial_enable]').filter("[value='DISABLE']").attr("checked","checked");
  else
   $('input[name=serial_enable]').filter("[value='ENABLE']").attr("checked","checked");
  serial_enable_change();

  // onLoad: TCP client/server init
  if( "<% iw_qsCfgVal_get("serialOpMode1","operationMode"); %>" == "TCP_CLIENT" )
  {
   $('input[name=tcpclient]')
    .filter("[value='TCP_CLIENT']").attr("checked","checked");
  }
  serial_op_tcp_change();

  // onLoad: Serial Basic Settings
  qs_init_option("#qs_baudrate", serial_baud_rate, "<% iw_qsCfgVal_get("serialPortSetting1", "portBaudRate"); %>");

  $('#qs_databits').val("<% iw_qsCfgVal_get("serialPortSetting1", "portDataBit"); %>");
  $('#qs_stopBits').val("<% iw_qsCfgVal_get("serialPortSetting1", "portStopBit"); %>");
  $('#qs_parity').val("<% iw_qsCfgVal_get("serialPortSetting1", "portParity"); %>");
  $('#qs_interface').val("<% iw_qsCfgVal_get("serialPortSetting1", "portInterface"); %>");

  // event: serial on/off
  $('input[name=serial_enable]').click(function(){
   serial_enable_change();
  });

  // event: serial op mode
  $('input[name=serial_op]').click(function(){
   serial_op_change();
  });

  // event: tcp server/client
  $('input[name=tcpclient]').click(function(){
   serial_op_tcp_change();
  });

  // submit
  $("#qsSerial").submit(function(){
   //: tcp sever/client
   if( $("#tcpclient_enable").attr("checked") )
    $("#qs_tcp_client").val("ENABLE");
   else
    $("#qs_tcp_client").val("DISABLE");
  });

    });
-->
</script>
<style type="text/css">
 .QS_SETTING .QS_SERIAL_OP_DESC {
  clear: both;
  display: block;
  width: 100%;

  border-left: 3px solid #009966;
     padding: 5px 0px 5px 32px;

  font-size: 9pt;
     font-weight: bold;
  font-family: Ubuntu, sans-serif;
     color: black;
  line-height:1.3em;
 }

 .QS_SETTING .QS_SETTING_TITLE_SERIAL_OP {
  clear: both;
  display: block;

  border-left: 3px solid #009966;
  padding-left: 10px;
  padding-right: 13px;

  font-size: 9pt;
  font-weight: bold;
  color: #009966;
 }

 .QS_SETTING .QS_SERIAL_VAL_TITLE {
  clear: both;
  display: block;
  width: 373px;

  border-left: 3px solid #009966;
  padding-left: 32px;

  font-size: 9pt;
     font-weight: bold;
     color: #009966;
 }
 .QS_SETTING .QS_SERIAL_VAL_VAL{
  float: left;
 }

</style>
</head>
<body>
<% iw_webQuickSetup_nav(); %>
<form id="qsSerial" action="/forms/web_qsSetting_serial" method="POST">
 <div class="QS_SETTING">
  <h2>Serial Interface On/Off</h2>
  <ul>
   <li class="QS_SETTING_TITLE">Serial Interface</li>
   <li class="QS_SETTING_VALUE">
    <INPUT type="radio" name="serial_enable" id="serial_enable" value="ENABLE" />&nbsp;&nbsp;Enable&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
    <INPUT type="radio" name="serial_enable" id="serial_enable" value="DISABLE" />&nbsp;&nbsp;Disable
   </li>
  </ul>
 </div>
    <div class="QS_SETTING" id="qsArea_serial_op">
        <h2>Serial Operation Mode</h2>
        <ul>
   <li class="QS_DESC_TITLE">When one or more serial devices are connected to the Moxa AP/Client's serial ports, a PC can access the serial devices over the wireless network. Three access modes are supported: Real COM, TCP, and UDP. Select the access mode best suited for your application.</li>

   <!-- Real COM -->
   <li class="QS_SETTING_TITLE_SERIAL_OP"><input type="radio" id="serial_op" name="serial_op" value="REAL_COM">&nbsp;&nbsp;Real COM Mode</li>
   <li class="HELPER_IMG" id="RF_type">
    <img src="Info.png"/>
    <span class="TOOLTIP_TEXT">
      Allows software on the PC to access the serial device "as though the serial device were connected directly to the PC's COM port."<br />
      You will need to install the Real COM/TTY driver on the PC. For details, see the user's manual.
    </span>
   </li>

   <!-- TCP server/client -->
   <li class="QS_SETTING_TITLE_SERIAL_OP"><input type="radio" id="serial_op" name="serial_op" value="TCP">&nbsp;&nbsp;TCP Server/Client Mode</li>
   <li class="HELPER_IMG" id="RF_type">
    <img src="Info.png"/>
    <span class="TOOLTIP_TEXT">
      The PC communicates with the serial device using the TCP protocol.<br/>
      When “TCP client” check box is selected, AWK will initiate the TCP connection with TCP server whose IP address indicated in “Destination address” input box. <br/>
      If the "Device is a TCP client" check box is not selected, the serial device acts as a TCP server, in which case it must wait for another Ethernet device to initiate a TCP connection.
    </span>
   </li>

   <div id="qs_serial_op_tcp">
    <ul>
     <li class="QS_SERIAL_VAL_TITLE">
      <input type="checkbox" id="tcpclient_enable" name="tcpclient" onclick="troam_change();" value="TCP_CLIENT" />
         <label for="tcpclient_enable">&nbsp;&nbsp;Device is a TCP client</label>
      <input type="hidden" name="qs_tcp_client" id="qs_tcp_client" />
     </li>

     <div id="qs_serial_op_tcp_client">
      <ul>
       <li class="QS_SERIAL_VAL_TITLE"><% cfgDescGet("serialSocket1", "ipv4DstHost1", ""); %></li>
       <li class="QS_SERIAL_VAL_VAL"><input type="text" size="45" maxlength="40" name="iw_serialSocket1_ipv4DstHost1" value = "<% iw_qsCfgVal_get("serialSocket1", "ipv4DstHost1"); %>" /></li>

       <li class="QS_SERIAL_VAL_TITLE">Destination Port</li>
       <li class="QS_SERIAL_VAL_VAL"><input type="text" size="13" maxlength="5" name="iw_serialSocket1_dstPort1" value="<% iw_qsCfgVal_get("serialSocket1", "dstPort1"); %>" /></li>
      </ul>
     </div>

     <div id="qs_serial_op_tcp_server">
      <ul>
       <li class="QS_SERIAL_VAL_TITLE"><% cfgDescGet("serialSocket1", "TCP_server_data_port", ""); %></li>
       <li class="QS_SERIAL_VAL_VAL"><input type="text" size="13" maxlength="5" name="iw_serialSocket1_TCP_server_data_port" value = "<% iw_qsCfgVal_get("serialSocket1", "TCP_server_data_port"); %>" /></li>
     </div>
    </ul>
   </div>

   <!-- UDP -->
   <li class="QS_SETTING_TITLE_SERIAL_OP"><input type="radio" id="serial_op" name="serial_op" value="UDP">&nbsp;&nbsp;UDP Mode</li>
   <li class="HELPER_IMG" id="RF_type">
    <img src="Info.png"/>
    <span class="TOOLTIP_TEXT">
      The PC communicates with AWK using UDP protocol. AWK can send data to the “Destination IP address” with no need to initiate the connection first.
    </span>
   </li>

   <div id="qs_serial_op_udp">
    <ul>
     <li class="QS_SERIAL_VAL_TITLE">Destination IP address - Begin</li>
     <li class="QS_SERIAL_VAL_VAL"><input type="text" size="45" maxlength="40" name="iw_serialSocket1_ipv4UDPdstBegin1" value = "<% iw_qsCfgVal_get("serialSocket1", "ipv4UDPdstBegin1"); %>" /></li>
     <li class="QS_SERIAL_VAL_TITLE">Destination IP address - End</li>
     <li class="QS_SERIAL_VAL_VAL"><input type="text" size="45" maxlength="40" name="iw_serialSocket1_ipv4UDPdstEnd1" value = "<% iw_qsCfgVal_get("serialSocket1", "ipv4UDPdstEnd1"); %>" /></li>

     <li class="QS_SERIAL_VAL_TITLE">Destination Port</li>
     <li class="QS_SERIAL_VAL_VAL"><input type="text" size="13" maxlength="5" name="iw_serialSocket1_UDPdstPort1" value = "<% iw_qsCfgVal_get("serialSocket1", "UDPdstPort1"); %>" /></li>
    </ul>
   </div>
        </ul>
    </div>
    <div class="QS_SETTING" id="qsArea_serial_basic">
  <h2>Basic Serial Settings</h2>
        <ul>
            <li class="QS_SETTING_TITLE"><% cfgDescGet("serialPortSetting1", "portBaudRate", ""); %></li>
            <li class="QS_SETTING_VALUE">
    <select size="1" id="qs_baudrate" name="iw_serialPortSetting1_portBaudRate" style="width: 115px"></select>
   </li>
   <li class="QS_SETTING_TITLE"><% cfgDescGet("serialPortSetting1", "portDataBit", ""); %></li>
            <li class="QS_SETTING_VALUE">
    <select size="1" id="qs_databits" name="iw_serialPortSetting1_portDataBit" style="width: 115px">
     <option>5</option>
     <option>6</option>
     <option>7</option>
     <option>8</option>
    </select>
   </li>
   <li class="QS_SETTING_TITLE"><% cfgDescGet("serialPortSetting1", "portStopBit", ""); %></li>
            <li class="QS_SETTING_VALUE">
    <select size="1" id="qs_stopBits" name="iw_serialPortSetting1_portStopBit" style="width: 115px">
     <option value="1">1</option>
     <option value="15">1.5</option>
     <option value="2">2</option>
    </select>
   </li>
   <li class="QS_SETTING_TITLE"><% cfgDescGet("serialPortSetting1", "portParity", ""); %></li>
            <li class="QS_SETTING_VALUE">
    <select size="1" id="qs_parity" name="iw_serialPortSetting1_portParity" style="width: 115px">
     <option value="NONE">None</option>
     <option value="ODD">Odd</option>
     <option value="EVEN">Even</option>
     <option value="MARK">Mark</option>
     <option value="SPACE">Space</option>
    </select>
   </li>
   <li class="QS_SETTING_TITLE"><% cfgDescGet("serialPortSetting1", "portInterface", ""); %></li>
            <li class="QS_SETTING_VALUE">
    <select size="1" id="qs_interface" name="iw_serialPortSetting1_portInterface" style="width: 115px">
     <option value="RS232">RS-232</option>
     <option value="RS422">RS-422</option>
     <option value="RS485_2_WIRE">RS-485&nbsp;2-wire</option>
     <option value="RS485_4_WIRE">RS-485&nbsp;4-wire</option>
    </select>
   </li>
  </ul>
    </div>
    <div class="BUTTON_AREA">
  <div>
         <a class="BUTTON" href="setup_option.asp">Cancel</a>
   <a class="BUTTON" href="<% iw_webQuickSetup_wifiLastPage(); %>">Back</a>
   <input type="submit" value="Next" class="BUTTON">
   <input type="hidden" name="nextPage" value="qs_confirm.asp" />
   <input type="hidden" name="bkpath" value="qs_serial.asp" />
  </div>
 </div>
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
