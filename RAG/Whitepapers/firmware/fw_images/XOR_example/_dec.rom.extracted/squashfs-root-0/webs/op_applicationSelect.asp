   <script type="text/javascript">
    function applicationChange(){
     var disableOpmode = true;
     var opModeOptions = {};
     var opModeSelect = $('#'+opModeId);
     switch(applicationServerValue){
      case "DEVICE_CONTROL":
       opModeOptions = {
        "REAL_COM": "Real COM",






       };
       disableOpmode = false;
      break;

      case "SOCKET":
       opModeOptions = {
       };
       disableOpmode = false;
      break;
     }
     var options = "";
     if(opModeSelect.prop) {
        options = opModeSelect.prop('options');
     }else {
        options = opModeSelect.attr('options');
     }

     $('option', opModeSelect).remove();

     $.each(opModeOptions, function(val, text) {
      var newOption = new Option(text, val);
          options[options.length] = newOption;
          if(val == opModeServerValue){
           newOption.selected = true;
          }
     });

     if(disableOpmode == true){
      $("table").each(function(){
       if(this.id == null){
        return;
       }
       if(this.id == "submitBtnableId"
       || this.id == "appSelectTableId"){
        return;
       }
       if($(this).attr("class") == "show_table"){
        return;
       }
       $(this).hide();
      });
      $("#"+opModeId).hide();
      $("#op_mode_tr_id").hide();
     }else{
      // $("#"+opModeId).show();
      // $("#op_mode_tr_id").show();
     }
    }

    function ChangeApplication(el){
     applicationServerValue = $(el).val();
     applicationChange();
     ChangePage();
    }

    function ChangePage()
    {
     var locationTarget = "?";
     if($("#submitForm")[0] != null){
      locationTarget +=$("#submitForm").serialize();
      locationTarget +="&saveValue=false";
      this.location = locationTarget;
      return;
     }

     locationTarget +=$("form").serialize();
     locationTarget +="&saveValue=false";
     this.location = locationTarget;
    }

    $(function(){
     $("#op_application_id").children().each(function(){
      var val =$(this).val();
         if (val == applicationServerValue){
             $(this).attr("selected","true");
             //this.selected = true;   
         }
     });
     applicationChange();
     serialDataPackInitial();
     $("#submitForm").bind("submit", checkRefinputDisableStatus);
     if (typeof conn_ctrl != "undefined"){
      if($.isFunction(conn_ctrl) == true){
       conn_ctrl(true);
      }
           }
    });


   </script>
   <input type="hidden" name="port_index" id="port_index_id" value="<% write(port_index);%>">
   <table id="appSelectTableId" width="100%" align="left">
             <TR>
                 <TD width="100%" colspan="2"> <P class="block_title"> Port <% write(port_index);%></P></TD>
             </TR>
    <TR>
     <TD width="30%" class="column_title">Application</TD>
     <TD width="70%">
      <SELECT id="op_application_id" name="op_application" onChange="ChangeApplication(this)"
       refinput="id_<% write(op_serialOpMode); %>_application">
       <OPTION value=DISABLE>Disable</OPTION>
       <OPTION value=DEVICE_CONTROL>Device&nbsp;Control</OPTION>
       <OPTION value=SOCKET>Socket</OPTION>



       <!--
        <OPTION value=ETHERNET_MODEM>Ethernet&nbsp;Modem</OPTION>
        <OPTION value=SMS_TUNNEL>SMS&nbsp;Tunnel</OPTION>
       -->
      </SELECT>
      <INPUT type="hidden"
                      id="id_<% write(op_serialOpMode); %>_application"
                   name="iw_<% write(op_serialOpMode); %>_application"
                value="<% write(op_application);%>">
     </TD>
    </TR>
    <TR id="op_mode_tr_id">
                 <TD width="30%" class="column_title">Mode</TD>
                 <TD width="70%">
                  <SELECT size="1" id="opMode_id" name="op_mode" onChange="ChangePage()"
       refinput="id_<% write(op_serialOpMode); %>_operationMode">
                  </SELECT>
     <INPUT type="hidden"
                      id="id_<% write(op_serialOpMode); %>_operationMode"
                   name="iw_<% write(op_serialOpMode); %>_operationMode"
                value="<% write(op_mode);%>">
     </TD>
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
