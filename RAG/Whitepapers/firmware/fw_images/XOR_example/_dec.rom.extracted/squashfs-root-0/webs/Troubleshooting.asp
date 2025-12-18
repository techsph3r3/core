<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
 <META http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
    <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate" />
    <meta http-equiv="Pragma" content="no-cache" />
    <meta http-equiv="Expires" content="0" />
 <link href="nport2g.css" rel=stylesheet type=text/css>
 <title><% iw_webSysDescHandler("TroubleshootingTree", "", ""); %></title>
 <% iw_webJSList_get(); %>
 <script type="text/javascript">

   var trBgColor = ["beige", "azure"];
  var script_time = <% iw_webGetScriptTime(); %>;
  var one_key_info= <% iw_webCheckOnekeyInfo(); %>;
  var script_info = <% iw_webCheckRunnungScriptInfo(); %>;


  var Diag = <% iw_webCheckDiagPermission(); %>;

  var result_file = <%iw_webGetResultName();%> ;

  $(document).ready(function(){
   document.getElementById('iw_troubleshooting_file').onchange = disablefield;
   document.getElementById('iw_troubleshooting_tftp').onchange = disablefield;
   $("#Export").click(function(){
    this.disabled = true ;
    this.innerHTML = "Process....." ;

    /* Take care!!  IE 8 do not support ajax , use XDomainRequest   */
    if ('XDomainRequest' in window && window.XDomainRequest !== null)
    {
     var xdr = new XDomainRequest(); // Use Microsoft XDR
           xdr.open("get", "/makeonekey.gz");
           xdr.send();
           setTimeout("self.location.reload();",3000);
       }

       /* For other browsers: use ajax to send request url to server  */
       else
       {
     $.ajax({
      url : "/makeonekey.gz" ,
      success:function(){
       setTimeout("self.location.reload();",3000);
      }
     });

    }
   });


  });

  function disablefield()
  {
   if ( document.getElementById('iw_troubleshooting_file').checked == true && script_info[0] == "default"){
    document.getElementById('iw_serverip').value = '';
    document.getElementById('iw_serverip').disabled = true}
   else if (document.getElementById('iw_troubleshooting_tftp').checked == true ){
    document.getElementById('iw_serverip').disabled = false;}

  }


  function CheckOnekeyState()
  {
   if(one_key_info == "done" ){
              document.location.href='getonekey.gz' ;
              setTimeout("self.location.reload();",1000);
             }else if(one_key_info == "making"){
    document.getElementById("Export").disabled = true ;
    document.getElementById("Export").innerHTML = "Process....."
    var myVar= setTimeout("self.location.reload();",1000);

          }else if(one_key_info == "busy"){
    document.getElementById("Export").disabled = true ;
    document.getElementById("Export").innerHTML = "Process....."
          }else{

           document.getElementById("Export").innerHTML="Export";
          }

  }
  function CheckRunScriptState()
  {
   if(script_info[0] == "done" ){
             document.getElementById("Runscript").disabled = false ;
             document.getElementById("iw_filename").disabled = false ;
    document.getElementById('iw_troubleshooting_file').disabled = false ;
    document.getElementById('iw_troubleshooting_tftp').disabled = false ;
    if(script_info[1] == "tftpfail")
     window.alert("TFTP server no response, please export file via web");

            }else if(script_info[0] == "making"){
    document.getElementById("Runscript").disabled = true ;
    document.getElementById("Stopscript").disabled = false ;
    document.getElementById("iw_filename").disabled = true ;
    document.getElementById('iw_troubleshooting_file').disabled = true ;
    document.getElementById('iw_troubleshooting_tftp').disabled = true ;

    if(script_info[1] == "tftp"){
     document.getElementById('iw_troubleshooting_tftp').checked = true ;
     document.getElementById('iw_troubleshooting_file').checked = false ;
     document.getElementById("iw_serverip").value = script_info[2] ;
    }

    var myVar= setTimeout("self.location.reload();",5000);

         }else if(script_info[0]=="error" ){

        window.alert(script_info[1]);
         }
  }

  function iw_onLoad()
  {
   CheckRunScriptState();
   CheckOnekeyState();

   DiagDisplay();

  }


  function check()
  {
   if(document.getElementById('iw_troubleshooting_tftp').checked && document.getElementById('iw_serverip').value == '')
   {
    window.alert("Error! Please enter ip.");
    return false;
   }


   if(document.run_script.iw_filename.value == "" && script_time[2] == 'N/A' )
   {
    window.alert("Error! Please specify a file.");
    return false;
   }
   document.getElementById("Runscript").disabled = true ;

   if ( confirm ("Warning!! When run the new script the last result will be removed") )
    return true;
  }


  function exportResult(iw_resultname)
  {
   document.location.href=('getscriptresult?'+iw_resultname) ;
   setTimeout("self.location.reload();",1000);
  }
  function removeResult(iw_resultname)
  {
   if ( confirm ("Warning!! Clicking 'ok' will remove the file and can't recover!") ){
    document.location.href=('removescriptresult?'+iw_resultname) ;
    setTimeout("self.location.reload();",1000);
   }
  }

  function stopScript()
  {
   document.getElementById("Stopscript").disabled = true ;
   document.location.href='stopscript' ;
  }


  function DiagDisplay(){
   if( 1 == Diag){
    document.getElementById("DiagBlock").style.display = "block";
   }else{
    document.getElementById("DiagBlock").style.display = "none";
   }
  }


  function removeScript()
  {
   document.location.href='removescript' ;
  }

</script>
</head>

<body onLoad = "iw_onLoad()">
  <h2><b><% iw_webSysDescHandler("TroubleshootingTree", "", "Troubleshooting"); %></b> </h2>


  <TABLE width="100%" id="onekey">
 <tr>
 <TD width="25%" class="column_title" colspan="2"><% iw_webSysDescHandler("CurrentDeviceTree", "", "Export current device information"); %></TD>


 <TD width="75%"> <button class="Export" id="Export" type="button"> Export</button> </TD>
 </tr>
  </TABLE>

 <br><br>
 <HR>

 <div id="DiagBlock">

<FORM name="run_script" id="run_script" method="POST" action="/forms/web_runScript" enctype="multipart/form-data" onsubmit="return check()">
  <TABLE width="100%">
  <tr>
   <TD width="25%" class="column_title" colspan="2"> <b> Diagnostics </b> </TD>
  </tr>
 <tr><td></td></tr>
   <tr>
   <TD width="25%" class="column_title" colspan="2">Diagnostic script</TD>
   <TD width="75%"><INPUT type="file" name="iw_filename" id="iw_filename" size="70"> </TD>
  </tr>
  <tr>
   <TD width="25%" class="column_title" colspan="2">Export diagnostic results</TD>
   <TD width="75%" class="column_text_no_bg" colspan="2">
    <INPUT type="radio" name="iw_storage" id="iw_troubleshooting_file" checked ="true" value="file" >to a file
   <INPUT type="radio" name="iw_storage" id="iw_troubleshooting_tftp" value="tftp">to a TFTP server

   </TD>
  </tr>
    <tr>
   <TD width="25%" class="column_title" colspan="2">TFTP server IP</TD>
   <TD width="25%" class="column_text_no_bg" colspan="2">
    <DIV id="TFTPserver">
    <INPUT type="text" name="iw_serverip" id="iw_serverip" maxlength="40" size="31" disabled >
   </DIV>
   </TD>
  </tr>
  <script>
  document.write('<tr>');
  document.write('<TD width="25%" class="column_title" colspan="2">Diagnostic script name</TD>');
  document.write('<TD width="75%" class="column_text_no_bg">'+ script_time[2]);
  if(script_time[2] != 'N/A' && script_info[0] == 'default' )
   document.write('<button type="button" id= "RemoveScript" name="Submit"  onclick="removeScript()"  > Remove </button>');
  document.write('</TD>');
  document.write('</tr>');
  document.write('<tr>');
  document.write('<TD width="25%" class="column_title" colspan="2">Last start time</TD>');
  document.write('<TD width="75%" class="column_text_no_bg">'+ script_time[0] +'</TD>');
  document.write('</tr>');
  document.write('<tr>');
  document.write('<TD width="25%" class="column_title" colspan="2">Last end time</TD>');
  document.write('<TD width="75%" class="column_text_no_bg">'+ script_time[1] +'</TD>');
  document.write('</tr>');
  </script>
 <tr>
  <TD width="25%" class="column_title" colspan="2">Diagnostic status</TD>
  <TD width="75%" class="column_title">
   <table width="75%" border="1">
    <tr>
     <td>
     <img src="/green_pix.jpg" height="16" width="<% iw_webGetRunningScriptProgress(); %>%">
     </td>
    <tr>
   </table>
  </TD>
  </tr>

  <script>
   document.write('<tr>');
   document.write('<TD width="25%" class="column_title" colspan="2">Diagnostic result</TD>');
   document.write('<TD width="75%"> ');

   document.write(result_file[0]);
   if(result_file[0]!='N/A'&&result_file[0]!=' '){
   document.write('<button type="button" id= "ExportResult" name="Submit"  onclick="exportResult(result_file[0])"  > Export </button>');
    document.write('<button type="button" id= "RemoveResult" name="Submit"  onclick="removeResult(result_file[0])"  > Remove </button>');

  }else{

   //document.write('<button type="button" id= "ExportResult" name="Submit" disabled onclick="exportResult()"  > Export </button>');  
    //document.write('<button type="button" id= "RemoveResult" name="Submit" disabled onclick="removeResult()"  > Remove </button>');  
  }
  document.write('</TD></tr>');
  for(i=1;i<result_file.length;i++){
   document.write('<tr>');
   document.write('<TD width="25%" class="column_title" colspan="2"></TD>');
   document.write('<TD width="75%"> ');
   document.write(result_file[i]);
   if(result_file[i]!='N/A'){
    var temp = result_file[i] ;
   document.write('<button type="button" id= "ExportResult" name="Submit"  onclick="exportResult(result_file['+i+'])"  > Export </button>');
    document.write('<button type="button" id= "RemoveResult" name="Submit"  onclick="removeResult(result_file['+i+'])"  > Remove </button>');

  }else{

   //document.write('<button type="button" id= "ExportResult" name="Submit" disabled onclick="exportResult()"  > Export </button>');  
    //document.write('<button type="button" id= "RemoveResult" name="Submit" disabled onclick="removeResult()"  > Remove </button>');  
  }

  document.write('</TD></tr>');
 }
  </script>

 </TABLE>
 <HR>
 <button type="submit" id= "Runscript" name="Submit" > Run Script </button>
 <button type="button" id= "Stopscript" name="Submit" disabled onclick="stopScript()" > Stop Script </button>

 <Input type="hidden" name="bkpath" value="/Troubleshooting.asp">
</FORM>

 </div>

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
