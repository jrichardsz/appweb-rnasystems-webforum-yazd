<%@ page language="java" pageEncoding="UTF-8" contentType="text/html; charset=UTF-8"%>
<%@ page import="java.util.*,
                 com.Yasna.forum.*,
				 com.Yasna.forum.util.*,
				 com.Yasna.forum.util.admin.*" 
				 errorPage="error.jsp"%>

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

	// make sure the user is authorized to create forums::
	ForumFactory forumFactory = ForumFactory.getInstance(authToken);
	ForumPermissions permissions = forumFactory.getPermissions(authToken);
	boolean isSystemAdmin = permissions.get(ForumPermissions.SYSTEM_ADMIN);
	boolean isUserAdmin   = permissions.get(ForumPermissions.FORUM_ADMIN);

	// redirect to error page if we're not a forum admin or a system admin
	if( !isUserAdmin && !isSystemAdmin ) {
		request.setAttribute("msg","No permission to create forums");
		response.sendRedirect("error.jsp");
		return;
	}
%>


<%	////////////////////
	// Get parameters
        int categoryID           = ParamUtils.getIntParameter(request,"category",-1);
        int forumGroupID         = ParamUtils.getIntParameter(request,"forumGroup",-1);
        boolean moderated      = ParamUtils.getCheckboxParameter(request,"moderate");
    boolean isarticle       =ParamUtils.getCheckboxParameter(request,"article");
    boolean doCreate         = ParamUtils.getBooleanParameter(request,"doCreate");
	String forumName         = ParamUtils.getParameter(request,"forumName");
	String forumDescription  = ParamUtils.getParameter(request,"forumDescription");
	String forumHeading  = ParamUtils.getParameter(request,"forumHeading");
    String forumFooter  = ParamUtils.getParameter(request,"forumFooter");

%>

<%	////////////////////
	// Error variables
	boolean forumNameError = (forumName==null);
	boolean categoryError = (categoryID < 0);
    boolean forumGroupError = (forumGroupID < 0);
	boolean errors = forumNameError || categoryError || forumGroupError;

	String errorMessage = "An error occured.";
%>


<%	//////////////////////////////
	// create forum if no errors and redirect to forum main page
	if( !errors && doCreate ) {
		Forum newForum = null;
		String message = null;
		try {
			if( forumDescription == null ) {
				forumDescription = "";
			}
			newForum = forumFactory.createForum( forumName, forumDescription, moderated, forumGroupID,isarticle );
			if (forumHeading!=null){
            	newForum.setProperty("header",forumHeading);
            }
            if (forumFooter != null){
            	newForum.setProperty("footer",forumFooter);
            }
			message = "Forum \"" + forumName + "\" created successfully!";
			request.setAttribute("message",message);
			response.sendRedirect("forumPerms.jsp?forum="+newForum.getID());
			return;
		}
		catch( UnauthorizedException ue ) {
			message = "Error creating forum \"" + forumName
				+ "\" - you are not authorized to create forums.";
		}
		catch(ForumAlreadyExistsException ee){
			message = "Error creating forum<br>Forum \""+forumName
			+ "\" already exists.";
		}
		catch( Exception e ) {
			message = "Error creating forum \"" + forumName + "\"";
            e.printStackTrace();
		}
		//request.setAttribute("msg",message);
		response.sendRedirect("error.jsp?msg="+message);
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
	String[] pageTitleInfo = { "Forums", "Create Forum" };
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

Note: This creates a forum with no permissions. After you create this forum,
you will be taken to the forum permissions screen.

<p>
<table border="0">
<tr><td>
<%	///////////////////////
	// show a pulldown box for categories
	Iterator categoryIterator = forumFactory.categories();
        categoryIterator = forumFactory.categories();
	if( !categoryIterator.hasNext() ) {
%>
		No categories!
<%	}
%>

<form>
	<select size="1" name="categorySelect" onchange="location.href='createForum.jsp?category='+this.options[categorySelect.selectedIndex].value;">
	<option value="-1">Choose Category:
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
	Category is required.
	</span>
<%	} %>
</td><td>
<%	///////////////////////
	// show a pulldown box for forum groups
	Iterator forumGroupIterator = null;
	if(categoryID > 0) {
	    Category category = forumFactory.getCategory(categoryID);
            forumGroupIterator = category.forumGroups();
	}
%>


<form>
	<select size="1" name="forumGroupSelect" onchange="location.href='createForum.jsp?forumGroup='+this.options[forumGroupSelect.selectedIndex].value+'&category=<%=categoryID%>';">
	<option value="-1">Choose Forum Group:
	<option value="-1">---------------------
<%
   if(forumGroupIterator != null){
        while( forumGroupIterator.hasNext() ) {
		ForumGroup forumGroup = (ForumGroup)forumGroupIterator.next();
                String selected = forumGroup.getID() == forumGroupID ? " SELECTED ":" ";
%>
		<option <%=selected%> value="<%= forumGroup.getID() %>"><%= forumGroup.getName() %>
<%	}
   }
%>
	</select>
</form>
<%	if( forumGroupError && doCreate ) { %>
	<span class="errorText">
	Forum Group is required.
	</span>
<%	} %>
</td></tr></table>

<form action="createForum.jsp" method="post">
<input type="hidden" name="doCreate" value="true">
<input type="hidden" name="category" value="<%= categoryID %>">
<input type="hidden" name="forumGroup" value="<%= forumGroupID %>">
<%-- forum name --%>
Forum name:
<%	if( forumNameError && doCreate ) { %>
	<span class="errorText">
	Forum name is required.
	</span>
<%	} %>
<ul>
	<input type="text" name="forumName" value="<%= (forumName!=null)?forumName:"" %>">
</ul>

<%-- forum description --%>
Forum description: <i>(optional)</i>
<ul>
	<textarea name="forumDescription" cols="30" rows="5" wrap="virtual"><%= (forumDescription!=null)?forumDescription:"" %></textarea>
</ul>
<%-- forum Header --%>
Forum Heading: <i>(optional - displayed on top of the forum <br>Maximum 255 characters)</i>
<ul>
<table><tr><td>
	<textarea name="forumHeading" cols="30" rows="5" wrap="virtual"><%= (forumHeading!=null)?forumHeading:"" %></textarea></td>
	    <td valign="middle">
Ideal space for disclaimer or ads. <br>You can easily integerate and use <a href="http://www.addispenser.com" target="_blank">Ad Dispenser</a> here to easily manage both.
    </td>
    </tr></table>
</ul>
<%-- forum Footer --%>
Forum Footer: <i>(optional - displayed on bottom of the forum <br>Maximum 255 characters)</i>
<ul>
<table><tr><td>
<textarea name="forumFooter" cols="30" rows="5" wrap="virtual"><%= (forumFooter!=null)?forumFooter:"" %></textarea></td>
	    <td valign="middle">
Ideal space for disclaimer or ads. <br>You can easily integerate and use <a href="http://www.addispenser.com" target="_blank">Ad Dispenser</a> here to easily manage both.
    </td>
    </tr></table>
</ul>

    <input type="checkbox" name="moderate">
    Should be this forum moderated?
<br>
<input type="checkbox" name="article">
Should be this forum be used for storing discussions about a web page or an article?

<p>
<%-- create button --%>
<input type="submit" value="Create">

</form>

</body>
</html>

