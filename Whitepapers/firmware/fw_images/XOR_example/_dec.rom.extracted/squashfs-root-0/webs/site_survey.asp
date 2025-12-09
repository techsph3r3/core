<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
 <%
  if ( iw_isset(index) == 0 )
  {
   index = 0;
  }else
  {
   index = index - 1;

   if ( index > 1 )
    index = 1;
   if ( index < 0 )
    index = 0;
  }

 %>
 <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
 <link href="nport2g.css" rel=stylesheet type=text/css>
 <title>Site Survey <% iw_websGetErrorString(); %></title>
 <% iw_webJSList_get(); %>
 <script type="text/javascript">
 <!--
  var http_req = iw_inithttpreq();

  function CheckValue(form)
  {
   return true;
  }

  function change_ssid(ssid)
  {
   if (!confirm("Are you sure to change the SSID to \"" + ssid +"\" ?"))
    return;
   parent.opener.document.getElementById("iw_ssid").value = ssid;
   parent.opener.document.getElementById("iw_ssid").onFocus = 1;
      parent.close();
  }

  function iw_siteSurvey()
  {
   document.getElementById("Refresh").disabled = true;
   document.getElementById("result").style.display = "none";
   document.getElementById("info").style.innerHTML = "Site Surveying...";
   document.getElementById("infoTable").style.display = "";

   if (!http_req)
   {
    document.getElementById("info").innerHTML = "Web browser internal error, please reload the page.";
         return false;
   }

   http_req.open( "GET", "/doSiteSurvey.asp?devIndex=<% write(index); %>", true );
      http_req.setRequestHeader( "Content-type", "application/x-www-form-urlencoded" );
      http_req.send( null );

   http_req.onreadystatechange = function()
   {
    if(http_req.readyState == 4)
    {
     var i;
     http_req.onreadystatechange = function() {};

     for( i = document.getElementById("result").rows.length; i > 1; i-- )
      document.getElementById("result").deleteRow(1);

     if(http_req.status == 200)
     {
      var newRow, newCell;
      var surveyData = http_req.responseText.split("\n");



             if (((surveyData.length-1) % 8) != 0) {

          top.location.reload();
          return false;
      }



      for( i = 0; i < surveyData.length - 1; i += 8 )

      {
       newRow = document.getElementById("result").insertRow(-1);
       newRow.bgColor = parseInt(i/6)%2 === 0 ? "beige" : "azure";

       newCell = newRow.insertCell(0);
       newCell.align = "center";
       newCell.innerHTML = "<small>" + parseInt(i/6+1) +"</small>";

       newCell = newRow.insertCell(1);
       newCell.align = "left";
       newCell.innerHTML = "<small><a href=\"javascript:change_ssid('" + surveyData[i] + "')\"><font color=\"blue\">" + surveyData[i+1] + "</font></small>";

       newCell = newRow.insertCell(2);
       newCell.align = "left";
       newCell.innerHTML = "<small>" + surveyData[i+2] +"</small>";

       newCell = newRow.insertCell(3);
       newCell.align = "center";
       newCell.innerHTML = "<small>" + surveyData[i+3] +"</small>";

       newCell = newRow.insertCell(4);
       newCell.align = "left";
       newCell.innerHTML = "<small>" + surveyData[i+4] +"</small>";

       newCell = newRow.insertCell(5);
       newCell.align = "center";



       newCell.innerHTML = "<img src=Signal_" + parseInt(surveyData[i+5]*5/71+1) + ".gif border=0 /><br />(" + surveyData[i+6] + "dBm/" + surveyData[i+7] + "dBm)";

      }

      document.getElementById("infoTable").style.display = "none";
      document.getElementById("result").style.display = "";
      document.getElementById("Refresh").disabled = false;

      return true;
     }
     document.getElementById("info").style.innerHTML = "Error";
     document.getElementById("Refresh").disabled = false;
     return false;
    }
   };
  }
 // -->
 </script>
</head>
<body onLoad="iw_siteSurvey();">
 <h2>Site Survey</h2>
 <form name="basic_time" method="post" action="#">
  <table id="infoTable" >
   <tr><td class="block_title"><div align="center" id="info">Site Surveying...</div></td></tr>
  </table>
  <table id="result" width=100% style="display:none">
  <tr>
   <td width=5% align=center class="block_title"><b>No.</b></td>
   <td width=30% align=center class="block_title"><p align=center><b>SSID</b></p></td>
   <td width=25% align=center class="block_title"><p align=center><b>MAC Address</b></p></td>
   <td width=10% align=center class="block_title"><p align=center><b>Channel</b></p></td>
   <td width=15% align=center class="block_title"><p align=center><b>Mode</b></p></td>
   <td width=15% align=center class="block_title"><p align=center><b>Signal/Noise Floor</b></p></td>
  </tr>
  </table>
  <br />
  <input type="button" id="Refresh" value="Refresh" style="width:80px" onClick="iw_siteSurvey();" />&nbsp;&nbsp;
  <input type="button" id="Close" value="Close" style="width:80px" onClick="self.close();" />
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
