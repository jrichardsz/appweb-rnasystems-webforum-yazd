
<%
/**
 *	$RCSfile: editUser.jsp,v $
 *	$Revision: 1.4 $
 *	$Date: 2006/01/07 00:21:56 $
 */
%>

<%@ page language="java" pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" import="java.util.*,
                 java.net.*,
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
	boolean isSystemAdmin = ((Boolean)session.getValue("yazdAdmin.systemAdmin")).booleanValue();

	// redirect to error page if we're not a user admin or a system admin
	if( !isSystemAdmin ) {
		throw new UnauthorizedException("Sorry, you don't have permission to edit a user");
	}
%>

<%	///////////////////////
	// get parameters

	boolean saveChanges = ParamUtils.getBooleanParameter(request,"saveChanges");
	String username = ParamUtils.getParameter(request,"user");
	String name = ParamUtils.getParameter(request,"name",true);
	String email = ParamUtils.getParameter(request,"email");
	boolean nameVisible = ParamUtils.getBooleanParameter(request,"nameVisible");
	boolean emailVisible = ParamUtils.getBooleanParameter(request,"emailVisible");
    boolean emailReply = ParamUtils.getBooleanParameter(request,"emailReply");
    int ranking = ParamUtils.getIntParameter(request,"ranking",-1);
%>

<%	////////////////
	// create a profile manager

	ProfileManager manager = forumFactory.getProfileManager();
%>

<%	/////////////////
	// check for errors

	boolean errorEmail = (email==null);
	boolean errors = (errorEmail);
%>

<%	//////////////////
	// save user changes if necessary

	if( !errors && saveChanges ) {
		User user = manager.getUser(username);
		if( name != null ) {
			user.setName(name);
		}
		if( email != null ) {
			user.setEmail(email);
		}
		user.setEmailVisible( emailVisible );
		user.setNameVisible( nameVisible );
		user.setEmailReply( emailReply );
        if(ranking >0){
            user.setProperty("ranking",Integer.toString(ranking));
        }
        // redirect to user main page
		response.sendRedirect(
			response.encodeRedirectURL("users.jsp?msg=Changes saved.")
		);
		return;
	}
%>

<%	//////////////////////
	// user properties

	User user = manager.getUser(username);
	int userID = user.getID();
	name = user.getName();
	email = user.getEmail();
	boolean isEmailVisible = user.isEmailVisible();
	boolean isNameVisible = user.isNameVisible();
        boolean hasEmailReply = user.getEmailReply();
	Enumeration userProperties = user.propertyNames();
%>

<html>
<head>
	<title></title>
	<link rel="stylesheet" href="style/global.css">
</head>

<body background="images/shadowBack.gif" bgcolor="#ffffff" text="#000000" link="#0000ff" vlink="#800080" alink="#ff0000">

<%	///////////////////////
	// pageTitleInfo variable (used by include/pageTitle.jsp)
	String[] pageTitleInfo = { "Users", "Edit User Properties" };
%>
<%	///////////////////
	// pageTitle include
%><%@ include file="include/pageTitle.jsp" %>

<p>

<form action="editUser.jsp">
<input type="hidden" name="saveChanges" value="true">
<input type="hidden" name="user" value="<%= username %>">

<p>

Properties for: <b><%= username %></b>

<p>

<table bgcolor="#666666" cellpadding="0" cellspacing="0" border="0" width="80%" align="center">
<td>
<table bgcolor="#666666" cellpadding="3" cellspacing="1" border="0" width="100%">
<tr bgcolor="#ffffff">
	<td>User ID:</td>
	<td colspan="2"><%= userID %></td>
</tr>
<tr bgcolor="#ffffff">
	<td>Username:</td>
	<td colspan="2"><%= username %></td>
</tr>
<tr bgcolor="#ffffff">
	<td>Name:</td>
	<td colspan="2">
		<input type="text" name="name" value="<%= (name!=null)?name:"" %>">
	</td>
</tr>
<tr bgcolor="#ffffff">
	<td>Name is visible in forums</td>
	<td>
		<input type="radio" name="nameVisible" value="true" id="rb01"<%= isNameVisible?" checked":"" %>>
		<label for="rb01">Yes</label>
	</td>
	<td>
		<input type="radio" name="nameVisible" value="false" id="rb02"<%= !isNameVisible?" checked":"" %>>
		<label for="rb02">No</label>
	</td>
</tr>
<tr bgcolor="#ffffff">
	<td>Email:</td>
	<td colspan="2">
		<input type="text" name="email" value="<%= (email!=null)?email:"" %>">
	</td>
</tr>
<tr bgcolor="#ffffff">
	<td>Email is visible in forums</td>
	<td>
		<input type="radio" name="emailVisible" value="true" id="rb03"<%= isEmailVisible?" checked":"" %>>
		<label for="rb03">Yes</label>
	</td>
	<td>
		<input type="radio" name="emailVisible" value="false" id="rb04"<%= !isEmailVisible?" checked":"" %>>
		<label for="rb04">No</label>
	</td>
</tr>
<tr bgcolor="#ffffff">
	<td>Receive email on reply</td>
	<td>
		<input type="radio" name="emailReply" value="true" id="rb05"<%= hasEmailReply?" checked":"" %>>
		<label for="rb05">Yes</label>
	</td>
	<td>
		<input type="radio" name="emailReply" value="false" id="rb06"<%= !hasEmailReply?" checked":"" %>>
		<label for="rb06">No</label>
	</td>
</tr>
    <tr bgcolor="#ffffff">
        <td>Ranking:<i>Lower is better!</i></td>
        <td colspan="2">
            <input type="text" name="ranking" value="<%=user.getProperty("ranking")%>">
        </td>
    </tr>
</table>
</td>
</table>
<br><br>
<center>
	<input type="submit" value="Save Changes">
</center>

<p>

Extended Properties <br>
Some of the values above are stored in the extended properties!

<p>

<table bgcolor="#666666" cellpadding="0" cellspacing="0" border="0" width="80%" align="center">
<td>
<table bgcolor="#666666" cellpadding="3" cellspacing="1" border="0" width="100%">
<%	if( !userProperties.hasMoreElements() ) { %>
<tr bgcolor="#ffffff">
	<td align="center"><i>No extended properties set</i></td>
</tr>
<%	} %>
<%	while( userProperties.hasMoreElements() ) {
		String propName = (String)userProperties.nextElement();
		String propValue = user.getProperty(propName);
%>
<tr bgcolor="#ffffff">
	<td><%= propName %></td>
	<td><%= propValue %></td>
</tr>
<%	} %>
</table></td></table>

<p>


</form>

</body>
</html>
