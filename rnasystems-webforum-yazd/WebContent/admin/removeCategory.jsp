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


	// redirect to error page if we're not a  system admin
	if(!isSystemAdmin ) {
		request.setAttribute("message","No permission to administer categories");
		response.sendRedirect("error.jsp");
		return;
	}
%>

<%	////////////////////
	// get parameters

	int categoryID   = ParamUtils.getIntParameter(request,"category",-1);
	boolean doDelete = ParamUtils.getBooleanParameter(request,"doDelete");
%>

<%	//////////////////////////////////
	// global error variables

	String errorMessage = "";

	boolean noCategorySpecified = (categoryID < 0);
	boolean errors = (noCategorySpecified);
%>

<%	/////////////////////
	// delete category if specified
	if( doDelete && !errors ) {
		String message = "";
		try {
			Category deleteableCategory = forumFactory.getCategory(categoryID);
			forumFactory.deleteCategory(deleteableCategory);
			message = "Category deleted successfully!";
		}
		catch( CategoryNotFoundException fnfe ) {
			message = "No category found";
		}
		catch( UnauthorizedException ue ) {
			message = "Not authorized to delete this category";
		}
		request.setAttribute("message",message);
		response.sendRedirect("categories.jsp");
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
	String[] pageTitleInfo = { "Categories : Remove Category" };
%>
<%	///////////////////
	// pageTitle include
%><%@ include file="include/pageTitle.jsp" %>

<p>

<%	////////////////////
	// display a list of categories to remove :
	if( noCategorySpecified ) {
		String formAction = "remove";
%>
		<%@ include file="categoryChooser.jsp"%>
<%		out.flush();
		return;
	}
%>


<%	/////////////////////
	// at this point, we know there is a category to work with:
	Category category = null;
	try {
            category = forumFactory.getCategory(categoryID);
	} catch( CategoryNotFoundException fnfe ) {
	} catch( UnauthorizedException ue ) {
	}
	String categoryName             = category.getName();
%>

Remove <b><%= categoryName %></b>?
<p>

<ul>
	Warning: This will delete <b>all</b> forum groups and forums. Are
	you sure you really want to do this?
</ul>

<form action="removeCategory.jsp" name="deleteCategory">
<input type="hidden" name="doDelete" value="true">
<input type="hidden" name="category" value="<%= categoryID %>">
	<input type="submit" value=" Delete Category ">
	&nbsp;
	<input type="submit" name="cancel" value=" Cancel " style="font-weight:bold;"
	 onclick="location.href='categories.jsp';return false;">
</form>

<script language="JavaScript" type="text/javascript">
<!--
document.deleteCategory.cancel.focus();
//-->
</script>

</body>
</html>

