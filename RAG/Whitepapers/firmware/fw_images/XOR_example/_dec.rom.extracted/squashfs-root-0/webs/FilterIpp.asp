<HTML>
<HEAD>
 <META http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
    <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate" />
    <meta http-equiv="Pragma" content="no-cache" />
    <meta http-equiv="Expires" content="0" />
 <LINK href="nport2g.css" rel="stylesheet" type="text/css">
 <TITLE<% iw_webSysDescHandler("PacketFiltersIppTree", "", "IP protocol filters"); %></TITLE>
 <% iw_webJSList_get(); %>
 <script type="text/javascript">
 <!--

  function CheckValue(form)
  {
   var i, j=0, enableCount;
   for(i = 0; i < form.length; i++)
   {
    if (form.elements[i].value.length > 0)
    {
     if (form.elements[i].name.match("SrcIP") || form.elements[i].name.match("DstIP"))
     {
      if (!verifyIP(form.elements[i], "IP"))
      {
       form.elements[i].focus();
       return false;
      }
     }
     else if (form.elements[i].name.match("SrcMask") || form.elements[i].name.match("DstMask"))
     {
      if (!verifyNetmask(form.elements[i], "Netmask"))
      {
       form.elements[i].focus();
       return false;
      }
     }
    }
   }
var ena = new Array(<%iw_webGet_FilterRuleEnable("ipp", "3"); %>);
   enableCount = 0;
   for(i = 0; i < form.length; i++)
   {
    if (form.elements[i].value.length > 0 )
    {
     if (form.elements[i].name.match("MM"))
     {
      if (form.elements[i].checked)
      {
       ena[j].value = "ENABLE";
       enableCount++;
       if(form.elements[i+1].value.length==0)
       {
        alert("The protocol should not be empty.");
        form.elements[i+1].focus();
        return false;
       }
       else if(form.elements[i+2].value.length==0 && form.elements[i+3].value.length==0 && form.elements[i+4].value.length==0 && form.elements[i+5].value.length==0)
       {
        alert("IP or netmask cannot be empty.");
        form.elements[i+2].focus();
        return false;
       }

       if(form.elements[i+2].value.length>0 || form.elements[i+3].value.length>0)
       {
        if(form.elements[i+2].value.length<7)
        {
         alert("IP cannot be empty.");
         form.elements[i+2].focus();
         return false;
        }
        if(form.elements[i+3].value.length<7)
        {
         alert("Netmask cannot be empty.");
         form.elements[i+3].focus();
         return false;
        }
       }

       if(form.elements[i+4].value.length>0 || form.elements[i+5].value.length>0)
       {
        if(form.elements[i+4].value.length<7)
        {
         alert("IP cannot be empty.");
         form.elements[i+4].focus();
         return false;
        }
        if(form.elements[i+5].value.length<7)
        {
         alert("Netmask cannot be empty.");
         form.elements[i+5].focus();
         return false;
        }
       }
      }else{
       ena[j].value = "DISABLE";
      }
      j ++;
     }
    }
   }

   if( document.getElementById("iw_fwL3_enable").selectedIndex == 0 &&
    document.getElementById("iw_fwL3_policy").selectedIndex == 0 &&
    enableCount == 0 )
   {
    alert( 'Warning : Network will be entirely blocked when using "Accept" policy without any active rule.' );
   }
  }
  function selall()
  {
   for(i = 0; i < document.ipp.length; i++)
   {
    if(document.ipp.elements[i].value.length > 0 )
    {
     if(document.ipp.elements[i].name.match("MM"))
     {
      if(document.ipp.SelAll.checked == true)
       document.ipp.elements[i].checked = true;
      else
       document.ipp.elements[i].checked = false;
     }
    }
   }
  }

        function iw_ippOnLoad()
  {
   var idx;
   var proto_val = new Array();
   <% iw_webGetFilterIppProto(); %>

   $('#iw_fwL3_enable').val("<% iw_webCfgValueHandler("fwL3", "enable", "DISABLE"); %>");
   $('#iw_fwL3_policy').val("<% iw_webCfgValueHandler("fwL3", "policy", "ACCEPT"); %>");

   for( idx = 0; idx < 32 ; idx++)
   {
    $('#iw_fwL3_rule' + (idx+1) + 'Proto').val(proto_val[idx]);
   }
  }


  function editPermission()
  {
   var form = document.ipp, i, j = <% iw_websCheckPermission(); %>;
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
<BODY onLoad="iw_ippOnLoad();iw_ChangeOnLoad();">
 <H2><% iw_webSysDescHandler("PacketFiltersIppTree", "", "IP protocol filters"); %> <% iw_websGetErrorString(); %></H2>
 <FORM name="ipp" method="POST" action="/forms/iw_webSetParameters" onSubmit="return CheckValue(this)">
   <TABLE width="100%">
       <TR align="left">
             <TD width="30%" class="column_title"><% iw_webCfgDescHandler("fwL3", "enable", "Functionality"); %>&nbsp;&nbsp;</TD>
             <TD width="70%">
             <SELECT size="1" id="iw_fwL3_enable" name="iw_fwL3_enable">
               <option value="ENABLE">Enable</option>
               <option value="DISABLE">Disable</option>
             </SELECT></TD></TR><p>
             <TR align="left">
             <TD width="30%" class="column_title"><% iw_webCfgDescHandler("fwL3", "policy", "Policy"); %>&nbsp;&nbsp;&nbsp;&nbsp;</TD>
             <TD width="70%">
             <SELECT size="1" id="iw_fwL3_policy" name="iw_fwL3_policy">
               <option value="ACCEPT">Accept</option>
               <option value="DROP">Drop</option>
             </SELECT></TD></TR><p>
  </TABLE>
  <TABLE width="100%">
   <TR align="left">
    <TD width="5%" align="center" class="block_title">No.</TD>
    <TD width="10%" align="center" class="block_title"><INPUT type="checkbox" id="SelAll" onclick="selall()";>Active</TD>
    <TD width="10%" class="block_title"><% iw_webCfgDescHandler("fwL3", "rule1Proto","Protocol"); %></TD>
    <TD width="18%" class="block_title"><% iw_webCfgDescHandler("fwL3", "rule1SrcIP","Source IP"); %></TD>
    <TD width="18%" class="block_title"><% iw_webCfgDescHandler("fwL3", "rule1SrcMask","Source Netmask"); %></TD>
    <TD width="18%" class="block_title"><% iw_webCfgDescHandler("fwL3", "rule1DstIP","Destination IP"); %></TD>
    <TD width="18%" class="block_title"><% iw_webCfgDescHandler("fwL3", "rule1DstMask","Destination Netmask"); %></TD>
   </TR>
   <% iw_webGetFilterIpp(); %>
  </TABLE><hr>
   <INPUT type="submit" value="Submit" name="Submit">
  <% iw_webGetFilterIppCheckbox(); %>
  <Input type="hidden" name="bkpath" value="/FilterIpp.asp">
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
