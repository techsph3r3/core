<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%
 var wifiSection, vapSection, certSection;

 if ( iw_isset(index) == 0 )
 {
  index = 1;
 }

 if ( iw_isset(vapIndex) == 0 )
 {
  vapIndex = 0;
 }

 if (index==2)
 {
  wifiSection = "wlanDevWIFI1";
  vapSection = "wlanVap2";
  certSection = "certWlan1";




 }else
 {
  wifiSection = "wlanDevWIFI0";
  vapSection = "wlanVap1";
  certSection = "certWlan";




  index = 1;
 }

 if ( vapIndex != 0 )
 {
  vapSection = vapSection + "0" + vapIndex ;
 }
%>
<html>
<head>
 <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
    <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate" />
    <meta http-equiv="Pragma" content="no-cache" />
    <meta http-equiv="Expires" content="0" />
 <link href="nport2g.css" rel=stylesheet type=text/css>
 <title>



  <% iw_webSysDescHandler("SecuritySettingsTree", "", "Security Settings"); %></title>
 <% iw_webJSList_get(); %>
 <script type="text/javascript">
 <!--
   var mem_state = <% iw_websMemoryChange(); %>;
  var rfType = new String("<% iw_webCfgValueHandler( wifiSection, "rfType", "G-MODE" ); %>");
   var VAPopMode = new String("<% if ( vapIndex == 0 ) { iw_webCfgValueHandler( wifiSection,	"operationMode", "AP" ); } else { write("AP"); }%>");



  var isAP = VAPopMode == "AP" || VAPopMode == "MASTER" ? 1 : 0;

  function iw_onSubmit()
  {
   var form = document.wireless_security;

   var authType = form.iw_authType.selectedIndex;
         var wpaType = form.iw_wpaType.selectedIndex;
         if( authType>1 && wpaType==0){
          if(form.iw_psk.value.length<8){
           alert("Invalid Passphrase. Please enter 8~63 ASCII characters or 64 HEX numbers.");
           return false;
          }else if (form.iw_psk.value.length >= 64){
           if(!isHEXDelimiter(form.iw_psk.value)){
            alert("Invalid Passphrase. Please enter 8~63 ASCII characters or 64 HEX numbers.");
            return false;
           }
          }else{
          if(!isAsciiString(form.iw_psk.value)){
            alert("Invalid Passphrase. Please enter 8~63 ASCII characters or 64 HEX numbers.");
            return false;
           }
          }
         }
         if( isAP && authType > 1 )
   {
    if( !isValidNumber(form.iw_rekey, 60, 86400, "<% iw_webCfgDescHandler("wlanVap1", "rekey", "Key renewal"); %>") )
    {
     return false;
    }

    if( 1 == wpaType ){
     if( (form.iw_ipv4FirstAuthSrv.value.length ==0) && (form.iw_ipv4SecondaryAuthSrv.value.length ==0) ){
      alert("Primary or secondary RADIUS server IP cannot be empty.");
      form.iw_ipv4FirstAuthSrv.focus();
      return false;
     }

     if( !verifyIP(form.iw_ipv4FirstAuthSrv, "<% iw_webCfgDescHandler("wlanVap1", "ipv4FirstAuthSrv", ""); %>")){
      return false;
     }
     if( !verifyIP(form.iw_ipv4SecondaryAuthSrv, "<% iw_webCfgDescHandler("wlanVap1", "ipv4SecondaryAuthSrv", ""); %>")){
      return false;
     }
     if( (form.iw_ipv4FirstAuthSrv.value.length !=0) && (form.iw_firstAuthSecreat.value.length ==0) ){
      alert("Primary RADIUS shared key cannot be empty.");
      return false;
     }
     if( (form.iw_ipv4SecondaryAuthSrv.value.length !=0) && (form.iw_secondAuthSecreat.value.length ==0) ){
      alert("Secondary RADIUS shared key cannot be empty.");
      return false;
     }

     if( !isValidPort(form.iw_firstAuthPort, "<% iw_webCfgDescHandler("wlanVap1", "firstAuthPort", ""); %>") )
     {
      return false;
     }
     if( !isValidPort(form.iw_secondAuthPort, "<% iw_webCfgDescHandler("wlanVap1", "secondAuthPort", ""); %>") )
     {
      return false;
     }
    }
   }

         if( authType == 1 ){

    if(rfType == "N-MODE-24G" || rfType == "N-MODE-5G"){
     alert("WEP is not supported when RF type is pure N!!");
     return false;
    }

                if( (form.iw_wepKeyIndex.selectedIndex == 0 ) && (form.iw_wepKey1.value.length <= 0 ))
             {
              alert("WEP key 1 cannot be empty.");
              form.iw_wepKey1.focus();
              return false;
             }
                if( (form.iw_wepKeyIndex.selectedIndex == 1 ) && (form.iw_wepKey2.value.length <= 0 ))
             {
              alert("WEP key 2 cannot be empty.");
              form.iw_wepKey2.focus();
              return false;
             }
                if( (form.iw_wepKeyIndex.selectedIndex == 2 ) && (form.iw_wepKey3.value.length <= 0 ))
             {
              alert("WEP key 3 cannot be empty.");
              form.iw_wepKey3.focus();
              return false;
             }
                if( (form.iw_wepKeyIndex.selectedIndex == 3 ) && (form.iw_wepKey4.value.length <= 0 ))
             {
              alert("WEP key 4 cannot be empty.");
              form.iw_wepKey4.focus();
              return false;
             }

                if( (form.iw_wepKey1.value.length > 0 ) && (form.iw_wepKey1.value.length < form.iw_wepKey1.maxLength ))
             {
              alert("WEP key 1 is too short.");
              form.iw_wepKey1.focus();
              return false;
             }
                if( (form.iw_wepKey2.value.length > 0 ) && (form.iw_wepKey2.value.length < form.iw_wepKey2.maxLength ))
             {
              alert("WEP key 2 is too short.");
              form.iw_wepKey2.focus();
              return false;
             }
                if( (form.iw_wepKey3.value.length > 0 ) && (form.iw_wepKey3.value.length < form.iw_wepKey3.maxLength ))
             {
              alert("WEP key 3 is too short.");
              form.iw_wepKey3.focus();
              return false;
             }
                if( (form.iw_wepKey4.value.length > 0 ) && (form.iw_wepKey4.value.length < form.iw_wepKey4.maxLength ))
             {
              alert("WEP key 4 is too short.");
              form.iw_wepKey4.focus();
              return false;
             }

                if( (form.iw_wepType.selectedIndex == 0 ) )
                {
                 var keyElement;
     for(i = 1; i <= 4; i++)
     {
      keyElement = document.getElementById('iw_wepKey'+(i));
      if (keyElement.value.length > 0)
      {
       if(!isHEXDelimiter(keyElement.value))
       {
        alert("Invalid HEX number.");
        keyElement.focus();
        return false;
       }
      }
     }
    }
         }

  }

  function ChangeKeyLength()
        {
         var i, j, keyLength, wepKeyTmp;
         var wepType = document.wireless_security.iw_wepType.selectedIndex;
         var wepLen = document.wireless_security.iw_wepLen.selectedIndex;
         var keyElement;

            if( 0 == wepLen ){
                    keyLength = 10;
            } else {
                    keyLength = 26;
            }
            if( 1 == wepType ){
                    keyLength = keyLength / 2;
            }

            for( i = 0; i < 4; i++){
             keyElement = document.getElementById('iw_wepKey'+(i+1));
             keyElement.maxLength = keyLength;
                wepKeyTmp = '';
                for( j = 0; j < keyLength; j++ ){
                        wepKeyTmp += keyElement.value.charAt(j);
                }
                keyElement.value = wepKeyTmp;
            }
         return true;
        }
  function editPermission()
  {
   var form = document.wireless_security, i, j = <% iw_websCheckPermission(); %>;
   if(j)
   {
    for(i = 0; i < form.length; i++)
     form.elements[i].disabled = true;
   }
  }


  function iw_onLoad()
  {
   var formItem, ctrlItem, newItem, i;

                        var AutoConnEnable = <% iw_web_AutoConn_enable(); %>
   var i;


   // For wireless_basic form
   formItem = document.wireless_security;




   if( VAPopMode == "SNIFFER" )
   {
    for( i = 0; i < formItem.elements.length; i++ )
    {
     formItem.elements[i].disabled = true;
    }
   }


   iw_selectSet(formItem.iw_authType, "<% iw_webCfgValueHandler(vapSection, "authType"    , "OPEN");       %>");
   iw_selectSet(formItem.iw_wepAuth, "<% iw_webCfgValueHandler(vapSection, "wepAuth"     , "OPEN");       %>");
   iw_selectSet(formItem.iw_wepKeyIndex, "<% iw_webCfgValueHandler(vapSection, "wepKeyIndex" , "1");          %>");



   iw_selectSet(formItem.iw_wpaType, "<% iw_webCfgValueHandler(vapSection, "wpaType"     , "PSK");        %>");
   iw_selectSet(formItem.iw_eapProto, "<% iw_webCfgValueHandler(vapSection, "eapProto"    , "TLS");        %>");
   iw_selectSet(formItem.iw_ttlsInner, "<% iw_webCfgValueHandler(vapSection, "ttlsInner"   , "PAP");        %>");
   iw_selectSet(formItem.iw_peapInner, "<% iw_webCfgValueHandler(vapSection, "peapInner"   , "MS-CHAPV2");  %>");
   iw_selectSet(formItem.iw_eapolVersion, "<% iw_webCfgValueHandler(vapSection, "eapolVersion", ""); %>" );

   iw_selectSet(formItem.iw_wepType, "<% iw_webCfgValueHandler(vapSection, "wepType"     , "HEX");        %>");
   iw_selectSet(formItem.iw_wepLen, "<% iw_webCfgValueHandler(vapSection, "wepLen"      , "64");         %>");
   if (rfType == "N-MODE-24G" || rfType == "N-MODE-5G") {
    $('#iw_authType_WEP').attr('disabled', true);
   }else{
    $('#iw_authType_WEP').attr('disabled', '');
   }

   iw_onChange();
   iw_onAuthTypeChange();





   iw_selectSet(formItem.iw_wpaEncrypt, "<% iw_webCfgValueHandler(vapSection, "wpaEncrypt"  , "TKIP");       %>");


   for(i = 0; i < formItem.length; i++)
   {
    if((AutoConnEnable != "DISABLE") && (<% write(vapIndex); %> == 0))
     formItem.elements[i].disabled = true;
    else
     formItem.elements[i].disabled = false;
   }
   formItem.iw_rekey.disabled = false;



                 editPermission();


   // CAUSION : This line must be executed in <body onLoad()>
   top.toplogo.location.reload();
  }

  // WPA/WPA2 change
  function iw_onChange_wpa()
  {
   var authType = document.getElementById("iw_authType");
   var currenttype = "<% iw_webCfgValueHandler(wifiSection, "rfType", "failed");  %>";
   var supportTKIP = 0;
   var ctrlItem = document.getElementById("iw_wpaEncrypt");
   var ctrlItemTempValue = ctrlItem.value;

   // Removes all option from Encryption type
   var idx;
   for( idx = ctrlItem.options.length; idx >= 0 ; idx-- )
   {
    ctrlItem.remove(idx);
   }
   // Check whether support pure TIKP
   if( currenttype == "A-MODE" || currenttype == "B-MODE" || currenttype == "G-MODE" || currenttype == "BGMixed" )
    supportTKIP = 1;

   if( supportTKIP )
   {
    ctrlItem.options.add(new Option("TKIP", "TKIP"));




   }
   ctrlItem.options.add(new Option("AES", "AES"));






   if ( currenttype != "N-MODE-24G" && currenttype != "N-MODE-5G" )
    ctrlItem.options.add(new Option("Mixed", "Mixed"));


   iw_selectSet(ctrlItem, ctrlItemTempValue);
  }

  var visibilityCtrl = new Array();

  function iw_onAuthTypeChange()
  {
   var formItem, ctrlItem, newItem, i;
   var wpa_type_val = $("#" + "iw_wpaType" + " option:selected").val();
   formItem = document.wireless_security;
   var authType = formItem.iw_authType.selectedIndex;
            var wpaType = formItem.iw_wpaType.selectedIndex;
            var eapProto = formItem.iw_eapProto.selectedIndex;

   if( 0 == authType ) // OPEN
   {
             document.getElementById("area_wep").style.display = "none";
             document.getElementById("area_wpa").style.display = "none";
             document.getElementById("area_wpa_psk").style.display = "none";
             document.getElementById("area_key_renew").style.display = "none";
             document.getElementById("area_wpa_EntAp").style.display = "none";
             document.getElementById("area_wpa_EntAc").style.display = "none";
             document.getElementById("area_wpa_EntAcTls").style.display = "none";
             document.getElementById("area_wpa_EntAcTtls").style.display = "none";
             document.getElementById("area_wpa_EntAcPeap").style.display = "none";
             document.getElementById("area_wpa_EntAcTtlsPeap").style.display = "none";
   }else if( 1 == authType ) //WEP
   {
    if(rfType == "N-MODE-24G" || rfType == "N-MODE-5G"){
     alert("WEP is not supported when RF type is pure N!!");
     return false;
    }
                document.getElementById("area_wep").style.display = "";
             document.getElementById("area_wpa").style.display = "none";

             document.getElementById("area_wpa_psk").style.display = "none";
             document.getElementById("area_key_renew").style.display = "none";
             document.getElementById("area_wpa_EntAp").style.display = "none";
             document.getElementById("area_wpa_EntAc").style.display = "none";
             document.getElementById("area_wpa_EntAcTls").style.display = "none";
             document.getElementById("area_wpa_EntAcTtls").style.display = "none";
             document.getElementById("area_wpa_EntAcPeap").style.display = "none";
             document.getElementById("area_wpa_EntAcTtlsPeap").style.display = "none";

              ChangeKeyLength();
            } else if( authType > 1 ) // WPA and WPA2
            {
    document.getElementById("area_wep").style.display = "none";
                document.getElementById("area_wpa").style.display = "";




    iw_onChange_wpa();

                if( isAP )
                {
                 document.getElementById("area_key_renew").style.display = "";

      if(wpa_type_val == "PSK"




                    )
                    {
      document.getElementById("area_wpa_psk").style.display = "";
      document.getElementById("area_wpa_EntAp").style.display = "none";
                    }else
                    {
      document.getElementById("area_wpa_psk").style.display = "none";
      document.getElementById("area_wpa_EntAp").style.display = "";
                    }

                    document.getElementById("area_wpa_EntAc").style.display = "none";
     document.getElementById("area_wpa_EntAcTls").style.display = "none";
     document.getElementById("area_wpa_EntAcTtls").style.display = "none";
              document.getElementById("area_wpa_EntAcPeap").style.display = "none";
              document.getElementById("area_wpa_EntAcTtlsPeap").style.display = "none";
                }else
                {
                 document.getElementById("area_key_renew").style.display = "none";

     if(wpa_type_val == "PSK"




     )
     {
      document.getElementById("area_wpa_psk").style.display = "";
      document.getElementById("area_wpa_EntAp").style.display = "none";

      document.getElementById("area_wpa_EntAc").style.display = "none";
      document.getElementById("area_wpa_EntAcTls").style.display = "none";
      document.getElementById("area_wpa_EntAcTtls").style.display = "none";
               document.getElementById("area_wpa_EntAcPeap").style.display = "none";
               document.getElementById("area_wpa_EntAcTtlsPeap").style.display = "none";
     } else
     {
      document.getElementById("area_wpa_psk").style.display = "none";
      document.getElementById("area_wpa_EntAp").style.display = "none";

      document.getElementById("area_wpa_EntAc").style.display = "";

      if( 0 == eapProto )
      {
          document.getElementById("area_wpa_EntAcTls").style.display = "";
          document.getElementById("area_wpa_EntAcTtlsPeap").style.display = "none";

          document.getElementById("area_wpa_EntAcTtls").style.display = "none";
        document.getElementById("area_wpa_EntAcPeap").style.display = "none";
      } else
      {
       document.getElementById("area_wpa_EntAcTtlsPeap").style.display = "";
       document.getElementById("area_wpa_EntAcTls").style.display = "none";

          if( 1 == eapProto )
          {
        document.getElementById("area_wpa_EntAcTtls").style.display = "";
        document.getElementById("area_wpa_EntAcPeap").style.display = "none";
          } else
          {
           document.getElementById("area_wpa_EntAcTtls").style.display = "none";
        document.getElementById("area_wpa_EntAcPeap").style.display = "";
          }
      }
     }
                }
            }
  }
  //: Use PRIMARY SSID's eapol vertion settings to determine all MULTI SSID's eapol version
  function iw_onEapolVersionChange()
  {
   var eapVersion = document.getElementById("iw_eapolVersion");
   var secondaryEapVersion=document.getElementById("iw_secondarySection_eapolVersion");
   var thirdEapVersion=document.getElementById("iw_thirdSection_eapolVersion");

   secondaryEapVersion.selectedIndex = eapVersion.selectedIndex;
   thirdEapVersion.selectedIndex = eapVersion.selectedIndex;
  }
  function iw_onChange()
  {
   var formItem, ctrlItem, newItem, i, selIndex;
  }

        -->
    </script>
</head>
<body onLoad="iw_onLoad();">

 <h2>




  <% iw_webSysDescHandler("SecuritySettingsTree", "", "Security Settings"); %>&nbsp;&nbsp;<% iw_websGetErrorString(); %></h2>

 <form name="wireless_security" method="post" action="/forms/iw_webSetParameters" onSubmit="return iw_onSubmit();">

 <table width="100%">
 <tr><td colspan="2" class="block_seperator"></td></tr>

 <tr>
  <td width=30% class="column_title">
   <% iw_webCfgDescHandler( vapSection, "ssid", "SSID" ); %>
  </td>
  <td width=70%>
   <% iw_webCfgValueHandler( vapSection, "ssid", "MOXA" ); %>
  </td>
 </tr>

 <tr>
  <td width=30% class="column_title">
   <% iw_webCfgDescHandler( vapSection, "authType", "Security mode" ); %>
  </td>
  <td width=70%>
   <select size="1" id="iw_authType" name="iw_<% write(vapSection); %>_authType" onChange="iw_onAuthTypeChange();">
    <option value="OPEN">Open</option>
    <option id="iw_authType_WEP" value="WEP" >WEP </option>
    <option value="WPA" >WPA </option>
    <option value="WPA2">WPA2</option>

    <option id="iw_authType_WPA_WPA2_MIX" value="WPA_WPA2_MIX">WPA-WPA2 mixed</option>

   </select>
  </td>
 </tr>
 </table>

 <div id="area_wep" style="display:none;">
 <table width="100%">
 <tr>
  <td width=30% class="column_title">
   <% iw_webCfgDescHandler( vapSection, "wepAuth", "Authentication type" ); %>
  </td>
  <td width=70%>
   <select size="1" id="iw_wepAuth" name="iw_<% write(vapSection); %>_wepAuth">
    <option value="OPEN">Open</option>
    <option value="SHARE">Shared</option>
   </select>
  </td>
 </tr>
 <tr>
  <td width=30% class="column_title">
   <% iw_webCfgDescHandler( vapSection, "wepType", "Key type" ); %>
  </td>
  <td width=70%>
   <select size="1" id="iw_wepType" name="iw_<% write(vapSection); %>_wepType" onChange="ChangeKeyLength()">
    <option value="HEX">HEX</option>
    <option value="ASCII">ASCII</option>
   </select>
  </td>
 </tr>
 <tr>
  <td width="30%" class="column_title"><% iw_webCfgDescHandler("wlanVap1", "wepLen", "Key len"); %></td>
  <td width="70%">
   <select size="1" id="iw_wepLen" name="iw_<% write(vapSection); %>_wepLen" onChange="ChangeKeyLength()">
    <option value="64">64 Bits</option>
    <option value="128">128 Bits</option>
   </select>
  </td>
 </tr>
 <tr>
  <td width=30% class="column_title">
   <% iw_webCfgDescHandler( vapSection, "wepKeyIndex", "Key index" ); %>
  </td>
  <td width=70%>
   <select size="1" id="iw_wepKeyIndex" name="iw_<% write(vapSection); %>_wepKeyIndex">
    <option value="1">1</option>
    <option value="2">2</option>
    <option value="3">3</option>
    <option value="4">4</option>
   </select>
  </td>
 </tr>
 <tr>
  <td width=30% class="column_title">
   <% iw_webCfgDescHandler( vapSection, "wepKey1", "WEP key 1" ); %>
  </td>
  <td width=70%>
   <input type="password" id="iw_wepKey1" name="iw_<% write(vapSection); %>_wepKey1" size="35" maxlength="26" value = "<% iw_webCfgValueHandler(vapSection, "wepKey1", ""); %>">
  </td>
 </tr>
 <tr>
  <td width=30% class="column_title">
   <% iw_webCfgDescHandler( vapSection, "wepKey2", "WEP key 2" ); %>
  </td>
  <td width=70%>
   <input type="password" id="iw_wepKey2" name="iw_<% write(vapSection); %>_wepKey2" size="35" maxlength="26" value = "<% iw_webCfgValueHandler(vapSection, "wepKey2", ""); %>">
  </td>
 </tr>
 <tr>
  <td width=30% class="column_title">
   <% iw_webCfgDescHandler( vapSection, "wepKey3", "WEP key 3" ); %>
  </td>
  <td width=70%>
   <input type="password" id="iw_wepKey3" name="iw_<% write(vapSection); %>_wepKey3" size="35" maxlength="26" value = "<% iw_webCfgValueHandler(vapSection, "wepKey3", ""); %>">
  </td>
 </tr>
 <tr>
  <td width=30% class="column_title">
   <% iw_webCfgDescHandler( vapSection, "wepKey4", "WEP key 4" ); %>
  </td>
  <td width=70%>
   <input type="password" id="iw_wepKey4" name="iw_<% write(vapSection); %>_wepKey4" size="35" maxlength="26" value = "<% iw_webCfgValueHandler(vapSection, "wepKey4", ""); %>">
  </td>
 </tr>
 </table>
 </div>

 <div id="area_wpa" style="display:none;">
 <table width="100%">
 <tr>
  <td width=30% class="column_title">
   <% iw_webCfgDescHandler( vapSection, "wpaType", "WPA type" ); %>
  </td>
  <td width=70%>
   <select size="1" id="iw_wpaType" name="iw_<% write(vapSection); %>_wpaType" onChange="iw_onAuthTypeChange();">
    <option value="PSK">Personal</option>
    <option value="ENTERPRISE">Enterprise</option>
   </select>
  </td>
 </tr>
 <tr>
  <td width=30% class="column_title">
   <% iw_webCfgDescHandler( vapSection, "wpaEncrypt", "WPA type" ); %>
  </td>
  <td width=70%>
   <select size="1" id="iw_wpaEncrypt" name="iw_<% write(vapSection); %>_wpaEncrypt">
   </select>
  </td>
 </tr>
 <tr>
  <td width=30% class="column_title">
   <% iw_webCfgDescHandler( vapSection, "eapolVersion", "EAPOL version" ); %>
  </td>
  <td width=70%>
   <select size="1" id="iw_eapolVersion" name="iw_<% write(vapSection); %>_eapolVersion" onChange="iw_onEapolVersionChange();">
    <option value="1">1</option>
    <option value="2">2</option>
   </select>
  </td>
 </tr>
 </table>

 <table width="100%" id="area_wpa_psk" style="display:none;">
 <tr>
  <td width=30% class="column_title">
   <% iw_webCfgDescHandler( vapSection, "psk", "Passphrase" ); %>
  </td>
  <td width=70%>
   <input type="password" id="iw_psk" name="iw_<% write(vapSection); %>_psk" size="70" maxlength="64" value="<% iw_webCfgValueHandler(vapSection, "psk", ""); %>">
  </td>
 </tr>
 </table>

 <table width="100%" id="area_wpa_EntAp" style="display:none;">
 <tr>
  <td width=30% class="column_title">
   <% iw_webCfgDescHandler( vapSection, "ipv4FirstAuthSrv", "Primary RADIUS server IP" ); %>
  </td>
  <td width=70%>
   <input type="text" id="iw_ipv4FirstAuthSrv" name="iw_<% write(vapSection); %>_ipv4FirstAuthSrv" size="21" maxlength="15" value = "<% iw_webCfgValueHandler(vapSection, "ipv4FirstAuthSrv", ""); %>">
  </td>
 </tr>
 <tr>
  <td width=30% class="column_title">
   <% iw_webCfgDescHandler( vapSection, "firstAuthPort", "Primary RADIUS port" ); %>
  </td>
  <td width=70%>
   <input type="text" id="iw_firstAuthPort" name="iw_<% write(vapSection); %>_firstAuthPort" size="21" maxlength="15" value = "<% iw_webCfgValueHandler(vapSection, "firstAuthPort", ""); %>">
  </td>
 </tr>
 <tr>
  <td width=30% class="column_title">
   <% iw_webCfgDescHandler( vapSection, "firstAuthSecreat", "Primary Shared key" ); %>
  </td>
  <td width=70%>
   <input type="password" id="iw_firstAuthSecreat" name="iw_<% write(vapSection); %>_firstAuthSecreat" size="37" maxlength="128" value = "<% iw_webCfgValueHandler(vapSection, "firstAuthSecreat", ""); %>">
  </td>
 </tr>
 <tr>
  <td width=30% class="column_title">
   <% iw_webCfgDescHandler( vapSection, "ipv4SecondaryAuthSrv", "Secondary RADIUS server IP" ); %>
  </td>
  <td width=70%>
   <input type="text" id="iw_ipv4SecondaryAuthSrv" name="iw_<% write(vapSection); %>_ipv4SecondaryAuthSrv" size="21" maxlength="15" value = "<% iw_webCfgValueHandler(vapSection, "ipv4SecondaryAuthSrv", ""); %>">
  </td>
 </tr>
 <tr>
  <td width=30% class="column_title">
   <% iw_webCfgDescHandler( vapSection, "secondAuthPort", "Secondary RADIUS port" ); %>
  </td>
  <td width=70%>
   <input type="text" id="iw_secondAuthPort" name="iw_<% write(vapSection); %>_secondAuthPort" size="21" maxlength="15" value = "<% iw_webCfgValueHandler(vapSection, "secondAuthPort", ""); %>">
  </td>
 </tr>
 <tr>
  <td width=30% class="column_title">
   <% iw_webCfgDescHandler( vapSection, "secondAuthSecreat", "Secondary Shared key" ); %>
  </td>
  <td width=70%>
   <input type="password" id="iw_secondAuthSecreat" name="iw_<% write(vapSection); %>_secondAuthSecreat" size="37" maxlength="128" value = "<% iw_webCfgValueHandler(vapSection, "secondAuthSecreat", ""); %>">
  </td>
 </tr>
 </table>

 <table width="100%" id="area_key_renew" style="display:none;">
 <tr>
  <td width=30% class="column_title">
   <% iw_webCfgDescHandler( vapSection, "rekey", "Key renewal" ); %>
  </td>
  <td width=70%>
   <input type="text" id="iw_rekey" name="iw_<% write(vapSection); %>_rekey" size="7" maxlength="5" value = "<% iw_webCfgValueHandler(vapSection, "rekey", ""); %>">&nbsp;&nbsp;(60~86400 seconds)
  </td>
 </tr>
 </table>

 <table width="100%" id="area_wpa_EntAc" style="display:none;">
 <tr>
  <td width=30% class="column_title">
   <% iw_webCfgDescHandler( vapSection, "eapProto", "EAP protocol" ); %>
  </td>
  <td width=70%>
   <select size="1" id="iw_eapProto" name="iw_<% write(vapSection); %>_eapProto" onChange="iw_onAuthTypeChange();">
    <option value="TLS">TLS</option>
    <option value="TTLS">TTLS</option>
    <option value="PEAP">PEAP</option>
   </select>
  </td>
 </tr>
 </table>

 <table width="100%" id="area_wpa_EntAcTls" style="display:none;">
 <tr>
  <td width=30% class="column_title">
   <% iw_webCfgDescHandler( certSection, "issueTo", "Certificate issued to" ); %>
  </td>
  <td width=70%>
   <% iw_webCfgValueHandler( certSection, "issueTo", "N/A" ); %>
  </td>
 </tr>
 <tr>
  <td width=30% class="column_title">
   <% iw_webCfgDescHandler( certSection, "issueBy", "Certificate issued by" ); %>
  </td>
  <td width=70%>
   <% iw_webCfgValueHandler( certSection, "issueBy", "N/A" ); %>
  </td>
 </tr>
 <tr>
  <td width=30% class="column_title">
   <% iw_webCfgDescHandler( certSection, "expireDate", "Certificate expiration date" ); %>
  </td>
  <td width=70%>
   <% iw_webCfgValueHandler( certSection, "expireDate", "N/A" ); %>
  </td>
 </tr>
 </table>

 <table width="100%" id="area_wpa_EntAcTtls" style="display:none;">
 <tr>
  <td width=30% class="column_title">
   <% iw_webCfgDescHandler( vapSection, "ttlsInner", "TTLS inner authentication" ); %>
  </td>
  <td width=70%>
   <select size="1" id="iw_ttlsInner" name="iw_<% write(vapSection); %>_ttlsInner">
    <option value="PAP">PAP</option>
    <option value="CHAP">CHAP</option>
    <option value="MS-CHAP">MS-CHAP</option>
    <option value="MS-CHAPV2">MS-CHAP-V2</option>
   </select>
  </td>
 </tr>
 </table>

 <table width="100%" id="area_wpa_EntAcPeap" style="display:none;">
 <tr>
  <td width=30% class="column_title">
   <% iw_webCfgDescHandler( vapSection, "peapInner", "Inner EAP protocol" ); %>
  </td>
  <td width=70%>
   <select size="1" id="iw_peapInner" name="iw_<% write(vapSection); %>_peapInner">
    <option value="MS-CHAPV2">MS-CHAP-V2</option>
   </select>
  </td>
 </tr>
 </table>

 <table width="100%" id="area_wpa_EntAcTtlsPeap" style="display:none;">
 <tr>
  <td width=30% class="column_title">
   <% iw_webCfgDescHandler( vapSection, "eapAnonymous", "" ); %>
  </td>
  <td width=70%>
   <input type="text" id="iw_eapAnonymous" name="iw_<% write(vapSection); %>_eapAnonymous" size="37" maxlength="31" value = "<% iw_webCfgValueHandler(vapSection, "eapAnonymous", ""); %>">
  </td>
 </tr>
 <tr>
  <td width=30% class="column_title">
   <% iw_webCfgDescHandler( vapSection, "eapUser", "" ); %>
  </td>
  <td width=70%>
   <input type="text" id="iw_eapUser" name="iw_<% write(vapSection); %>_eapUser" size="37" maxlength="31" value = "<% iw_webCfgValueHandler(vapSection, "eapUser", ""); %>">
  </td>
 </tr>
 <tr>
  <td width=30% class="column_title">
   <% iw_webCfgDescHandler( vapSection, "eapPass", "" ); %>
  </td>
  <td width=70%>
   <input type="password" id="iw_eapPass" name="iw_<% write(vapSection); %>_eapPass" size="37" maxlength="128" value = "<% iw_webCfgValueHandler(vapSection, "eapPass", ""); %>">
  </td>
 </tr>
 </table>
 </div>
 <table width="100%">
 <tr>
  <td>
   <hr>
   <input type="submit" value="Submit" name="Submit">
   <input type="hidden" name="bkpath" value="/wireless_security.asp?index=<% write(index); %>&amp;vapIndex=<% write(vapIndex); %>">
   <input type="hidden" name="wifiSection" value="<% write(wifiSection); %>">
   <input type="hidden" name="vapSection" value="<% write(vapSection); %>">
   <input type="hidden" name="certSection" value="<% write(certSection); %>">
  </td>
 </tr>
 </table>
 </form>
</body>
</html>
<script language="JavaScript" src="js/jquery-1.5.2.min.js"></script>
<script type="text/javascript">
	$(document).ready(function () {
		var isEditPermission = !<% iw_websCheckPermission(); %>;
		if (isEditPermission == 0) {
			$(":input").attr('disabled','disabled');
		}
	});
</script>
