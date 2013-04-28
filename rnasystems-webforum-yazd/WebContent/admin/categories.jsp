
<%@ page language="java" pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" import="java.util.*,
                 com.Yasna.forum.*,
				 com.Yasna.forum.util.*,
				 com.Yasna.forum.util.admin.*" %>

<jsp:useBean id="adminBean" scope="session"
 class="com.Yasna.forum.util.admin.AdminBean"/>

<%	////////////////////////////////
	// Yazd authorization check

	// check the bean for the existence of an authorization token.
	// Its existence proves the user is valid. If it's not found, redirect
	// to the login page
	Authorization authToken = adminBean.getAuthToken();
	if( authToken == null ) {
		response.sendRedirect( "login.jsp" );
		return;
	}
%>

<%	////////////////////
	// Security check

	ForumFactory forumFactory = ForumFactory.getInstance(authToken);
	ForumPermissions permissions = forumFactory.getPermissions(authToken);
	boolean isSystemAdmin = permissions.get(ForumPermissions.SYSTEM_ADMIN);

	// redirect to error page if we're not a system admin
	if( !isSystemAdmin ) {
		request.setAttribute("message","No permission to create categories");
		response.sendRedirect("error.jsp");
		return;
	}
%>


<html>
<head>
	<title></title>
	<link rel="stylesheet" href="style/global.css">
</head>

<body background="images/shadowBack.gif" bgcolor="#ffffff" text="#000000" link="#0000ff" vlink="#800080" alink="#ff0000">

<%	///////////////////////
	// pageTitleInfo variable (used by include/pageTitle.jsp)
	String[] pageTitleInfo = { "Categories" };
%>
<%	///////////////////
	// pageTitle include
%><%@ include file="include/pageTitle.jsp" %>

<p>

<%	///////////////////////////////
	// print out message, if any
	String message = (String)request.getAttribute("message");
	if( message != null ) {
%>
	<span class="messageText">
	<%= message %>
	</span>
<%	}
%>

<p>

<%	//////////////////////
	// category iterator

	Iterator categoryIterator = forumFactory.categories();
%>


<p>

<form>

<table bgcolor="#999999" cellpadding="0" cellspacing="0" border="0" width="100%">
<td>
<table cellpadding="3" cellspacing="1" border="0" width="100%">
<tr bgcolor="#eeeeee">
	<td class="categoryCellHeader" width="1%" nowrap>
		<b>ID</b>
	</td>
	<td class="categoryCellHeader" width="1%" nowrap>
		<b>Category Name</b>
	</td>
	<td class="categoryCellHeader" width="93%"><b>Description</b></td>
    <td class="categoryCellHeader" align="center" width="1%" nowrap><b>Order</b></td>
        <td class="categoryCellHeader" align="center" width="1%" nowrap><b>Properties</b></td>
	<td class="categoryCellHeader" align="center" width="1%" nowrap><b>Remove</b></td>
	<td class="categoryCellHeader" align="center" width="1%" nowrap><b>Content</b></td>
</tr>
<%
	if( !categoryIterator.hasNext() ) {
%>
		<tr bgcolor="#ffffff">
		<td colspan="6" align="center" class="categoryCell"><br><i>No Categories.<br>Try <a href="createCategory.jsp">creating one</a>.</i><br><br></td>
		</tr>
<%
	}
	while( categoryIterator.hasNext()) {
		Category category = (Category)categoryIterator.next();
		int categoryID = category.getID();
		String description = category.getDescription();
	%>

	<tr bgcolor="#ffffff">
		<td class="categoryCell" align="center"><b><%= category.getID() %></b></td>
		<td class="categoryCell">
			<b><%= category.getName() %></b>
		</td>
		<td class="categoryCell"><i><%= (description!=null&&!description.equals(""))?description:"" %></i></td>
        <td class="categoryCell" align="center"><%= category.getOrder() %></td>
		<td align="center">
			<input type="radio" name="edit"
			 onclick="location.href='editCategory.jsp?category=<%= categoryID %>'">
		</td>
		<td align="center">
			<input type="radio" name="remove"
			 onclick="location.href='removeCategory.jsp?category=<%= categoryID %>';">
		</td>
		<td align="center">
			<input type="radio" name="content"
			 onclick="location.href='categoryContent.jsp?category=<%= categoryID %>';">
		</td>
	</tr>

<%	}
%>

</table>
</td>
</table>

</form>

<p>

</body>
</html>

