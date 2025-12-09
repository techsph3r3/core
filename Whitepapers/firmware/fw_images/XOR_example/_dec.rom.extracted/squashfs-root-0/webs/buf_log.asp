<% web_GenerateSectionNameAndPortIndex("serialPortBuffering");%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<HTML>
<HEAD>
    <META http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
 <TITLE><% iw_webSysDescHandler("SerialPortBufferTree", "", "Data Buffering/Log"); %></TITLE>
    <link href="nport2g.css" rel=stylesheet type=text/css>
 <% iw_webJSList_get(); %>
    <SCRIPT language="JavaScript">


 function editPermission()
 {
  var form = document.buflog, i, j = <% iw_websCheckPermission(); %>;
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
    </SCRIPT>
</HEAD>

<BODY onload="iw_onLoad()">
    <h2><% iw_webSysDescHandler("SerialPortBufferTree", "", "Data Buffering/Log"); %><% iw_websGetErrorString(); %></h2>
    <form name="buflog" method="POST" action="/forms/iw_webSetParameters" onsubmit="return CheckValue(this)">
        <table width="100%">
        <TABLE width="100%">
            <TR>
                <TD width="100%" colspan="3">
                    <P class="block_title">
                        Port <% write(port_index);%>
                    </P>
                </TD>
            </TR>
            <TR>
            <TD width="30%" class="column_title">
                    <% iw_webCfgDescHandler( serialPortBuffering, "portBufferEnable", "Port buffering (256K)"); %>
    </TD>
                <TD width="70%" colspan="2">
                    <input type="radio" name="bufEnable" value="ENABLE" onClick="buf_ctrl()" id="bufEnable1"
        refinput="id_<% write(serialPortBuffering); %>_portBufferEnable">
        <label for="bufEnable1">Enable</label>
     <input type="radio" name="bufEnable" value="DISABLE" onClick="buf_ctrl()" id="bufEnable0"
        refinput="id_<% write(serialPortBuffering); %>_portBufferEnable">
        <label for="bufEnable0">Disable</label>&nbsp;
                    <input type="hidden"
                           id="id_<% write(serialPortBuffering); %>_portBufferEnable"
                           name="iw_<% write(serialPortBuffering); %>_portBufferEnable"
                           value="<% iw_webCfgValueHandler(serialPortBuffering, "portBufferEnable", "DISABLE");%>">
    </TD>
            </TR>
            <TR>
                <TD width="30%" class="column_title">
                    <% iw_webCfgDescHandler( serialPortBuffering, "serialDatalogging", "Serial data logging (256K)"); %>
    </TD>
                <TD width="70%" colspan="2">
                    <input type="radio" name="logEnable" value="ENABLE" id="logEnable1"
        refinput="id_<% write(serialPortBuffering); %>_serialDatalogging">
        <label for="logEnable1">Enable</label>
                    <input type="radio" name="logEnable" value="DISABLE" id="logEnable0"
        refinput="id_<% write(serialPortBuffering); %>_serialDatalogging">
        <label for="logEnable0">Disable</label>&nbsp;
                    <input type="hidden"
                           id="id_<% write(serialPortBuffering); %>_serialDatalogging"
                           name="iw_<% write(serialPortBuffering); %>_serialDatalogging"
                           value="<% iw_webCfgValueHandler(serialPortBuffering, "serialDatalogging", "DISABLE");%>">
                    </TD>
            </TR>
        </TABLE>
        <HR><input type="submit" value="Submit" name="Submit">
      <input type="hidden" name="bkpath" value="/buf_log.asp?port_index=<% write(port_index);%>" />
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
