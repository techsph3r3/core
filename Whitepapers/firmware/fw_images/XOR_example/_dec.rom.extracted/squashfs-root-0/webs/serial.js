function iwSerialStrMap(str)
{
	var StrMap = [];
	StrMap['RS232']					= 'RS-232';
 	StrMap['RS422']					= 'RS-422';
 	StrMap['RS485_2_WIRE']			= 'RS-485 2-wire';
 	StrMap['RS485_4_WIRE']			= 'RS-485 4-wire';
 	StrMap['NONE']					= 'None';
 	StrMap['ODD']					= 'Odd';
 	StrMap['EVEN']					= 'Even';
 	StrMap['MARK']					= 'Mark';
 	StrMap['SPACE']					= 'Space';
	StrMap['ENABLE']				= 'Enable';
	StrMap['DISABLE']				= 'Disable';
 	StrMap['DEVICE_CONTROL']		= '	Device Control';
 	StrMap['15']					= '1.5';
 	StrMap['1']						= '1';
 	StrMap['2']						= '2';
	if ( StrMap[str] == "undefined" ){
		return str ;
	}
 	return StrMap[str];
}