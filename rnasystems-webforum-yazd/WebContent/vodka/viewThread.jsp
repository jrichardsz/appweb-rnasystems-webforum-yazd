<%@	page import="java.io.*,
                 java.util.*,
                 java.text.*,
                 java.net.*,
                 com.Yasna.forum.*,
                 com.Yasna.forum.util.*,com.Yasna.forum.locale.YazdLocale"
	errorPage="error.jsp"
%>

<%!	////////////////
	// global variables
	boolean isSystemAdmin = false;
	boolean isUserAdmin   = false;
	boolean isModerator   = false;
    boolean isAdmin       = false;
    boolean readText      = false;
    boolean isPrivate     = false;
    boolean isApproved    = false;
    boolean isRootUser    = false;
    	boolean sameColor    = false;
    String seperatorColor = "777777";
	int	tableColor = 250;
	SimpleDateFormat dateFormatter;

	/**
	 * Print a child message
	 */
	private String printChildMessage( Forum forum, ForumThread thread, ForumMessage message, int tindentation, String mode, Authorization authToken ,Locale locale,TimeZone timezone,ForumFactory forumFactory)
	{
        String threadLink = "viewThread.jsp?forum="+forum.getID()+"&thread="+thread.getID();
        StringBuffer buf = new StringBuffer();
		int tcolor = tableColor;
        int indentation = tindentation;
		try {
		if( mode.equals("flat") ) {
			indentation = 0;
		}
		if( !sameColor) {
			tcolor = tcolor + (8*tindentation);
			if (tcolor > 240 ){
				/* this shouldn't happen, but accomodates for the case that there are too many messages */
				tcolor = 250;
			}
		}
		String subject = message.getSubject();
		boolean msgIsAnonymous = message.isAnonymous();
        User author = message.getUser();
        String authorName = author.getName();
        String authorEmail = author.getEmail();
        String userName = author.getUsername();
        String userColour = author.getProperty("colour");
        String userCity = author.getProperty("city");
        String userCountry = author.getProperty("country");
        String userGender = author.getProperty("gender");
        String userIP = author.getProperty("IP");
        String userSig = author.getProperty("sig");
        String userURL = author.getProperty("URL");
        String userRanking = author.getProperty("ranking");
        String avatar = author.getProperty("avatar");
        String nickname = author.getProperty("ssnickname");

        int userID = author.getID();
        Calendar lastlogin = author.getLastLogin();
        int forumID = forum.getID();
        int threadID = thread.getID();
        int messageID = message.getID();
        Date creationDate = message.getCreationDate();
		String msgBody = getMessageBody(message, authToken,locale);
		buf.append("<tr bgcolor=\"#");
		buf.append((userColour!=null && !userColour.equals("") && userColour.length()==6)?userColour: Integer.toHexString(tcolor) + Integer.toHexString(tcolor) + Integer.toHexString(tcolor));
        buf.append("\">");
        // new changes
		buf.append("<td nowrap valign=\"top\">");
        buf.append("<table><tr><td><span class=\"messageAuthor\">");
        if( msgIsAnonymous ) {
            String savedName = message.getProperty("name");
            String savedEmail = message.getProperty("email");
            userIP = message.getProperty("IP");
            if( savedEmail != null && savedName != null ) {
            	authorName = "<a href=\"mailto:" + savedEmail + "\">" + savedName + "</a>";
            }
            else {
            	if( savedName == null ) {
            		authorName = "<i>"+YazdLocale.getLocaleKey("Anonymous",locale)+"</i>";
            	}
            	else {
            		authorName = savedName;
            	}
            }
        buf.append(YazdLocale.getLocaleKey("Posted_by",locale)+": ").append( authorName);
        } else {
        	if( author.isEmailVisible() ) {
            	userName = "<a href=\"mailto:" + authorEmail + "\">" + userName + "</a>";
           	}
           	buf.append(YazdLocale.getLocaleKey("Posted_by",locale)+": ").append( userName);

            if( author.isNameVisible() && (authorName!=null && !authorName.equals("")) ) {
            	buf.append("(");
                if( author.isEmailVisible() ) {
            		buf.append("&nbsp;<i><a href=\"mailto:").append( authorEmail +"\">");
            	}
                buf.append(authorName);
                if( author.isEmailVisible()) { buf.append("</a></i>"); }
            	buf.append(")");
            }
            if(isAdmin){
                if (author.getProperty("BLOCKED")!=null && author.getProperty("BLOCKED").equals("true")){
                    buf.append(" <a href=\""+threadLink+"&blockuser="+userID+"&block=false\">unBlock User</a>");
                }else{
                    buf.append(" <a href=\""+threadLink+"&blockuser="+userID+"&block=true\">Block User</a>");
                }
            }

       	}
        buf.append("</span></td></tr>");
        if (userCity!=null){
           buf.append("<tr><td><span class=\"userInfo\">");
           buf.append(userCity!=null?userCity+",":"");
           buf.append(userCountry!=null?userCountry:"").append("</span></td></tr>");
        }
        if (userGender!=null){
           buf.append("<tr><td><span class=\"userInfo\">").append(userGender!=null?userGender:"").append("</span></td></tr>");
        }
        if (userIP!=null){
           buf.append("<tr><td><span class=\"userInfo\">").append(userIP!=null?userIP:"").append("</span>");
           if(isSystemAdmin){
               ClientIP cip = new ClientIP("",userIP);
               if (forumFactory.isBlackListed(cip)){
                   buf.append(" <a href=\""+threadLink+"&blockip="+userIP+"&block=false\">unBlock IP</a>");
               }else{
                   buf.append(" <a href=\""+threadLink+"&blockip="+userIP+"&block=true\">Block IP</a>");
               }
           }
           buf.append("</td></tr>");
        }
        if (avatar!=null){
           buf.append("<tr><td align=\"center\"><span class=\"userInfo\"><img src=\"").append(avatar).append("\" border=\"0\"></span></td></tr>");
        }
        if (nickname!=null){
            buf.append("<tr><td align=\"center\"><span class=\"userInfo\"><a target=\"_blank\" href=\"http://www.sexstanding.com/standing/?i=").append(URLEncoder.encode(nickname,"UTF-8")).append("\">");
            buf.append("<img src=\"http://www.sexstanding.com/servlet/sex.standing?i=").append(URLEncoder.encode(nickname,"UTF-8")).append("\" alt=\"Verified by SexStanding.com\" oncontextmenu=\"alert('SexStanding image is copyrighted and copying is Prohibited by Law'); return false;\" width=\"140\" height=\"36\" border=\"0\"></a><br>");
        }
        if (userSig!=null){
           buf.append("<tr><td><span class=\"userInfo\">").append(userSig!=null?userSig:"").append("</span></td></tr>");
        }
        if (userURL!=null){
           buf.append("<tr><td><span class=\"userInfo\">").append(userURL!=null?"<a href=\""+userURL+"\">"+userURL+"</a>":"").append("</span></td></tr>");
        }
        if (lastlogin!=null && lastlogin.getTimeInMillis() > 0){
           buf.append("<tr><td><span class=\"userInfo\">").append("Last logged in:"+dateFormatter.format(lastlogin.getTime())).append("</span></td></tr>");
        }
        if (isAdmin & !msgIsAnonymous){
            buf.append("<tr><td><span class=\"userInfo\">").append("Ranking: "+ userRanking)
                    .append("&nbsp;<a style=\"text-decoration : none;color : #990000;\" href=\"").append(threadLink).append("&ruser="+userID).append("&ranking=1\">+</a>")
                    .append("&nbsp;<a style=\"text-decoration : none;color : #990000;\" href=\"").append(threadLink).append("&ruser="+userID).append("&ranking=-1\">-</a>")
                    .append("</span></td></tr>");
        }
        buf.append("<tr><td align=\"center\">");
	if(!thread.isClosed()){
		buf.append("<a href=\"post.jsp?reply=true&forum=").append( forumID).append("&thread=").append(threadID).append("&message=").append(messageID).append("\"");
		buf.append("><img src=\"images/reply.gif\" width=\"50\" height=\"19\" alt=\"Click to reply to this message\" border=\"0\"></a>");
        if (!msgIsAnonymous && authToken.getUserID() != -1 && authToken.getUserID() != author.getID()) {
        	buf.append("<a href=\"post.jsp?isPrivate=true&reply=true&forum=").append(forumID).append("&thread=").append(threadID).append("&message=").append(messageID).append("\"><img src=\"images/reply_private.gif\" width=\"97\" height=\"19\" alt=\"Click to reply private to this message\" border=\"0\"></a>");
        }
	}
        if (isAdmin) {
            buf.append("<input type=\"image\" name=\"delete_" + messageID + "\" src=\"images/delete_gray.gif\" width=60 height=19 border=\"0\" alt=\"Delete message\" />&nbsp;");
            if (!message.isApproved()) {
                buf.append("<input type=\"image\" name=\"approve_" + messageID + "\" src=\"images/approve_gray.gif\" width=72 height=19 border=\"0\" alt=\"Approve message\" />&nbsp;");
            }
        }
        if (!message.isApproved()) {
                buf.append("<img src=\"images/not_approved_gray.gif\" width=103 height=13 border=\"0\">");
        }
        if (message.isPrivate()) {
                buf.append("<br><span class=\"privateMessage\">"+YazdLocale.getLocaleKey("Private_message",locale)+"</span>&nbsp;");
        }
        buf.append("</td></tr>");
        buf.append("<tr><td width=\"1%\" nowrap align=\"center\"><small class=\"date\">");
        buf.append(YazdLocale.getLocaleKey("Posted",locale)+" ").append(SkinUtils.dateToText(creationDate,locale,timezone));
        buf.append("<br><i>").append(dateFormatter.format(creationDate)).append("</i></small></td></tr></table></td>");
        buf.append("<td valign=\"top\">");
        buf.append("<table cellpadding=\"5\" cellspacing=\"0\" border=\"0\" width=\"100%\"><tr>");
        buf.append("<tr><td><span class=\"messageSubject\">").append(subject).append("</span></td><td align=\"right\">");
        if(isApproved && isRootUser && authToken.getUserID()!= message.getUser().getID() &&message.getRanking().getRank()== MessageRanking.NOTRANKED){
            buf.append("<table cellpadding=\"5\"><tr><td><b>"+YazdLocale.getLocaleKey("RankMessage",locale)+"</b><td><input type=\"image\" name=\"rankpositive_" + messageID + "\" src=\"images/positive.gif\"  border=\"0\" alt=\"Positive Ranking\" /></td>");
            buf.append("<td><input type=\"image\" name=\"rankneutral_" + messageID + "\" src=\"images/neutral.gif\"  border=\"0\" alt=\"Neutral Ranking\" /></td>");
            buf.append("<td><input type=\"image\" name=\"ranknegative_" + messageID + "\" src=\"images/negative.gif\" border=\"0\" alt=\"Negative Ranking\" /></td></table>");
        }
        if(message.getRanking().getRank()!=MessageRanking.NOTRANKED){
            buf.append("<b>"+YazdLocale.getLocaleKey(message.getRanking().getRankName(),locale)+"</b>");
        }
        buf.append("</td></tr>");
        buf.append("<tr><td colspan=\"2\"><span class=\"messageBody\">").append((msgBody!=null)?msgBody:"");
        buf.append("</span></td></tr></table></td></tr>");

		} catch( Exception ignored ) {}
		return buf.toString();
	}

    private String getMessageBody(ForumMessage message, Authorization authToken,Locale locale) {
        readText = false;
        isPrivate = false;
        isApproved = false;
        //if admin or sender
        if (isAdmin || (message.getUser().getID() == authToken.getUserID() && authToken.getUserID() != -1)) {
            readText = true;
            isApproved = true;
        } else {
            if (message.isApproved()) {
                isApproved = true;
                //if private message
                if (message.isPrivate()) {
                    //if receiver
                    if (message.getReplyPrivateUserId() == authToken.getUserID()) {
                        readText = true;
                    } else {
                        isPrivate = true;
                    }
                } else {//not private message
                    readText = true;
                }
            }
        }//if
        StringBuffer b = new StringBuffer();
        if (!isApproved) {
            b.append("<img src=\"images/not_approved_white.gif\" width=103 height=13 border=\"0\">");
        }
        if (isPrivate) {
            b.append("&nbsp;<span class=\"privateMessage\">"+YazdLocale.getLocaleKey("Private_message",locale)+"</span>");
        }
        if (readText) {
            b.append(message.getBody());
        }
        return b.toString();
    }

	/**
	 * Recursive method to print all the children of a message.
	 */
	private String printChildren( TreeWalker walker, Forum forum, ForumThread thread, ForumMessage message, int indentation, String mode, Authorization authToken,Locale locale,TimeZone timezone ,ForumFactory factory)
	{
		StringBuffer buf = new StringBuffer();

		buf.append( printChildMessage( forum, thread, message, indentation, mode, authToken,locale,timezone,factory ) );

		// recursive call
        int numChildren = walker.getChildCount(message);
        if( numChildren > 0 ) {
            for( int i=0; i<numChildren; i++ ) {
                buf.append(
					printChildren( walker, forum, thread, walker.getChild(message,i), (indentation+1), mode, authToken,locale,timezone,factory )
				);
            }
        }
		return buf.toString();
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
	dateFormatter = new SimpleDateFormat("EEE, MMM d '"+YazdLocale.getLocaleKey("at",locale)+"' hh:mm:ss z",locale);
	dateFormatter.setTimeZone(timezone);

	long userLastVisitedTime = SkinUtils.getLastVisited(request,response);

	ForumPermissions permissions = forumFactory.getPermissions(authToken);
	isSystemAdmin = permissions.get(ForumPermissions.SYSTEM_ADMIN);
	isUserAdmin   = permissions.get(ForumPermissions.FORUM_ADMIN);
%>

<%	//////////////////////
	// get parameters
	int forumID  = ParamUtils.getIntParameter(request,"forum",-1);
	int threadID = ParamUtils.getIntParameter(request,"thread",-1);
	String mode = ParamUtils.getParameter(request,"mode");
    int rankUser = ParamUtils.getIntParameter(request,"ruser",-1);
    int ranking = ParamUtils.getIntParameter(request,"ranking",0);
    boolean blockcommand= ParamUtils.getBooleanParameter(request,"block");
    String blockip = ParamUtils.getParameter(request,"blockip");
    int blockuser = ParamUtils.getIntParameter(request,"blockuser",-1);
    boolean setSticky = ParamUtils.getBooleanParameter(request,"sticky");
    boolean setClosed = ParamUtils.getBooleanParameter(request,"close");
    boolean setCFlag = ParamUtils.getBooleanParameter(request,"doCFlag");
    boolean setSFlag = ParamUtils.getBooleanParameter(request,"doSFlag");

    if( mode == null ) {
		// mode = "threaded";
		mode = "flat";
	}
%>

<%	//////////////////////
	// page error variables

	String errorMessage = "";

	boolean invalidForumID = (forumID < 0);
	boolean invalidThreadID = (threadID < 0);
	boolean notAuthorizedToViewForum = false;
	boolean forumNotFound = false;
	boolean threadNotFound = false;
	boolean rootMessageNotFound = false;
%>

<%	//////////////////////////
	// try loading up forums (exceptions may be thrown)
	Forum forum = null;
	try {
		forum = forumFactory.getForum(forumID);
	}
	catch( UnauthorizedException ue ) {
		notAuthorizedToViewForum = true;
	}
	catch( ForumNotFoundException fnfe ) {
		forumNotFound = true;
	}
    if (forum != null) {
        isModerator   = forum.getPermissions(authToken).get(ForumPermissions.MODERATOR);
    }
    isAdmin = isSystemAdmin || isUserAdmin || isModerator;
%>

<%	//////////////////////////////////
	// try loading up the thread
	ForumThread thread = null;
	if( forum != null && !invalidThreadID ) {
		try {
			thread = forum.getThread(threadID);
            thread.addReadCount();
		} catch( ForumThreadNotFoundException ftnfe ) {}
		if( thread == null ) {
			threadNotFound = true;
		}
	}
    if(isAdmin && setCFlag){
        thread.setClosed(setClosed);
    }
    if(isAdmin && setSFlag){
        thread.setSticky(setSticky);
    }
%>
<%	///////////////////////
	// Try loading up the root message
	ForumMessage rootMessage = null;
	int rootMessageID = -1;
	rootMessage = thread.getRootMessage();
	rootMessageID = rootMessage.getID();
    isRootUser = !rootMessage.getUser().isAnonymous() && rootMessage.getUser().getID()==authToken.getUserID();
%>
<%
    //check if is post back
    if (isAdmin || isRootUser) {
        if (isAdmin && rankUser > 0 && ranking != 0 && !(ranking < -1) && !(ranking > 1)) {
            try {
                User tmpUser = forumFactory.getProfileManager().getUser(rankUser);
                int tmpranking = Integer.parseInt(tmpUser.getProperty("ranking"));
                // the lowest the ranking can be is 1.
                if (tmpranking+ranking > 0){
                    tmpUser.setProperty("ranking",Integer.toString(tmpranking+ranking));
                }
            } catch(Exception e) {
                response.sendRedirect( "error.jsp?msg=" + URLEncoder.encode("Unable to complete delete operation due to following error: " + e.getMessage()) );
            }
        }else if(isAdmin && blockuser > 0){
            User tmpUser = forumFactory.getProfileManager().getUser(blockuser);
            tmpUser.setProperty("BLOCKED",Boolean.toString(blockcommand));
        }else if(isSystemAdmin && blockip!=null){
            ClientIP cip = new ClientIP("",blockip);
            forumFactory.BlackListIP(cip,blockcommand);
        }
        Enumeration en = request.getParameterNames();
        while (en.hasMoreElements()) {
            String p = (String) en.nextElement();
            if (isAdmin && p.startsWith("approve_")) {
                try {
                    String idStr = p.substring(8, p.indexOf("."));
                    int id = Integer.parseInt(idStr);
                    thread.getMessage(id).setApprovment(true);
                    break;
                } catch(Exception e) {
                    response.sendRedirect( "error.jsp?msg=" + URLEncoder.encode("Unable to complete approve operation due to following error: " + e.getMessage()) );
                }
            } else if (isAdmin && p.startsWith("delete_")) {
                try {
                    String idStr = p.substring(7, p.indexOf("."));
                    int id = Integer.parseInt(idStr);
                    ForumMessage toDelete = thread.getMessage(id);
                    thread.deleteMessage(toDelete);
                    break;
                } catch(Exception e) {
                    response.sendRedirect( "error.jsp?msg=" + URLEncoder.encode("Unable to complete delete operation due to following error: " + e.getMessage()) );
                }
            } else if (isRootUser && p.startsWith("rankpositive_")) {
                try {
                    String idStr = p.substring(13, p.indexOf("."));
                    int id = Integer.parseInt(idStr);
                    thread.getMessage(id).setRanking(MessageRanking.POSITIVE);
                    break;
                } catch(Exception e) {
                    response.sendRedirect( "error.jsp?msg=" + URLEncoder.encode("Unable to complete delete operation due to following error: " + e.getMessage()) );
                }
            } else if (isRootUser && p.startsWith("rankneutral_")) {
                try {
                    String idStr = p.substring(12, p.indexOf("."));
                    int id = Integer.parseInt(idStr);
                    thread.getMessage(id).setRanking(MessageRanking.NEUTRAL);
                    break;
                } catch(Exception e) {
                    response.sendRedirect( "error.jsp?msg=" + URLEncoder.encode("Unable to complete delete operation due to following error: " + e.getMessage()) );
                }
            } else if (isRootUser && p.startsWith("ranknegative_")) {
                try {
                    String idStr = p.substring(13, p.indexOf("."));
                    int id = Integer.parseInt(idStr);
                    thread.getMessage(id).setRanking(MessageRanking.NEGATIVE);
                    break;
                } catch(Exception e) {
                    response.sendRedirect( "error.jsp?msg=" + URLEncoder.encode("Unable to complete delete operation due to following error: " + e.getMessage()) );
                }
            }

        }

    }//if isAdmin
%>


<%	/////////////////////
	// global error check
	boolean errors = (invalidForumID || invalidThreadID
		|| notAuthorizedToViewForum || forumNotFound
		|| threadNotFound || rootMessageNotFound || (forum==null) );
%>

<%	/////////////////////
	// check for errors
	if( errors ) {
		if( invalidForumID ) {
			errorMessage = "No forum specified or invalid forum ID.";
		}
		else if( notAuthorizedToViewForum ) {
			errorMessage = "No permission to view this forum.";
		}
		else if( forumNotFound ) {
			errorMessage = "Requested forum was not found in the system.";
		}
		else if( threadNotFound ) {
			errorMessage = "Requested thread was not found in the system.";
		}
		else if( rootMessageNotFound ) {
			errorMessage = "Requested message was not found in the system.";
		}
		else {
			errorMessage = "General error occured. Please contact the "
				+ "administrator and bug him/her.";
		}
		//request.setAttribute("message",errorMessage);
		response.sendRedirect("error.jsp?msg="+errorMessage);
		return;
	}
%>

<%	//////////////////////
	// get forum properties (assumed no errors at this point)
	String forumName = forum.getName();
	String threadName = thread.getName();
%>

<%	//////////////////////////////
	// get root message properties

	User author = rootMessage.getUser();
	int rootMsgAuthorID = author.getID();
	String userName = null;
	String authorName = null;
	String authorEmail = null;
	authorName = author.getName();
	userName = author.getUsername();
    String userColour = author.getProperty("colour");
    String userCity = author.getProperty("city");
    String userCountry = author.getProperty("country");
    String userGender = author.getProperty("gender");
    String userIP = author.getProperty("IP");
    String userSig = author.getProperty("sig");
    String userURL = author.getProperty("URL");
    String avatar = author.getProperty("avatar");
    String nickname = author.getProperty("ssnickname");
    Calendar lastlogin = author.getLastLogin();
	authorEmail = author.getEmail();
	Date creationDate = rootMessage.getCreationDate();
	boolean rootMsgIsAnonymous = rootMessage.isAnonymous();
    String userRanking = author.getProperty("ranking");
    int userID = author.getID();

    //if( authorName == null ) {
	//	rootMsgIsAnonymous = true;
	//}

	String rootMsgSubject = rootMessage.getSubject();
        String rootMsgBody = getMessageBody(rootMessage, authToken,locale);
%>

<%	////////////////////
	// page title variable for header
	String title = "Yazd Forums: " + forumName + ": " + threadName;
%>
<%	/////////////////////
	// page header
%>
<%@ include file="header.jsp" %>


<%	////////////////////
	// breadcrumb variable
	String[][] breadcrumbs = {
		{YazdLocale.getLocaleKey("Home",locale), "index.jsp" },
		{ forumName, ("viewForum.jsp?forum="+forumID) },
		{ threadName, "" }
	};
%>
<%@ include file="breadcrumb.jsp" %>


<%	///////////////////
	// toolbar variables
	boolean showToolbar = true;
	String viewLink = "viewForum.jsp?forum="+forumID;
	String postLink = "post.jsp?mode=new&forum="+forumID;
    String replyLink = "post.jsp?reply=true&forum="+forumID+"&thread="+threadID+"&message="+rootMessageID;
    if(thread.isClosed()){
        replyLink=null;
    }
	String searchLink = "search.jsp?forum="+forumID;
    String threadLink = "viewThread.jsp?forum="+forumID+"&thread="+threadID;
    String accountLink = "userAccount.jsp";
%>
<%@ include file="toolbar.jsp" %>

<%	/////////////////////
	// print out the number of replies
	int numReplies = thread.getMessageCount()-1;
    int readcnt = thread.getReadCount();
%>
<p>
<b><%=YazdLocale.getLocaleKey("There",locale)%> <%= YazdLocale.getLocaleKey(((numReplies==1)?"Is":"Are"),locale) %> <%= numReplies %> <%= YazdLocale.getLocaleKey((numReplies==1)?"Reply":"Replies",locale) %> <%=YazdLocale.getLocaleKey("To_this_message",locale)%>.</b>
<b><%=YazdLocale.getLocaleKey("This_thread_was_viewed",locale)%> <%=readcnt%>.</b>

<%
    if(isAdmin || isModerator){
%>
<br><br>
<table bgcolor="#999999" width="50%" border="0" cellspacing="0" cellpadding="1">
<td><table bgcolor="#ccccdd" width="100%" border="0" cellspacing="0" cellpadding="3">
<td width="100%">&nbsp;<b>Admin Thread Toolbar</b></td>
</table></td></table>
<table bgcolor="#cccccc" width="50%" border="0" cellspacing="0" cellpadding="1">
<td><table bgcolor="#eeeeff" width="100%" border="0" cellspacing="0" cellpadding="3">
    <%
        if(thread.isClosed()){
    %>
        <td width="1%"><a href="viewThread.jsp?forum=2"><img src="images/yazd_unlock.gif" width="19" height="19" border="0" alt="Click to open this thread"></a></td>
		<td width="1%" nowrap><a href="viewThread.jsp?forum=<%=forum.getID()%>&thread=<%=thread.getID()%>&close=false&doCFlag=true" class="toolbar" title="Click to open this thread">Open Thread</a></td>
		<td width="1%">&nbsp;&nbsp;</td>
    <%
        }else{
    %>
    <td width="1%"><a href="viewThread.jsp?forum=2"><img src="images/yazd_lock.gif" width="19" height="19" border="0" alt="Click to close this thread"></a></td>
    <td width="1%" nowrap><a href="viewThread.jsp?forum=<%=forum.getID()%>&thread=<%=thread.getID()%>&close=true&doCFlag=true" class="toolbar" title="Click to close this thread">Close Thread</a></td>
    <td width="1%">&nbsp;&nbsp;</td>
    <%
        }
    %>
    <%
        if(thread.isSticky()){
    %>
        <td width="1%"><a href="viewThread.jsp?mode=new&forum=2"><img src="images/yazd_stick.gif" width="19" height="19" border="0" alt="Click to make this thread unsticky"></a></td>
		<td width="1%" nowrap><a href="viewThread.jsp?forum=<%=forum.getID()%>&thread=<%=thread.getID()%>&sticky=false&doSFlag=true" class="toolbar" title="Click to make this thread unsticky">Remove Sticky </a></td>
		<td width="1%">&nbsp;&nbsp;</td>
    <%
    }else{
    %>
    <td width="1%"><a href="viewThread.jsp?mode=new&forum=2"><img src="images/yazd_stick.gif" width="19" height="19" border="0" alt="Click to make this thread sticky"></a></td>
    <td width="1%" nowrap><a href="viewThread.jsp?forum=<%=forum.getID()%>&thread=<%=thread.getID()%>&sticky=true&doSFlag=true" class="toolbar" title="Click to make this thread sticky">Make Sticky </a></td>
    <td width="1%">&nbsp;&nbsp;</td>
    <%
        }
    %>
	<td width="94%">
		<span class="toolbar">&nbsp;</span>
	</td>
	</table>
	</td>
</table>
<%
    }
%>






<p>
<form action="viewThread.jsp" method="get">

<%-- root message --%>
<table bgcolor="#<%=seperatorColor%>" cellpadding="0" cellspacing="1" border="0" width="100%" align="right">
<tr><td>
<table bgcolor="#cccccc" cellpadding="4" cellspacing="1" border="0" width="100%">
    <tr bgcolor="#cccccc">
        <td width="20%"><span class="messageAuthor"><%=YazdLocale.getLocaleKey("Author",locale)%></span></td>
        <td width="80%"><%if(thread.isSticky()){%><img src="images/yazd_stick.gif" width="19" height="19" alt="Sticky"><%}%><%if(thread.isClosed()){%><img src="images/yazd_lock.gif" width="19" height="19" alt="Sticky"><%}%><span class="messageHeader"><%=YazdLocale.getLocaleKey("Topic",locale)%>:  <%= rootMsgSubject %><%if(thread.getThreadType().getID()>0){%> (<%=thread.getThreadType().getName()%>)<%}%></span></td>
    </tr>
	<tr bgcolor="#<%=(userColour!=null && !userColour.equals("") && userColour.length()==6)?userColour:Integer.toHexString(tableColor)+Integer.toHexString(tableColor)+Integer.toHexString(tableColor)%>">
		<td nowrap valign="top">
            <!--Toolbar -->
            <table>
                <tr><td>
			<span class="messageAuthor">
			<%	if( rootMsgIsAnonymous ) {
					String savedName = rootMessage.getProperty("name");
					String savedEmail = rootMessage.getProperty("email");
                    userIP = rootMessage.getProperty("IP");
					if( savedEmail != null && savedName != null ) {
						authorName = "<a href=\"mailto:" + savedEmail + "\">" + savedName + "</a>";
					}
					else {
						if( savedName == null ) {
							authorName = "<i>"+YazdLocale.getLocaleKey("Anonymous",locale)+"</i>";
						}
						else {
							authorName = savedName;
						}
					}
			%>

				<%=YazdLocale.getLocaleKey("Posted_by",locale)%>: <%= authorName %>

			<%	} else { %>

				<%	if( author.isEmailVisible() ) { %>
					<% userName = "<a href=\"mailto:" + authorEmail + "\">" + userName + "</a>"; %>
				<%	} %>
				<%=YazdLocale.getLocaleKey("Posted_by",locale)%>: <%= userName %>

				<%	if( author.isNameVisible() && (authorName!=null && !authorName.equals("")) ) { %>
				(<%	if( author.isEmailVisible() ) { %>
					&nbsp;<i><a href="mailto:<%= authorEmail %>"
					><% } %><%= authorName %><% if( author.isEmailVisible()) { %></a></i>
					<% } %>
					)
				<%	} %>
                <%if(isAdmin){if (author.getProperty("BLOCKED")!=null && author.getProperty("BLOCKED").equals("true")){%><a href="<%=threadLink%>&blockuser=<%=userID%>&block=false">unBlock User</a><%}else{%><a href="<%=threadLink%>&blockuser=<%=userID%>&block=true">Block User</a><%}}%>
			<%	} %>
			</span>

            </td></tr>
            <tr><td><span class="userInfo"><%=userCity!=null?userCity+",":""%><%=userCountry!=null?userCountry:""%></span></td></tr>
            <tr><td><span class="userInfo"><%=userGender!=null?userGender:""%></span></td></tr>
            <%if(userIP != null){

                %>
            <tr><td><span class="userInfo"><%=userIP%></span> <%if(isSystemAdmin){ClientIP cip = new ClientIP("",userIP);if (forumFactory.isBlackListed(cip)){%><a href="<%=threadLink%>&blockip=<%=userIP%>&block=false">unBlock IP</a><%}else{%><a href="<%=threadLink%>&blockip=<%=userIP%>&block=true">Block IP</a><%}}%></td></tr>
            <%}%>
            <tr><td align="center"><span class="userInfo"><%=avatar!=null?"<img src=\""+avatar+"\" border=\"0\">":""%></span></td></tr>
            <tr><td align="center"><span class="userInfo"><% if(nickname!=null){%>
                <a target="_blank" href="http://www.sexstanding.com/standing/?i=<%=URLEncoder.encode(nickname,"UTF-8")%>">
                <img src="http://www.sexstanding.com/servlet/sex.standing?i=<%=URLEncoder.encode(nickname,"UTF-8")%>" alt="Verified by SexStanding.com" oncontextmenu="alert('SexStanding image is copyrighted and copying is Prohibited by Law'); return false;" width="140" height="36" border="0">
                </a><br>
                <%}%></span></td></tr>
            <tr><td><span class="userInfo"><%=userSig!=null?userSig:""%></span></td></tr>
            <tr><td><span class="userInfo"><%=userURL!=null?"<a href=\""+userURL+"\">"+userURL+"</a>":""%></span></td></tr>
            <tr><td><span class="userInfo"><%=lastlogin!=null && lastlogin.getTimeInMillis() > 0?YazdLocale.getLocaleKey("Last_logged_in",locale)+":"+dateFormatter.format(lastlogin.getTime()):""%></span></td></tr>
<%
                if (isAdmin & !rootMsgIsAnonymous){
                    %>
                    <tr><td><span class="userInfo">Ranking: <%=userRanking%>
                            &nbsp;<a style="text-decoration : none;color : #990000;" href="<%=threadLink%>&ruser=<%=userID%>&ranking=1">+</a>
                            &nbsp;<a style="text-decoration : none;color : #990000;" href="<%=threadLink%>&ruser=<%=userID%>&ranking=-1">-</a>
                            </span></td></tr>
                <%
                }
%>
            <tr>
		            <td align="center">
                        <%
                            if(!thread.isClosed()){
                        %>
                        <a href="post.jsp?reply=true&forum=<%= forumID %>&thread=<%= threadID %>&message=<%= rootMessageID %>"
            			><img src="images/reply.gif" width="50" height="19" alt="Click to reply to this message" border="0"></a>
            <%
                            }
                            if ((!rootMsgIsAnonymous && authToken.getUserID() != -1 && authToken.getUserID() != rootMsgAuthorID)&&!thread.isClosed()) {
            %>
            			<a href="post.jsp?isPrivate=true&reply=true&forum=<%= forumID %>&thread=<%= threadID %>&message=<%= rootMessageID %>"><img src="images/reply_private.gif" width="97" height="19" alt="Click to reply private to this message" border="0"></a>
            <%
                            }

                    if (isAdmin) {
                        out.print("<input type=\"image\" name=\"delete_" + rootMessageID + "\" src=\"images/delete_gray.gif\" width=60 height=19 border=\"0\" alt=\"Delete message\" />&nbsp;");
                        if (!rootMessage.isApproved()) {
                            out.print("<input type=\"image\" name=\"approve_" + rootMessageID + "\" src=\"images/approve_gray.gif\" width=72 height=19 border=\"0\" alt=\"Approve message\" />&nbsp;");
                        }
                    }
                    if (!rootMessage.isApproved()) {
            			out.print("<img src=\"images/not_approved_gray.gif\" width=103 height=13 border=\"0\">");
                    }
            %>
            <%
                            if (rootMessage.isPrivate()) {
            %>
            			<br><span class="privateMessage"><%=YazdLocale.getLocaleKey("Private_message",locale)%></span>&nbsp;
            <%
                            }
            %>
            		</td>

            </tr>
            <tr>
		            <td width="1%" nowrap align="center">
            			<small class="date">
            			<%=YazdLocale.getLocaleKey("Posted",locale)%> <%= SkinUtils.dateToText(creationDate,locale,timezone) %>
            			<br><i><%= dateFormatter.format(creationDate) %></i>
            			</small>
            		</td>

            </tr>
            </table>
		</td>
        <td valign="top">

			<span class="messageSubject">
			<%= rootMsgSubject %>
			</span>
			<br>
    		<table cellpadding="5" cellspacing="0" border="0" width="100%">
	    	<td><span class="messageBody"><%= (rootMsgBody!=null)?rootMsgBody:"" %></span></td>
		    </table>

        </td>
	</tr>

 <%	/////////////////////////
	// print out all child messages:

	// if there are children to display:
	if( numReplies > 0 ) {
		StringBuffer buf = new StringBuffer();
		TreeWalker treeWalker = thread.treeWalker();
		int numChildren = treeWalker.getChildCount(rootMessage);
		int indentation = 1;
		for( int i=0; i<numChildren; i++ ) {
			buf.append(
				printChildren( treeWalker, forum, thread, treeWalker.getChild(rootMessage,i), indentation, mode, authToken ,locale,timezone,forumFactory)
			);
		}
%>
		<%= buf.toString() %>
<%	} %>
</table>
</td></tr>
</table>
<%-- /root message --%>

<br clear="all">
<br>

<p>


<br clear="all"><a href="http://www.forumsoftware.ca"> </a>
<input type="hidden" name="forum" value="<%= forumID %>" />
<input type="hidden" name="thread" value="<%= threadID %>" />
</form>
<%	/////////////////////
	// page footer
%>
<%
    String formSubject=rootMsgSubject;
    String pathtopost="post.jsp";
    boolean reply=true;
    int messageID = rootMessage.getID();
    String pageKey="";
    Locale yazdlocale=locale;
    User yazduser =user;
%>
<%
    if(!thread.isClosed()){
%>
<%@include file="include/post_include.jsp"%>
<%
    }
%>


<%@ include file="footer.jsp" %>



