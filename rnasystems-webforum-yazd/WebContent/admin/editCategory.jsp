<%@ page language="java" pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" import="java.util.*,
                 com.Yasna.forum.*,
                 com.Yasna.forum.util.*,
				 com.Yasna.forum.util.admin.*"%>

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

	// make sure the user is authorized to administer users:
	ForumFactory forumFactory = ForumFactory.getInstance(authToken);
	ForumPermissions permissions = forumFactory.getPermissions(authToken);
	boolean isSystemAdmin = permissions.get(ForumPermissions.SYSTEM_ADMIN);
	boolean isUserAdmin   = permissions.get(ForumPermissions.FORUM_ADMIN);

	// redirect to error page if we're not a forum admin or a system admin
	if( !isUserAdmin && !isSystemAdmin ) {
		request.setAttribute("message","No permission to administer forums");
		response.sendRedirect("error.jsp");
		return;
	}
%>

<%	////////////////////
	// get parameters

	int categoryID   = ParamUtils.getIntParameter(request,"category",-1);
	boolean doUpdate = ParamUtils.getBooleanParameter(request,"doUpdate");
	String newCategoryName = ParamUtils.getParameter(request,"categoryName");
	String newCategoryDescription = ParamUtils.getParameter(request,"categoryDescription");
    int catorder   = ParamUtils.getIntParameter(request,"catorder",-1);

%>

<%	//////////////////////////////////
	// global error variables

	String errorMessage = "";

	boolean noCategorySpecified = (categoryID < 0);
%>


<%	/////////////////
	// update category settings, if no errors
	if( doUpdate && !noCategorySpecified ) {
		try {
			Category tempCategory = forumFactory.getCategory(categoryID);
			if( newCategoryName != null ) {
                            tempCategory.setName(newCategoryName);
			}
			if( newCategoryDescription != null ) {
                            tempCategory.setDescription(newCategoryDescription);
			}
            if(catorder > 0){
                tempCategory.setOrder(catorder);
            }
            request.setAttribute("message","Category properties updated successfully");
			response.sendRedirect("categories.jsp");
			return;
		}
		catch( CategoryAlreadyExistsException e ) {
			System.err.println(e); e.printStackTrace();
		}
		catch( CategoryNotFoundException fnfe ) {
			System.err.println(fnfe); fnfe.printStackTrace();
		}
		catch( UnauthorizedException ue ) {
			System.err.println(ue); ue.printStackTrace();
		}
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
	String[] pageTitleInfo = { "Category : Edit Category Properties" };
%>
<%	///////////////////
	// pageTitle include
%><%@ include file="include/pageTitle.jsp" %>

<p>

<%	////////////////////
	// display a list of groups to edit if no group was specified:
	if( noCategorySpecified ) {
		String formAction = "edit";
%>
		<%@ include file="categoryChooser.jsp"%>



<%	/////////////////////
	// get an iterator of forums and display a list

	categoryIterator = forumFactory.categories();
	if( !categoryIterator.hasNext() ) {
%>
		No categories!
<%
	}
%>

<%		out.flush();
		return;
	}
%>

<%	/////////////////////
	Category category = null;
	try {
		category                  = forumFactory.getCategory(categoryID);
	}
	catch( CategoryNotFoundException fnfe ) {
	}
	catch( UnauthorizedException ue ) {
	}
	String categoryName             = category.getName();
	String categoryDescription      = category.getDescription();
%>

Properties for: <%= categoryName %>

<p>

<form action="editCategory.jsp" method="post">
<input type="hidden" name="doUpdate" value="true">
<input type="hidden" name="category" value="<%= categoryID %>">
	Change Category Name:
	<input type="text" name="categoryName" value="<%= categoryName %>">

	<p>

	Change Description:
	<textarea cols="30" rows="5" wrap="virtual" name="categoryDescription"><%= categoryDescription %></textarea>

	<p>
    Category Order:
    <input type="text" name="catorder" value="<%= category.getOrder() %>">
    <br><i>Higher order is listed first!</i>

    <p>

	<input type="submit" value="Update">
</form>

</body>
</html>

