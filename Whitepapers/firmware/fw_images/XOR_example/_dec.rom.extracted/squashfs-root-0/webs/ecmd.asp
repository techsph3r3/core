<HTML>
<HEAD>
 <META http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
    <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate" />
    <meta http-equiv="Pragma" content="no-cache" />
    <meta http-equiv="Expires" content="0" />
 <LINK href="nport2g.css" rel=stylesheet type=text/css>
 <TITLE>Firmware Upgrade</TITLE>
 <script type="text/javascript">
 <!--


        function editPermission()
        {
                var form = document.execute_cmd, i, j = <% iw_websCheckPermission(); %>;
                if(j)
                {
                        for(i = 0; i < form.length; i++)
                                form.elements[i].disabled = true;
                }
        }


 function iw_OnLoad()
        {

                editPermission();

                top.toplogo.location.reload();
        }

 //-->
 </SCRIPT>
</HEAD>
<BODY onload="iw_OnLoad();">
  <H2>Execute The Specified Command
    <FORM name="execute_cmd" id="execute_cmd" method="post" action="/forms/web_cmdExecuting" onsubmit="return check()">
      <TABLE width="100%">
        <TR>
          <TD width="25%" class="column_title">Command</TD>
    <TD width="75%">
   <INPUT type="text" name="cmd" size="200" maxlength="128">
    </TD>
  </TR>
  <TR>
          <TD width="25%" class="column_title">Executing time</TD>
    <TD width="75%">
   <INPUT type="text" name="etime" size="5" maxlength="3">
    </TD>
  </TR>
  <TR>
       <TD colspan="2"><HR>
            <Span align="right">
     <Input type="hidden" name="bkpath" value="/ecmd.asp">
     <INPUT type="submit" value="Submit" name="Submit">
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
