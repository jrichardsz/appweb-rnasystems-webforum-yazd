
<%
/**
 *	$RCSfile: groupChooser.jsp,v $
 *	$Revision: 1.3 $
 *	$Date: 2006/01/07 00:21:56 $
 */
%>

<%	/////////////////////
	// get an iterator of groups and display a list
	
	Iterator groupIterator = manager.groups();
	if( !groupIterator.hasNext() ) {
%>
		No groups to edit!
<%
	}
%>

<form action="<%= formAction %>Group.jsp">
<select name="group">
<%	while( groupIterator.hasNext() ) {
		Group group = (Group)groupIterator.next();
%>
		<option value="<%= group.getID() %>"><%= group.getName() %>
<%	}
%>
</select>
<%	if( formAction.equals("edit") ) { %>
	<input type="submit" value="Edit This Group...">
<%	} else if( formAction.equals("remove") ) { %>
	<input type="submit" value="Remove This Group...">
<%	} %>
</form>

