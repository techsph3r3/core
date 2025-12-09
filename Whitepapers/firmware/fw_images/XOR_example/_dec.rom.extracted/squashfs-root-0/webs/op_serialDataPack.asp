            <script type="text/javascript">
             $(function(){
              delim_ctrl();
     $("#PackLen").change(delim_ctrl);
             });

             function delim_ctrl()
    {
     var delim;
     if($("#PackLen").val() == 0){
      delim = true;
     }
     else{
      delim = false;
     }
     $("#DelimiterChar1").attr("disabled", !delim);
     $("#DelimiterChar1Flag").attr("disabled", !delim);
     $("#DelimiterChar2").attr("disabled", !delim);
     $("#DelimiterChar2Flag").attr("disabled", !delim);
     $("#DelimiterProcess").attr("disabled", !delim);
    }
            </script>
            <TABLE id="dataPackTableId" width="100%" align="left">
            <TR>
                <TD width="100%" colspan="2"> <P class="block_title">
                 <% iw_webSysDescHandler( "serialDataPacking", "", "Data Packing"); %>
                 </P>
                </TD>
            </TR>
            <TR>
                <TD width="30%" class="column_title">
                 <% iw_webCfgDescHandler( serialDataPacking, "packingLength", "Packing length"); %>
                </TD>
                <TD width="70%" >
                 <input type="text" id="PackLen" name="PackLen" size="5" maxlength="4" value="0"
                     refInput="id_<% write(serialDataPacking);%>_packingLength" >
                 <INPUT type="hidden"
                     id="id_<% write(serialDataPacking);%>_packingLength"
                        name="iw_<% write(serialDataPacking);%>_packingLength"
                     value="<% iw_webCfgValueHandler(serialDataPacking, "packingLength", "0");%>">
                    (0 to 1024)
                </TD>
            </TR>
            <TR>
                <TD width="30%" class="column_title">
                 <% iw_webCfgDescHandler( serialDataPacking, "delimiterCh1", "Delimiter 1"); %>
                </TD>
                <TD width="70%" >
                 <input type="text" id="DelimiterChar1" name="DelimiterChar1" size="3" maxlength="2" value="00"
                   refInput="id_<% write(serialDataPacking);%>_delimiterCh1"
       valueRenderFn="iw_Hex2Dec">
                 <INPUT type="hidden"
                      id="id_<% write(serialDataPacking);%>_delimiterCh1"
                      name="iw_<% write(serialDataPacking);%>_delimiterCh1"
                      value="<% iw_webCfgValueHandler(serialDataPacking, "delimiterCh1", "0");%>"
       valueRenderFn="iw_Dec2Hex">
                    (Hex)
                    <INPUT type="checkbox"
                      id="DelimiterChar1Flag"
                      name="DelimiterChar1Flag"
                      refInput="id_<% write(serialDataPacking);%>_delimiter1Enable">
                    <label for="DelimiterChar1Flag">Enable</label>
                    <INPUT type="hidden"
                 id="id_<% write(serialDataPacking);%>_delimiter1Enable"
                    name="iw_<% write(serialDataPacking);%>_delimiter1Enable"
                    value="<% iw_webCfgValueHandler(serialDataPacking, "delimiter1Enable", "DISABLE");%>">
    </TD>
            </TR>
             <TR>
                <TD width="30%" class="column_title">
                 <% iw_webCfgDescHandler( serialDataPacking, "delimiterCh2", "Delimiter 2"); %>
                </TD>
                <TD width="70%" >
                 <input type="text" id="DelimiterChar2" name="DelimiterChar2" size="3" maxlength="2" value="00"
                      refInput="id_<% write(serialDataPacking);%>_delimiterCh2"
       valueRenderFn="iw_Hex2Dec">
                 <INPUT type="hidden"
                      id="id_<% write(serialDataPacking);%>_delimiterCh2"
                      name="iw_<% write(serialDataPacking);%>_delimiterCh2"
                      value="<% iw_webCfgValueHandler(serialDataPacking, "delimiterCh2", "0");%>"
       valueRenderFn="iw_Dec2Hex">
                    (Hex)
                    <INPUT type="checkbox"
                      id="DelimiterChar2Flag"
                      name="DelimiterChar2Flag"
                      refInput="id_<% write(serialDataPacking);%>_delimiter2Enable">
                    <label for="DelimiterChar1Flag">Enable</label>
                    <INPUT type="hidden"
                 id="id_<% write(serialDataPacking);%>_delimiter2Enable"
                    name="iw_<% write(serialDataPacking);%>_delimiter2Enable"
                    value="<% iw_webCfgValueHandler(serialDataPacking, "delimiter2Enable", "DISABLE");%>">
    </TD>
            </TR>
            <TR>
                <TD width="30%" class="column_title">
                 <% iw_webCfgDescHandler( serialDataPacking, "delimiterMode", "Delimiter process"); %>
                </TD>
                <TD width="70%" >
                <SELECT size="1" id="DelimiterProcess" name="DelimiterProcess" refInput="id_<% write(serialDataPacking);%>_delimiterMode">
                 <option value="DO_NOTHING">Do Nothing</option>
                 <option value="DELIMITER_1">Delimiter+1</option>
                 <option value="DELIMITER_2">Delimiter+2</option>
                 <option value="STRIP_DELIMITER">Strip Delimiter</option>
                </SELECT>
                <INPUT type="hidden"
                 id="id_<% write(serialDataPacking);%>_delimiterMode"
                    name="iw_<% write(serialDataPacking);%>_delimiterMode"
                    value="<% iw_webCfgValueHandler(serialDataPacking, "delimiterMode", "DO_NOTHING");%>">
                (Processed only when Packing length is 0) </TD>
            </TR>
            <TR>
                <TD width="30%" class="column_title">
                 <% iw_webCfgDescHandler( serialDataPacking, "forceTransmit", "Force transmit"); %>
                </TD>
                <TD width="70%" >
                 <input type="text" id="ForceTxTime" name="ForceTxTime" size="6" maxlength="5" value="0"
                   refInput="id_<% write(serialDataPacking);%>_forceTransmit">
                 <INPUT type="hidden"
                   id="id_<% write(serialDataPacking);%>_forceTransmit"
                   name="iw_<% write(serialDataPacking);%>_forceTransmit"
                   value="<% iw_webCfgValueHandler(serialDataPacking, "forceTransmit", "11");%>">
                (0 to 65535 ms)</TD>
            </TR>
            </table>
<script language="JavaScript" src="js/jquery-1.5.2.min.js"></script>
<script type="text/javascript">
	$(document).ready(function () {
		var isEditPermission = !<% iw_websCheckPermission(); %>;
		if (isEditPermission == 0) {
			$(":input").attr('disabled','disabled');
		}
	});
</script>
