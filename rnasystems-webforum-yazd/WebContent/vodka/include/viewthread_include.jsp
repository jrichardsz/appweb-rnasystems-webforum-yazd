

<%@	page import="java.util.*,
                 java.text.*,
                 com.Yasna.forum.*,
                 com.Yasna.forum.util.*,com.Yasna.forum.locale.YazdLocale"
%>

<%	//////////////////////
    // these two parameters need to be defined for this page.
    // int forumID
    // int threadID
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
    String color_array[]={"aa9999","99aa99","9999aa"};
    int	tableColor = 250;
	SimpleDateFormat thdateFormatter;

	/**
	 * Print a child message
	 */
	private String printChildMessage( ForumMessage message, Authorization authToken ,Locale yazdlocale,TimeZone yazdtimezone,String tcolor)
	{
        StringBuffer buf = new StringBuffer();
		try {
		String subject = message.getSubject();
		boolean msgIsAnonymous = message.isAnonymous();
        User author = message.getUser();
        String authorName = author.getName();
        String authorEmail = author.getEmail();
        String userName = author.getUsername();
        String userColour = author.getProperty("colour");
        Date creationDate = message.getCreationDate();
		String msgBody = getMessageBody(message, authToken,yazdlocale);
		buf.append("<tr bgcolor=\"#");
		buf.append((userColour!=null && !userColour.equals("") && userColour.length()==6)?userColour: tcolor);
        buf.append("\">");
        // new changes
        buf.append("<td valign=\"top\">");
        buf.append("<table cellpadding=\"5\" cellspacing=\"0\" border=\"0\" width=\"100%\"><tr>");
        buf.append("<tr><td><span class=\"messageSubject\">").append(subject).append("</span>");
            buf.append("<br><span class=\"messageAuthor\">");
            if( msgIsAnonymous ) {
                String savedName = message.getProperty("name");
                String savedEmail = message.getProperty("email");
                if( savedEmail != null && savedName != null ) {
                    authorName = "<a href=\"mailto:" + savedEmail + "\">" + savedName + "</a>";
                }
                else {
                    if( savedName == null ) {
                        authorName = "<i>"+YazdLocale.getLocaleKey("Anonymous",yazdlocale)+"</i>";
                    }
                    else {
                        authorName = savedName;
                    }
                }
            buf.append(YazdLocale.getLocaleKey("Posted_by",yazdlocale)+": ").append( authorName);
            } else {
                if( author.isEmailVisible() ) {
                    userName = "<a href=\"mailto:" + authorEmail + "\">" + userName + "</a>";
                   }
                   buf.append(YazdLocale.getLocaleKey("Posted_by",yazdlocale)+": ").append( userName);

                if( author.isNameVisible() && (authorName!=null && !authorName.equals("")) ) {
                    buf.append("(");
                    if( author.isEmailVisible() ) {
                        buf.append("&nbsp;<i><a href=\"mailto:").append( authorEmail +"\">");
                    }
                    buf.append(authorName);
                    if( author.isEmailVisible()) { buf.append("</a></i>"); }
                    buf.append(")");
                }

               }
            buf.append("</span><br>");
            buf.append("<small class=\"date\">");
            buf.append(YazdLocale.getLocaleKey("Posted",yazdlocale)+" ");
            buf.append(thdateFormatter.format(creationDate)).append("</small><br>");
            buf.append("</td></tr>");
            buf.append("<tr><td>");

        buf.append("<span class=\"messageBody\">").append((msgBody!=null)?msgBody:"");
        buf.append("</span></td></tr></table></td></tr>");

		} catch( Exception ignored ) {}
		return buf.toString();
	}

    private String getMessageBody(ForumMessage message, Authorization authToken,Locale yazdlocale) {
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
            b.append("&nbsp;<span class=\"privateMessage\">"+YazdLocale.getLocaleKey("Private_message",yazdlocale)+"</span>");
        }
        if (readText) {
            b.append(message.getBody());
        }
        return b.toString();
    }

	/**
	 * Recursive method to print all the children of a message.
	 */
	private String printChildren( TreeWalker walker, ForumMessage message, Authorization authToken,Locale yazdlocale,TimeZone yazdtimezone,int icolor )
	{
		StringBuffer buf = new StringBuffer();
        int tmpi = icolor;
        if(tmpi >= color_array.length ){
            tmpi=0;
        }else{
            tmpi++;
        }

        buf.append( printChildMessage( message, authToken,yazdlocale,yazdtimezone,color_array[icolor] ) );
		// recursive call
        int numChildren = walker.getChildCount(message);
        if( numChildren > 0 ) {
            for( int i=0; i<numChildren; i++ ) {
                buf.append(
					printChildren( walker, walker.getChild(message,i),authToken,yazdlocale,yazdtimezone,tmpi )
				);
            }
        }
		return buf.toString();
    }
%>

<%	///////////////////////
	// page forum variables

	// do not delete these
	TimeZone yazdtimezone = yazduser.getUserTimeZone();
	thdateFormatter = new SimpleDateFormat("EEE, MMM d '"+YazdLocale.getLocaleKey("at",yazdlocale)+"' hh:mm:ss z",yazdlocale);
	thdateFormatter.setTimeZone(yazdtimezone);

	long userLastVisitedTime = SkinUtils.getLastVisited(request,response);

	ForumPermissions permissions = afactory.getPermissions(aauthToken);
	isSystemAdmin = permissions.get(ForumPermissions.SYSTEM_ADMIN);
	isUserAdmin   = permissions.get(ForumPermissions.FORUM_ADMIN);
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
		forum = afactory.getForum(forumID);
	}
	catch( UnauthorizedException ue ) {
		notAuthorizedToViewForum = true;
	}
	catch( ForumNotFoundException fnfe ) {
		forumNotFound = true;
	}
    if (forum != null) {
        isModerator   = forum.getPermissions(aauthToken).get(ForumPermissions.MODERATOR);
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
%>
<%	///////////////////////
	// Try loading up the root message
	ForumMessage rootMessage = null;
	int rootMessageID = -1;
	rootMessage = thread.getRootMessage();
	rootMessageID = rootMessage.getID();
    messageID=rootMessageID;
    isRootUser = !rootMessage.getUser().isAnonymous() && rootMessage.getUser().getID()==aauthToken.getUserID();
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
<%	//////////////////////////////
	// get root message properties

	User author = rootMessage.getUser();
	String userName = null;
	String authorName = null;
	String authorEmail = null;
	authorName = author.getName();
	userName = author.getUsername();
    String userColour = author.getProperty("colour");
	authorEmail = author.getEmail();
	Date creationDate = rootMessage.getCreationDate();
	boolean rootMsgIsAnonymous = rootMessage.isAnonymous();
	String rootMsgSubject = rootMessage.getSubject();
        String rootMsgBody = getMessageBody(rootMessage, aauthToken,yazdlocale);
	// print out the number of replies
	int numReplies = thread.getMessageCount()-1;
    int readcnt = thread.getReadCount();
%>
<p>
User comments
<p>
<form action="viewThread.jsp" method="get">

<%-- root message --%>
<table bgcolor="#<%=seperatorColor%>" cellpadding="0" cellspacing="1" border="0" width="100%" align="right">
<tr><td>
<table bgcolor="#cccccc" cellpadding="4" cellspacing="1" border="0" width="100%">
	<tr bgcolor="#<%=(userColour!=null && !userColour.equals("") && userColour.length()==6)?userColour:color_array[0]%>">
        <td valign="top">
            <span class="messageSubject">
			<%= rootMsgSubject %>
            </span><br>
            <span class="messageAuthor">
			<%	if( rootMsgIsAnonymous ) {
                    String savedName = rootMessage.getProperty("name");
                    String savedEmail = rootMessage.getProperty("email");
                    if( savedEmail != null && savedName != null ) {
                        authorName = "<a href=\"mailto:" + savedEmail + "\">" + savedName + "</a>";
                    }
                    else {
                        if( savedName == null ) {
                            authorName = "<i>"+YazdLocale.getLocaleKey("Anonymous",yazdlocale)+"</i>";
                        }
                        else {
                            authorName = savedName;
                        }
                    }
			%>

				<%=YazdLocale.getLocaleKey("Posted_by",yazdlocale)%>: <%= authorName %>

			<%	} else { %>

				<%	if( author.isEmailVisible() ) { %>
					<% userName = "<a href=\"mailto:" + authorEmail + "\">" + userName + "</a>"; %>
				<%	} %>
				<%=YazdLocale.getLocaleKey("Posted_by",yazdlocale)%>: <%= userName %>

				<%	if( author.isNameVisible() && (authorName!=null && !authorName.equals("")) ) { %>
                (<%	if( author.isEmailVisible() ) { %>
                    &nbsp;<i><a href="mailto:<%= authorEmail %>"
                    ><% } %><%= authorName %><% if( author.isEmailVisible()) { %></a></i>
					<% } %>
                    )
				<%	} %>

			<%	} %>
            </span>
            <br>
            <small class="date">
            			<%=YazdLocale.getLocaleKey("Posted",yazdlocale)%> <%= thdateFormatter.format(creationDate) %>
            </small>
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
        int icolor=1;
        for( int i=0; i<numChildren; i++ ) {
			buf.append(
				printChildren( treeWalker, treeWalker.getChild(rootMessage,i), aauthToken ,yazdlocale,yazdtimezone,icolor)
			);
            icolor++;
            if(icolor >= color_array.length){
                icolor=0;
            }
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


<input type="hidden" name="forum" value="<%= forumID %>" />
<input type="hidden" name="thread" value="<%= threadID %>" />
</form>
