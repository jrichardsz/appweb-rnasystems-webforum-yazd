
<%
/**
 *	$RCSfile: userDetail.jsp,v $
 *	$Revision: 1.3 $
 *	$Date: 2004/12/21 02:22:53 $
 */
%>

<%@	page import="java.util.*,
                 java.text.*,
                 com.Yasna.forum.*,
                 com.Yasna.forum.util.*,com.Yasna.forum.locale.YazdLocale"

%>

<%!	////////////////
	// global variables

	// date formatter
	SimpleDateFormat dateFormatter
		= new SimpleDateFormat("EEE, MMM d 'at' hh:mm:ss z");

	// number of threads to display per page array:
	private final int[] threadRange = { 10,25,50,100 };

	// default starting index and number of threads to display
	// per page (for paging)
	private final int DEFAULT_RANGE = 10;
	private final int START_INDEX   = 0;
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
	// get parameters
	int range    = ParamUtils.getIntParameter(request,"range",DEFAULT_RANGE);
	int start    = ParamUtils.getIntParameter(request,"start",0);
	String usrname = ParamUtils.getParameter(request,"user");
	int forumID  = ParamUtils.getIntParameter(request,"forum",-1);
%>

<%	//////////////////////
	// page error variables
	boolean invalidUser = (usrname == null);
	boolean userNotFound = false;
	User InterestedUser = null;

	try{
		InterestedUser = forumFactory.getProfileManager().getUser(usrname);
	} catch(UserNotFoundException e){
		userNotFound=true;
	}		
	// we check to make sure that the user is not null and also
	// not the administrator.
	if (InterestedUser == null || InterestedUser.getID()==1){
		invalidUser=true;
	}

	String errorMessage = "";

	boolean invalidForum = (forumID < 0);
	boolean notAuthorizedToViewUser = false;
%>

<%	//////////////////////////
	// try loading up user (exceptions may be thrown)
	ProfileManager manager = forumFactory.getProfileManager();
	// try to load up the forum (optional paramter)
	Forum forum = null;
	if( !invalidForum ) {
		try {
			forum = forumFactory.getForum(forumID);
		}
		catch( UnauthorizedException ue ) {
			invalidForum = true;
		}
		catch( ForumNotFoundException fnfe ) {
			invalidForum = true;
		}
	}
%>

<%	/////////////////////
	// global error check
	boolean errors = (invalidUser || notAuthorizedToViewUser || userNotFound
		|| (user==null) );
%>

<%	/////////////////////
	// check for errors
	if( errors ) {
		if( invalidUser ) {
			errorMessage = YazdLocale.getLocaleKey("No_user_specified_or_invalid_user_id",locale);
		}
		else if( notAuthorizedToViewUser ) {
			errorMessage = YazdLocale.getLocaleKey("No_permission_to_view_this_user",locale);
		}
		else if( userNotFound ) {
			errorMessage = YazdLocale.getLocaleKey("Requested_user_was_not_found_in_the_system",locale);
		}
		else {
			errorMessage = YazdLocale.getLocaleKey("General_error_occured",locale);
		}
		//request.setAttribute("msg",errorMessage);
		response.sendRedirect("error.jsp?msg="+errorMessage);
		return;
	}
%>

<%	//////////////////////
	// get user properties (assumed no errors at this point)

	int userID = user.getID();
	String email = null;
	String name = null;
	email = user.getEmail();
	name = user.getName();
	boolean isAnonymous = user.isAnonymous();
	boolean isEmailVisible = user.isEmailVisible();
	boolean isNameVisible = user.isNameVisible();
	int userMessageCount = 0;
	Iterator userMessageIterator = null;
	if( !invalidForum ) {
		userMessageCount = manager.userMessageCount(InterestedUser,forum);
		userMessageIterator = manager.userMessages(InterestedUser,forum,0,15);
	}

	// forum properties
	String forumName = null;
	if( !invalidForum ) {
		forumName = forum.getName();
	}
%>

<%	/////////////////////
	// page title
	String title = "Yazd Forums: " + forumName;
%>
<%	/////////////////////
	// page header
%>
<%@ include file="header.jsp" %>


<%	////////////////////
	// breadcrumb array & include
	String[][] breadcrumbs = null;
	if( !invalidForum ) {
		breadcrumbs = new String[][] {
			{ YazdLocale.getLocaleKey("Home",locale), "index.jsp" },
			{ ("Forum: "+forumName), ("viewForum.jsp?forum="+forumID) },
			{ YazdLocale.getLocaleKey("User_detail",locale)+": " +InterestedUser.getUsername(), "" }
		};
	}
	else {
		breadcrumbs = new String[][] {
			{ YazdLocale.getLocaleKey("Home",locale), "index.jsp" },
			{ YazdLocale.getLocaleKey("User_detail",locale)+": " +InterestedUser.getUsername(), "" }
		};
	}
%>
<%@ include file="breadcrumb.jsp" %>


<%	///////////////////
	// toolbar variables
	boolean showToolbar = true;
	String viewLink = null;
	if( !invalidForum ) {
		viewLink = "viewForum.jsp?forum="+forumID;
	}
	String postLink = null;
	if( !invalidForum ) {
		postLink = "post.jsp?mode=new&forum="+forumID;
	}
	String replyLink = null;
	String accountLink = "userAccount.jsp";
	String searchLink = "search.jsp?forum="+forumID;
%>
<%@ include file="toolbar.jsp" %>

<p>

<span class="viewForumHeader">
	<%= YazdLocale.getLocaleKey("User_detail_for",locale)+": "+InterestedUser.getUsername() %>
</span>
<br>
<%	if( !invalidForum ) { %>
	<span class="viewForumDeck">
	<%	if( InterestedUser.isEmailVisible() ) { %>
		<%= YazdLocale.getLocaleKey("Email",locale)%>: <a href="mailto:<%= InterestedUser.getEmail() %>"><%= InterestedUser.getEmail() %></a>
		<br>
	<%	} %>
	<%= YazdLocale.getLocaleKey("Number_of_messages_posted_in_this_forum",locale)%>: <%= userMessageCount %>
	</span>
<%	} %>

<p>

<b><%= (userMessageCount > 15 ? "15":Integer.toString(userMessageCount))%> <%= YazdLocale.getLocaleKey("Recent_messages_posted_by_the_user_in_this_forum",locale)%>: <%= userMessageCount %>:</b>
<p>

<%-- show list of messages posted by this user --%>
<table bgcolor="#cccccc" cellpadding="0" cellspacing="0" border="0" width="95%" align="right">
<td>
<table bgcolor="#cccccc" cellpadding="3" cellspacing="1" border="0" width="100%">
<tr bgcolor="#eeeeee">
	<td class="forumListHeader" width="99%"><%= YazdLocale.getLocaleKey("Subject",locale)%></td>
	<td class="forumListHeader" width="1%" nowrap><%= YazdLocale.getLocaleKey("Post_date",locale)%></td>
</tr>
<%	if( !userMessageIterator.hasNext() ) { %>
<tr bgcolor="#ffffff">
	<td align="center" colspan="2"><i><%= YazdLocale.getLocaleKey("No_messages_posted_by",locale)%> <b><%= InterestedUser.getUsername() %></b> <%= YazdLocale.getLocaleKey("In_this_forum",locale)%>.</i></td>
</tr>
<%	} %>

<%	while( userMessageIterator.hasNext() ) { %>
<%		ForumMessage message = (ForumMessage)userMessageIterator.next();
		String subject = message.getSubject();
		Date creationDate = message.getCreationDate();
		ForumThread thread = message.getForumThread();
%>
<tr bgcolor="#ffffff">
	<td class="forumListCell">
		<a href="viewThread.jsp?forum=<%=forumID%>&thread=<%=thread.getID()%>"
		 ><%= subject %></a>
	</td>
	<td nowrap class="forumListDateCell" align="center"><%= SkinUtils.dateToText(creationDate,locale,timezone) %></td>
</tr>
<%	} %>
</table>
</td>
</table>
<br clear="all"><br>
<%-- /show list of messages posted by this user --%>

<%	/////////////////////
	// page footer
%>
<%@ include file="footer.jsp" %>


