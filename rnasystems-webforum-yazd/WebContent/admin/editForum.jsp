
<%
/**
 *	$RCSfile: editForum.jsp,v $
 *	$Revision: 1.4 $
 *	$Date: 2005/02/15 22:31:36 $
 */
%>

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

	int forumID   = ParamUtils.getIntParameter(request,"forum",-1);
	boolean doUpdate = ParamUtils.getBooleanParameter(request,"doUpdate");
	String newForumName = ParamUtils.getParameter(request,"forumName");
	String newForumDescription = ParamUtils.getParameter(request,"forumDescription");
	    String newForumHeading  = ParamUtils.getParameter(request,"forumHeading");
        String newForumFooter  = ParamUtils.getParameter(request,"forumFooter");
    int forumorder = ParamUtils.getIntParameter(request,"order",0);

%>

<%	//////////////////////////////////
	// global error variables

	String errorMessage = "";

	boolean noForumSpecified = (forumID < 0);
%>

<%	////////////////////
	// make a profile manager
	ProfileManager manager = forumFactory.getProfileManager();
%>

<%	/////////////////
	// update forum settings, if no errors
	if( doUpdate && !noForumSpecified ) {
		try {
			Forum tempForum = forumFactory.getForum(forumID);
			if( newForumName != null ) {
				tempForum.setName(newForumName);
			}
			if( newForumDescription != null ) {
				tempForum.setDescription(newForumDescription);
			}
			if( newForumHeading != null ) {
				tempForum.setProperty("header",newForumHeading);
			}
			if( newForumFooter != null ) {
				tempForum.setProperty("footer",newForumFooter);
			}
            if(forumorder != tempForum.forumOrder()){
                tempForum.setForumOrder(forumorder);
            }
            request.setAttribute("message","Forum properties updated successfully");
			response.sendRedirect("forums.jsp");
			return;
		}
		catch( ForumAlreadyExistsException e ) {
			System.err.println(e); e.printStackTrace();
		}
		catch( ForumNotFoundException fnfe ) {
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
	String[] pageTitleInfo = { "Forums : Edit Forum Properties" };
%>
<%	///////////////////
	// pageTitle include
%><%@ include file="include/pageTitle.jsp" %>

<p>

<%	////////////////////
	// display a list of groups to edit if no group was specified:
	if( noForumSpecified ) {
		String formAction = "edit";
%>
		<%@ include file="forumChooser.jsp"%>



<%	/////////////////////
	// get an iterator of forums and display a list

	forumIterator = forumFactory.forumsWithArticlesForums();
	if( !forumIterator.hasNext() ) {
%>
		No forums!
<%
	}
%>

<%		out.flush();
		return;
	}
%>

<%	/////////////////////
	// at this point, we know there is a group to work with:
	Forum forum = null;
	try {
		forum                  = forumFactory.getForum(forumID);
	}
	catch( ForumNotFoundException fnfe ) {
	}
	catch( UnauthorizedException ue ) {
	}
	String forumName             = forum.getName();
	String forumDescription      = forum.getDescription();
    String forumHeading = forum.getProperty("header");
    String forumFooter = forum.getProperty("footer");
%>

Properties for: <%= forumName %>

<p>

<form action="editForum.jsp" method="post">
<input type="hidden" name="doUpdate" value="true">
<input type="hidden" name="forum" value="<%= forumID %>">
	Change Forum Name:
	<input type="text" name="forumName" value="<%= forumName %>">

	<p>
        Forum Order Number (Higher order is listed first):
        <input type="text" name="order" value="<%= forum.forumOrder() %>">

        <p>

	Change Description:
	<textarea cols="30" rows="5" wrap="virtual" name="forumDescription"><%= forumDescription %></textarea>

	<p><br><br>
<%-- forum Header --%>
Forum Heading: <i>(optional - displayed on top of the forum <br>Maximum 255 characters) <br><br>

<p> <table><tr><td>
	<textarea name="forumHeading" cols="30" rows="5" wrap="virtual"><%= (forumHeading!=null)?forumHeading:"" %></textarea></td>
    <td valign="middle">
Ideal space for disclaimer or ads. <br>You can easily integerate and use <a href="http://www.addispenser.com" target="_blank">Ad Dispenser</a> here to easily manage both.</i>
    </td>
    </tr></table>
</p>
<%-- forum Footer --%>
Forum Footer: <i>(optional - displayed on bottom of the forum <br>Maximum 255 characters)</i>
<p><table><tr><td>
	<textarea name="forumFooter" cols="30" rows="5" wrap="virtual"><%= (forumFooter!=null)?forumFooter:"" %></textarea></td>
    <td valign="middle">
Ideal space for disclaimer or ads. <br>You can easily integerate and use <a href="http://www.addispenser.com" target="_blank">Ad Dispenser</a> here to easily manage both.</i>
    </td>
    </tr></table>
</p>

	<input type="submit" value="Update">
</form>

</body>
</html>

