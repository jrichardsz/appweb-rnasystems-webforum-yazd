<%	/////////////////////
	// get an iterator of forums and display a list

	Iterator categoryIterator = forumFactory.categories();
	if( !categoryIterator.hasNext() ) {
%>
		No categories!
		<br>
		Try <a href="createCategory.jsp">creating one</a>.
<%
	} else {
%>

	<%	if( formAction.equals("edit") ) { %>
		<form action="editCategory.jsp">
	<%	} else if( formAction.equals("remove") ) { %>
		<form action="removeCategory.jsp">
	<%	} else if( formAction.equals("content") ) { %>
		<form action="categoryContent.jsp">
	<%	} %>

	<select name="category">
	<%	while( categoryIterator.hasNext() ) {
			Category tmpCategory = (Category)categoryIterator.next();
	%>
			<option value="<%= tmpCategory.getID() %>"><%= tmpCategory.getName() %>
	<%	}
	%>
	</select>

	<%	if( formAction.equals("edit") ) { %>
		<input type="submit" value="Edit Properties...">
	<%	} else if( formAction.equals("remove") ) { %>
		<input type="submit" value="Remove This Category...">
	<%	} else if( formAction.equals("content") ) { %>
		<input type="submit" value="Category Content...">
	<%	} %>

	</form>

<%	} %>
