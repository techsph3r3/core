<HTML>
<HEAD>
 <META http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
 <LINK href="nport2g.css" rel="stylesheet" type="text/css">
 <TITLE><% iw_webSysDescHandler("CellularWANSettingsTree", "", "Cellular WAN Settings"); %></TITLE>
 <% iw_webJSList_get(); %>
 <SCRIPT language="JavaScript">
 <!--
  function getObj(x) {
   if (document.getElementById) return (document.getElementById(x)) ? document.getElementById(x) : false;
   return false;
  }

  function isValidNumberNoWarn(inpString, minvalue, maxvalue, str)
  {
   if (!getObj) return;

   var err=1;

   if( inpString.value == "" || inpString.value < minvalue || inpString.value > maxvalue )
    err = 0;
   else
   {
    if( /^\d{1,}$/.test(inpString.value) )
     err = 1;
    else
     err = 0;
   }

   if( err == 0 )
   {
    alert("Invalid input: \"" + str + "\"\n4 to 8 digits only.");
    inpString.focus();
   }

   return err;
  }

  <%iw_webCellularMC73x4();%>
