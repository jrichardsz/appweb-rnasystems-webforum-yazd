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

	// redirect to error page if we're not a system admin
	if( !isSystemAdmin ) {
		request.setAttribute("message","No permission to administer forum groups");
		response.sendRedirect("error.jsp");
		return;
	}
%>

<%	////////////////////
	// get parameters
        int categoryID = ParamUtils.getIntParameter(request,"category",-1);
	int forumGroupID = ParamUtils.getIntParameter(request,"forumGroup",-1);
	boolean doUpdate = ParamUtils.getBooleanParameter(request,"doUpdate");
	String newForumGroupName = ParamUtils.getParameter(request,"forumGroupName");
	String newForumGroupDescription = ParamUtils.getParameter(request,"forumGroupDescription");
    int grporder = ParamUtils.getIntParameter(request,"grporder",-1);
%>

<%	//////////////////////////////////
	// global error variables

	String errorMessage = "";

	boolean noForumGroupSpecified = (forumGroupID < 0 || categoryID < 0);
%>


<%	/////////////////
	// update forumGroup settings, if no errors
	if( doUpdate && !noForumGroupSpecified ) {
		try {
			Category tempCategory = forumFactory.getCategory(categoryID);
                        ForumGroup tmpForumGroup = tempCategory.getForumGroup(forumGroupID);

			if( newForumGroupName != null ) {
                            tmpForumGroup.setName(newForumGroupName);
			}
			if( newForumGroupDescription != null ) {
                            tmpForumGroup.setDescription(newForumGroupDescription);
			}
            if(grporder > 0){
                tmpForumGroup.setOrder(grporder);
            }
            request.setAttribute("message","ForumGroup properties updated successfully");
			response.sendRedirect("forumGroups.jsp");
			return;
		}
		catch( ForumGroupNotFoundException fnfe ) {
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
	String[] pageTitleInfo = { "ForumGroup : Edit ForumGroup Properties" };
%>
<%	///////////////////
	// pageTitle include
%><%@ include file="include/pageTitle.jsp" %>

<p>


<%	if( noForumGroupSpecified ) {
		response.sendRedirect("forumGroups.jsp");
		return;
	}
%>


<%	/////////////////////
	Category category = null;
        ForumGroup forumGroup = null;
	try {
		category   = forumFactory.getCategory(categoryID);
                forumGroup = category.getForumGroup(forumGroupID);
	}
	catch( CategoryNotFoundException fnfe ) {
	}
	catch( UnauthorizedException ue ) {
	}
        String forumGroupName = forumGroup.getName();
        String forumGroupDescription = forumGroup.getDescription();
%>

Properties for: <%= forumGroupName %>

<p>

<form action="editForumGroup.jsp" method="post">
<input type="hidden" name="doUpdate" value="true">
<input type="hidden" name="category" value="<%= categoryID %>">
<input type="hidden" name="forumGroup" value="<%= forumGroupID %>">
	Change ForumGroup Name:
	<input type="text" name="forumGroupName" value="<%= forumGroupName %>">

	<p>

	Change Description:
	<textarea cols="30" rows="5" wrap="virtual" name="forumGroupDescription"><%= forumGroupDescription %></textarea>

	<p>
    Change ForumGroup Order:
    <input type="text" name="grporder" value="<%= forumGroup.getOrder() %>">
    <br><i>Higher order is listed first!</i>

    <p>

	<input type="submit" value="Update">
</form>

</body>
</html>

