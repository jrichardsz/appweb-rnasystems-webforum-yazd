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
		request.setAttribute("message","No permission to administer forum groups");
		response.sendRedirect("error.jsp");
		return;
	}
%>

<%	////////////////////
	// get parameters
        int categoryID = ParamUtils.getIntParameter(request,"category",-1);
	int forumGroupID   = ParamUtils.getIntParameter(request,"forumGroup",-1);
	boolean doDelete = ParamUtils.getBooleanParameter(request,"doDelete");
%>

<%	//////////////////////////////////
	// global error variables

	String errorMessage = "";

	boolean noForumGroupSpecified = (forumGroupID < 0 || categoryID < 0);
	boolean errors = (noForumGroupSpecified);
%>

<%	/////////////////////
	// delete forum group if specified
	if( doDelete && !errors ) {
		String message = "";
		try {
			Category category = forumFactory.getCategory(categoryID);
                        ForumGroup forumGroup = category.getForumGroup(forumGroupID);
			category.deleteForumGroup(forumGroup);
			message = "Forum Group deleted successfully!";
		}
		catch( CategoryNotFoundException fnfe ) {
			message = "No category found";
		}
		catch( ForumGroupNotFoundException fnfe ) {
			message = "No forum group found";
		}
		catch( UnauthorizedException ue ) {
			message = "Not authorized to delete this category";
		}
		request.setAttribute("message",message);
		response.sendRedirect("forumGroups.jsp");
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
	String[] pageTitleInfo = { "ForumGroups : Remove ForumGroup" };
%>
<%	///////////////////
	// pageTitle include
%><%@ include file="include/pageTitle.jsp" %>

<p>

<%	////////////////////
	// return to summary page :
	if( noForumGroupSpecified ) {
            response.sendRedirect("forumGroups.jsp");
	    return;
	}
%>


<%	/////////////////////
	// at this point, we know there is a category and forum group to work with:
	Category category = null;
        ForumGroup forumGroup = null;
	try {
           category = forumFactory.getCategory(categoryID);
           forumGroup = category.getForumGroup(forumGroupID);
        } catch( ForumGroupNotFoundException fgfe ) {
            System.err.println(fgfe);
	} catch( CategoryNotFoundException fnfe ) {
            System.err.println(fnfe);
	} catch( UnauthorizedException ue ) {
            System.err.println(ue);
	}
	String forumGroupName = forumGroup.getName();
%>

Remove <b><%= forumGroupName %></b>?
<p>

<ul>
	Warning: This will delete <b>all</b> forums. Are
	you sure you really want to do this?
</ul>

<form action="removeForumGroup.jsp" name="deleteForumGroup">
<input type="hidden" name="doDelete" value="true">
<input type="hidden" name="category" value="<%= categoryID %>">
<input type="hidden" name="forumGroup" value="<%= forumGroupID %>">
	<input type="submit" value=" Delete ForumGroup ">
	&nbsp;
	<input type="submit" name="cancel" value=" Cancel " style="font-weight:bold;"
	 onclick="location.href='forumGroups.jsp';return false;">
</form>

<script language="JavaScript" type="text/javascript">
<!--
document.deleteForumGroup.cancel.focus();
//-->
</script>

</body>
</html>

