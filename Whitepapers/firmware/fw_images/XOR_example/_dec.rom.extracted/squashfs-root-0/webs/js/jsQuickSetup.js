function qs_nav_init(opmode)
{
	var TROAM_OPMODE = ["CLIENT"];
	if( $.inArray( opmode, TROAM_OPMODE) == -1 )
	{
		$('#qs_NAV_troam').addClass("NAV_DISABLE");
		$('#qs_NAV_troam').removeAttr('href');
	}
}

function qs_init_option(ui_id, opt_list, selected_val)
{
	var idx;

	for( idx = 0; idx < opt_list.length; idx++ )
	{
		$(ui_id).append($("<option></option>").attr("value", opt_list[idx]).text(opt_list[idx]));
	}
	
	$(ui_id).val(selected_val);
}

function qs_chanList_init(val_id, chan, dfs_chan)
{
	var text, idx;

	for( idx = 0; idx < chan.length; idx++ )
	{
		chan_int = chan[idx];
		if( $.inArray( chan_int, dfs_chan ) != -1 )
			text = chan[idx] + "*";
		else
			text = chan[idx];
		
		$(val_id).append($("<option></option>").attr("value", chan[idx]).text(text));
	}
}