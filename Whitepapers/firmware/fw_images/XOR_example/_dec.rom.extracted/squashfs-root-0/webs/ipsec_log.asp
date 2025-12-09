<HTML>
<HEAD>
 <LINK href="nport2g.css" rel="stylesheet" type="text/css">
 <% iw_webJSList_get(); %>
 <TITLE><% iw_webSysDescHandler("IPSECStatusTree", "", "IPSEC Log"); %></TITLE>
</HEAD>
 <script type="text/javascript">
 <!--
  function confirm_clearlog()
  {
   if (window.confirm("Are you sure to clear IPSec log?"))
   {
    document.ipseclog.clean.value = "1";
    document.ipseclog.Log.value = "";
    document.ipseclog.submit();
   }
  }

  function scroll_to_latest(e)
  {
   e.scrollTop = e.scrollHeight;
  }

  function Backup()
  {
          document.location.href='ipsec.log' ;
  }

         var mem_state = <% iw_websMemoryChange(); %>;

  function editPermission()
  {
   var form = document.ipseclog, i, j = <% iw_websCheckPermission(); %>;
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


              function iw_ChangeOnLoad()
              {

                 editPermission();


                        top.toplogo.location.reload();
              }
    -->
    </Script>

 <H2><% iw_webSysDescHandler("IPSecStatusTree", "", "IPSec Log"); %></H2>
<BODY onLoad = "scroll_to_latest(document.ipseclog.Log);iw_ChangeOnLoad();">
 <FORM name="ipseclog" method="POST" action="/forms/webClearIPSecLog">
  <Table width="100%">
   <TR>
    <TD>
     <TEXTAREA name="Log" rows="20" cols="100" READONLY><% iw_webGetIPSecLog(); %>
     </TEXTAREA>
    </TD>

   </TR>

  <TR>
         <TD><HR>
   <INPUT type="hidden" name="clean" value="0">
   <INPUT type="button" name="Export" value="Export Log" onClick="Backup()";>
   <INPUT type="button" name="ClearLog" value="Clear Log" onclick="confirm_clearlog();">
   <INPUT type="button" name="Refresh" value="Refresh" onClick="window.location.reload()">
   <Input type="hidden" name="bkpath" value="/ipsec_log.asp">
   </TD>
     </TR>
     </Table>
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
