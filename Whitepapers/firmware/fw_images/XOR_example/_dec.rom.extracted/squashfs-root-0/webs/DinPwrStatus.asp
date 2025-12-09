
<HTML>
<HEAD>
    <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate" />
    <meta http-equiv="Pragma" content="no-cache" />
    <meta http-equiv="Expires" content="0" />
 <LINK href="nport2g.css" rel="stylesheet" type="text/css">
 <% iw_webJSList_get(); %>
 <TITLE><% iw_webSysDescHandler("DinPowerStatusTree", "", "DI and Power Status"); %></TITLE>
</HEAD>
<BODY>
 <H2><% iw_webSysDescHandler("DinPowerStatusTree", "", "DI and Power Status"); %></H2>
 <script type="text/javascript">
  function do_referesh()
  {
   if(document.getElementById("ref5").checked)
   document.location.reload();
  }
  function check_referesh()
  {
   if(document.getElementById("ref5").checked)
    window.setTimeout("do_referesh()", 10000);
  }
  if(window.setTimeout)
  {
   document.write("<INPUT type='checkbox' id='ref5' checked onclick='check_referesh()'><label for='ref5'>Auto Update</label>");
   check_referesh();
  }
 </SCRIPT>
 <TABLE width="100%">
  <TR class="column_title_bg">
   <TD width="50%" align="center" class="block_title">Input Status</TD>
   <TD width="50%" align="center" class="block_title">On / Off</TD>
  </TR>

  <script type="text/javascript">
   var pwr = <% iw_webSysValueHandler("pwrstate", "", ""); %>, din = <% iw_webSysValueHandler("dinstate", "", ""); %>;
   var color;
   var support_poe = <% iw_webIsSupportPoe(); %>;
   var statusStr = new Array("Off", "On");
   var i, Title;

   var bgColorIndicator = 0;
   var bgColorArray = ["beige", "azure"];
   function addStatusRow( Title, State )
   {
    document.write("<tr style=\"background-color: " + bgColorArray[bgColorIndicator] + ";\">");
    document.write("<td class=\"column_title\" style=\"background-color: " + bgColorArray[bgColorIndicator] + ";\">" + Title + " status</td>");
    document.write("<td>" + State + "</td>");
    document.write("</tr>");
    bgColorIndicator = 1 - bgColorIndicator;
   }

   for( i = 0; i < pwr.length; i++ )
   {


    if( i < 2 )
     Title = "Power " + (i+1);
                else if( support_poe )
                    Title = "PoE";
    else
     break;
    addStatusRow( Title, statusStr[pwr[i]] );
   }


   for( i = 0; i < din.length; i++ )
   {
    Title = "DI " + (i+1);
    addStatusRow( Title, statusStr[din[i]] );
   }

  </SCRIPT>
 </TABLE>
</BODY>
</HTML>
