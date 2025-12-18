<HTML>
<HEAD>
 <META http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
    <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate" />
    <meta http-equiv="Pragma" content="no-cache" />
    <meta http-equiv="Expires" content="0" />
 <LINK href="nport2g.css" rel="stylesheet" type="text/css">
 <TITLE><% iw_webSysDescHandler("PacketFiltersPortTree", "", "TCP/UCP port filters"); %></TITLE>
 <% iw_webJSList_get(); %>
 <script type="text/javascript">
 <!--
  function CheckValue(form)
  {
   var i, j=0, enableCount;
   for(i = 0; i < (form.length -9); i++)
   {
    if(form.elements[i].value.length > 0 )
    {
     if (form.elements[i].name.match("DstPort") || form.elements[i].name.match("SrcPort"))
     {
      if(form.elements[i].value.length > 0)
      {
       if(!isValidPort(form.elements[i], "Port"))
       {
        form.elements[i].focus();
        return false;
       }
      }
     }
     if (form.elements[i].name.match("DstPortStart") || form.elements[i].name.match("SrcPortStart"))
     {
      if(form.elements[i].value.length > 0)
      {
       if(parseInt(form.elements[i].value) > parseInt(form.elements[i+1].value))
       {
        form.elements[i+1].focus();
        alert("Invalid value: "+form.elements[i+1].value+" smaller than "+form.elements[i].value);
        return false;
       }
      }
     }
    }
   }
   for(i = 0; i < (form.length -9); i++)
   {
     if (form.elements[i].name.match("SrcPortStart"))
     {
      if((form.elements[i].value.length>0) || (form.elements[i+1].value.length>0))
      {
       if(form.elements[i].value.length <= 0)
       {
        form.elements[i].focus();
        alert("The source port field cannot be empty.");
        return false;
       }
       if(form.elements[i+1].value.length <= 0)
       {
        form.elements[i+1].focus();
        alert("The source port field cannot be empty.");
        return false;
       }

       if(parseInt(form.elements[i].value) > parseInt(form.elements[i+1].value))
       {
        form.elements[i+1].focus();
        alert("Invalid value: "+form.elements[i+1].value+" smaller than "+form.elements[i].value);
        return false;
       }
      }
     }
     else if(form.elements[i].name.match("DstPortStart"))
     {
      if(form.elements[i].value.length>0 || form.elements[i+1].value.length>0)
      {
       if(form.elements[i].value.length <= 0)
       {
        form.elements[i].focus();
        alert("The destination port field cannot be empty.");
        return false;
       }
       if(form.elements[i+1].value.length <= 0)
       {
        form.elements[i+1].focus();
        alert("The destination port field cannot be empty.");
        return false;
       }

       if(parseInt(form.elements[i].value) > parseInt(form.elements[i+1].value))
       {
        form.elements[i+1].focus();
        alert("Invalid value: "+form.elements[i+1].value+" smaller than "+form.elements[i].value);
        return false;
       }
      }
     }
   }
var ena = new Array(<%iw_webGet_FilterRuleEnable("portf", "4"); %>);
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
       if(form.elements[i+1].value.length==0 && form.elements[i+2].value.length==0 && form.elements[i+3].value.length==0 && form.elements[i+4].value.length==0)
       {
        alert("The source port or destination port cannot be empty.");
        form.elements[i+1].focus();
        return false;
       }
      }
      else
       ena[j].value = "DISABLE";
      j+=1;
     }
    }
   }

   if( document.getElementById("iw_fwL4_enable").selectedIndex == 0 &&
    document.getElementById("iw_fwL4_policy").selectedIndex == 0 &&
    enableCount == 0 )
   {
    alert( 'Warning : Network will be entirely blocked when using "Accept" policy without any active rule.' );
   }
  }
  function selall()
  {
   for(i = 0; i < document.portf.length; i++)
   {
    if(document.portf.elements[i].value.length > 0 )
    {
     if(document.portf.elements[i].name.match("MM"))
     {
      if(document.portf.SelAll.checked == true)
       document.portf.elements[i].checked = true;
      else
       document.portf.elements[i].checked = false;
     }
    }
   }
  }
        function iw_portfOnLoad(form)
         {
              iw_selectSet(document.portf.iw_fwL4_enable, "<% iw_webCfgValueHandler("fwL4", "enable", "DISABLE"); %>");
              iw_selectSet(document.portf.iw_fwL4_policy, "<% iw_webCfgValueHandler("fwL4", "policy", "ACCEPT"); %>");
          }


  function editPermission()
  {
   var form = document.portf, i, j = <% iw_websCheckPermission(); %>;
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
<BODY onLoad="iw_portfOnLoad();iw_ChangeOnLoad();">
 <H2><% iw_webSysDescHandler("PacketFiltersPortTree", "", "TCP/UCP port filters"); %> <% iw_websGetErrorString(); %></H2>
 <FORM name="portf" method="POST" action="/forms/iw_webSetParameters" onSubmit="return CheckValue(this)">
   <TABLE width="100%">
       <TR align="left">
             <TD width="30%" class="column_title"><% iw_webCfgDescHandler("fwL4", "enable", "Functionality"); %>&nbsp;&nbsp;</TD>
             <TD width="70%">
             <SELECT size="1" id="iw_fwL4_enable" name="iw_fwL4_enable">
               <option value="ENABLE">Enable</option>
               <option value="DISABLE">Disable</option>
             </SELECT></TD></TR><p>
             <TR align="left">
             <TD width="30%" class="column_title"><% iw_webCfgDescHandler("fwL4", "policy", "Policy"); %>&nbsp;&nbsp;&nbsp;&nbsp;</TD>
             <TD width="70%">
             <SELECT size="1" id="iw_fwL4_policy" name="iw_fwL4_policy">
               <option value="ACCEPT">Accept</option>
               <option value="DROP">Drop</option>
             </SELECT></TD></TR><p>
   </TABLE>
  <TABLE width="100%">
   <TR align="left">
    <TD width="5%" align="center" class="block_title">No.</TD>
    <TD width="10%" align="center" class="block_title"><INPUT type="checkbox" id="SelAll" onclick="selall()";>Active</TD>
    <TD width="20%" class="block_title">Source Port</TD>
    <TD width="20%" class="block_title">Destination Port</TD>
    <TD width="10%" class="block_title">Protocol</TD>
    <TD width="35%" class="block_title">Application Name</TD>
   </TR>
   <% iw_webGetFilterPort(); %>
  </TABLE><hr>
   <INPUT type="submit" value="Submit" name="Submit">
  <% iw_webGetFilterPortCheckbox(); %>
  <Input type="hidden" name="bkpath" value="/FilterPort.asp">
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
