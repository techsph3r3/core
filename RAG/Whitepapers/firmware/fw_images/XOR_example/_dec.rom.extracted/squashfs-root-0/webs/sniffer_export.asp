<HTML>
<HEAD>
 <LINK href="nport2g.css" rel="stylesheet" type="text/css">
 <% iw_webJSList_get(); %>

 <TITLE><% iw_webSysDescHandler("SnifferExportTree", "", "Sniffer and Export"); %></TITLE>
 <script type="text/javascript">
 <!--

  var snifferStatus = new String("<% iw_webGetSnifferStatus(); %>");


  function startfunc()
  {
   var rf_status = new String("<% iw_webCfgValueMainHandler("wlanDevWIFI0", "rfType", "G-MODE"); %>");
   var prefix = document.sniffer.prefix.value;
   var pktsCount = parseInt(document.sniffer.pktsCount.value);
   var rotatePkts = parseInt(document.sniffer.rotatePkts.value);
                        var len = document.sniffer.pktsCount.value.length;
   var tftpip = document.sniffer.tftp.value;

   if(prefix.length < 1){
    alert("Please enter Prefix Name.");
    document.sniffer.prefix.focus();
    return false;
   }

   var validStr ="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_";
   for (var i = 0 ; i < prefix.length ;i++){
    var c = prefix.charAt(i);
    if(validStr.indexOf(c) < 0){
     alert("Prefix Name could not have \'"+c+"\'");
     return false;
    }
   }
   if(tftpip.length < 1){
    alert("Please enter TFTP Server.");
                                document.sniffer.tftp.focus();
    return false;
   }

   if(rotatePkts < 1 || rotatePkts > 2000){
    alert("Please enter rotate packets count as an integer from 1 ~ 2000");
                                document.sniffer.rotatePkts.focus();
    return false;
   }
   if(pktsCount < 0 || pktsCount > 100000000){
                                alert("Please enter max total packets count as an integer from 0 ~ 100000000");
                                document.sniffer.pktsCount.focus();
                                return false;
                        }
   if(pktsCount!=0 && pktsCount < rotatePkts){
    alert("Max packets must be larger than rotate packets.");
    document.sniffer.pktsCount.value = "";
    document.sniffer.pktsCount.focus();
    return false;
   }

   /*

			if(rf_status == "BGMixed"){

				if(document.sniffer.modeb.checked == false &&  document.sniffer.modeg.checked == false){

					alert("You have to select one mode of 802.11b or 802.11g");

					return false;

				}

				if(document.sniffer.modeb.checked && document.sniffer.modeg.checked ){

					alert("You could only select one mode of 802.11b or 802.11g");

					document.sniffer.modeb.checked = false;

					document.sniffer.modeg.checked = false;

					return false;

				}

			}

			*/
   if( verifyIP(document.sniffer.tftp, "TFTP Server") == false){
    return false;
   }

   document.sniffer.Startbtn.disabled = true;
   alert("Start to sniffer packets.");
   document.sniffer.submit();
  }

  function stopfunc(){
   //window.open('/sniffer_stop','','scrollbars=no,menubar=no,height=100,width=200,resizable=yes,toolbar=no,location=no,status=yes');
   alert("Stop sniffer packets.");
   document.sniffer.submit();
  }


  function editPermission()
  {
   var form = document.sniffer, i, j = <% iw_websCheckPermission(); %>;
   if(j)
   {
    for(i = 0; i < form.length; i++)
     form.elements[i].disabled = true;
   }
  }


  function window_onload()
  {
                 var rf_status = new String("<% iw_webCfgValueMainHandler("wlanDevWIFI0", "rfType", "G-MODE"); %>");
                 var channel_statea = new String("<% iw_webCfgValueMainHandler("wlanDevWIFI0", "channel_a", "32"); %>");
          var channel_stateb = new String("<% iw_webCfgValueMainHandler("wlanDevWIFI0", "channel_b", "6"); %>");
          var channel_stateg = new String("<% iw_webCfgValueMainHandler("wlanDevWIFI0", "channel_g", "1"); %>");
   /*	

                        document.sniffer.a_channel.value=channel_statea;

                        document.sniffer.b_channel.value=channel_stateb;

                        document.sniffer.g_channel.value=channel_stateg;



			document.sniffer.modea.disabled = true;

                        document.sniffer.modeb.disabled = true;

                        document.sniffer.modeg.disabled = true;

                        document.sniffer.a_channel.disabled=true;

                        document.sniffer.b_channel.disabled=true;

                        document.sniffer.g_channel.disabled=true;



			if(rf_status=="A-MODE"){

				document.sniffer.modea.disabled = false;

				document.sniffer.a_channel.disabled=false;

			}

			else if(rf_status=="B-MODE"){

                                document.sniffer.modeb.disabled = false;

                                document.sniffer.b_channel.disabled=false;

			}

			else if(rf_status=="G-MODE"){

                                document.sniffer.modeg.disabled = false;

                                document.sniffer.g_channel.disabled=false;

                        }

			else if(rf_status=="BGMixed"){

                                document.sniffer.modeb.disabled = false;

                                document.sniffer.modeg.disabled = false; 

                                document.sniffer.b_channel.disabled=false;

                                document.sniffer.g_channel.disabled=false;

			}

			else{

				alert("Unknow RF Type");

			}

			*/
   document.sniffer.pktsCount.select();
   document.sniffer.pktsCount.focus();

   if(snifferStatus == "true"){
    document.sniffer.Startbtn.disabled = true;
    document.sniffer.Stopbtn.disabled = false;
   }
   else{
    document.sniffer.Startbtn.disabled = false;
    document.sniffer.Stopbtn.disabled = true;
   }
   document.sniffer.status.value = snifferStatus;

                 editPermission();

  }


  function selectModeBG(source){
   /*

			var rf_status =  new String("<% iw_webCfgValueMainHandler("wlanDevWIFI0", "rfType", "G-MODE"); %>");

			if(rf_status=="BGMixed"){

				if(document.sniffer.modeb == source ){

                                	document.sniffer.modeg.checked = false;

                                	document.sniffer.b_channel.disabled=false;

                                	document.sniffer.g_channel.disabled=true;

					return;

                       	 	}

				if(document.sniffer.modeg == source ){

                                	document.sniffer.modeb.checked = false;

                                	document.sniffer.b_channel.disabled=true;

                                	document.sniffer.g_channel.disabled=false;

                                	return;

                        	}

			}

			*/
  }
 -->
 </SCRIPT>
</HEAD>

<BODY onload="window_onload()">
 <H2><% iw_webSysDescHandler("SnifferExportTree", "", "Sniffer and Export"); %></H2>
 <FORM name="sniffer" action="/forms/webSetSnifferExport" method="POST" >
  <TABLE width="100%">
   <!--
   <TR>
    <TD width="30%" class="column_title">Mode</TD>

                                <TD width="70%">
                                        <INPUT type="radio" name="modea" value="a" ><label>802.11a</label>
                                        <SELECT NAME="a_channel">
      <OPTION>36</OPTION>
      <OPTION>40</OPTION>
      <OPTION>44</OPTION>
      <OPTION>48</OPTION>
     </SELECT>
                                </TD>
   </TR>
   <TR>
     <TD width="30%" class="column_title"></TD>
    <TD>
                                        <INPUT type="radio" name="modeb" value="b" onclick="selectModeBG(this);"><label>802.11b</label>
                                        <SELECT NAME="b_channel">
                                                <OPTION>1</OPTION>
                                                <OPTION>2</OPTION>
                                                <OPTION>3</OPTION>
                                                <OPTION>4</OPTION>
      <OPTION>5</OPTION>
                                                <OPTION>6</OPTION>
                                                <OPTION>7</OPTION>
                                                <OPTION>8</OPTION>
                                                <OPTION>9</OPTION>
                                                <OPTION>10</OPTION>
                                                <OPTION>11</OPTION>
                                                <OPTION>12</OPTION>
      <OPTION>13</OPTION>
                                        </SELECT>
    </TD>
   </TR>
   <TR>
     <TD width="30%" class="column_title"></TD>
                                <TD>
                                        <INPUT type="radio" name="modeg" value="g" onclick="selectModeBG(this);"><label>802.11g</label>
                                        <SELECT NAME="g_channel">
                                                <OPTION>1</OPTION>
                                                <OPTION>2</OPTION>
                                                <OPTION>3</OPTION>
                                                <OPTION>4</OPTION>
                                                <OPTION>5</OPTION>
                                                <OPTION>6</OPTION>
                                                <OPTION>7</OPTION>
                                                <OPTION>8</OPTION>
                                                <OPTION>9</OPTION>
                                                <OPTION>10</OPTION>
                                                <OPTION>11</OPTION>
                                                <OPTION>12</OPTION>
                                                <OPTION>13</OPTION>
                                        </SELECT>
                                </TD>
   </TR>

   <TR>
     <TD width="30%" class="column_title"></TD>
                                <TD>
                                        <INPUT type="radio" name="modebg" value="bg" id="mode"><label>802.11bg</label>
                                        <SELECT NAME="bg_channel">
                                                <OPTION>1</OPTION>
                                                <OPTION>2</OPTION>
                                                <OPTION>3</OPTION>
                                                <OPTION>4</OPTION>
                                                <OPTION>5</OPTION>
                                                <OPTION>6</OPTION>
                                                <OPTION>7</OPTION>
                                                <OPTION>8</OPTION>
                                                <OPTION>9</OPTION>
                                                <OPTION>10</OPTION>
                                                <OPTION>11</OPTION>
                                                <OPTION>12</OPTION>
                                                <OPTION>13</OPTION>
                                        </SELECT>
                                </TD>

   </TR>

   -->
                        <TR>
                                 <TD width="30%" class="column_title">Prefix Name</TD>
                                <TD>
                                        <INPUT type="text" name="prefix" value="" size="20" maxlength="15">
                                </TD>

                        </TR>

                        <TR>
                                 <TD width="30%" class="column_title">TFTP Server</TD>
                                <TD>
                                        <INPUT type="text" name="tftp" value="" size="20" maxlength="15">
                                </TD>

                        </TR>
   <TR>
    <TD width="30%" class="column_title">Next file every</TD>
                                <TD>
                                        <INPUT type="text" name="rotatePkts" size="12" maxlength="10" value = "2000">packet(s)(1~2000)
                                </TD>
                        </TR>
    <TD width="30%" class="column_title">Stop capture after</TD>
    <TD>
     <INPUT type="text" name="pktsCount" size="12" maxlength="10" value = "0">packet(s)(0~100000000)
    </TD>
   </TR>
  </TABLE>
  <HR>
  <Input type="hidden" name="status" value="false" />
  <INPUT type="button" name="Startbtn" value="Start" onclick="startfunc()" />
  <INPUT type="button" name="Stopbtn" value="Stop" onclick="stopfunc()" />


        </TABLE>

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
