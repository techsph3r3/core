<TITLE>Disable Mode</TITLE>
</HEAD>
<BODY>
 <H2>Operation Modes<% iw_websGetErrorString(); %></H2>
 <FORM id="submitForm" name="opmode" method="POST" action="<% write(action_page); %>">
 <table class="show_table">
  <tbody>
  <tr><td>
   <% include("op_applicationSelect.asp"); %>
  </td>
  </tr>
  <tr><td>
      <table class="show_table" width="100%">
       <tr><td><hr></td></tr>
       <tr><td><INPUT type="submit" value="Submit" name="Submit"></td></tr>
         </table>
  </td></tr>
  </tbody>
 </table>
 </FORM>
<script language="JavaScript" src="js/jquery-1.5.2.min.js"></script>
<script type="text/javascript">
	$(document).ready(function () {
		var isEditPermission = !<% iw_websCheckPermission(); %>;
		if (isEditPermission == 0) {
			$(":input").attr('disabled','disabled');
		}
	});
</script>
