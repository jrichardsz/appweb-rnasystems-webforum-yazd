
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
		request.setAttribute("message","No permission to create forumGroups");
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
	String[] pageTitleInfo = { "ForumGroups" };
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
	// category iterator, forum count
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
		<b>ForumGroup Name</b>
	</td>
	<td class="categoryCellHeader" width="93%"><b>Description</b></td>
	<td class="categoryCellHeader" width="1%"  align="center">
		<b>ForumGroup<br>Category</b>
	</td>
    <td class="categoryCellHeader" width="1%" align="center">
        <b>Group<br>Order</b>
    </td>
    <td class="categoryCellHeader" align="center" width="1%" nowrap><b>Properties</b></td>
	<td class="categoryCellHeader" align="center" width="1%" nowrap><b>Remove</b></td>
	<td class="categoryCellHeader" align="center" width="1%" nowrap><b>Content</b></td>
</tr>
<%
        boolean hasForumGroup = false;
	while( categoryIterator.hasNext()) {
		Category category = (Category)categoryIterator.next();
                Iterator forumGroupIterator = category.forumGroups();
                while (forumGroupIterator.hasNext()){
                   hasForumGroup = true;
                   ForumGroup forumGroup = (ForumGroup)forumGroupIterator.next();
		   int forumGroupID = forumGroup.getID();
                   String name = forumGroup.getName();
		   String description = forumGroup.getDescription();
	%>

	<tr bgcolor="#ffffff">
		<td class="categoryCell" align="center"><b><%=forumGroupID%></b></td>
		<td class="categoryCell">
			<b><%= name %></b>
		</td>
		<td class="categoryCell"><i><%= (description!=null&&!description.equals(""))?description:"" %></i></td>
		<td class="categoryCell">
			<b><%= category.getName() %></b>
		</td>
        <td class="categoryCell" align="center">
            <b><%= forumGroup.getOrder() %></b>
        </td>
		<td align="center">
			<input type="radio" name="edit"
			 onclick="location.href='editForumGroup.jsp?forumGroup=<%= forumGroupID %>&category=<%= category.getID() %>'">
		</td>
		<td align="center">
			<input type="radio" name="remove"
			 onclick="location.href='removeForumGroup.jsp?forumGroup=<%= forumGroupID %>&category=<%= category.getID() %>'">
		</td>
		<td align="center">
			<input type="radio" name="content"
			 onclick="location.href='forums.jsp?forumGroup=<%= forumGroupID %>&category=<%= category.getID() %>'">
		</td>
	</tr>

<%
                }
        }
	if( !hasForumGroup) {
%>
		<tr bgcolor="#ffffff">
		<td colspan="7" align="center" class="categoryCell"><br><i>No forumgroups.<br>Try <a href="createForumGroup.jsp">creating one</a>.</i><br><br></td>
		</tr>
<%
	}
%>

</table>
</td>
</table>

</form>

<p>

</body>
</html>

