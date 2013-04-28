<%@ page language="java" pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" import="java.util.*,
                 java.text.SimpleDateFormat,
                 com.Yasna.forum.*,
                 com.Yasna.forum.util.*,
				 com.Yasna.forum.util.admin.*"
	errorPage="error.jsp"
%>

<jsp:useBean id="adminBean" scope="session"
 class="com.Yasna.forum.util.admin.AdminBean"/>

<%	////////////////////////////////
	// Yazd authorization check

	// check the bean for the existence of an authorization token.
	// Its existence proves the user is valid. If it's not found, redirect
	// to the login page
	System.err.println("heelo");
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

	// redirect to error page if we're not a forum admin or a system admin
	if(!isSystemAdmin) {
		request.setAttribute("message","No permission to administer categories");
		response.sendRedirect("error.jsp");
		return;
	}
%>

<%	////////////////////
	// get parameters

	int categoryID   = ParamUtils.getIntParameter(request,"category",-1);
	boolean deleteForumGroup = ParamUtils.getBooleanParameter(request,"deleteForumGroup");
	int forumGroupID = ParamUtils.getIntParameter(request,"forumGroup",-1);
%>

<%	//////////////////////////////////
	// global error variables

	String errorMessage = "";

	boolean noCategorySpecified = (categoryID < 0);
	boolean noForumGroupSpecified = (forumGroupID < 0);
%>


<%	/////////////////////
	// delete a forumgroup
	if( deleteForumGroup ) {
			Category tempCategory = forumFactory.getCategory(categoryID);
			ForumGroup tempForumGroup = tempCategory.getForumGroup(forumGroupID);
			tempCategory.deleteForumGroup(tempForumGroup);
			response.sendRedirect("categoryContent.jsp?category="+categoryID);
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
	String[] pageTitleInfo = { "Categories : Manage Category Content" };
%>
<%	///////////////////
	// pageTitle include
%><%@ include file="include/pageTitle.jsp" %>

<p>

<%	//////////////////////
	// show the name of the category we're working with (if one was selected)
	Category currentCategory = null;
	if( !noCategorySpecified ) {
		try {
			currentCategory = forumFactory.getCategory(categoryID);
	%>
			You're currently working with category: <b><%= currentCategory.getName() %></b>
	<%	}
		catch( CategoryNotFoundException fnfe ) {
	%>
			<span class="errorText">Category not found.</span>
	<%	}
		catch( UnauthorizedException ue ) {
	%>
			<span class="errorText">Not authorized to administer this forum.</span>
	<%	}
	}
%>

<p>

<%	///////////////////////
	// show a pulldown box
	Iterator categoryIterator = forumFactory.categories();
	if(isSystemAdmin ) {
	    categoryIterator = forumFactory.categories();
	}
	if( !categoryIterator.hasNext() ) {
%>
		No categories!
<%	}
%>

<p>

<form>
	<select size="1" name="" onchange="location.href='categoryContent.jsp?category='+this.options[this.selectedIndex].value;">
	<option value="-1">Manage content for:
	<option value="-1">---------------------
<%	while( categoryIterator.hasNext() ) {
		Category category = (Category)categoryIterator.next();
%>
		<option value="<%= category.getID() %>"><%= category.getName() %>
<%	}
%>
	</select>
</form>

<%	if( noCategorySpecified ) {
		out.flush();
		return;
	}
%>

<p>


<table bgcolor="#cccccc" cellpadding=0 cellspacing=0 border=0 width="100%">
<td>
<table bgcolor="#cccccc" cellpadding=3 cellspacing=1 border=0 width="100%">
<tr bgcolor="#dddddd">
	<td class="forumListHeader" width="1%" nowrap bgcolor="#cccccc"><b>delete?</b></td>
	<td class="forumListHeader" width="95%">Name</td>
	<td class="forumListHeader" width="1%" nowrap>description</td>
</tr>

<%	/////////////////////
	// get an iterator
	Iterator forumGroupIterator = currentCategory.forumGroups();

	if( !forumGroupIterator.hasNext() ) {
%>

	<tr bgcolor="#ffffff">
		<td colspan="5" align="center" class="forumListCell">
		<br><i>No forum groups in this category.</i><br><br>
		</td>
	</tr>

<%	}
	while( forumGroupIterator.hasNext() ) {
			ForumGroup currentForumGroup = (ForumGroup)forumGroupIterator.next();
			int currentForumGroupID = currentForumGroup.getID();
			String name = currentForumGroup.getName();
			String description = currentForumGroup.getDescription();
%>
	<tr>
		<form>
		<td width="1%" class="forumListCell" align="center">
			<input type="radio"
			 onclick="if(confirm('Are you sure you want to delete this forum group and all its forums?')){location.href='categoryContent.jsp?category=<%=categoryID%>&deleteForumGroup=true&forumGroup=<%= currentForumGroupID %>';}">
		</td>
		<td class="forumListCell" width="96%">
			<a href="forums.jsp?category=<%=categoryID%>&forumGroup=<%=currentForumGroupID%>"><%= currentForumGroup.getName() %></a>
		</td>
		<td class="forumListCell" width="1%" nowrap align="center">
			<%= description %>
		</td>
		</form>
	</tr>

<%	}
%>

</table>
</td>
</table>


</body>
</html>

