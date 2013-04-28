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

	// make sure the user is authorized to create category::
	ForumFactory forumFactory = ForumFactory.getInstance(authToken);
	ForumPermissions permissions = forumFactory.getPermissions(authToken);
	boolean isSystemAdmin = permissions.get(ForumPermissions.SYSTEM_ADMIN);
	boolean isUserAdmin   = permissions.get(ForumPermissions.FORUM_ADMIN);

	// redirect to error page if we're not a forum admin or a system admin
	if( !isUserAdmin && !isSystemAdmin ) {
		request.setAttribute("message","No permission to create category");
		response.sendRedirect("error.jsp");
		return;
	}
%>


<%	////////////////////
	// Get parameters
	boolean doCreate         = ParamUtils.getBooleanParameter(request,"doCreate");
	String categoryName         = ParamUtils.getParameter(request,"categoryName");
	String categoryDescription  = ParamUtils.getParameter(request,"categoryDescription");
%>

<%	////////////////////
	// Error variables
	boolean categoryNameError = (categoryName==null);

	boolean errors = categoryNameError;

	String errorMessage = "An error occured.";
%>

<%	//////////////////////////////
	// create category if no errors and redirect to category main page

	if( !errors && doCreate ) {
		Category newCategory = null;
		String message = null;
		try {
			if( categoryDescription == null ) {
				categoryDescription = "";
			}
			newCategory = forumFactory.createCategory( categoryName, categoryDescription );
			message = "Category \"" + categoryName + "\" created successfully!";
			request.setAttribute("message",message);
			response.sendRedirect("categories.jsp");
			return;
		}
		catch( UnauthorizedException ue ) {
			message = "Error creating category \"" + categoryName
				+ "\" - you are not authorized to create category.";
		}
		catch( Exception e ) {
			message = "Error creating category \"" + categoryName + "\"";
		}
		request.setAttribute("message",message);
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
	String[] pageTitleInfo = { "Category", "Create Category" };
%>
<%	///////////////////
	// pageTitle include
%><%@ include file="include/pageTitle.jsp" %>

<p>

<%	///////////////////////////////////////////
	// print out error message if there was one
	if( errors && doCreate ) {
%>		<span class="errorText">
		<%= errorMessage %>
		</span>
		<p>
<%	} %>


<form action="createCategory.jsp" method="post">
<input type="hidden" name="doCreate" value="true">

<%-- forum name --%>
Category name:
<%	if( categoryNameError && doCreate ) { %>
	<span class="errorText">
	Category name is required.
	</span>
<%	} %>
<ul>
	<input type="text" name="categoryName" value="<%= (categoryName!=null)?categoryName:"" %>">
</ul>

<%-- forum description --%>
Category description: <i>(optional)</i>
<ul>
	<textarea name="categoryDescription" cols="30" rows="5" wrap="virtual"><%= (categoryDescription!=null)?categoryDescription:"" %></textarea>
</ul>

<%-- create button --%>
<input type="submit" value="Create">

</form>

</body>
</html>

