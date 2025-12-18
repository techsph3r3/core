
<HTML>
<HEAD>
 <META http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
 <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate" />
 <meta http-equiv="Pragma" content="no-cache" />
 <meta http-equiv="Expires" content="0" />
 <LINK href="nport2g.css" rel=stylesheet type=text/css />
 <LINK href="aeroMag.css" rel=stylesheet type=text/css />
 <TITLE>AeroMag</TITLE>
 <% iw_webJSList_get(); %>
 <script type="text/javascript">
 <!--

 // var pwd;
 var done_for_settings = <% iw_web_AutoConn_done(); %>;
 var done_for_auto_update = 0;
 var refresh_timeout = 0;
 var refresh_active_lock = 0;

 function aeroMag_ConnDev_clear()
 {
  if( confirm("All records of AeroMag units will be deleted. Do you want to proceed?") )
  {
   var http_req = iw_inithttpreq();

   if (!http_req)
   {
    alert("Init request fail, please clear again later!");
    return false;
   }

   http_req.open( "POST", "/forms/webAeroMagConnDevClear", true );
   http_req.setRequestHeader( "Content-type", "application/x-www-form-urlencoded" );
   http_req.send( "null" );

   http_req.onreadystatechange = function()
   {
    if(http_req.readyState == 4 && http_req.status == 200)
    {
     if( http_req.status == 200 )
     {
      activate_refresh(0);
      return true;
     }
    }
   }
  }

  return true;
 }

 function aeroMag_refreshChan()
 {
  if( confirm("The AWK may change operating channels automatically if necessary. \nDo you want to proceed?") )
  {
   var http_req = iw_inithttpreq();

   if (!http_req)
   {
    alert("Init request fail, please try again later!");
    return false;
   }

   http_req.open( "POST", "/forms/webAeroMagRefreshChan", true );
   http_req.setRequestHeader( "Content-type", "application/x-www-form-urlencoded" );
   http_req.send( "null" );

   http_req.onreadystatechange = function()
   {
    if(http_req.readyState == 4 && http_req.status == 200)
    {
     if( http_req.status == 200 )
     {
      alert('Refreshing channel ...');
      done_for_auto_update = 0;
      iw_setting_privilege();
      activate_refresh(1);
      return true;
     } else
     {
      alert('Err: cannot refresh channel!');
      activate_refresh(1);
      return false;
     }
    }
   }
  }

  return true;
 }

 function iw_onchange_AutoConnMode()
 {
  if( $("#iw_AeroMag_enable").val() == "AP")
  {
   $('#iw_AutoConn_both_action').show();
   $('#iw_AutoConn_freeze').show();
   $('#iw_AutoConn_AP_refresh').show();

   $('#iw_AutoConn_Refresh').show();

   if( !$("#ref5").is(':checked') )
   {
    $("#ref5").attr("checked", "checked");
    activate_refresh(0);
   }

   $('#am_status_ap').show();
   $('#am_status_client').hide();
   $('#am_status_config').show();
   $('#am_status_conn_dev').show();
   $('#iw_AutoConn_ConnDev_clear').show();
   $('#am_status_channel_arrange').show();
  }
  else if( $("#iw_AeroMag_enable").val() == "Client")
  {
   $('#iw_AutoConn_both_action').show();
   $('#iw_AutoConn_freeze').hide();
   $('#iw_AutoConn_AP_refresh').hide();

   $('#iw_AutoConn_Refresh').show();
   if( !$("#ref5").is(':checked') )
   {
    $("#ref5").attr("checked", "checked");
    activate_refresh(0);
   }

   $('#am_status_ap').hide();
   $('#am_status_client').show();
   $('#am_status_config').show();
   $('#am_status_conn_dev').hide();
   $('#iw_AutoConn_ConnDev_clear').hide();
   $('#am_status_channel_arrange').hide();
  }
  else
  {
   $('#iw_AutoConn_both_action').hide();
   $('#iw_AutoConn_freeze').hide();
   $('#iw_AutoConn_AP_refresh').hide();

   $('#iw_AutoConn_Refresh').hide();
   $("#ref5").attr("checked", "");

   $('#am_status_ap').hide();
   $('#am_status_client').hide();
   $('#am_status_config').hide();
   $('#am_status_conn_dev').hide();
   $('#iw_AutoConn_ConnDev_clear').hide();
   $('#am_status_channel_arrange').hide();
  }
 }

 function editPermission()
 {
  var form = document.aeroMag, i, j = <% iw_websCheckPermission(); %>;
  if(j)
  {
   for(i = 0; i < form.length; i++)
    form.elements[i].disabled = true;
  }
 }

 function AutoConn_freeze_onClick()
 {
  if( $("#AutoConn_freeze").is(':checked') )
  {
   if( confirm("Lock system?") )
   {
    var http_req = iw_inithttpreq();

    if (!http_req)
    {
     alert("Init request fail, please try again later!");
     return false;
    }

    http_req.open( "POST", "/forms/webAeroMagFreeze", true );
    http_req.setRequestHeader( "Content-type", "application/x-www-form-urlencoded" );
    http_req.send( "null" );
   } else
    $('#AutoConn_freeze').attr('checked', '');
  }
  else
  {
   if( confirm("Unlock system?") )
   {
    var http_req = iw_inithttpreq();

    if (!http_req)
    {
     alert("Init request fail, please try again later!");
     return false;
    }

    http_req.open( "POST", "/forms/webAeroMagUnFreeze", true );
    http_req.setRequestHeader( "Content-type", "application/x-www-form-urlencoded" );
    http_req.send( "null" );
   } else
    $('#AutoConn_freeze').attr('checked', 'checked');
  }

  return true;
 }

 function iw_setting_privilege()
 {
  if(done_for_settings == 0)
  {
   $('#iw_aeroMagAction_new').attr('disabled', true);
   $('#iw_aeroMagAction_keep').attr('disabled', true);
   $('#AutoConn_freeze').attr('disabled', true);
  } else
  {
   $('#iw_aeroMagAction_new').attr('disabled', false);
   $('#iw_aeroMagAction_keep').attr('disabled', false);
   $('#AutoConn_freeze').attr('disabled', false);
  }

  if( done_for_auto_update == 0 )
  {
   $('#am_refresh_channel').attr('disabled', true);
  } else
  {
   $('#am_refresh_channel').attr('disabled', false);
  }
 }

 function iw_onLoad()
 {
  var is_freezing = <% iw_web_AutoConn_freeze_update(); %>;

  // init value of settings 
  $('#iw_AeroMag_enable').val("<% iw_webCfgValueHandler("AeroMag", "enable", "DISABLE"); %>");
  if( is_freezing )
   $('#AutoConn_freeze').attr("checked", "checked");
  if( "<% iw_webCfgValueHandler("AeroMag", "reset", "DISABLE"); %>" == "ENABLE"
    || done_for_settings == 0)
   $("#iw_aeroMagAction_new").attr("checked", "checked");
  else
   $("#iw_aeroMagAction_keep").attr("checked", "checked");

  // set the privilege of settings
  iw_setting_privilege();

  // update AeroMag information Area
  iw_onchange_AutoConnMode();

  editPermission();
  top.toplogo.location.reload();
 }

 function update_client_status(aeroMag_res)
 {
  var status, table;

  $("#am_status_client").empty();

  $('<h2>AeroMag Client Operating Status</h2>').appendTo('#am_status_client');
  table = $('<ul>');
  table.appendTo('#am_status_client');

  // title
  $('<li class="AEROMAG_STAGE_TITLE TABLE_TITLE">').text("AeroMag Operating Stage").appendTo(table);
  $('<li class="AEROMAG_STAGE_VALUE TABLE_TITLE">').text("Status").appendTo(table);

  // status
  status = $('<li class="AEROMAG_STAGE_TITLE TABLE_ROW1">').text(aeroMag_res.CLIENT_STATUS.find_ap.desc).appendTo(table);
  status = $('<li class="AEROMAG_STAGE_VALUE TABLE_ROW1">').text(aeroMag_res.CLIENT_STATUS.find_ap.val).appendTo(table);

  status = $('<li class="AEROMAG_STAGE_TITLE TABLE_ROW2">').text(aeroMag_res.CLIENT_STATUS.identity_verification.desc).appendTo(table);
  status = $('<li class="AEROMAG_STAGE_VALUE TABLE_ROW2">').text(aeroMag_res.CLIENT_STATUS.identity_verification.val).appendTo(table);

  status = $('<li class="AEROMAG_STAGE_TITLE TABLE_ROW1">').text(aeroMag_res.CLIENT_STATUS.apply_config.desc).appendTo(table);
  status = $('<li class="AEROMAG_STAGE_VALUE TABLE_ROW1">').text(aeroMag_res.CLIENT_STATUS.apply_config.val).appendTo(table);

 }

 function update_ap_status(aeroMag_res)
 {
  var status, table;

  $("#am_status_ap").empty();

  $('<h2>AeroMag AP Operating Status</h2>').appendTo('#am_status_ap');
  table = $('<ul>');
  table.appendTo('#am_status_ap');

  // title
  $('<li class="AEROMAG_STAGE_TITLE TABLE_TITLE">').text("AeroMag Operating Stage").appendTo(table);
  $('<li class="AEROMAG_STAGE_VALUE TABLE_TITLE">').text("Status").appendTo(table);

  // status
  status = $('<li class="AEROMAG_STAGE_TITLE TABLE_ROW1">').text(aeroMag_res.AP_STATUS.grouping.desc).appendTo(table);
  status = $('<li class="AEROMAG_STAGE_VALUE TABLE_ROW1">').text(aeroMag_res.AP_STATUS.grouping.val).appendTo(table);

  status = $('<li class="AEROMAG_STAGE_TITLE TABLE_ROW2">').text(aeroMag_res.AP_STATUS.generating_config.desc).appendTo(table);
  status = $('<li class="AEROMAG_STAGE_VALUE TABLE_ROW2">').text(aeroMag_res.AP_STATUS.generating_config.val).appendTo(table);

  status = $('<li class="AEROMAG_STAGE_TITLE TABLE_ROW1">').text(aeroMag_res.AP_STATUS.alignment_config.desc).appendTo(table);
  status = $('<li class="AEROMAG_STAGE_VALUE TABLE_ROW1">').text(aeroMag_res.AP_STATUS.alignment_config.val).appendTo(table);

  status = $('<li class="AEROMAG_STAGE_TITLE TABLE_ROW2">').text(aeroMag_res.AP_STATUS.ready_deploying.desc).appendTo(table);
  status = $('<li class="AEROMAG_STAGE_VALUE TABLE_ROW2">').text(aeroMag_res.AP_STATUS.ready_deploying.val).appendTo(table);

  status = $('<li class="AEROMAG_STAGE_TITLE TABLE_ROW1">').text(aeroMag_res.AP_STATUS.refresh_chan.desc).appendTo(table);
  status = $('<li class="AEROMAG_STAGE_VALUE TABLE_ROW1">').text(aeroMag_res.AP_STATUS.refresh_chan.val).appendTo(table);
 }

 function update_config_status(aeroMag_res)
 {
  var status, table, show_pwd;
  var chan_data = "", idx, warn_msg;

  $("#am_status_config").empty();

  $('<br>').appendTo('#am_status_config');
  $('<h2>AP Settings</h2>').appendTo('#am_status_config');
  table = $('<ul>');
  table.appendTo('#am_status_config');

  $('<li class="AEROMAG_SETTING_TITLE">').text("SSID").appendTo(table);
  $('<li class="AEROMAG_SETTING_VALUE">').text(aeroMag_res.CONFIG.SSID).appendTo(table);

  $('<li class="AEROMAG_SETTING_TITLE">').text("Password").appendTo(table);
  if( aeroMag_res.CONFIG.PWD_AUTHORITY )
  {
   // Layout & default value
   $('<li class="AEROMAG_SETTING_VALUE" id="am_config_pwd">').appendTo(table);
   show_pwd = $('<input type="checkbox" id="am_config_pwd_showchk" />');
   show_pwd.appendTo('#am_config_pwd');
   $('#am_config_pwd').append('<span id="am_config_pwd_val"></span>');
   $('#am_config_pwd_val').text("*************");

   // event
   $('#am_config_pwd_showchk').click(function()
   {
    if($("#am_config_pwd_showchk").is(':checked'))
    {
     $('#am_config_pwd_val').text(aeroMag_res.CONFIG.PWD);
    } else
    {
     $('#am_config_pwd_val').text("*************");
    }
   });
  } else
  {
   $('<li class="AEROMAG_SETTING_VALUE">').text(aeroMag_res.CONFIG.PWD).appendTo(table);
  }

  $('<li class="AEROMAG_SETTING_TITLE">').text("RF Type").appendTo(table);
  $('<li class="AEROMAG_SETTING_VALUE">').text(iwStrMap(aeroMag_res.CONFIG.RF_TYPE)).appendTo(table);


  if( aeroMag_res.CONFIG.USED_CHAN == 0 )
  {
   chan_data = "N/A"
  } else
  {
   for(idx=0; idx < 3; idx++)
   {
    if( idx != 0 )
     chan_data = chan_data + ", ";
    chan_data = chan_data + aeroMag_res.CONFIG.CHANNEL_LIST[idx].CHANNEL;
    if( $('#iw_AeroMag_enable').val() == "AP"
       && aeroMag_res.CONFIG.CHANNEL_LIST[idx].CHANNEL == aeroMag_res.CONFIG.USED_CHAN )
    {
     chan_data = chan_data + "(*)";
    }
   }
  }

  $('<li class="AEROMAG_SETTING_TITLE">').text("Channel").appendTo(table);
  $('<li class="AEROMAG_SETTING_VALUE">').text(chan_data).appendTo(table);

  warn_msg = "";
  if( aeroMag_res.CONFIG_DONE == 1 && aeroMag_res.CONFIG.SSID != aeroMag_res.CONFIG.SSID_CONFIG)
  {
   warn_msg = 'SSID could be changed to \"' + aeroMag_res.CONFIG.SSID_CONFIG + '"';
  }

  if( warn_msg.length != 0 )
  {
   $('<p>').css('clear', 'both').css('padding-top', '5px').css('color', 'blue')
    .css('font-weight', 'bolder')
    .text('Warning: After Save and Restart, ' + warn_msg + '- unless "Generate a new configuration" is selected').appendTo('#am_status_config');
  }
 }

 function update_conn_dev_status(aeroMag_res)
 {
  var idx;
  var dev_no, dev_time, dev_src, dev_join, dev_join_mode, dev_join_status;

  $("#am_status_conn_dev").empty();

  $('<br>').appendTo('#am_status_conn_dev');
  $('<h2>AeroMag Unit Logs</h2>').appendTo('#am_status_conn_dev');
  table = $('<ul class="AEROMAG_CONN_DEV">');
  table.appendTo('#am_status_conn_dev');

  // title
  $('<li class="CONN_DEV_NO		TABLE_TITLE">').text("No.").appendTo(table);
  $('<li class="CONN_DEV_TIME	TABLE_TITLE">').text("Timestamp").appendTo(table);
  $('<li class="CONN_DEV_MAC		TABLE_TITLE">').text("Source Device").appendTo(table);
  $('<li class="CONN_DEV_MAC		TABLE_TITLE">').text("Joining Device").appendTo(table);
  $('<li class="CONN_DEV_OP		TABLE_TITLE">').text("Mode").appendTo(table);
  $('<li class="CONN_DEV_STATUS	TABLE_TITLE">').text("Joining Status").appendTo(table);

  if( aeroMag_res.CONN_DEV_LIST.length == 0 )
  {
   table = $('<ul>');
   table.appendTo('#am_status_conn_dev');
   $('<li class="CONN_DEV_NO     TABLE_ROW1">').text("N/A").appendTo(table);
   $('<li class="CONN_DEV_TIME   TABLE_ROW1">').text("N/A").appendTo(table);
   $('<li class="CONN_DEV_MAC    TABLE_ROW1">').text("N/A").appendTo(table);
   $('<li class="CONN_DEV_MAC    TABLE_ROW1">').text("N/A").appendTo(table);
   $('<li class="CONN_DEV_OP     TABLE_ROW1">').text("N/A").appendTo(table);
   $('<li class="CONN_DEV_STATUS TABLE_ROW1">').text("N/A").appendTo(table);

   return;
  }

  for(idx = 0; idx < aeroMag_res.CONN_DEV_LIST.length; idx++)
  {
   table = $('<ul class="AEROMAG_CONN_DEV">');
   table.appendTo('#am_status_conn_dev');

   dev_no = $('<li class="CONN_DEV_NO">');
   dev_time = $('<li class="CONN_DEV_TIME">');
   dev_src = $('<li class="CONN_DEV_MAC">');
   dev_join = $('<li class="CONN_DEV_MAC">');
   dev_join_mode = $('<li class="CONN_DEV_OP">');
   dev_join_status = $('<li class="CONN_DEV_STATUS">');

   dev_no.text( idx + 1 );
   dev_time.text(aeroMag_res.CONN_DEV_LIST[idx].TS);
   dev_src.html(aeroMag_res.CONN_DEV_LIST[idx].SRC_NAME + "<br>(" + aeroMag_res.CONN_DEV_LIST[idx].SRC_MAC + ")");
   dev_join.html(aeroMag_res.CONN_DEV_LIST[idx].JOIN_NAME + "<br>(" + aeroMag_res.CONN_DEV_LIST[idx].JOIN_MAC + ")");
   dev_join_mode.text(aeroMag_res.CONN_DEV_LIST[idx].JOIN_ROLE);
   dev_join_status.text(aeroMag_res.CONN_DEV_LIST[idx].JOIN_STATUS);

   if( (idx % 2) == 0)
   {
    dev_no.addClass('TABLE_ROW1');
    dev_time.addClass('TABLE_ROW1');
    dev_src.addClass('TABLE_ROW1');
    dev_join.addClass('TABLE_ROW1');
    dev_join_mode.addClass('TABLE_ROW1');
    dev_join_status.addClass('TABLE_ROW1');
   } else
   {
    dev_no.addClass('TABLE_ROW2');
    dev_time.addClass('TABLE_ROW2');
    dev_src.addClass('TABLE_ROW2');
    dev_join.addClass('TABLE_ROW2');
    dev_join_mode.addClass('TABLE_ROW2');
    dev_join_status.addClass('TABLE_ROW2');
   }

   dev_no.appendTo(table);
   dev_time.appendTo(table);
   dev_src.appendTo(table);
   dev_join.appendTo(table);
   dev_join_mode.appendTo(table);
   dev_join_status.appendTo(table);
  }
 }

 function update_channel_arrange_status(aeroMag_res)
 {
  var idx, row_max;
  var dev_chan1, dev_chan2, dev_chan3;

  $("#am_status_channel_arrange").empty();

  $('<br>').appendTo('#am_status_channel_arrange');
  $('<h2>Channel Arrangement</h2>').appendTo('#am_status_channel_arrange');
  table = $('<ul>');
  table.appendTo('#am_status_channel_arrange');

  $('<li class="CHAN_ARRAGNE_TITLE          TABLE_TITLE">').text(aeroMag_res.CONFIG.CHANNEL_LIST[0].CHANNEL).appendTo(table);
  $('<li class="CHAN_ARRAGNE_TITLE          TABLE_TITLE">').text(aeroMag_res.CONFIG.CHANNEL_LIST[1].CHANNEL).appendTo(table);
  $('<li class="CHAN_ARRAGNE_TITLE          TABLE_TITLE">').text(aeroMag_res.CONFIG.CHANNEL_LIST[2].CHANNEL).appendTo(table);

  row_max = (aeroMag_res.CHAN_ARRANGE.CHAN_1.length > aeroMag_res.CHAN_ARRANGE.CHAN_2.length) ?
   aeroMag_res.CHAN_ARRANGE.CHAN_1.length : aeroMag_res.CHAN_ARRANGE.CHAN_2.length;
  row_max = (aeroMag_res.CHAN_ARRANGE.CHAN_3.length > row_max) ? aeroMag_res.CHAN_ARRANGE.CHAN_3.length : row_max;

  if( row_max <= 0 )
  {
   $('<li class="CHAN_ARRANGE_VALUE TABLE_ROW1">').text("N/A").appendTo(table);
   $('<li class="CHAN_ARRANGE_VALUE TABLE_ROW1">').text("N/A").appendTo(table);
   $('<li class="CHAN_ARRANGE_VALUE TABLE_ROW1">').text("N/A").appendTo(table);
   return;
  }

  for(idx = 0 ; idx < row_max ; idx++)
  {
   dev_chan1 = $('<li class="CHAN_ARRANGE_VALUE">');
   dev_chan2 = $('<li class="CHAN_ARRANGE_VALUE">');
   dev_chan3 = $('<li class="CHAN_ARRANGE_VALUE">');

   if( (idx % 2) == 0 )
   {
    dev_chan1.addClass('TABLE_ROW1');
    dev_chan2.addClass('TABLE_ROW1');
    dev_chan3.addClass('TABLE_ROW1');
   } else
   {
    dev_chan1.addClass('TABLE_ROW2');
    dev_chan2.addClass('TABLE_ROW2');
    dev_chan3.addClass('TABLE_ROW2');
   }

   // dev of 1st channel
   if( idx >= aeroMag_res.CHAN_ARRANGE.CHAN_1.length )
    dev_chan1.text("N/A");
   else
    dev_chan1.text(aeroMag_res.CHAN_ARRANGE.CHAN_1[idx].DEV);

   // dev of 2nd channel
   if( idx >= aeroMag_res.CHAN_ARRANGE.CHAN_2.length )
    dev_chan2.text("N/A");
   else
    dev_chan2.text(aeroMag_res.CHAN_ARRANGE.CHAN_2[idx].DEV);

   // dev of 3rd channel
   if( idx >= aeroMag_res.CHAN_ARRANGE.CHAN_3.length )
    dev_chan3.text("N/A");
   else
    dev_chan3.text(aeroMag_res.CHAN_ARRANGE.CHAN_3[idx].DEV);

   dev_chan1.appendTo(table);
   dev_chan2.appendTo(table);
   dev_chan3.appendTo(table);
  }
 }

 function show_status_ap()
 {
  $.getJSON("/restful/getAeroMagAPStatus", function(aeroMag_res)
  {
   var done_for_settings_temp, done_for_auto_update_temp, done_changed = 0;
   update_ap_status(aeroMag_res);
   update_config_status(aeroMag_res);
   update_conn_dev_status(aeroMag_res);
   update_channel_arrange_status(aeroMag_res);

   // Lock status
   if( aeroMag_res.LOCK_STATUS )
    $("#AutoConn_freeze").attr('checked', 'checked');
   else
    $("#AutoConn_freeze").attr('checked', '');

   done_for_settings_temp = ( aeroMag_res.CONFIG_DONE ) ? 1 : 0;
   if( done_for_settings != done_for_settings_temp )
   {
    done_changed = 1;
    done_for_settings = done_for_settings_temp;

    if( done_for_settings_temp )
     $("#iw_aeroMagAction_keep").attr("checked", "checked");
   }

   if( aeroMag_res.AP_STATUS.ready_deploying.val == "Done"
      && (aeroMag_res.AP_STATUS.refresh_chan.val == "Ready" ||
     aeroMag_res.AP_STATUS.refresh_chan.val == "Refresh Channel failed because not all AeroMag APs are available now. Please try again." ))
   {
    done_for_auto_update_temp = 1;
   } else
   {
    done_for_auto_update_temp = 0;
   }

   if( done_for_auto_update_temp != done_for_auto_update )
   {
    done_for_auto_update = done_for_auto_update_temp;
    done_changed = 1;
   }

   if( done_changed )
    iw_setting_privilege();

  }).error(function(jqXHR, textStatus, errorThrown){ /* assign handler */
   /* alert(jqXHR.responseText) */
  });
 }

 function show_status_client()
 {
  $.getJSON("/restful/getAeroMagClientStatus", function(aeroMag_res)
  {
   var done_for_settings_temp, done_for_auto_update_temp, done_changed = 0;

   update_client_status(aeroMag_res);
   update_config_status(aeroMag_res);

   done_for_settings_temp = ( aeroMag_res.CONFIG_DONE ) ? 1 : 0;
   if( done_for_settings != done_for_settings_temp )
   {
    done_changed = 1;
    done_for_settings = done_for_settings_temp;

    if( done_for_settings_temp )
     $("#iw_aeroMagAction_keep").attr("checked", "checked");
   }

   done_for_auto_update_temp = ( aeroMag_res.CLIENT_STATUS.apply_config.val == "Done" ) ? 1 : 0;
   if( done_for_auto_update_temp != done_for_auto_update )
   {
    done_for_auto_update = done_for_auto_update_temp;
    done_changed = 1;
   }

   if( done_changed )
    iw_setting_privilege();

  }).error(function(jqXHR, textStatus, errorThrown){ /* assign handler */
   /* alert(jqXHR.responseText) */
  });
 }

 function show_status()
 {
  var aeroMag_mode = $('#iw_AeroMag_enable').val();
  if( $('#iw_AeroMag_enable').val() == "AP")
   show_status_ap();
  else if( $('#iw_AeroMag_enable').val() == "Client" )
   show_status_client();
  return;
 }

 function activate_refresh(waiting_sec)
 {
  if( $("#ref5").is(':checked') )
  {
   refresh_timeout = waiting_sec;
   if( refresh_active_lock == 0 )
   {
    refresh_active_lock = 1;
    do_referesh_status();
   }
  }
 }

 function do_referesh_status()
 {
  if( "<% iw_webCfgValueMainHandler("AeroMag", "enable", ""); %>" == "DISABLE" )
  {
   $('#ref5_desc').text("Auto Update: When AeroMag is inactive, Update is not needed.");
   $("#ref5").attr("disabled", true);
   $("#ref5").attr("checked", "");
  } else if( !$("#ref5").is(':checked') )
  {
   $('#ref5_desc').text('Auto Update: Please enable "Auto Update", if status update is required.');
   refresh_active_lock = 0;
  } else
  {
   if( refresh_timeout == 0 )
    $('#ref5_desc').text('Auto Update: Updating ...');
   else
    $('#ref5_desc').text('Auto Update: Update after ' + refresh_timeout + ' secs ...');
   window.setTimeout("do_referesh_status()", 1000);
  }

  if( refresh_timeout == 0 )
  {
   /* set no cache */
   $.ajaxSetup({ cache: false });
   show_status();

   if( $("#ref5").is(':checked') )
   {
    refresh_timeout = ( done_for_auto_update ) ? 30 : 5;
   }

  } else if( $("#ref5").is(':checked') )
  {
   refresh_timeout--;
  }
 }

  -->
  </script>
</HEAD>
<BODY onLoad="iw_onLoad()">
 <h2>AeroMag <% iw_websGetErrorString(); %></h2>
 <FORM name="aeroMag" method="POST" action="/forms/iw_webSetParameters">
 <table width=100%>
  <tr>
   <td width="20%" class="column_title">AeroMag operation mode</td>
   <td width="80%">
    <select size="1" name="iw_AeroMag_enable" id="iw_AeroMag_enable" onChange="iw_onchange_AutoConnMode();">
     <% iw_web_AutoConn_opmode(); %>
    </select>
   </td>
  </tr>
  <tr id="iw_AutoConn_both_action" style="display:none">
   <td width="20%" class="column_title">Apply AeroMag configuration</td>
   <td width="80%">
    <INPUT type="radio" name="iw_AeroMag_reset" id="iw_aeroMagAction_keep" value="DISABLE" />
    <LABEL for="iw_aeroMagAction_">Use the current configuration</LABEL>&nbsp;&nbsp;&nbsp;
    <INPUT type="radio" name="iw_AeroMag_reset" id="iw_aeroMagAction_new" value="ENABLE" />
    <LABEL for="iw_lanEnable_new">Generate a new configuration</LABEL>
   </td>
  </tr>
  <tr id="iw_AutoConn_freeze" style="display:none">
   <td width="20%" class="column_title">Lock AeroMag topology</td>
   <td width="80%">
    <ul class="HELP_UL">
     <li><input type="checkbox" name="AutoConn_freeze" id="AutoConn_freeze" onclick="AutoConn_freeze_onClick();"></li>
     <li class="HELP_IMG"><img src="Info.png"/><span class="TOOLTIP_TEXT"><% iw_web_AutoConn_freeze(); %></span></li>
    </ul>
   </td>
  </tr>
 </table>
 <table width="100%">
  <TR>
   <HR>
   <INPUT type="submit" value="Submit" name="Submit" />
   <Input type="hidden" name="bkpath" value="/aeroMag.asp" />
   </HR>
  </TR>
 </table>
 <br>
 <div class="AEROMAG_CHAN_REFRESH" id="iw_AutoConn_AP_refresh" style="display:none">
  <ul>
   <li><INPUT type="button" id="am_refresh_channel" value="Refresh Channel" onClick="aeroMag_refreshChan();"
    title="The AWK will change channels when the active channel is congested." /></li>
  </ul>
 </div>

 <div id="iw_AutoConn_Refresh" style="display:none">
  <input type='checkbox' id='ref5' onclick='activate_refresh(0)' /><label for='ref5' id="ref5_desc"></label>

 </div>

 <div class="AEROMAG_STAGE" id="am_status_ap" style="display:none"></div>
 <div class="AEROMAG_STAGE" id="am_status_client" style="display:none"></div>
 <div class="AEROMAG_SETTING" id="am_status_config" style="display:none"></div>
 <div class="CHAN_ARRANGE" id="am_status_channel_arrange"></div>
 <div class="AEROMAG_CONN_DEV" id="am_status_conn_dev"></div>
 <div class="AEROMAG_CHAN_REFRESH" id="iw_AutoConn_ConnDev_clear" style="display:none">
  <ul>
   <li><INPUT type="button" value="Clear" onClick="aeroMag_ConnDev_clear();" title="Clear all data above"></li>
  </ul>
 </div>


 <br/>
 <br/>
 <br/>

 <input type="hidden" id="iw_checkbox_show"/>
 </FORM>
</BODY>
</HTML>
