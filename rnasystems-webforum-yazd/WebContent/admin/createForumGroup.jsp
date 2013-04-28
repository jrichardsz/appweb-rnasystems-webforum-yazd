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

	// make sure the user is authorized to create forum group::
	ForumFactory forumFactory = ForumFactory.getInstance(authToken);
	ForumPermissions permissions = forumFactory.getPermissions(authToken);
	boolean isSystemAdmin = permissions.get(ForumPermissions.SYSTEM_ADMIN);

	// redirect to error page if we're nota system admin
	if(!isSystemAdmin ) {
		request.setAttribute("message","No permission to create forum group");
		response.sendRedirect("error.jsp");
		return;
	}
%>


<%	////////////////////
	// Get parameters
        int categoryID = ParamUtils.getIntParameter(request,"category",-1);
	boolean doCreate         = ParamUtils.getBooleanParameter(request,"doCreate");
	String forumGroupName         = ParamUtils.getParameter(request,"forumGroupName");
	String forumGroupDescription  = ParamUtils.getParameter(request,"forumGroupDescription");
%>

<%	////////////////////
	// Error variables
	boolean forumGroupNameError = (forumGroupName==null);
        boolean categoryError = (categoryID < 0);
	boolean errors = forumGroupNameError || categoryError;

	String errorMessage = "An error occured.";
%>

<%	//////////////////////////////
	// create forum group if no errors and redirect to forum group main page

	if( !errors && doCreate ) {
		ForumGroup newForumGroup = null;
		String message = null;
		try {
			if( forumGroupDescription == null ) {
				forumGroupDescription = "";
			}
                        Category category = forumFactory.getCategory(categoryID);
			newForumGroup = category.createForumGroup( forumGroupName, forumGroupDescription );
			message = "ForumGroup \"" + forumGroupName + "\" created successfully!";
			request.setAttribute("message",message);
			response.sendRedirect("forumGroups.jsp");
			return;
		}
		catch( UnauthorizedException ue ) {
			message = "Error creating froum groups \"" + forumGroupName
				+ "\" - you are not authorized to create forum group.";
		}
		catch( Exception e ) {
			message = "Error creating category \"" + forumGroupName + "\"";
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
	String[] pageTitleInfo = { "Forum Group", "Create Forum Group" };
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
	<select size="1" name="" onchange="location.href='createForumGroup.jsp?category='+this.options[this.selectedIndex].value;">
	<option value="-1">Create Forum Group in:
	<option value="-1">---------------------
<%	while( categoryIterator.hasNext() ) {
		Category category = (Category)categoryIterator.next();
                String selected = category.getID() == categoryID ? " SELECTED ":" ";
%>
		<option <%=selected%> value="<%= category.getID() %>"><%= category.getName() %>
<%	}
%>
	</select>
</form>

<%	if( categoryError && doCreate ) { %>
	<span class="errorText">
	 Category name is required.
	</span>
<%	} %>
<form action="createForumGroup.jsp" method="post">
<input type="hidden" name="doCreate" value="true">
<input type="hidden" name="category" value="<%= categoryID %>">
<%-- forum name --%>
Forum Group name:
<%	if( forumGroupNameError && doCreate ) { %>
	<span class="errorText">
	ForumGroup name is required.
	</span>
<%	} %>
<ul>
	<input type="text" name="forumGroupName" value="<%= (forumGroupName!=null)?forumGroupName:"" %>">
</ul>

<%-- forum description --%>
Forum Group description: <i>(optional)</i>
<ul>
	<textarea name="forumGroupDescription" cols="30" rows="5" wrap="virtual"><%= (forumGroupDescription!=null)?forumGroupDescription:"" %></textarea>
</ul>

<%-- create button --%>
<input type="submit" value="Create">

</form>

</body>
</html>

