function verifyIP(ipaddr, str)
{
	var regex = /^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$/;
	var ret=1;
	
        if( 0 == ipaddr.value.length ){
                return ret;
        }
        
	if( regex.test(ipaddr.value) )
	{
		var parts = ipaddr.value.split(".");
		var a = parseInt(parts[0]);
		var b = parseInt(parts[1]);
		var c = parseInt(parts[2]);
		var d = parseInt(parts[3]);

		// ip over 255
		if(a > 255 || b > 255 || c > 255 || d > 255)
			ret = 0;

		// 0.0.0.0
		if(a+b+c+d == 0)
			ret = 0;
		// 255.255.255.255
		if(a+b+c+d == 255*4)
			ret = 0;
	}
	else
		ret = 0;

	if( ret == 0 )
	{
		alert("Invalid input: \"" + str + "\" (" + ipaddr.value + ")");
		ipaddr.focus();
	}

	return ret;
}
function isSameIP(ipaddr1, ipaddr2){
	var ret=0;
	var regex = /^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$/;

	if( regex.test(ipaddr1.value)){
		var parts = ipaddr1.value.split(".");
		var a = parseInt(parts[0]);
                var b = parseInt(parts[1]);
                var c = parseInt(parts[2]);
                var d = parseInt(parts[3]);
		if(regex.test(ipaddr2.value)){
			var parts1 = ipaddr2.value.split(".");
	                var e = parseInt(parts1[0]);
        	        var f = parseInt(parts1[1]);
               		var g = parseInt(parts1[2]);
                	var h = parseInt(parts1[3]);

		}
		if(a == e && b == f && c == g && d == h){
			ret = 1
		}
	}
	return ret;
}

function verifyNetmask(ipaddr, str)
{
	var regex = /^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$/;
	var valid = 1;
	var i;

	if( regex.test(ipaddr.value) )
	{
		var parts = ipaddr.value.split(".");
		var val = new Array(0, 128, 192, 224, 240, 248, 252, 254, 255);
		var idx;

		valid = 0;
		for(idx = 0; idx < 4; idx++)
		{
			if(!valid)
			{
				for(i = 0; i < val.length; i++)
				{
					if(parseInt(parts[idx]) == val[i])	// Is a valid netmask number
					{
						valid = 1;
						break;
					}
				}
				if(!valid)	// Not a valid netmask number
					break;
			}
			else
			{
				if(parseInt(parts[idx]) != 0)
				{
					valid = 0;
					break;
				}
			}
			if(idx < 3 && parseInt(parts[idx]) == 255)
			{
				valid = 0;	// Continue next stage verification
			}
		}
	} else
		valid = 0;

	if( valid == 0 )
	{
		alert("Invalid input: \"" + str + "\" (" + ipaddr.value + ")");
		ipaddr.focus();
	}
	return valid;
}

function verifyStartIP(ipaddr, str)
{
	var regex = /^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$/;
	var ret=1;
	
        if( 0 == ipaddr.value.length ){
                return ret;
        }
        
	if( regex.test(ipaddr.value) )
	{
		var parts = ipaddr.value.split(".");
		var a = parseInt(parts[0]);
		var b = parseInt(parts[1]);
		var c = parseInt(parts[2]);
		var d = parseInt(parts[3]);

		// ip over 255
		if(d == 255 || d == 0)
			ret = 0;
	}
	else
		ret = 0;

	if( ret == 0 )
	{
		alert("Invalid input: \"" + str + "\" (" + ipaddr.value + ")");
		ipaddr.focus();
	}

	return ret;
}

function verifyMulticastIP(ipaddr, str)
{
	var regex = /^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$/;
	var ret=1;
	
        if( 0 == ipaddr.value.length ){
                return ret;
        }
        
	if( regex.test(ipaddr.value) )
	{
		var parts = ipaddr.value.split(".");
		var a = parseInt(parts[0]);
		var b = parseInt(parts[1]);
		var c = parseInt(parts[2]);
		var d = parseInt(parts[3]);

		// ip first byte from left side between 224 and 239 is multicast IP
		if (a >= 224 && a<=239)
			ret = 0;
	}
	else
	{
		ret = 0;
	}

	return ret;
}

function verifyReservedIP(ipaddr, str)
{
	var regex = /^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$/;
	var ret=1;
	
        if( 0 == ipaddr.value.length ){
                return ret;
        }
        
	if( regex.test(ipaddr.value) )
	{
		var parts = ipaddr.value.split(".");
		var a = parseInt(parts[0]);
		var b = parseInt(parts[1]);
		var c = parseInt(parts[2]);
		var d = parseInt(parts[3]);

		// ip over 255
		if (a >= 240)
			ret = 0;
	}
	else
		ret = 0;

	if( ret == 0 )
	{
		alert("Invalid input: \"" + str + "\" (reserved IP/" + ipaddr.value + ")");
		ipaddr.focus();
	}

	return ret;
}

function verifyBroadcastIP(ipaddr, netmask, str)
{
	var regex = /^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$/;
	var ret=1;
	var t1, t2, t3, t4;
	
        if( (0 == ipaddr.value.length) || (0 == netmask.value.length )){
		  alert("IP or netmask cannot be empty.");
                return 0;
        }
        
	regex.test(ipaddr.value);
	var parts = ipaddr.value.split(".");
	var a = parseInt(parts[0]);
	var b = parseInt(parts[1]);
	var c = parseInt(parts[2]);
	var d = parseInt(parts[3]);
        
	regex.test(netmask.value);
	var partsn = netmask.value.split(".");
	var an = parseInt(partsn[0]);
	var bn = parseInt(partsn[1]);
	var cn = parseInt(partsn[2]);
	var dn = parseInt(partsn[3]);

	t1= (255 - an) +(a & an);
	t2= (255 - bn) +(b & bn);
	t3= (255 - cn) +(c & cn);
	t4= (255 - dn) +(d & dn);

	if( (a==t1) &&  (b==t2) && (c==t3) && (d==t4))
	{
		ret = 0;
		alert("Invalid input: \"" + str + "\" (broadcast IP/" + ipaddr.value + ")");
		ipaddr.focus();
	}

	return ret;
}

function isAlphaNumericString(str)
{
    var i;
    alphanum = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_*";
    for (i=0; i<str.length; i++)
    {
        if (alphanum.indexOf(str.charAt(i)) < 0)
        {
            return 0;
        }
    }
    return 1;
}

function isAsciiString(str)
{
    var i;
    alphanum = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789`~!@#$%^&*()_+-={}|[]\\:\";'<>?,./ ";
    for (i=0; i<str.length; i++)
    {
        if (alphanum.indexOf(str.charAt(i)) < 0)
        {
            return 0;
        }
    }
    return 1;
}
function isHEXDelimiter(str)
{
    var i;
    alphanum = "abcdefABCDEF0123456789";
    for (i=0; i<str.length; i++)
    {
        if (alphanum.indexOf(str.charAt(i)) < 0)
        {
            return 0;
        }
    }
    return 1;
}

function isMACaddress(mac)
{    
	var mac_arr = mac.split(":");    
	var i, ret=1;	
	if (mac.length==0)		
		return ret;	
	if ( mac.length>0 && mac.length<17)		
	{
		window.alert("Invalid MAC address. \nThe correct MAC address format should be \"00:00:00:00:00:00\" (HEX)."); 
		return 0;	    
	}

	for (i=0; i<6; i++)    
	{        
		if (mac_arr[i].length>2)        
		{            
			ret = 0;			
			break;        
		}				
		if (!isHEXDelimiter(mac_arr[i]))        
		{            
			ret = 0;			
			break;        
		}    
	}    
	if (ret == 0)    
	{        
		window.alert("Invalid MAC address. \nThe correct MAC address format should be \"00:00:00:00:00:00\" (HEX).");    
	}    
	return ret;
}

function isRoamDomainaddress(mac)
{    
	var mac_arr = mac.split(":");    
	var i, ret=1;
	
	if (mac.length==0)		
		return ret;	
		
	if ( mac.length>0 && mac.length<8)		
	{
			window.alert("Invalid Roaming domain address. \nThe correct Roaming domain address format should be \"FF:90:E8:00:00:00\" (HEX)."); 
			return 0;	    
	}

	for (i=0; i<3; i++)    
	{        
		if (mac_arr[i].length>2)        
		{            
			ret = 0;			
			break;        
		}				
		if (!isHEXDelimiter(mac_arr[i]))        
		{            
			ret = 0;			
			break;        
		}    
	}    
	if (ret == 0)    
	{        
		window.alert("Invalid Roaming domain address. \nThe correct Roaming domain address format should be \"00:00:00\" (HEX).");    
	}    

	return ret;
}

function isValidPort(inpString, str)
{
	return isValidNumber(inpString, 0, 65535, str);
}

function isValidNumber(inpString, minvalue, maxvalue, str)
{
	var err=1;

	if( inpString.value == "" || inpString.value < minvalue || inpString.value > maxvalue )
		err = 0;
	else
	{
		if( /^\d{1,}$/.test(inpString.value) )
			err = 1;
		else
			err = 0;
	}

	if( err == 0 )
	{
		alert("Invalid input: \"" + str + "\" (" + inpString.value + ")");
		inpString.focus();
	}

	return err;
}

function isValidNegNumber(inpString, minvalue, maxvalue, str)
{
	var err=1;

	if( inpString.value == "" || inpString.value < minvalue || inpString.value > maxvalue )
		err = 0;
	else
	{
		if( /^-\d{1,}$/.test(inpString.value) )
			err = 1;
		else
			err = 0;
	}

	if( err == 0 )
	{
		alert("Invalid input: \"" + str + "\" (" + inpString.value + ")");
		inpString.focus();
	}

	return err;
}

function isValidDHCPMaxNo(inpString, ipaddr, minvalue, maxvalue, str)
{
	var regex = /^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$/;
	var ret=1;
	
        if( 0 == ipaddr.value.length ){
                return ret;
        }
        
	if( regex.test(ipaddr.value) )
	{
		var parts = ipaddr.value.split(".");
		var d = parseInt(parts[3]);
	}
	var err=1;

	if( inpString.value == "" || inpString.value < minvalue || inpString.value > (maxvalue-d) )
		err = 0;
	else
	{
		if( /^\d{1,}$/.test(inpString.value) )
			err = 1;
		else
			err = 0;
	}

	if( err == 0 )
	{
		alert("Invalid input: \"" + str + "\" (" + inpString.value + ")");
		inpString.focus();
	}

	return err;
}


function isValidTimeNumber(inpString)
{
  	return /^\d{1,5}$/.test(inpString);
}
function isValidEmail(inpString, str)
{
	var err=1;
	if( /^.+\@(\[?)[a-zA-Z0-9\-\.]+\.([a-zA-Z]{2,3}|[0-9]{1,3})(\]?)$/.test(inpString.value) )
		return true;
	else
	{
		alert("Invalid input: \"" + str + "\" (" + inpString.value + ")");
		inpString.focus();
		return false;
	}
}

function isSameSubnet(ipA, netmask, ipB)
{
    var ipA_arr = ipA.value.split(".");
    var mask_arr = netmask.value.split(".");
    var ipB_arr = ipB.value.split(".");
    var i, ret=1;

    for (i=0; i<ipA_arr.length; i++)
    {
        if (parseInt(parseInt(ipA_arr[i])&parseInt(mask_arr[i])) != parseInt(parseInt(mask_arr[i])&parseInt(ipB_arr[i])))
        {
            ret = 0;
        }
    }
    /* 2015-03-26 Marked by CHU, MOXA. 
     * Rename this function for general usage to check IP A and B is in same subnet.
     * If not, show relative alert message in where we call this function. */
    /*if (ret == 0)
    {
        window.alert("IP address and Gateway are not at the same subnet.");
    }*/
    return ret;
}

function isValidKey(str)
{
	if(/^((\^[a-zA-Z\[\\\]\^_])|.|[ ].|.[ ])$/.test(str))
		return true;
	return false;
}

function isPhoneNumber(str)
{
    var i;
    alphanum = "0123456789";
    prefix = "+";
        
    if (str.value == "")
    	return 1;
    
    if ((str.charAt(0) != '+') && (alphanum.indexOf(str.charAt(0)) < 0))
    {	
    	return 0;
    }	
    
    for (i=1; i<str.length; i++)
    {
        if (alphanum.indexOf(str.charAt(i)) < 0)
        {        	
            return 0;
        }
    }
    return 1;
}

function trim(stringToTrim)
{
	return stringToTrim.replace(/^\s+|\s+$/g,"");
}

function iw_is5GHz (str)
{
    var iw_5Ghz = [ "A-MODE", "ANMixed", "N-MODE-5G"];

    val = jQuery.inArray(str, iw_5Ghz);
    return val == -1 ? false : true;
}

function iw_isLegacy (str)
{
    var iw_Legacy = [ "B-MODE", "BGMixed", "G-MODE", "A-MODE"];

    val = jQuery.inArray(str, iw_Legacy);
    return val == -1 ? false : true;
}

function isValidIpMaskPair( ip, netmask, itemName )
{
    var ip_arr = ip.value.split(".");
    var mask_arr = netmask.value.split(".");
    var i, ret=1;
    var ip_n, mask_n;

    for ( i = 0; i < ip_arr.length; ++i ) { 
        ip_n = parseInt(ip_arr[i]);
        mask_n = parseInt(mask_arr[i]);
        if ( ( ip_n & mask_n ) != ip_n ) { 
            ret = 0;
            break;
        }
    }   

    if( ret == 0 ) { 
        ip.focus();
		window.alert("Invalid input: " + itemName + " \n(IP: "+ ip.value + " and Netmask: " + netmask.value + " do not match.)" );
    }   
    return ret;
}


function iw_findInputDesc ( slt ) 
{
	return $(slt).parent().prev().html();
}

function iw_isValidPorts(sltArr, str, descAuto)
{
	for ( var i = 0; i < $(sltArr).length; ++i) {
		if ( descAuto ) {
			str = iw_findInputDesc( $(sltArr[i]) );
		}
		if ( $(sltArr[i]).val().length && ! isValidNumber( $(sltArr[i])[0], 1, 65535, str) ) {
			return false;
		}
	}
	return true;
}

function iw_isValidIP(sltArr, str, descAuto) 
{
	for ( var i = 0; i < sltArr.length; ++i) 
	{
		if (descAuto) {
			str = iw_findInputDesc$(sltArr[i]);
		}
		if ( $(sltArr[i]).val().length && ! verifyIP( $(sltArr[i])[0] , str)  ) {
			return false;
		}
	}
	return true;
}

function iw_hasEmpty ( sltArr, ruleStr ) 
{
	var rt = whichEmpty(sltArr);
	if ( rt >= 0 ) {
		alert( ruleStr + ' cannot have any empty fields');
		$(sltArr[rt])[0].focus();
		return true;
	}
	return false;
}

function whichEmpty ( sltArr ) 
{
	for ( var i = 0; i < sltArr.length; ++i) {
		if ( ! $(sltArr[i]).val().length ) {
			return i;
		}
	}
	return -1;
}

function iw_hasDuplicate(sltArr, alertStr)
{
    var rt;
    var newSltArr = new Array();

    for ( var i = 0; i < sltArr.length; ++i ) {
        if ( $(sltArr[i]).val().length > 0) {
            newSltArr.push(sltArr[i]);
        }
    }

    if ( (rt = whichHasDuplicate(newSltArr)) >= 0 ) {
        $(newSltArr[rt])[0].focus();
        if ( alertStr == '' ) {
			/* Do nothing */
        } else {
            window.alert(alertStr);
        }
    }
    return rt >= 0 ? true : false;
}

function whichHasDuplicate(sltArr) 
{
    var hash = {};
    for ( var i = 0; i < sltArr.length; ++i ) {
        if ( typeof( hash[ $(sltArr[i]).val() ] ) == 'undefined') {
            hash[ $(sltArr[i]).val().toString() ] = true;
        } else {
            return i;
        }
    }
    return -1;
}
