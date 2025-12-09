<HTML>
<HEAD>
    <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate" />
    <meta http-equiv="Pragma" content="no-cache" />
    <meta http-equiv="Expires" content="0" />
 <LINK href="nport2g.css" rel="stylesheet" type="text/css">
 <% iw_webJSList_get(); %>
 <TITLE><% iw_webSysDescHandler("SystemLogTree", "", "System Log"); %></TITLE>
</HEAD>
 <script type="text/javascript">
 <!--
  function confirm_clearlog()
  {
   if (window.confirm("Are you sure you want to clear the system log?"))
   {
    document.systemlog.clean.value = "1";
    document.systemlog.Log.value = "";
    document.systemlog.submit();
   }
  }

  function scroll_to_latest(e)
  {
   e.scrollTop = e.scrollHeight;
  }

  function Backup()
  {
          document.location.href='systemlog.log' ;
  }


  function editPermission()
  {
   var form = document.systemlog, i, j = <% iw_websCheckPermission(); %>;
   if(j)
   {
    for(i = 0; i < form.length; i++)
    {
     if( form.elements[i].name == "Export" )
                     continue;
                 if( form.elements[i].name == "Refresh" )
                     continue;

     form.elements[i].disabled = true;
    }
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

 <H2><% iw_webSysDescHandler("SystemLogTree", "", "System Log"); %></H2>
<BODY onLoad = "scroll_to_latest(document.systemlog.Log);iw_ChangeOnLoad();">
 <FORM name="systemlog" method="POST" action="/forms/webSetSystemLogData">
  <Table width="100%">
   <TR>
    <TD>
     <TEXTAREA name="Log" rows="20" cols="100" READONLY><% iw_webGetSystemLogData(); %>
     </TEXTAREA>
    </TD>

   </TR>

  <TR>
         <TD><HR>
   <INPUT type="hidden" name="clean" value="0">
   <INPUT type="button" name="Export" value="Export Log" onClick="Backup()";>
   <INPUT type="button" name="ClearLog" value="Clear Log" onclick="confirm_clearlog();">
   <INPUT type="button" name="Refresh" value="Refresh" onClick="window.location.reload()">
   <Input type="hidden" name="bkpath" value="/system_log.asp">
   </TD>
     </TR>
     </Table>
 </FORM>
</BODY>
</HTML>
