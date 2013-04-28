
<%
/**
 *	$RCSfile: viewForum.jsp,v $
 *	$Revision: 1.6 $
 *	$Date: 2004/12/21 02:22:53 $
 */
%>
<%@	page import="java.util.*,
                 java.text.*,
                 java.net.*,
                 com.Yasna.forum.*,
                 com.Yasna.forum.util.*,com.Yasna.forum.locale.YazdLocale"
	errorPage="error.jsp"
%>
<%@ page import="com.Yasna.util.StringUtils" %>
<%@ page import="java.util.regex.Pattern" %>

<%!	//////////////////////////////////
	// customize the look of this page

	// Colors of the table that displays a list of forums
	final static String threadTableBgcolor = "#bbbbbb";
	final static String threadTableFgcolor = "#ffffff";
	final static String threadTableHeaderFgcolor = "#eeeeee";
	final static String threadTableHiLiteColor = "#eeeeff";
	final static String threadPagingRowColor = "#dddddd";

	boolean isSystemAdmin = false;
	boolean isUserAdmin   = false;
	boolean isModerator   = false;
    boolean isAdmin       = false;
%>

<%!	///////////////////
	// global variables

	// number of threads to display per page:
	private final int[] threadRange = { 15,25,50,100 };

	// default starting index and number of threads to display
	// per page (for paging)
	private final int DEFAULT_RANGE = 15;
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
    int sortBy = 0;
    String sortByStr = request.getParameter("sortBy");
    if (sortByStr != null) {
        if ("creationDate".equals(sortByStr)) {
            sortBy = 0;
        } else if ("modifiedDate".equals(sortByStr)) {
            sortBy = 1;
        }
    } else {
        sortByStr = "creationDate";
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

	ForumPermissions permissions = forumFactory.getPermissions(authToken);
	isSystemAdmin = permissions.get(ForumPermissions.SYSTEM_ADMIN);
	isUserAdmin   = permissions.get(ForumPermissions.FORUM_ADMIN);

%>

<%	//////////////////////
	// get parameters
	int range    = ParamUtils.getIntParameter(request,"range",DEFAULT_RANGE);
	int start    = ParamUtils.getIntParameter(request,"start",0);
	int forumID  = ParamUtils.getIntParameter(request,"forum",-1);
    int watchThread =ParamUtils.getIntParameter(request,"thread",-1);
    boolean watch = ParamUtils.getBooleanParameter(request,"watch");
    if(user.getID() > 1 && watchThread > 1){
        user.setProperty("WatchThread"+watchThread,watch?"true":"false");
    }
%>

<%	////////////////////
	// Load up the forum

	// If the forum is not found, a ForumNotFoundException will be thrown
	// and the user will be redirected to the error page
    Forum forum = null;
    try {
	    forum = forumFactory.getForum(forumID);
        if(forum.isArticleForum()){
            throw new Exception();
        }
    } catch (Exception e) {
        response.sendRedirect( "error.jsp?msg=" + URLEncoder.encode(YazdLocale.getLocaleKey("Unable_to_load_forum_with_id",locale)+" " + forumID) );
    }

	isModerator   = false;
    if (forum != null) {
        isModerator   = forum.getPermissions(authToken).get(ForumPermissions.MODERATOR);
    }
    isAdmin = (isModerator || isSystemAdmin || isUserAdmin);

    //check if post back
    if (isAdmin) {
        Enumeration en = request.getParameterNames();
        while (en.hasMoreElements()) {
            String p = (String) en.nextElement();
            if (p.startsWith("approve_")) {
                try {
                    String idStr = p.substring(8, p.indexOf("."));
                    int id = Integer.parseInt(idStr);
                    forum.getThread(id).setApprovment(true);
                    break;
                } catch(Exception e) {
                    response.sendRedirect( "error.jsp?msg=" + URLEncoder.encode(YazdLocale.getLocaleKey("Unable_to_complete_approve_operation_due_to_following_error",locale)+": " + e.getMessage()) );
                }
            } else if (p.startsWith("delete_")) {
                try {
                    String idStr = p.substring(7, p.indexOf("."));
                    int id = Integer.parseInt(idStr);
                    ForumThread toDelete = forum.getThread(id);
                    forum.deleteThread(toDelete);
                    break;
                } catch(Exception e) {
                    response.sendRedirect( "error.jsp?msg=" + URLEncoder.encode(YazdLocale.getLocaleKey("Unable_to_complete_delete_operation_due_to_following_error",locale)+": " + e.getMessage()) );
                }
            }
        }
    }//if

	// Get some properties of the forum
	String forumName  = forum.getName();
	int numThreads    = forum.getThreadCount();
	int numMessages   = forum.getMessageCount();
%>

<%	//////////////////////
	// Header file include

	// The header file looks for the variable "title"
	String title = "Yazd Forums: " + forumName;
%>
<%@ include file="header.jsp" %>


<%	////////////////////
	// Breadcrumb bar

	// The breadcrumb file looks for the variable "breadcrumbs" which
	// represents a navigational path, ie "Home > My Forum > Hello World"
	String[][] breadcrumbs = {
		{ YazdLocale.getLocaleKey("Home",locale), "index.jsp" },
		{ forumName, "" }
	};
%>
<%@ include file="breadcrumb.jsp" %>


<%	/////////////
	// Toolbar

	// The toolbar file looks for the following variables. To make a particular
	// "button" not appear, set a variable to null.
	boolean showToolbar = true;
	String viewLink = null;
	String postLink = "post.jsp?mode=new&forum="+forumID;
	String replyLink = null;
	String searchLink = "search.jsp?forum="+forumID;
	// we can show a link to a user account if the user is logged in (handled
	// in the toolbar jsp)
	String accountLink = "userAccount.jsp";
%>
<%@ include file="toolbar.jsp" %>

<p>

<h2>
<%= forumName %>
</h2>
<center> <%=forum.getProperty("header")!=null?forum.getProperty("header"):""%></center>
<h4>
<%=YazdLocale.getLocaleKey("Topics",locale)%>: <%= numThreads %>, <%=YazdLocale.getLocaleKey("Messages",locale)%>: <%= numMessages %>
</h4>
<form action="viewForum.jsp" method="get" id="form1">

<%-- table for list of threads --%>
<table bgcolor="<%= threadTableBgcolor %>" cellpadding="0" cellspacing="0" border="0" width="100%">
<td><table bgcolor="<%= threadTableBgcolor %>" cellpadding="4" cellspacing="1" border="0" width="100%">
	<%-- paging row --%>
	<tr bgcolor="<%= threadPagingRowColor %>">
		<td colspan="<%=isAdmin?"8":"7"%>" width="99%">
		<%-- table for paging --%>
		<table cellpadding="0" cellspacing="0" border="0" width="100%">
			<td width="1%" nowrap>
			<%	if( start > 0 ) { %>
				<small>
				<a href="viewForum.jsp?forum=<%=forumID%>&start=<%= (start-range) %>&range=<%= range %>"
				><img src="images/prev.gif" width="14" height="15" border="0"></a>
				<a href="viewForum.jsp?forum=<%=forumID%>&start=<%= (start-range) %>&range=<%= range %>" class="toolbar"
				><%=YazdLocale.getLocaleKey("Previous",locale)%> <%= range %> <%=YazdLocale.getLocaleKey("Threads",locale)%></a>
				<small>
			<%	} %>
				&nbsp;
			</td>
			<td width="98%" align="center">
				<a href="post.jsp?forum=<%=forumID%>"
				><img src="images/postnewmsg.gif" width="97" height="15" alt="Post a new topic" border="0"></a>
			</td>
			<td width="1%" nowrap>
				&nbsp;
			<%	if( numThreads > (start+range) ) { %>
			<%		int numRemaining = (numThreads-(start+range)); %>
				<small>
				<a href="viewForum.jsp?forum=<%=forumID%>&start=<%= (start+range) %>&range=<%= range %>" class="toolbar"
				><%=YazdLocale.getLocaleKey("Next",locale)%> <%= (numRemaining>range)?range:numRemaining %> <%=YazdLocale.getLocaleKey("Threads",locale)%></a>
				<a href="viewForum.jsp?forum=<%=forumID%>&start=<%= (start+range) %>&range=<%= range %>"
				><img src="images/next.gif" width="14" height="15" border="0"></a>
				</small>
			<%	} %>
			</td>
		</table>
		<%-- /table for paging --%>
		</td>
	</tr>
	<%-- /paging row --%>
	<tr bgcolor="<%= threadTableHeaderFgcolor %>">
		<td width="1%" nowrap><small><%=YazdLocale.getLocaleKey("New",locale)%></small></td>
        <td width="1%" nowrap><small><%=YazdLocale.getLocaleKey("Type",locale)%></small></td>
<%
        if (isAdmin) {
%>
		<td width="85%" align="center"><small><%=YazdLocale.getLocaleKey("Subject",locale)%></small></td>
		<td width="10%" align="center"><small><%=YazdLocale.getLocaleKey("Admin",locale)%></small></td>
<%
        } else {
%>
		<td width="95%" align="center"><small><%=YazdLocale.getLocaleKey("Subject",locale)%></small></td>
<%      } %>
		<td width="1%" nowrap align="center"><small><%=YazdLocale.getLocaleKey("Replies",locale)%></small></td>
		<td width="1%" nowrap align="center"><small><%=YazdLocale.getLocaleKey("Viewed",locale)%></small></td>
		<td width="1%" nowrap align="center"><small><%=YazdLocale.getLocaleKey("Posted_by",locale)%></small></td>
		<td width="1%" nowrap align="center">
        <%=YazdLocale.getLocaleKey("Sort_by",locale)%>:&nbsp;
        <select name="sortBy" onchange="javascript: document.getElementById('form1').submit();">
            <option value="creationDate" <%= (sortBy == Forum.SORT_BY_CREATE_DATE) ? "selected='true'":""%>><%=YazdLocale.getLocaleKey("Creation_date",locale)%></option>
            <option value="modifiedDate" <%= (sortBy == Forum.SORT_BY_MODIFIED_DATE) ? "selected='true'":""%>><%=YazdLocale.getLocaleKey("Last_modified",locale)%></option>
        </select>
        </td>
	</tr>

<%	/////////////////////
	// get an iterator of threads
	Iterator threadIterator = forum.threads(start,range,sortBy);//, sortBy

	if( !threadIterator.hasNext() ) {
%>
	<tr bgcolor="<%= threadTableFgcolor %>">
		<td colspan="6" align="center" class="forumListCell">
		<br>
		<i>
		<%=YazdLocale.getLocaleKey("No_topics_in_this_forum",locale)%>. <a href="post.jsp?mode=new&forum=<%=forumID%>"><%=YazdLocale.getLocaleKey("Click_here_to_add_your_own",locale)%></a>.
		</i>
		<br><br>
		</td>
	</tr>
<% }
    while (threadIterator.hasNext()) {
        ForumThread thread = (ForumThread) threadIterator.next();
        int threadID = thread.getID();
        ForumMessage rootMessage = thread.getRootMessage();
        String threadName = rootMessage.getSubject();
        String threadText = StringUtils.replace(StringUtils.chopAtWord(rootMessage.getBody(), 200), "\"", "&#34;");
        threadText = Pattern.compile("\\<((\\s|.)*?)\\>", Pattern.CASE_INSENSITIVE).matcher(threadText).replaceAll("");
        if (threadName == null) {
            threadName = "<i>" + YazdLocale.getLocaleKey("No_subject", locale) + "</i>";
        }
        boolean rootMsgIsAnonymous = rootMessage.isAnonymous();
        User rootMessageUser = rootMessage.getUser();
        String username = rootMessageUser.getUsername();
        String name = rootMessageUser.getName();
        String email = rootMessageUser.getEmail();
        Date lastModified = thread.getModifiedDate();
        boolean wasModified = (userLastVisitedTime < lastModified.getTime());
%>
    <script language="javascript">
        var imgOver
        var imgOut;
        if (document.images) {
            imgOver = new Image();
            imgOver.src = "images/not_approved_violet.gif";
            imgOut = new Image();
            imgOut.src = "images/not_approved_white.gif";
        }

        function mouseOver(id) {
            if (document.images) {
                var obj = document.getElementById("img" + id);
                if (obj) {
                    obj.src = imgOver.src;
                }
            }
        }

        function mouseOut(id) {
            if (document.images) {
                var obj = document.getElementById("img" + id);
                if (obj) {
                    obj.src = imgOut.src;
                }
            }
        }

    </script>
	<tr bgcolor="<%= threadTableFgcolor %>">
		<td width="1%" align="center"><img src="images/<%= (wasModified)?"bang":"blank" %>.gif" width="8" height="8" border="0"></td>
        <td width="1%" align="center"><img src="images/<%
        switch(thread.getThreadType().getID()){
            case 0: out.print("blank");break;
            case 1: out.print("question");break;
            case 2: out.print("comment");break;
            case 3: out.print("announce");break;
            default:out.print("blank");break;
        }
        %>.gif" width="10" height="10" border="0"></td>
		<td onmouseover="this.bgColor='<%= threadTableHiLiteColor %>';this.style.cursor='hand';mouseOver(<%= threadID %>);" onmouseout="this.bgColor='#ffffff';mouseOut(<%= threadID %>);" onclick="location.href='viewThread.jsp?forum=<%= forumID %>&thread=<%= threadID %>'" title="<%=threadText%>">
			<%if(thread.isSticky()){%><img src="images/yazd_stick.gif" width="19" height="19" alt="Sticky"> <%}%><%if(thread.isClosed()){%><img src="images/yazd_lock.gif" width="19" height="19" alt="Closed"> <%}%><a href="viewThread.jsp?forum=<%= forumID %>&thread=<%= threadID %>" class="forum" alt="<%=threadText%>"><%= threadName %></a>
<%
        if (!thread.isApproved()) {
%>
<img id="img<%= threadID %>" src="images/not_approved_white.gif" width=103 height=13 border="0" align='center'/>
<%
            }
%>
            <%
                if(user.getID() > 1 ){
                    String userprop=  user.getProperty("WatchThread"+threadID);
                    if(userprop!=null && userprop.equals("true")){
            %>
            <a href="viewForum.jsp?forum=<%=forumID%>&start=<%= start %>&range=<%= range %>&thread=<%=threadID%>&watch=false"><img border="0" src="images/stopwatch.gif" alt="Stop Watching Thread"></a>
            <%
                    }else{
                    %>
            <a href="viewForum.jsp?forum=<%=forumID%>&start=<%= start %>&range=<%= range %>&thread=<%=threadID%>&watch=true"><img border="0" src="images/startwatch.gif" alt="Start Watching Thread"></a>
            <%
                    }
                }
            %>
        </td>
<%
        if (isAdmin) {
%>
            <td><input type="image" name="delete_<%= threadID %>" src="images/delete_gray.gif" width=60 height=19 border="0" alt="Delete thread" /><%
            if (!thread.isApproved()) {
%>&nbsp;<input type="image" name="approve_<%= threadID %>" src="images/approve_gray.gif" width=72 height=19 border="0" alt="Approve thread" />
<%
            }
%></td><%
        }
%>		<td width="1%" nowrap align="center">
			<%= (thread.getMessageCount()-1) %>
		</td>
		<td width="1%" nowrap align="center">
			<%= (thread.getReadCount()) %>
		</td>
		<td width="1%" nowrap align="center">
		<%	if( rootMsgIsAnonymous ) {
				String savedName = rootMessage.getProperty("name");
				String savedEmail = rootMessage.getProperty("email");
				String displayName = "<i>"+YazdLocale.getLocaleKey("Anonymous",locale)+"</i>";
				if( savedName != null ) {
					displayName = "<i>" + savedName + "</i>";
				}
				if( savedEmail != null ) {
					displayName = "<a href=\"mailto:" + savedEmail + "\">" + displayName + "</a>";
				}
		%>
		    <%= displayName %>
		<%	} else {
				boolean emailReadable = rootMessageUser.isEmailVisible();
				String displayName = username;
					displayName = "<a href=\"userDetail.jsp?user=" + displayName + "&forum="+forumID+"\">" + displayName + "</a>";
		%>
		    <b><%= displayName %></b>
		<%	} %>
	    </td>
		<td width="1%" nowrap align="right">
			<small class="date">
            <%
                Date date = null;
                switch (sortBy) {
                    case Forum.SORT_BY_CREATE_DATE: date = thread.getCreationDate();break;
                    case Forum.SORT_BY_MODIFIED_DATE: date = thread.getModifiedDate();break;
                    default: date = rootMessage.getCreationDate();
                }
                out.print(SkinUtils.dateToText( date ,locale,timezone));
            %></small>
		</td>
	</tr>
<%	} %>

<%-- paging row --%>
<tr bgcolor="<%= threadPagingRowColor %>">
	<td class="forumListHeader" colspan="<%=(isAdmin?"8":"7")%>" width="99%">
	<%-- table for paging --%>
	<table cellpadding="0" cellspacing="0" border="0" width="100%">
		<td width="1%" nowrap>
		<%	if( start > 0 ) { %>
			<small>
			<a href="viewForum.jsp?forum=<%=forumID%>&start=<%= (start-range) %>&range=<%= range %>"
			><img src="images/prev.gif" width="14" height="15" border="0"></a>
			<a href="viewForum.jsp?forum=<%=forumID%>&start=<%= (start-range) %>&range=<%= range %>" class="toolbar"
			><%=YazdLocale.getLocaleKey("Previous",locale)%> <%= range %> <%=YazdLocale.getLocaleKey("Threads",locale)%></a>
			<small>
		<%	} %>
		&nbsp;
		</td>
		<td width="98%" align="center"></td>
		<td width="1%" nowrap>
		&nbsp;
		<%	if( numThreads > (start+range) ) { %>
		<%		int numRemaining = (numThreads-(start+range)); %>
			<small>
			<a href="viewForum.jsp?forum=<%=forumID%>&start=<%= (start+range) %>&range=<%= range %>" class="toolbar"
			><%=YazdLocale.getLocaleKey("Next",locale)%> <%= (numRemaining>range)?range:numRemaining %> <%=YazdLocale.getLocaleKey("Threads",locale)%></a>
			<a href="viewForum.jsp?forum=<%=forumID%>&start=<%= (start+range) %>&range=<%= range %>"
			><img src="images/next.gif" width="14" height="15" border="0"></a>
			</small>
		<%	} %>
		</td>
	</table>
	<%-- /table for paging --%>
	</td>
</tr>
<%-- /paging row --%>

</table>
</td>
</table>

<p>

<%-- range options --%>
	<input type="hidden" name="forum" value="<%= forumID %>">
	<%=YazdLocale.getLocaleKey("Show_me",locale)%>
	<select size="1" name="range" class="pulldown" onchange="location.href='viewForum.jsp?forum=<%=forumID%>&range='+this.options[this.options.selectedIndex].value;">
<%	// loop through the array of ranges
	for( int i=0; i<threadRange.length; i++ ) {
		// Indicate which range is currently selected
		String selected = "";
		if( threadRange[i] == range ) {
			selected = " selected";
		}
%>
	<option value="<%= threadRange[i] %>"<%= selected %>><%= threadRange[i] %>
<%	} %>
	</select>
	<%=YazdLocale.getLocaleKey("Messages_per_page",locale)%>.
	<noscript>
	<input type="submit" value="Save">
	</noscript>
</form>
<%-- /range options --%>
<center> <%=forum.getProperty("footer")!=null?forum.getProperty("footer"):""%></center>
<br>

<%	/////////////////////
	// page footer
%>
<%@ include file="footer.jsp" %>


