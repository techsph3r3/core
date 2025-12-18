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

 // DISABLE AEROMAG, if enters this page
 <% iw_qsDisableAeroMag(); %>

 var rf_type = new Array(
  new Array( "2.4GHz", "", "" ),
  new Array( "B", "B-MODE", "24G" ),
  new Array( "G", "G-MODE", "24G" ),
  new Array( "B/G Mixed", "BGMixed", "24G" ),
  new Array( "G/N Mixed", "GNMixed", "24G" ),
  new Array( "B/G/N Mixed", "BGNMixed", "24G" ),
  new Array( "N Only (2.4GHz)", "N-MODE-24G", "24G" ),
  new Array( "5GHz", "", "" ),
  new Array( "A", "A-MODE", "5G" ),
  new Array( "A/N Mixed", "ANMixed", "5G" ),
  new Array( "N Only (5GHz)", "N-MODE-5G", "5G" )
 );

 var chan_list = new Array();
 chan_list["24G"] = new Array(<% iw_webGetWirelessChan2G(1, 0, 0); %>);
 chan_list["5G"] = new Array(<% iw_webGetWirelessChan5G(1, 0, 0); %>);

 var dfs_chan_list = [ <% iw_dfs_channel_list(1, 0); %> ];

 function op_mode_change()
 {
  if( $('#qs_opmode').val() == "AP" ){
   $("#qs_ap_setting").show();
  } else {
   $("#qs_ap_setting").hide();
  }

  // site survey
  if( $('#qs_opmode').val() == "CLIENT" )
   $("#qs_wlan_siteSurvey").show();
  else
   $("#qs_wlan_siteSurvey").hide();
 }

 function channel_update()
 {
  var idx_rf_type, idx;
  var chan, text, chan_int;

  idx_rf_type = $("#qs_rfType option:selected").index();
  chan = chan_list[rf_type[idx_rf_type][2]];

  $("#qs_channel option").remove();
  qs_chanList_init("#qs_channel", chan, dfs_chan_list);
 }

 function rf_type_change()
 {
  channel_update();
 }

 function chan_usage_survey_table_show(table_name, res_desc, ca_res, ca_res_cnt)
 {
  var idx, ca_idx, row_start, row_end, row_cnt = 7, row_na_cnt;
  var table, title;

  $('<h2>Channel Usage Result - ' + res_desc + '</h2>')
   .appendTo('#qsArea_siteSurvey_res');

  table = $('<table id="' + table_name + '">');
  $('#qsArea_siteSurvey_res').append( $('<ul>').append($('<li class="QS_TABLE">').append(table)));

  for( row_start = 0; row_start < ca_res_cnt; row_start += row_cnt)
  {
   if( ( row_start + row_cnt ) > ca_res_cnt)
   {
    row_end = ca_res_cnt;
    row_na_cnt = row_start + row_cnt - row_end;
   } else
   {
    row_end = row_start + row_cnt;
    row_na_cnt = 0;
   }

   // Channel
   title = $('<tr>');
   title.append( $('<th>').text("Channel").css('width', '100px'));
   for( ca_idx = row_start; ca_idx < row_end; ca_idx++ )
    title.append( $('<th>').text(ca_res[ca_idx].Channel).css('width', '70px'));

   for( idx = 0; idx < row_na_cnt ; idx++)
    title.append( $('<td>').text("--"));
   $('#' + table_name).append(title);

   // AP Counts
   title = $('<tr>');
   title.append( $('<th>').text("Number of APs"));
   for( ca_idx = row_start; ca_idx < row_end; ca_idx++ )
    title.append( $('<td>').text(ca_res[ca_idx].nBSS));

   for( idx = 0; idx < row_na_cnt ; idx++)
    title.append( $('<td>').text("--"));
   $('#' + table_name).append(title);

   // Loading (%)
   title = $('<tr>');
   title.append( $('<th>').text("Loading (%)"));
   for( ca_idx = row_start; ca_idx < row_end; ca_idx++ )
    title.append( $('<td>').text(ca_res[ca_idx].load));

   for( idx = 0; idx < row_na_cnt ; idx++)
    title.append( $('<td>').text("--"));
   $('#'+ table_name).append(title);

   // Noise floor
   title = $('<tr>');
   title.append( $('<th>').text("Noise floor (dBm)"));
   for( ca_idx = row_start; ca_idx < row_end; ca_idx++ )
    title.append( $('<td>').text(ca_res[ca_idx].nf ));
   for( idx = 0; idx < row_na_cnt ; idx++)
    title.append( $('<td>').text("--"));
   $('#' + table_name).append(title);
  }
 }

 function chan_usage_survey()
 {
  /* set no cache */
  $.ajaxSetup({ cache: false });

  $("#qsArea_siteSurvey_h2").hide();
  $("#qsArea_siteSurvey_h2").empty();

  $("#qsArea_siteSurvey_res").show();
  $("#qsArea_siteSurvey_res").empty();

  $('<h2>Channel Usage Result: Analyzing ...</h2>')
   .appendTo('#qsArea_siteSurvey_res');

  $.getJSON("/restful/getCAResult", function(ca_res)
  {
   var idx, ca_idx, row_start, row_end, row_cnt = 7;
   var table = $('<table id="qs_siteSurvey_res">');

   $("#qsArea_siteSurvey_res").empty();

   chan_usage_survey_table_show("qs_ca_24G", "2.4 GHz", ca_res.f24G, ca_res.f24G.length);
   chan_usage_survey_table_show("qs_ca_5G", "5 GHz", ca_res.f5G, ca_res.f5G.length);

  }).error(function(jqXHR, textStatus, errorThrown){ /* assign handler */
   /* alert(jqXHR.responseText) */
   alert("error occurred!");
  });
 }

 function site_survey()
 {
  var http_req = iw_inithttpreq();

  $("#qsArea_siteSurvey_h2").show();
  $("#qsArea_siteSurvey_h2").empty();
  $('<h2 id="siteSurvey_title">Site Survey Result: Surveying ...</h2>')
   .appendTo('#qsArea_siteSurvey_h2');

  $("#qsArea_siteSurvey_res").hide();
  $("#qsArea_siteSurvey_res").empty();

  if (!http_req)
  {
   alert("Init request fail, please try again later!");
        return false;
  }

  http_req.open( "GET", "/doSiteSurvey.asp?devIndex=0", true );
  http_req.setRequestHeader( "Content-type", "application/x-www-form-urlencoded" );
  http_req.send( null );

  http_req.onreadystatechange = function()
  {
   if(http_req.readyState == 4)
   {
    var i, number;
    http_req.onreadystatechange = function() {};

    if(http_req.status == 200)
    {

     var surveyData = http_req.responseText.split("\n");

     $("#siteSurvey_title").text("Site Survey Result:");
     $("#qsArea_siteSurvey_res_title").show();
     $("#qsArea_siteSurvey_res").show();
     $("#qsArea_siteSurvey_res").empty();

     {
      var table = $('<table id="qs_siteSurvey_res">');
      var title = $('<tr>');

      $('#qsArea_siteSurvey_res').append( $('<ul>').append($('<li class="QS_TABLE">').append(table)));

      title.append( $('<th>').text("No.").css('width', '50px'));
      title.append( $('<th>').text("SSID").css('width', '200px'));
      title.append( $('<th>').text("MAC").css('width', '170px'));
      title.append( $('<th>').text("Channel").css('width', '70px'));
      title.append( $('<th>').text("Mode").css('width', '170px'));
      title.append( $('<th>').text("Signal Strength").css('width', '130px'));
      title.append( $('<th>').text("Noise Floor").css('width', '80px'));
      $('#qs_siteSurvey_res').append(title);
     }

     for( i = 0, number = 1; i < surveyData.length - 1; i += 8, number++ )
     {
      var row = $('<tr>');

      if( number % 2 === 0)
       row.css('background-color', 'beige');
      else
       row.css('background-color', 'white');

      row.append( $('<td>').text(number).css('font-weight', 'bold'));
      row.append( $('<td>').text(surveyData[i])
            .bind('click', function () { $('#iw_ssid').val($(this).text()); })
            .css('color', '#0000FF')
            .css('text-decoration', 'underline')
            .hover( function(){ $(this).css('cursor', 'pointer')}));
      row.append( $('<td>').text(surveyData[i+2]));
      row.append( $('<td>').text(surveyData[i+3]));
      row.append( $('<td>').text(surveyData[i+4]));
      row.append( $('<td>').text(surveyData[i+6] + 'dBm'));
      row.append( $('<td>').text(surveyData[i+7]));

      $('#qs_siteSurvey_res').append(row);
     }
    }
   }
  }

 }

 function qs_var_verify()
 {
  if( $('#iw_ssid').val() == '' )
  {
   alert("SSID cannot be empty.");
   return false;
  }
 }

 //: onLoad
 $(function() {
  var idx, idx_opt;

  // onLoad: operation mode
  $('#qs_opmode').val("<% iw_qsCfgVal_get("wlanDevWIFI0", "operationMode"); %>");
  op_mode_change();

  //: rfType
  for( idx = 0; idx < rf_type.length; idx++ )
  {
   $("#qs_rfType").append($("<option></option>").attr("value", rf_type[idx][1]).text(rf_type[idx][0]));

   idx_opt = idx + 1;
   if( rf_type[idx][1] == "")
   {
    $('#qs_rfType option:nth-child('+ idx_opt + ')').css('color', 'white');
    $('#qs_rfType option:nth-child('+ idx_opt + ')').css('background-color', 'black');
    $('#qs_rfType option:nth-child('+ idx_opt + ')').attr('disabled', true);
   }
  }

  $('#qs_rfType').val("<% iw_qsCfgVal_get("wlanDevWIFI0", "rfType"); %>");

  //: channel
  channel_update();

  //: Site survery
  $("#qsArea_siteSurvey_h2").hide();
  $("#qsArea_siteSurvey_res").hide();

  //: Verify
  $('#qsForm').submit(function()
  {
   return qs_var_verify();
  });

 });


-->
</script>
</head>
<body>
<% iw_webQuickSetup_nav(); %>
<form id="qsForm" action="/forms/web_qsSetting" method="POST">
    <div class="QS_SETTING">
        <h2>Basic Settings</h2>
        <ul>
            <li class="QS_SETTING_TITLE"><% cfgDescGet("wlanDevWIFI0", "operationMode", ""); %></li>
            <li class="QS_SETTING_VALUE">
    <select size="1" id="qs_opmode" name="iw_wlanDevWIFI0_operationMode" onchange="op_mode_change();" style="width: 80px">

     <option value="AP">AP</option>

     <option value="CLIENT">Client</option>
    </select>
   </li>

   <li class="QS_SETTING_TITLE"><% cfgDescGet("wlanVap1", "ssid", ""); %></li>
            <li class="QS_SETTING_VALUE"><input type="text" id="iw_ssid" name="iw_wlanVap1_ssid" size="38" maxlength="32" value = "<% iw_qsCfgVal_get("wlanVap1", "ssid"); %>" /></li>
   <li class="QS_SETTING_BUTTON" id="qs_wlan_siteSurvey"><input type="button" id="qs_survey" value="Site Survey" onClick="site_survey();" /></li>
        </ul>
        <h2>RF Settings</h2>
        <ul>
            <li class="QS_SETTING_TITLE"><% cfgDescGet("wlanDevWIFI0", "rfType", ""); %></li>
            <li class="QS_SETTING_VALUE">
    <select size="1" id="qs_rfType" name="iw_wlanDevWIFI0_rfType" onChange="rf_type_change();"></select>
   </li>
  </ul>
  <div id="qs_ap_setting">
         <ul>
             <li class="QS_SETTING_TITLE"><% cfgDescGet("wlanDevWIFI0", "channel_a", ""); %></li>
    <li class="QS_SETTING_VALUE">
     <select size="1" id="qs_channel" name="wlan0_channel" onchange='iw_onChannelChange();'></select>
    </li>
   </ul>
   <h2>Channel Usage</h2>
   <ul>
    <li class="QS_SETTING_TITLE">Channel Survey</li>
    <li class="QS_SETTING_BUTTON"><input type="button" id="qs_survey" value="Survey" onClick="chan_usage_survey();" /></li>
    <li class="HELPER_IMG" id="RF_type">
     <img src="Info.png"/>
     <span class="TOOLTIP_TEXT">
     Channel Survey takes 4 seconds. The Wi-Fi communication may disconnect during Channel Survey. Channel Loading indicates the percentage of not only 802.11 signal power but also non-802.11 signal power.
     </span>
    </li>
   </ul>
  </div> <!-- id="qs_ap_setting" -->
  <div id="qsArea_siteSurvey_h2"></div>
  <div id="qsArea_siteSurvey_res"></div>
    </div>
    <div class="BUTTON_AREA">
  <div>
         <a class="BUTTON" href="setup_option.asp">Cancel</a>
   <a class="BUTTON" href="qs_wifi_settings_menu.asp">Back</a>
   <input type="submit" value="Next" class="BUTTON">
   <input type="hidden" name="nextPage" value="qs_wifi_security.asp" />
   <input type="hidden" name="bkpath" value="qs_wifi_settings.asp" />
  </div>
    </div>
</form>
</body>
<script language="JavaScript" src="js/jquery-1.5.2.min.js"></script>
<script type="text/javascript">
	$(document).ready(function () {
		var isEditPermission = !<% iw_websCheckPermission(); %>;
		if (isEditPermission == 0) {
			$(":input").attr('disabled','disabled');
		}
	});
</script>
