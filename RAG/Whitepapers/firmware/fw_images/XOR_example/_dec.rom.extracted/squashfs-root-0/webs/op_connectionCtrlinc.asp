     <script type="text/javascript">
      function conn_ctrl(isCheckBindValue)
   {
     if($("#MaxConnect")[0] == null){
      return;
     }
     var checkEl = $("#MaxConnect")[0];
     if(isCheckBindValue == true){
      var checkEl = $("#id_<% write(serialConnectionSettings); %>_tcpMaxConnection")[0];
     }
     if( $(checkEl).val() == 1 )
     {
      document.opmode.IgnoreJam[0].disabled = true;
      document.opmode.IgnoreJam[1].disabled = true;
      document.opmode.AllowDrvCtrl[0].disabled = true;
      document.opmode.AllowDrvCtrl[1].disabled = true;
     }
     else
     {
      document.opmode.IgnoreJam[0].disabled = false;
      document.opmode.IgnoreJam[1].disabled = false;
      document.opmode.AllowDrvCtrl[0].disabled = false;
      document.opmode.AllowDrvCtrl[1].disabled = false;
     }
   }

   $(function(){
    if (typeof conn_ctrl != "undefined"){
     if($.isFunction(conn_ctrl) == true){
      conn_ctrl(true);
     }
    }
   });
     </script>
     <TABLE width=100% align="left">
         <TR>
             <TD width="30%" class="column_title"><% iw_webCfgDescHandler( serialConnectionSettings, "tcpAliveCheckTimeMin", "TCP alive check time"); %></TD>
             <TD width="70%" colspan="2"><input type="text" name="TCPAliveCheck" size="3" maxlength="2" value="7"
                    refinput="id_<% write(serialConnectionSettings); %>_tcpAliveCheckTimeMin">
                 <INPUT type="hidden"
                   size="3" maxlength="2"
                     id="id_<% write(serialConnectionSettings); %>_tcpAliveCheckTimeMin"
                  name="iw_<% write(serialConnectionSettings); %>_tcpAliveCheckTimeMin"
               value="<% iw_webCfgValueHandler(serialConnectionSettings, "tcpAliveCheckTimeMin", "4");%>">
                 (0 to 99 minutes)</TD>
         </TR>
         <TR>
             <TD width="30%" class="column_title"><% iw_webCfgDescHandler( serialConnectionSettings, "tcpMaxConnection", "Max connection"); %></TD>
             <TD width="70%" colspan="2"><SELECT id="MaxConnect" name="MaxConnect" onChange="conn_ctrl()" refinput="id_<% write(serialConnectionSettings); %>_tcpMaxConnection">
                 <option value="1">1</option>
                 <option value="2">2</option>
             </SELECT>
                 <INPUT type="hidden"
                 id="id_<% write(serialConnectionSettings); %>_tcpMaxConnection"
                 name="iw_<% write(serialConnectionSettings); %>_tcpMaxConnection"
                 value="<% iw_webCfgValueHandler(serialConnectionSettings, "tcpMaxConnection", "1");%>"></TD>
         </TR>
         <TR>
             <TD width="30%" class="column_title"><% iw_webCfgDescHandler( serialConnectionSettings, "skipJammedIP", "Ignore jammed IP"); %></TD>
             <TD width="70%" colspan="2"><INPUT type="radio" name="IgnoreJam" value="ENABLE" id="IgnoreJam1" refinput="id_<% write(serialConnectionSettings); %>_skipJammedIP">
                 <label for="IgnoreJam1">Enable</label>
                 <INPUT type="radio" name="IgnoreJam" value="DISABLE" id="IgnoreJam0" refinput="id_<% write(serialConnectionSettings); %>_skipJammedIP" checked>
                 <label for="IgnoreJam0">Disable</label>
                 &nbsp;
                 <INPUT type="hidden"
                 id="id_<% write(serialConnectionSettings); %>_skipJammedIP"
                    name="iw_<% write(serialConnectionSettings); %>_skipJammedIP"
                    value="<% iw_webCfgValueHandler(serialConnectionSettings, "skipJammedIP", "DISABLE");%>"></TD>
         </TR>
         <TR>
             <TD width="30%" class="column_title"><% iw_webCfgDescHandler( serialConnectionSettings, "allowDriverCtrl", "Allow driver control"); %></TD>
             <TD width="70%" colspan="2"><INPUT type="radio" name="AllowDrvCtrl" value="ENABLE" id="allowdrvctrl1" refinput="id_<% write(serialConnectionSettings); %>_allowDriverCtrl">
                 <label for="allowdrvctrl1">Enable</label>
                 <INPUT type="radio" name="AllowDrvCtrl" value="DISABLE" id="allowdrvctrl0" refinput="id_<% write(serialConnectionSettings); %>_allowDriverCtrl" checked>
                 <label for="allowdrvctrl0">Disable</label>
                 <INPUT type="hidden"
                 id="id_<% write(serialConnectionSettings); %>_allowDriverCtrl"
                    name="iw_<% write(serialConnectionSettings); %>_allowDriverCtrl"
                    value="<% iw_webCfgValueHandler(serialConnectionSettings, "allowDriverCtrl", "DISABLE");%>"></TD>
         </TR>
  </TABLE>
<script language="JavaScript" src="js/jquery-1.5.2.min.js"></script>
<script type="text/javascript">
	$(document).ready(function () {
		var isEditPermission = !<% iw_websCheckPermission(); %>;
		if (isEditPermission == 0) {
			$(":input").attr('disabled','disabled');
		}
	});
</script>
