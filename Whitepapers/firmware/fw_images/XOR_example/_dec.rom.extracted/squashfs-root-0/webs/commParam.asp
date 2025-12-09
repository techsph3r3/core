<% web_GenerateSectionNameAndPortIndex("serialPortSetting");%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<HTML>
<HEAD>
    <META http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
    <link href="nport2g.css" rel=stylesheet type=text/css>
    <TITLE><% iw_webSysDescHandler("SerialSettingTree", "", "Communication Parameters"); %></TITLE>
 <% iw_webJSList_get(); %>
    <SCRIPT language="JavaScript">
    <!--
        function CheckValue(form)
        {
            if(! isAsciiString(document.serial.PortAlias.value))
            {
                    alert("Invalid Port alias: ASCII only");
                    document.serial.PortAlias.focus();
                    return false;
            }

            if(document.serial.BaudRate.value == -1)
            {
                if(!isValidNumber(document.serial.ManualBaudRate, 50, 921600, "Manual baud rate"))
                    return false;
            }

            return true;
        }
        function editPermission()
        {
                var form = document.serial, i, j = <% iw_websCheckPermission(); %>;
                if(j)
                {
                        for(i = 0; i < form.length; i++)
                                form.elements[i].disabled = true;
                }
        }


  function iw_onLoad(){
   /*   
			 *   The funciton "initialAllInputStatus" will load the config automatically 
			 *   from hidden input to specific ui component.
             *   Please reference to jsCommonInclude.js.
			 *   
			*/
   initialAllInputStatus();

                 editPermission();

   if (typeof top.toplogo != "undefined") {
                top.toplogo.location.reload();
            }



  }
    // -->
    </SCRIPT>
</HEAD>
<BODY onload="iw_onLoad();">
<h2><% iw_webSysDescHandler("SerialSettingTree", "", "Communication Parameters"); %><% iw_websGetErrorString(); %></h2>
<form name="serial" method="POST" action="/forms/iw_webSetParameters" onsubmit="return CheckValue(this)">
        <table width="100%">

                <tbody><tr>
                    <td width="100%" colspan="2">
                        <p class="block_title">
                            Port <% write(port);%>
                        </p>
                    </td>
                </tr>
                <tr>
                    <td width="30%" class="column_title">
                     <% iw_webCfgDescHandler( serialPortSetting, "portAlias", "Port alias"); %>
     </td>
                    <td width="70%">
                       <input type="text" name="PortAlias" size="21" maxlength="16" id="PortAlias"
        refinput="id_<% write(serialPortSetting); %>_portAlias">
                       <input type="hidden"
                        id="id_<% write(serialPortSetting); %>_portAlias"
                        name="iw_<% write(serialPortSetting); %>_portAlias"
                        value="<% iw_webCfgValueHandler(serialPortSetting, "portAlias", "");%>">
     </td>
                </tr>

            <tr>
                <td width="100%" colspan="2">
                 <p class="block_title">
                  <% iw_webSysDescHandler("SerialPortParamStr", "", "Serial Parameters"); %>
                    </p>
    </td>
            </tr>
            <tr>
                <td width="30%" class="column_title">
                 <% iw_webCfgDescHandler( serialPortSetting, "portBaudRate", "Baud rate"); %>



                </td>
                <td width="70%">
                    <select size="1" name="BaudRate" onchange="baudset();"
        refinput="id_<% write(serialPortSetting); %>_portBaudRate">



      <option value="75">75</option>
      <option value="110">110</option>
      <option value="134">134</option>
      <option value="150">150</option>
      <option value="300">300</option>
      <option value="600">600</option>
      <option value="1200">1200</option>
      <option value="1800">1800</option>
      <option value="2400">2400</option>
      <option value="4800">4800</option>



      <option value="9600">9600</option>
      <option value="19200">19200</option>
      <option value="38400">38400</option>
      <option value="57600">57600</option>
      <option value="115200">115200</option>
      <option value="230400">230400</option>
      <option value="460800">460800</option>
      <option value="921600">921600</option>



                    </select>
                    <input type="hidden"
                       id="id_<% write(serialPortSetting); %>_portBaudRate"
                       name="iw_<% write(serialPortSetting); %>_portBaudRate"
                       value="<% iw_webCfgValueHandler(serialPortSetting, "portBaudRate", "115200");%>">
                </td>
            </tr>
            <tr>
                <td width="30%" class="column_title">
                 <% iw_webCfgDescHandler( serialPortSetting, "portDataBit", "Data bits"); %>
     </td>
                <td width="70%">
                    <select size="1" name="DataBits"
        refinput="id_<% write(serialPortSetting); %>_portDataBit">
                        <option value="5">5</option>
      <option value="6">6</option>
      <option value="7">7</option>
      <option value="8">8</option>
                    </select>
     <input type="hidden"
                            id="id_<% write(serialPortSetting); %>_portDataBit"
                            name="iw_<% write(serialPortSetting); %>_portDataBit"
                            value="<% iw_webCfgValueHandler(serialPortSetting, "portDataBit", "8");%>">
                </td>
            </tr>
            <tr>
                <td width="30%" class="column_title">
                    <% iw_webCfgDescHandler( serialPortSetting, "portStopBit", "Stop bits"); %>
    </td>
                <td width="70%">
                    <select size="1" name="StopBits"
        refinput="id_<% write(serialPortSetting); %>_portStopBit">
                        <option value="1">1</option>
      <option value="15">1.5</option>
      <option value="2">2</option>
                    </select>
     <input type="hidden"
                        id="id_<% write(serialPortSetting); %>_portStopBit"
                        name="iw_<% write(serialPortSetting); %>_portStopBit"
                        value="<% iw_webCfgValueHandler(serialPortSetting, "portStopBit", "1");%>">
                </td>
            </tr>
            <tr>
                <td width="30%" class="column_title">
                    <% iw_webCfgDescHandler( serialPortSetting, "portParity", "Parity"); %>
    </td>
                <td width="70%">
                    <select size="1" name="Parity"
                       refinput="id_<% write(serialPortSetting); %>_portParity">
                        <option value="NONE">None</option>
      <option value="ODD">Odd</option>
      <option value="EVEN">Even</option>
      <option value="MARK">Mark</option>
      <option value="SPACE">Space</option>
                    </select>
     <input type="hidden"
                        id="id_<% write(serialPortSetting); %>_portParity"
                        name="iw_<% write(serialPortSetting); %>_portParity"
                        value="<% iw_webCfgValueHandler(serialPortSetting, "portParity", "1");%>">

                </td>
            </tr>
            <tr>
                <td width="30%" class="column_title">
                    <% iw_webCfgDescHandler( serialPortSetting, "portFlowControl", "Flow control"); %>
    </td>
                <td width="70%">
                    <select size="1" name="FlowCtrl"
                        refinput="id_<% write(serialPortSetting); %>_portFlowControl">
                        <option value="NONE">None</option>
      <option value="RTS_CTS">RTS/CTS</option>
      <option value="XON_XOFF">XON/XOFF</option>
                    </select>
     <input type="hidden"
                        id="id_<% write(serialPortSetting); %>_portFlowControl"
                        name="iw_<% write(serialPortSetting); %>_portFlowControl"
                        value="<% iw_webCfgValueHandler(serialPortSetting, "portFlowControl", "RTS_CTS");%>">
                </td>
            </tr>

                <tr>
                    <td width="30%" class="column_title">
                        <% iw_webCfgDescHandler( serialPortSetting, "portFIFO", "FIFO"); %>
     </td>
                    <td width="70%">
                        <input type="radio" name="FIFO" value="ENABLE" id="FIFO1"
                            refinput="id_<% write(serialPortSetting); %>_portFIFO">
      <label for="FIFO1">Enable</label>
                        <input type="radio" name="FIFO" value="DISABLE" id="FIFO0"
                            refinput="id_<% write(serialPortSetting); %>_portFIFO">
      <label for="FIFO0">Disable</label>
      <input type="hidden"
                         id="id_<% write(serialPortSetting); %>_portFIFO"
                         name="iw_<% write(serialPortSetting); %>_portFIFO"
                         value="<% iw_webCfgValueHandler(serialPortSetting, "portFIFO", "DISABLE");%>">
     </td>
                </tr>

            <tr>
                <td width="30%" class="column_title">
                    <% iw_webCfgDescHandler( serialPortSetting, "portInterface", "Interface"); %>
        </td>
                <td width="70%">
                    <select size="1" name="IfType"
                        refinput="id_<% write(serialPortSetting); %>_portInterface">
                        <option value="RS232">RS-232</option>
      <option value="RS422">RS-422</option>
      <option value="RS485_2_WIRE">RS-485&nbsp;2-wire</option>
      <option value="RS485_4_WIRE">RS-485&nbsp;4-wire</option>
                    </select>
     <input type="hidden"
                        id="id_<% write(serialPortSetting); %>_portInterface"
                        name="iw_<% write(serialPortSetting); %>_portInterface"
                        value="<% iw_webCfgValueHandler(serialPortSetting, "portInterface", "RS232");%>">
                </td>
            </tr>
            <tr>
                <td colspan="2">
                    <br><hr>
                    <input type="submit" value="Submit" name="Submit">
     <input type="hidden" name="bkpath" value="/commParam.asp?port_index=<% write(port_index);%>" />
                </td>
            </tr>
            </tbody>
  </table>

    </form>
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
