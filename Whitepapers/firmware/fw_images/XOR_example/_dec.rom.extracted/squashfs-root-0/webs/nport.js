function inputText(name, len, value)
{
	document.write("<INPUT type='text' name='" + name + "' size=" + (len + 5) + " maxlength=" + len + " id=\"" + name + "\">");
	document.getElementById(name).value = value;
}
function inputTextEx(name, len, value, more)
{
	document.write("<INPUT type='text' name='" + name + "' size=" + (len + 5) + " maxlength=" + len + " id=\"" + name + "\" " + more + ">");
	document.getElementById(name).value = value;
}
function inputPassword(name, len, value)
{
	document.write("<INPUT type='password' name='" + name + "' size=" + (len + 5) + " maxlength=" + len + " id=\"" + name + "\">");
	document.getElementById(name).value = value;
}
function swap_opt(opt1, opt2)
{
	var	ctext = opt1.text;
	var	cid = opt1.id;
	var	cvalue = opt1.value;
	
	opt1.text = opt2.text;
	opt1.id = opt2.id;
	opt1.value = opt2.value;
	
	opt2.text = ctext;
	opt2.id = cid;
	opt2.value = cvalue;
}
function option_up(sel)
{
	var	idx = sel.options.selectedIndex;
	if(idx > 0)
	{
		swap_opt(sel.options[idx], sel.options[idx - 1]);
		--sel.options.selectedIndex;
	}
}
function option_down(sel)
{
	var	idx = sel.options.selectedIndex;
	if(idx >= 0 && idx < sel.options.length - 1)
	{
		swap_opt(sel.options[idx], sel.options[idx + 1]);
		++sel.options.selectedIndex;
	}
}
function option_sort(source_obj, result_obj)
{
	var	i;
	var	value_sorted = "";
	for(i = 0; i < source_obj.length; i++)
	{
		if(i > 0)
			value_sorted += ","
		value_sorted += source_obj.options[i].value;
	}
	result_obj.value = value_sorted;
}
function applyToPort(this_port)
{
	if(getNumOfSerialPorts() == 1)
	{
	}
	else if(getNumOfSerialPorts() == 2)
	{
		document.write("<TR>");
			document.write("<TD width=\"100%\" colspan=\"3\">");
				document.write("<INPUT type=\"checkbox\" name=\"ApplyAll\" value=\"ON\" id=\"ApplyAll\"><label for=\"ApplyAll\">Apply the above settings to all serial ports</label>");
			document.write("</TD>");
		document.write("</TR>");
	}
	else
	{
		var	port;
		document.write("<TR>");
			document.write("<TD width=\"30%\" class=\"column_title\">Apply the above settings to</TD>");
			document.write("<TD width=\"70%\">");
				document.write("<TABLE width=\"100%\">");
				document.write("<TR>");
					for(port = 1; port <= getNumOfSerialPorts(); port++)
					{
						if(port % 8 == 1)
						{
							if(port != 1)
								document.write("</TR><TR>");
						}
						document.write("<TD>");
							document.write("<INPUT type=\"checkbox\" name=\"ApplyTo" + port + "\" value=\"Yes\" id=\"ApplyTo" + port + "\"" + ((port == this_port) ? " disabled checked" : "") + " onclick=\"var i;for(i=1;i<=getNumOfSerialPorts();i++)if(document.getElementById(\'ApplyTo\'+i).checked==false){document.getElementById(\'ApplyToAll\').checked=false;return;}document.getElementById(\'ApplyToAll\').checked=true;\"><label for=\"ApplyTo" + port + "\">P" + port + "</label>");
						document.write("</TD>");
					}
				document.write("</TR><TR>");
					document.write("<TD colspan=\"8\">");
						document.write("<INPUT type=\"checkbox\" name=\"ApplyToAll\" id=\"ApplyToAll\" onclick=\"var i;for(i=1;i<=getNumOfSerialPorts();i++)if(i!=" + this_port + ")document.getElementById(\'ApplyTo\'+i).checked=this.checked;\"><label for=\"ApplyToAll\">All ports</label>");
					document.write("</TD>");
				document.write("</TR>");
				document.write("</TABLE>");
			document.write("</TD>");
		document.write("</TR>");
	}
}