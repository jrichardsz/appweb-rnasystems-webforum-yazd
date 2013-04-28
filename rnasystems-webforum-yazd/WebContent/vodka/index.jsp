
<%
/**
 *	$RCSfile: index.jsp,v $
 *	$Revision: 1.7 $
 *	$Date: 2005/09/26 18:26:26 $
 */
%>

<%@	page import="java.util.*,
                 com.Yasna.forum.*,
                 com.Yasna.forum.util.*,
                    com.Yasna.forum.locale.YazdLocale"

%>

<%!	//////////////////////////////////
	// customize the look of this page

	// Colors of the table that displays a list of forums
	final static String forumTableBgcolor = "#ccccdd";
	final static String forumTableFgcolor = "#ffffff";
	final static String forumTableHeaderFgcolor = "#ccccdd";
    final static String forumTableGroupBgcolor = "#eeeeee";
%>

<%	//////////////////////////////
	// Logout a user if requested

	// check for the parameter "logout=true"
	if( ParamUtils.getBooleanParameter(request,"logout") ) {
		// invalidate their authentication token
		SkinUtils.removeUserAuthorization(request,response);
		// redirect them to the page from where they came
        String referringPage = request.getHeader("REFERER");
        if (referringPage == null || referringPage.equals("null")){
            referringPage="index.jsp";
        }

		response.sendRedirect(referringPage);
		return;
	}
%>

<%	////////////////////////
	// Authorization check

	// check for the existence of an authorization token
	Authorization authToken = SkinUtils.getUserAuthorization(request,response);

	// if the token was null, they're not authorized. Since this skin will
	// allow guests to view forums, we'll set a "guest" authentication
	// token
	if( authToken == null ) {
		authToken = AuthorizationFactory.getAnonymousAuthorization();
	}
%>

<%	///////////////////////
	// page forum variables

	// do not delete these
    ForumFactory forumFactory = ForumFactory.getInstance(authToken);
    User user = forumFactory.getProfileManager().getUser(authToken.getUserID());
    // get the locale for the forum
    // please note that even if the user is anonymous, the locale that will be returned will be the default
    // Locale for the forum.
    Locale locale = user.getUserLocale();
    TimeZone timezone = user.getUserTimeZone();

    long userLastVisitedTime = SkinUtils.getLastVisited(request,response);
%>

<%	//////////////////////
	// Header file include

	// The header file looks for the variable "title"
	String title = " Forums: Example Skin";
%>
<%@ include file="header.jsp" %>
<%
    if(!user.isAnonymous()){
        int Wforum= ParamUtils.getIntParameter(request,"forumID",-1);
        boolean WChange = ParamUtils.getBooleanParameter(request,"W");
        if(Wforum > 0){
            user.setProperty("WatchForum"+Integer.toString(Wforum),Boolean.toString(WChange));
        }
    }
%>
<%	////////////////////
	// Breadcrumb bar

	// The breadcrumb file looks for the variable "breadcrumbs" which
	// represents a navigational path, ie "Home > My Forum > Hello World"
	String[][] breadcrumbs = {
		{ YazdLocale.getLocaleKey("Home",locale), "" }
	};
%>
<%@ include file="breadcrumb.jsp" %>


<%	/////////////
	// Toolbar

	// The toolbar file looks for the following variables. To make a particular
	// "button" not appear, set a variable to null.
	boolean showToolbar = true;
	String viewLink = null;
	String postLink = null;
	String replyLink = null;
	String searchLink = null;
	// we can show a link to a user account if the user is logged in (handled
	// in the toolbar jsp)
	String accountLink = "userAccount.jsp";
%>
<%@ include file="toolbar.jsp" %>


<%	////////////////////////////////////////////////////
	// customize which forums are displayed on this page

	// There are two ways to decide which forums get diplayed to the user
	//
	//	1.	Display a list of all forums the current user has permission to
	//		view. For instance, if there are 4 forums in the system and
	//		a "guest" has authorization to view 2 of them, then just those
	//		two forums will be displayed. This works the same way for
	//		registered users -- they'll only see the forums they have
	//		access to.
	//
	//	2.	Specify by name which forums to display. Again, if there are
	//		4 forums in the system and you specify all forums by name and
	//		the skin user has access to only 2 of them, then only 2 forums
	//		will be displayed

	// Set the following boolean variable to "false" to display a list
	// of forums in the system (case 1) or set it to "true" to specify
	// a list of forums by name (case 2)

	boolean loadForumsByName = false;
	String BLANK = "&nbsp;";

	// If you choose to load forums by name, specify the names by
	// adding them to the following list of forum names:

	ArrayList forumNames = new ArrayList(0);
	if( loadForumsByName ) {
		forumNames.add( "First Forum" );
		forumNames.add( "Another Forum" );
	}
%>

<br>


<%	/////////////////////
	// check for messages

	// we might come to this page from another page and that page might
	// pass us a message. If so, grab it and display it (also remove it from persistence)
	String message = SkinUtils.retrieve(request,response,"message",true);
	if( message != null ) {
%>
	<h4><i><%= message %></i></h4>
	<p>
<%	} %>

<%	// print out a greeting to a registered user.

	if( !user.isAnonymous() ) { %>

	<%=YazdLocale.getLocaleKey("Welcome_back",locale)%>, <%= user.getName() %>!
	(<%=YazdLocale.getLocaleKey("If_youre_not",locale)%> <%= user.getName() %>, <a href="index.jsp?logout=true"><%=YazdLocale.getLocaleKey("Click_here",locale)%></a>.)

<%	} %>

<p>
<%--Page partition for the recent messages--%>
<table width="100%"><tr><td width="99%" valign="top">

<%
    Iterator categoryIterator = forumFactory.categories();
    if (!categoryIterator.hasNext()) {
%>
			<br><br><span class="error">
				<%=YazdLocale.getLocaleKey("No_categories_in_the_system",locale)%>
            </span><br>

<%
    }
    while(categoryIterator.hasNext()){
     Category category = (Category)categoryIterator.next();
     String categoryName = category.getName();
     Iterator forumGroupIterator = category.forumGroups();

        if (!forumGroupIterator.hasNext()) {
           continue;
        }//if

%>



<%
    boolean showheading = true;
    boolean showfooting = false; // we flip it after we show the heading
     while(forumGroupIterator.hasNext()){
         ForumGroup forumGroup = (ForumGroup)forumGroupIterator.next();
         String groupName = forumGroup.getName();

	// The iterator we use to loop through forums
         Iterator forumIterator = forumGroup.forums();
%>

<%	/////////////////////
	// loop through forums, display forum info:
	if( !forumIterator.hasNext() ) {
        categoryName = BLANK;
        groupName = BLANK;
        continue;
     }//if
%>

<%
	boolean forumLoaded = false;
    boolean showgroup = true;
    while( forumIterator.hasNext() ) {
		Forum forum;
		// since loading a forum could throw an unauthorized exception, we
		// should catch it so we can skip this forum and try to load another
		// forum
		try {
			if( loadForumsByName ) {
				forum = forumFactory.getForum( (String)forumIterator.next() );
			}
			else {
				forum = (Forum)forumIterator.next();
			}
			forumLoaded = true;
            int forumID = forum.getID();
			String forumName = forum.getName();
			String forumDescription = forum.getDescription();
			int threadCount = forum.getThreadCount();
			int messageCount = forum.getMessageCount();
			Date creationDate = forum.getCreationDate();
			Date modifiedDate = forum.getModifiedDate();
			boolean wasModified = (userLastVisitedTime < modifiedDate.getTime());
            boolean beingWatched = false;
            if (!user.isAnonymous()&&
                    user.getProperty("WatchForum"+Integer.toString(forumID))!=null){
                beingWatched = Boolean.valueOf(user.getProperty("WatchForum"+Integer.toString(forumID))).booleanValue();
            }
%>
    <%
        if (showheading){
            showheading = false;
            showfooting = true;
    %>
<p>
<h2><%= category.getName() %></h2>
<p>
<table bgcolor="<%= forumTableBgcolor %>" cellpadding="0" cellspacing="0" border="0" width="100%">
<td>
<table bgcolor="<%= forumTableBgcolor %>" cellpadding="4" cellspacing="1" border="0" width="100%">

<tr bgcolor="<%= forumTableHeaderFgcolor %>">
	<td align="center" width="1%">
		<small><%=YazdLocale.getLocaleKey("New_posts",locale)%></small>
	</td>
	<td align="center" width="10%" nowrap>
		<small><%=YazdLocale.getLocaleKey("Forum_name",locale)%></small>
	</td>
	<td align="center" width="48%">
		<small><%=YazdLocale.getLocaleKey("Description",locale)%></small>
	</td>
    <% if(!user.isAnonymous()){%>
	<td align="center" width="10%">
		<small><!-- watch column --></small>
	</td>
    <%}%>
	<td align="center" width="10%">
		<small><%=YazdLocale.getLocaleKey("Topics",locale)%></small>
	</td>
	<td align="center" width="10%">
		<small><%=YazdLocale.getLocaleKey("Messages",locale)%></small>
	</td>
	<td align="center" width="1%" nowrap>
		<small><%=YazdLocale.getLocaleKey("Last_updated",locale)%></small>
	</td>
</tr>
    <%
        }
    %>
    <%
        if (showgroup){
            showgroup = false;
    %>
<tr bgcolor="<%=forumTableGroupBgcolor%>">
	<td align="left" width="100%" colspan="<%=user.isAnonymous()?"6":"7"%>" class="group">
        	<%=groupName%>

</td>
    <%
        }
    %>
</tr>
	<tr bgcolor="<%= forumTableFgcolor %>">
		<td align="center"><img src="images/<%= (wasModified)?"bang":"blank" %>.gif" width="8" height="8" border="0"></td>
		<td nowrap><a href="viewForum.jsp?forum=<%= forumID %>" class="forum"><%= forumName %></a></td>
		<td><i><%= (forumDescription!=null)?forumDescription:"&nbsp;" %></i> <span class=userInfo><%=beingWatched?"("+YazdLocale.getLocaleKey("You_are_watching_this_forum",locale)+")":""%></span></td>
        <% if(!user.isAnonymous()){%>
		<td align="center" nowrap class="userInfo"><a href="index.jsp?forumID=<%=forumID%>&W=<%=beingWatched?"false":"true"%>"><%=beingWatched?"<img border=\"0\" src=\"images/stopwatch.gif\" alt=\""+YazdLocale.getLocaleKey("Stop_watch_this_forum",locale)+"\">":"<img border=\"0\" src=\"images/startwatch.gif\" alt=\""+YazdLocale.getLocaleKey("Watch_this_forum",locale)+"\">"%></a></td>
        <%}%>
		<td align="center" nowrap><%= threadCount %> </td>
		<td align="center" nowrap> <%= messageCount %></td>
		<td nowrap align="right"><small class="date"><%= SkinUtils.dateToText(modifiedDate,locale,timezone) %></small></td>
	</tr>
<%		} catch( UnauthorizedException ignored ) {
		}
        categoryName = BLANK;
        groupName = BLANK;
     }//while forumIterator
    }//while forumGroupIterator
%>
    <% if(showfooting){%>
        </table>
        </td>
        </table>
    <%}%>

<%
  }//while categoryIterator
%>
</td>
<td width="1%" valign="top">
    <table width="100%" border=0><tr><td>
<%-- recent dicussions --%>
		    <jsp:include page="recentMessages.jsp" flush="true"/>
<%-- end recent dicussions --%>
    </td></tr>
        <tr>
            <td><jsp:include page="sessionlist.html" flush="true"/></td>
        </tr>
    </table>
</td>
</tr></table>
<p>

<%	/////////////////////
	// page footer
%>
<%@ include file="footer.jsp" %>

