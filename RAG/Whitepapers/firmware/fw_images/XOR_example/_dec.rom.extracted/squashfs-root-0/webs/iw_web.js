function iw_selectDisplay(inputSelect, inputIndex, inputID)
{
	if( typeof inputSelect == "undefined" )
   		return;

   var tmp = document.getElementById(inputID);

   if( typeof tmp == "undefined" )
   		return;

   if( inputIndex == inputSelect.selectedIndex ){
       tmp.style.display = "none";
   } else {
       tmp.style.display = "";
   }

}

function iw_selectSet(inputSelect, token)
{
   var i, j = 0;

   if( typeof inputSelect == "undefined")
   		return;

   for(i = 0; i < inputSelect.length; i++){
        if( inputSelect[i].value == token ){
          inputSelect.selectedIndex = i;
          j++;
          break;
        }
   }
   if( 0 == j ){
         inputSelect.selectedIndex = 0;
   }
}

function iw_checkedSet(inputSelect, token)
{
   var i, j = 0;

   if( typeof inputSelect == "undefined")
   		return;

        if( "ENABLE" == token )
          inputSelect.checked = true;
        else
	   inputSelect.checked = false;
}

function iw_radioDisplay(inputRadio, inputIndex, inputID)
{
   var tmp = document.getElementById(inputID);
   if( true == inputRadio[inputIndex].checked ){
       tmp.style.display = "none";
   } else {
       tmp.style.display = "";
   }

}

function iw_radioSet(inputRadio, token)
{
    var i, j = 0;

    if( typeof inputRadio == "undefined")
   		return;

    for( i = 0; i < inputRadio.length; i++ ){
        if( inputRadio[i].value == token ){
          inputRadio[i].checked = true;
          j++;
          break;
        }
    }
    if( 0 == j ){
         inputRadio[0].checked = true;
    }
}

function iw_checkDisplay(inputCheck, inputID)
{
	if( typeof inputCheck == "undefined" )
   		return;

   var tmp = document.getElementById(inputID);

   if( typeof tmp == "undefined" )
   		return;

   if( true == inputCheck.checked ){
       tmp.style.display = "none";
   } else {
       tmp.style.display = "";
   }
}

function iw_checkSet(inputCheck, token)
{
	if( typeof inputCheck == "undefined" )
   		return;

    if( token == inputCheck.value ){
        inputCheck.checked = true;
    } else {
        inputCheck.checked = false;
    }

}

/*
ajax basic routines
*/
function iw_inithttpreq()
{
	var http_req = false;
/*
	try {  http_req = new ActiveXObject('Msxml2.XMLHTTP');   }
	catch (e)
	{
		try {   http_req = new ActiveXObject('Microsoft.XMLHTTP');    }
		catch (e2)
		{
			try {  http_req = new XMLHttpRequest();     }
			catch (e3) {  http_req = false;   }
		}
	}
*/
       if (window.XMLHttpRequest) { //: Mozilla, Safari, ...
            http_req = new XMLHttpRequest();
       } else if (window.ActiveXObject) { //: IE
            try {
                http_req = new ActiveXObject("Msxml2.XMLHTTP");
            } catch (e) {
                try {
                    http_req = new ActiveXObject("Microsoft.XMLHTTP");
                } catch (e) {}
            }
        }

	return http_req;
}

function iw_strText2Html(str)
{
	var converter = document.createElement ("div");
	(converter.textContent != null) ? (converter.textContent = str) : (converter.innerText = html);
	return converter.innerHTML;
}

function iw_strHtml2Text(str)
{
	var converter = document.createElement ("div");
	converter.innerHTML = str;
	return converter.innerText || converter.textContent; ;
}

function addslashes(str) {
	str=str.replace(/\\/g,'\\\\');
	str=str.replace(/\'/g,'\\\'');
	str=str.replace(/\"/g,'\\"');
	str=str.replace(/\0/g,'\\0');
	return str;
}

function stripslashes(str) {
	str=str.replace(/\\'/g,'\'');
	str=str.replace(/\\"/g,'"');
	str=str.replace(/\\0/g,'\0');
	str=str.replace(/\\\\/g,'\\');
	return str;
}

function htmlspecialchars(str)
{
	str = str.toString();
	str = str.replace(/&/g, '&amp;');
	str = str.replace(/</g, '&lt;');
	str = str.replace(/>/g, '&gt;');
	str = str.replace(/"/g, '&quot;');
	str = str.replace(/'/g, '&#039;');

	return str;
}

function RoamDomainaddress(mac)
{     
	var roman_domain_header = "FF:90:E8:";
  
	if(mac=="::")
		mac="";
	else	
		mac = roman_domain_header + mac;
	
	return mac;
}

function iwStrMap(str)
{
	var StrMap = [];
	StrMap['MASTER']				= 'Master';
 	StrMap['SLAVE']					= 'Slave';
 	StrMap['AP']					= 'AP';
 	StrMap['CLIENT']				= 'Client';
 	StrMap['CLIENT-ROUTER']			= 'Client-Router';
	StrMap['ACA']					= 'ACA';
	StrMap['ACC']					= 'ACC';
 	StrMap["REDUNDANT_AP"]			= "Redundant AP";
 	StrMap["REDUNDANT_CLIENT"]		= "Redundant client";
 	StrMap['AP-CLIENT']				= 'Client';
	StrMap['WIRELESS_SNIFFER']		= 'Wireless Sniffer';
	StrMap['SNIFFER']				= 'Sniffer';
	StrMap['INTER_CARRIAGE']			= 'Inter-carriage';
 	StrMap['DISABLE']				= 'Disable';
 	StrMap["WIRELESS_REDUNDANCY"]	= "Wireless redundancy";
 	StrMap["AP_WDS"]				= "AP with WDS enabled";
 	StrMap['WIRELESS_BRIDGE']		= 'Wireless bridge';
 	StrMap['AP_CLIENT']				= 'AP-Client';
 	StrMap['A-MODE']				= 'A';
 	StrMap['B-MODE']				= 'B';
 	StrMap['G-MODE']				= 'G';
 	StrMap['BGMixed']				= 'B/G Mixed';
 	StrMap['GNMixed']				= 'G/N Mixed';
 	StrMap['BGNMixed']				= 'B/G/N Mixed';
 	StrMap['ANMixed']				= 'A/N Mixed';
 	StrMap['N-MODE-24G']			= 'N Only (2.4GHz)';
 	StrMap['N-MODE-5G']				= 'N Only (5GHz)';
 	StrMap['AUTO']					= 'Auto';
 	StrMap['FULL']					= 'Full';
 	StrMap['HIGH']					= 'High';
 	StrMap['MEDIUM']				= 'Medium';
 	StrMap['LOW']					= 'Low';
 	StrMap['OPEN']					= 'Open';
 	StrMap['WEP']					= 'WEP';
 	StrMap['WPA']					= 'WPA';
 	StrMap['WPA2']					= 'WPA2';
 	StrMap['N/A']					= 'N/A';
 	StrMap['(AeroMag Processing)']	= '(AeroMag Processing)';
 	StrMap['----']					= '----';
 	
 	return StrMap[str];
}

function WlanAccStatus(state, target)
{
	this.state 	= state;
	this.target	= target;
}

function WlanStatus( devIndex, vapIndex, opmode, rftype, channel, bssid, ApIp, signalPicIndex, rssi, txrate, txpower, authtype, ssid, mac,txpk,txer,txdr,rxpk,rxer,rxdr)
{
	this.devIndex = devIndex;
	this.vapIndex = vapIndex;
	this.opmode = opmode;
	this.rftype = rftype;
	this.channel = channel;
	this.bssid = bssid;
    this.ApIp = ApIp;
	this.signalPicIndex = signalPicIndex;
	this.rssi = rssi;
	this.txrate = txrate;
	this.txpower = txpower;
	this.authtype = authtype;
	this.ssid = ssid;
	this.mac = mac;
	this.txpacket = txpk;
	this.txerror = txer;
	this.txdrop=txdr;
	this.rxpacket = rxpk;
	this.rxerror = rxer;
	this.rxdrop=rxdr;
	
}

function WlanSSID( devIndex, vapIndex, ssid )
{
	this.devIndex = devIndex;
	this.vapIndex = vapIndex;
	this.ssid = ssid;
}

function WDSInfo(wdsId, isActive, macAddr){
	this.wdsId = wdsId;
	this.isActive = isActive;
	this.macAddr = macAddr;
}

function WirelessVAP (devIndex, vapIndex, isWirelessEnable, opMode, rfType, channel, authType, ssid, isSSIDBroadcast, isWDSEnable, isAPFunctionality, wdsAry) {
	this.devIndex = devIndex;
	this.vapIndex = vapIndex;
	this.isWirelessEnable = isWirelessEnable;
	this.opMode = opMode;
	this.rfType = rfType;
	this.channel = channel;
	this.authType = authType;
	this.ssid = ssid;
	this.isSSIDBroadcast = isSSIDBroadcast;
	this.isWDSEnable = isWDSEnable;
	this.isAPFunctionality = isAPFunctionality;
	this.wdsAry = wdsAry;
}

function wirelessBasicStruct( opMode, authType, rfType, channels, SSID )
{
	this.opMode = opMode;
	this.authType = authType;
	this.rfType = rfType;
	this.channels = channels;
	this.SSID = SSID;
}

function rstpInfoStruct( portName, sectionName, isEnable, isEdge, portPrioirty, portPathCost, portStatus )
{
	this.portName = portName;
	this.sectionName = sectionName;
	this.isEnable = isEnable;
	this.isEdge = isEdge;
	this.portPrioirty = portPrioirty;
	this.portPathCost = portPathCost;
	this.portStatus = portStatus;
}

function iw_changeStateOnLoad( top )
{
    if (typeof top.toplogo != "undefined") {
        top.toplogo.location.reload();
    }
}

function reload_page( )
{
	// cannot fill with var ?
	if ( document.getElementById('ref5').checked ) {
		document.location.reload();
	}
}

function set_refresh( id, second )
{
	var timer = null;

	if ( ! window.setTimeout ) { 
		return;
	}

    if(document.getElementById(id).checked ) {
			timer = window.setTimeout("reload_page()", second * 1000);
	} else {
		if ( timer != null ) {
			clearTimeout(timer);
		}
	}
}

function toggleBlockDisplay(blockSlt, hideFlg )
{
	hideFlg ? $(blockSlt).hide() : $(blockSlt).show();
}

/* Copy and rename key of data */
function iw_loadConfig(data) {
	var iw_data = {};
	var prefix = '#iw_';
	var v;
	
	for ( section in data ) { 
		for ( key in data[section] ) {
			v = data[section][key];
			iw_data[prefix + section + '_' + key] = v;
		}
			
	}
	loadConfig(iw_data);
}
/*
 * data = { id1: data1, id2: data2};
 */
function loadConfig( data )
{
	var v, name;

	for (key in data) {
		name = key;
		v = data[key];
		// load config
		if ( $(name).is('input') ) {
			if ( $(name).is('input') && $(name).attr('type') == 'checkbox' ) { 
				$(name).attr('checked', true);
			}
			if ( $(name).is('input') && $(name).attr('type') == 'radio' ) { 
				$(name).val( new Array( v ) );
			}
			else {
				$(name).val( v.toString() );
			}
		} else if ( $(name).is('select') ) {
			$(name).val( v.toString() );
		}
	}
}
function MemoryStatus (total,used,free) 
{
    this.total = total;
    this.used = used;
    this.free = free;
    
}
function ArpTable (ip,mac) 
{
    this.ip = ip;
    this.mac = mac;
}
function RoutingTable (Dest,GW,Mask,Inf) 
{
    this.destination = Dest;
    this.gateway = GW;
    this.mask = Mask;
    this.inface = Inf;
}
function BridgeMac (Port,Mac)
{
	this.mac = Mac ;
	this.port = Port;
}
function ScriptTime (start,end)
{
	this.starttime = start ;
	this.endtime = end;
}

function iw_event_selectCheckBoxAll(ckBox, triggerArr)
{
    var realName;
    var ckFlg;
    /* Bind selectALL checkbox */
    $(ckBox).bind('change', function(event) {
        ckFlg = $(ckBox).attr('checked') ? true: false;

        for ( var i = 0; i < triggerArr.length; ++i ) {
            realName = '#' + iw_checkboxHiddenToReal(triggerArr[i].name);
            /* change checkboxs */
            $(triggerArr[i]).attr('checked', ckFlg);
            /* copy hidden checkbox to hidden input */
            $(realName).val( iw_checkboxBoolToStr(ckFlg) );
        }
    });
    /* Inner Function Point for get selectAll checkbox value */
    var getAllCkStat_fptr = function ( slt ) {
        var allFlg = true;
        for ( var j = 0; j < slt.length; ++j ) {
            allFlg &= $(slt[j]).attr('checked');
        }
        return allFlg;
    }
    /* Load current ckbox status and enable/disable select ALL button */
    $(ckBox).attr('checked', getAllCkStat_fptr(triggerArr) );

    for ( var i = 0; i < triggerArr.length; ++i ) {
        /* bind each checkbox for enabling ALL checkbox */
        $(triggerArr[i]).bind('change', function(event) {
            $(ckBox).attr('checked', getAllCkStat_fptr(triggerArr) );
        });
    }
}

/* Check Operation */
function iw_fixCheckBoxs(realCkArr)
{

    $(realCkArr).each ( function() {
        var flg;
        var name = '#' + this.name;
        var fkName = '#' + iw_checkboxRealToHidden( this.name ) ;
        /* copy data from hidden to fake checkbox */
        $(fkName).attr('checked', iw_checkboxStrToBool ( $(this).val() ) );
        /* copy data from fake to hidden */
        $(fkName).bind('change', { 'real': name }, function(event) {
            $(event.data.real).val( iw_checkboxBoolToStr( $(this).attr('checked') ) );
        });
    });
}

function iw_checkboxStrMapping( key, type ) 
{
    if ( type == 'bool' )
        return key ? 'ENABLE': 'DISABLE';
    var m = { 'DISABLE': false, 'ENABLE': true };
    return typeof(m[key]) == 'undefined' ? false : m[key] ;
}

function iw_checkboxBoolToStr( checked )
{
    return iw_checkboxStrMapping(checked, 'bool');
}

function iw_checkboxStrToBool( cond )
{
    return iw_checkboxStrMapping(cond, 'string');
}

function iw_checkboxRealToHidden( name )
{
    return 'fk_' + name;
}

function iw_checkboxHiddenToReal(name)
{
    return name.replace(/^fk_/,'');
}

function iw_warrningMessage(str)
{
	var warnMap = [];
	warnMap['SECURITY_PASSWORD']        = 'Security Warning! For your device security protection, please change your password via HTTPS.';
	warnMap['----']                     = '----';

	var message;
	if(warnMap[str] === undefined) {
		message = warnMap["----"];
	} else {
		message = warnMap[str];
	}

	return message;
}
