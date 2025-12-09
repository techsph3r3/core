<HTML>
<HEAD>
 <META http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
    <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate" />
    <meta http-equiv="Pragma" content="no-cache" />
    <meta http-equiv="Expires" content="0" />
 <LINK href="nport2g.css" rel="stylesheet" type="text/css">
 <TITLE><% iw_webSysDescHandler("PacketFiltersMacTree", "", "MAC filters"); %></TITLE>
 <% iw_webJSList_get(); %>
 <script type="text/javascript">
 <!--
  function CheckValue(form)
  {
   var i, j=0, enableCount;
   for(i = 0; i < (form.length); i++)
   {
    if(form.elements[i].value.length > 0 )
    {
     if (form.elements[i].name.match("Mac"))
     {
      if(form.elements[i].value.length > 0)
      {
       if(!isMACaddress(form.elements[i].value))
       {
        form.elements[i].focus();
        return false;
       }
      }
     }
    }
   }
var ena = new Array(<%iw_webGet_FilterRuleEnable("macf", "2"); %>);
   enableCount = 0;
   for(i = 0; i < form.length; i++)
   {
    if(form.elements[i].value.length > 0 )
    {
     if(form.elements[i].name.match("MM"))
     {
      if(form.elements[i].checked)
      {
       ena[j].value = "ENABLE";
       enableCount++;
       if(form.elements[i+2].value.length<17)
       {
        alert("Invalid MAC address.");
        form.elements[i+2].focus();
        return false;
       }
      }
      else
       ena[j].value = "DISABLE";
      j+=1;
     }
    }
   }

   if( document.getElementById("iw_fwL2_enable").selectedIndex == 0 &&
    document.getElementById("iw_fwL2_policy").selectedIndex == 0 &&
    enableCount == 0 )
   {
    alert( 'Warning : Network will be entirely blocked when using "Accept" policy without any active rule.' );
   }
  }
  function selall()
  {
   for(i = 0; i < document.macf.length; i++)
   {
    if(document.macf.elements[i].value.length > 0 )
    {
     if(document.macf.elements[i].name.match("MM"))
     {
      if(document.macf.SelAll.checked == true)
       document.macf.elements[i].checked = true;
      else
       document.macf.elements[i].checked = false;
     }
    }
   }
  }
        function iw_macfOnLoad(form)
     {
          iw_selectSet(document.macf.iw_fwL2_enable, "<% iw_webCfgValueHandler("fwL2", "enable", "DISABLE"); %>");
          iw_selectSet(document.macf.iw_fwL2_policy, "<% iw_webCfgValueHandler("fwL2", "policy", "ACCEPT"); %>");
      }


        function editPermission()
        {
                var form = document.macf, i, j = <% iw_websCheckPermission(); %>;
                if(j)
                {
                        for(i = 0; i < form.length; i++)
                                form.elements[i].disabled = true;
                }
        }


     var mem_state = <% iw_websMemoryChange(); %>;
     function iw_ChangeOnLoad()
     {

                editPermission();

  top.toplogo.location.reload();
     }

 //-->
 </SCRIPT>
</HEAD>
<BODY onLoad="iw_macfOnLoad();iw_ChangeOnLoad();">
 <H2><% iw_webSysDescHandler("PacketFiltersMacTree", "", "MAC filters"); %> <% iw_websGetErrorString(); %></H2>
 <FORM name="macf" method="POST" action="/forms/iw_webSetParameters" onSubmit="return CheckValue(this)">
   <TABLE width="100%">
   <TR align="left">
             <TD width="30%" class="column_title"><% iw_webCfgDescHandler("fwL2", "enable", "Functionality"); %>&nbsp;&nbsp;</TD>
             <TD width="70%">
             <SELECT size="1" id="iw_fwL2_enable" name="iw_fwL2_enable">
               <option value="ENABLE">Enable</option>
               <option value="DISABLE">Disable</option>
             </SELECT></TD></TR><p>
             <TR align="left">
             <TD width="30%" class="column_title"><% iw_webCfgDescHandler("fwL2", "policy", "Policy"); %>&nbsp;&nbsp;&nbsp;&nbsp;</TD>
             <TD width="70%">
             <SELECT size="1" id="iw_fwL2_policy" name="iw_fwL2_policy">
               <option value="ACCEPT">Accept</option>
               <option value="DROP">Drop</option>
             </SELECT></TD></TR><p>
   </TABLE>
  <TABLE width="100%">
   <TR align="left">
    <TD width="5%" align="center" class="block_title">No.</TD>
    <TD width="10%" align="center" class="block_title"><INPUT type="checkbox" id="SelAll" onclick="selall()";>Active</TD>
    <TD width="35%" class="block_title">Name</TD>
    <TD width="35%" class="block_title">MAC Address</TD>
   </TR>
   <% iw_webGetFilterMac(); %>
  </TABLE><hr>
   <INPUT type="submit" value="Submit" name="Submit">
  <% iw_webGetFilterMacCheckbox(); %>
  <Input type="hidden" name="bkpath" value="/FilterMac.asp">
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
