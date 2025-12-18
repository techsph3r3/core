<% iw_webInitialSerialDataLog();%>
<% include("commonHtmlHeader.htm");%>
<TITLE><% iw_webSysDescHandler("SerialDataLogTree", "", "Serial Data Logs"); %></TITLE>
</HEAD>
 <script type="text/javascript">
 <!--
  var G_port_index = <% write(port_index);%>;
  var G_data_type = <% write(data_type);%>;
  var mem_state = <% iw_websMemoryChange(); %>;
  var G_clearLog = false;
  var ASCII_TYPE = 0;
  var HEX_TYPE = 1;

  function scroll_to_latest(e)
  {
   e.scrollTop = e.scrollHeight;
  }
    function updateG_dataType(dataType){
      G_data_type = dataType;
    refreshLogData();
    }

    function refresh_ASCII_HEX_link(){
      //var hyperSrc = "?port_index=<% write(port_index);%>&data_type="+(!dataType);
    if( G_data_type == ASCII_TYPE){
     $("#dataTypeID").html("[ASCII][<a onclick=\"updateG_dataType("+HEX_TYPE+")\" href=\"#\">HEX</a>]");
    }else{
     $("#dataTypeID").html("[<a onclick=\"updateG_dataType("+ASCII_TYPE+")\" href=\"#\">ASCII</a>][HEX]");
    }
    }

          function refreshLogData(){
              refresh_ASCII_HEX_link();
              $("#SerialLog_id")[0].disabled = true;
              $("#refreshBtn_id")[0].disabled = true;
              $.ajax({
                  type: "GET",
                  url: "Sio_getLogData.asp",
                  data: {
                      port_index: G_port_index,
                      data_type: G_data_type,
                      clear_log: (G_clearLog ? "1" : "0"),
                  },
                  dataType: "text",
                  success: function(data, textStatus){
                      if (data.redirect) {
                          // data.redirect contains the string URL to redirect to
                          window.top.location.href = data.redirect;
        return;
                      }

       var redirPage = data.slice(0,10);
                      if(redirPage.toLowerCase().indexOf("<!doctype") != -1){
        top.location.reload();
      return;
       }
                      $("#SerialLog_id")[0].disabled = false;
                      $("#refreshBtn_id")[0].disabled = false;
                      $("#SerialLog_id").val($.trim(data));
                      scroll_to_latest($("#SerialLog_id")[0]);
                      G_clearLog = false;
                  }
              });
          }

          function confirm_clearlog(){
              if (!window.confirm("Are you sure to clear log?")) {
                  return;
              }
              G_clearLog = true;
              refreshLogData();
          }

          $(function(){
              refreshLogData();
     $("#refreshBtn_id").bind("click",refreshLogData);
     /*

			  var i = 0;

			  var maxSpace = 180;

			  if($.browser.msie){

			  	maxSpace -= 78;

			  }

			  while(i++ < maxSpace){

			  	$("#space_area").html("&nbsp;"+$("#space_area").html());

			  }

			  */
          });


  function editPermission()
  {
   var form = document.seriallogForm, i, j = <% iw_websCheckPermission(); %>;
   if(j)
   {
    for(i = 0; i < form.length; i++)
    {
     if( form.elements[i].name == "SelectAll" )
                     continue;
                 if( form.elements[i].name == "Refresh" )
                     continue;

     form.elements[i].disabled = true;
    }
   }
  }


        function iw_ChangeOnLoad()
        {

                editPermission();

                top.toplogo.location.reload();
        }

    -->
    </Script>

 <H2><% iw_webSysDescHandler("SerialDataLogTree", "", "Serial Data Logs"); %></H2>
<BODY onLoad = "iw_ChangeOnLoad();">
 <FORM name="seriallogForm" method="POST" action="">
  <Table width="728" border="0" cellpadding="0" cellspacing="0">
  <TR>
    <td width="100" align="left">
     <span>
     Select port
     <select name="portNumber">
      <option value="1">Port1</option>
     </select>
     </span>


    </td>
    <td width="100" align="right"><span id="space_area">
     </span>
     <span id="dataTypeID"></span>&nbsp;</td>
    <td align="right">&nbsp;</td>
  </TR>
  <TR>
   <TD colspan="2"><textarea id="SerialLog_id" name="SerialLog" rows="20" cols="100" readonly>
    </textarea></TD>
   <TD>&nbsp;</TD>
  </TR>
  <TR>
         <TD colspan="3"><HR>
    <input type="button" name="SelectAll" value="Select all" onClick="this.form.SerialLog.focus(); this.form.SerialLog.select();">
    <INPUT type="button" name="ClearLog" value="Clear Log" onClick="confirm_clearlog();">
    <INPUT type="button" name="Refresh" value="Refresh" id="refreshBtn_id">
    <Input type="hidden" name="bkpath" value="./Sio_log.asp">
    <input type="hidden" name="port_index" value="<% write(port_index);%>">
    <input type="hidden" name="data_type" value="<% write(data_type);%>">
   </TD>
     </TR>
     </Table>
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
