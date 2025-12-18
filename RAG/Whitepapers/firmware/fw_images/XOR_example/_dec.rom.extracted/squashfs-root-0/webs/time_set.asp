<HTML>
<HEAD>
 <META http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate" />
    <meta http-equiv="Pragma" content="no-cache" />
    <meta http-equiv="Expires" content="0" />
 <LINK href="nport2g.css" rel=stylesheet type=text/css>
 <TITLE><% iw_webSysDescHandler("BasicSettingsTree", "", "Basic Settings"); %></TITLE>
 <% iw_webJSList_get(); %>
 <SCRIPT Language="JavaScript">
 <!--
  function CheckValueTime(form)
  {
   if( !isValidNumber(form.Year, 2000, 2038, "Year") )
    return false;

   if( !isValidNumber(form.Month, 1, 12, "Month") )
    return false;

   if( !isValidNumber(form.Day, 1, 31, "Day") )
    return false;

   if( !isValidNumber(form.Hour, 0, 23, "Hour") )
    return false;

   if( !isValidNumber(form.Minutes, 0, 59, "Minute") )
    return false;

   if( !isValidNumber(form.Seconds, 0, 59, "Second") )
    return false;

   return true;
  }

  function CheckValue(form)
  {
      if (!isValidNumber(form.iw_IWtime_queryPeriod, 600, 9999, "<% iw_webCfgDescHandler("IWtime", "queryPeriod", "Query Period"); %>"))
      {
                 return false;
      }

      if (!isValidNumber(form.iw_IWtime_dstOnTrigHour, 0, 23, "<% iw_webCfgDescHandler("IWtime", "dstOnTrigHour", "Daylight saving start time : hour"); %>"))
      {
                 return false;
      }

      if (!isValidNumber(form.iw_IWtime_dstOnTrigMin, 0, 59, "<% iw_webCfgDescHandler("IWtime", "dstOnTrigMin", "Daylight saving start time : minute"); %>"))
      {
                 return false;
      }

      if (!isValidNumber(form.iw_IWtime_dstOffTrigHour, 0, 23, "<% iw_webCfgDescHandler("IWtime", "dstOffTrigHour", "Daylight saving stop time : hour"); %>"))
      {
                 return false;
      }

      if (!isValidNumber(form.iw_IWtime_dstOffTrigMin, 0, 59, "<% iw_webCfgDescHandler("IWtime", "dstOffTrigMin", "Daylight saving stop time : minute"); %>"))
      {
                 return false;
      }
        }

  function MakeRemote()
  {
   remote = window.open("", "rtc", "width=400, height=200, left=250, top=250, resizable=1");
   remote.location.href = "time.asp";
   if( remote.opener == null)
    remote.opener = window;
  }


  function editPermission()
  {
   var form = document.basic_time, form1 = document.ds, i, j = <% iw_websCheckPermission(); %>;
   if(j)
   {
    for(i = 0; i < form.length; i++)
     form.elements[i].disabled = true;
    for(i = 0; i < form1.length; i++)
     form1.elements[i].disabled = true;
   }
  }


         var mem_state = <% iw_websMemoryChange(); %>;
              function iw_ChangeOnLoad()
              {

                 editPermission();

                        top.toplogo.location.reload();
              }
    -->
    </Script>
</HEAD>
<BODY onLoad="  document.getElementById('dstEnable').checked = document.getElementById('iw_IWtime_dstEnable').value=='DISABLE'?false:true; document.getElementById('DSTTABLE').style.display = document.getElementById('dstEnable').checked? 'inline':'none'; 



iw_ChangeOnLoad(); ">
 <H2><% iw_webSysDescHandler("TimeSettingsTree", "", "Time Settings"); %> <% iw_websGetErrorString(); %></H2>
 <FORM name="basic_time" method="POST" action="/forms/webSetBasicTime" onSubmit="return CheckValueTime(this);">
 <TABLE>
 <TR>
  <TD rowspan="3" width=30% class="column_title">Current local time&nbsp;&nbsp;&nbsp;</TD>
  <TD class="column_title_bg" align="center" width="170">Date (YYYY/MM/DD)</TD>
  <TD class="column_title_bg" align="center" width="150">Time (HH:MM:SS)</TD>
  <td></td>
 </TR>
 <TR>
  <TD>
   <center>
   <INPUT type="text" name="Year" size="4" maxlength="4" value="<% iw_webSysValueHandler("Dateyear", "", ""); %>">&nbsp;/&nbsp;
   <INPUT type="text" name="Month" size="2" maxlength="2" value="<% iw_webSysValueHandler("Datemonth", "", ""); %>">&nbsp;/&nbsp;
   <INPUT type="text" name="Day" size="2" maxlength="2" value="<% iw_webSysValueHandler("Dateday", "", ""); %>">
   </center>
  </TD>
  <TD>
   <center>
   <INPUT type="text" name="Hour" size="2" maxlength="2" value="<% iw_webSysValueHandler("Datehour", "", ""); %>">:
   <INPUT type="text" name="Minutes" size="2" maxlength="2" value="<% iw_webSysValueHandler("Datemin", "", ""); %>">:
   <INPUT type="text" name="Seconds" size="2" maxlength="2" value="<% iw_webSysValueHandler("Datesec", "", ""); %>">
   </center>
  </TD>
  <td></td>
 </TR>
 <TR>
  <TD align="left">
   <INPUT type="submit" value="Set Time" name="SetTime">
   <Input type="hidden" name="bkpath" value="/time_set.asp">
  </TD>
  <td></td>
 </TR>
 </TABLE>
 </FORM>

 <FORM name="ds" method="POST" action="/forms/iw_webSetParameters" onSubmit="return CheckValue(this)">
 <TABLE width="100%">
    <TR>
        <TD colspan="2"><HR>
        </TD>
    </TR>

    <TR>
  <TD width="30%" class="column_title">Time protocol</TD>
  <TD width="70%">






        SNTP

    </TD>
 </TR>

 <TR>
  <TD width="30%" class="column_title"><% iw_webCfgDescHandler("IWtime", "timeZone", "Time zone"); %></TD>
  <TD width="70%">
   <SELECT size="1" name="iw_IWtime_timeZone">
   <% iw_webGet_TimezoneTable(); %>
         </SELECT>
    </TD>
 </TR>
 <TR>
     <TD width=30% class="column_title"><% iw_webSysDescHandler("DSTTitle", "", "Daylight Saving Time"); %></TD>
     <TD width=70%>
               <INPUT type="checkbox" id="dstEnable" name="dstEnable" style="vertical-align:middle" onclick="javascript:document.getElementById('DSTTABLE').style.display = this.checked? 'inline':'none'; document.getElementById('iw_IWtime_dstEnable').value = this.checked? 'ENABLE':'DISABLE'; ">
  <label for dstEnable style="vertical-align:middle"> <% iw_webCfgDescHandler("IWtime", "dstEnable", "Enable"); %></label>
     </TD>
 </TR>
 <TR>
  <TD width=30% class="column_title">&nbsp;</TD>
  <TD width=70%>
   <DIV id="DSTTABLE" name="DSTTABLE" style="display:none">
   <% iw_webGetDSTTable(); %>
   </DIV>
  </TD>
 </TR>

 <TR>
  <TD width=30% class="column_title"><% iw_webCfgDescHandler("IWtime", "firstTimeSrv", "Time server"); %> 1</TD>
  <TD width=70%>
   <INPUT type="text" name="iw_IWtime_firstTimeSrv" size="48" maxlength="39" value = "<% iw_webCfgValueHandler("IWtime", "firstTimeSrv", ""); %>">
  </TD>
 </TR>
 <TR>
  <TD width=30% class="column_title"><% iw_webCfgDescHandler("IWtime", "secondTimeSrv", "Time server"); %> 2</TD>
  <TD width=70%>
   <INPUT type="text" name="iw_IWtime_secondTimeSrv" size="48" maxlength="39" value = "<% iw_webCfgValueHandler("IWtime", "secondTimeSrv", ""); %>">
  </TD>
 </TR>
 <TR>
  <TD width=30% class="column_title"><% iw_webCfgDescHandler("IWtime", "queryPeriod", "Query period"); %></TD>
  <TD width=70%>
   <INPUT type="text" name="iw_IWtime_queryPeriod" size="6" maxlength="4" value = "<% iw_webCfgValueHandler("IWtime", "queryPeriod", ""); %>">&nbsp;(600 to 9999 seconds)
  </TD>
 </TR>
    <TR>
        <TD colspan="2"><HR>
            <Span align="right">
   <INPUT type="submit" value="Submit" name="Submit">
   <Input type="hidden" name="bkpath" value="/time_set.asp">
   <INPUT type="hidden" name="iw_IWtime_dstEnable" id="iw_IWtime_dstEnable" value="<% iw_webCfgValueHandler("IWtime", "dstEnable", "DISABLE"); %>">
            </Span>
        </TD>
    </TR>
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
