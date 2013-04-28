
<%
    /**
     *	$RCSfile: moveThread.jsp,v $
     */
%>

    <%@ page language="java" pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" import="java.util.*,
                     java.text.SimpleDateFormat,
                     com.Yasna.forum.*,
                     com.Yasna.forum.util.*,
                     com.Yasna.forum.util.admin.*"
        errorPage="error.jsp"
    %>

    <jsp:useBean id="adminBean" scope="session"
     class="com.Yasna.forum.util.admin.AdminBean"/>

<%!
        /**
         * Print a child message
         */
        private String printChildMessage( Forum forum, ForumThread thread, ForumMessage message, int indentation )
        {
            StringBuffer buf = new StringBuffer();
            try {
            if( message.getID() == thread.getRootMessage().getID() ) {
                return "";
            }
            String subject = message.getSubject();
            boolean msgIsAnonymous = message.isAnonymous();
            User author = message.getUser();
            String authorName = author.getName();
            String authorEmail = author.getEmail();
            int forumID = forum.getID();
            int threadID = thread.getID();
            int messageID = message.getID();
            Date creationDate = message.getCreationDate();
            String msgBody = message.getBody();

    buf.append("<tr>");
    buf.append("<td class=\"forumListCell\" width=\"").append(99-indentation).append("%\">");
    buf.append("<table cellpadding=2 cellspacing=0 border=0 width=\"100%\">");
    buf.append("<tr bgcolor=\"#dddddd\">");
    int i = indentation;
    while(i-- >= 0 ) {
    buf.append("<td bgcolor=\"#ffffff\">&nbsp;</td>");
    }
    buf.append("<td><b>").append( message.getSubject() ).append("</b></td>");
    buf.append("</tr>");
    buf.append("<tr bgcolor=\"#eeeeee\">");
    String rootMsgUsername = "<i>Anonymous</i>";
    User rootMsgUser = message.getUser();
    if( !message.getUser().isAnonymous() ) {
    rootMsgUsername = rootMsgUser.getUsername();
    }
    i = indentation;
    while(i-- >= 0 ) {
    buf.append("<td bgcolor=\"#ffffff\">&nbsp;</td>");
    }
    buf.append("<td><font size=\"-2\"><b>Posted by ").append( rootMsgUsername ).append(", on some date ").append( message.getCreationDate() ).append("</b></font></td>");
    buf.append("</tr>");
    buf.append("<tr>");
    i = indentation;
    while(i-- >= 0 ) {
    buf.append("<td>&nbsp;</td>");
    }
    buf.append("<td>").append( message.getBody() ).append("</td>");
    buf.append("</tr>");
    buf.append("</table></td></tr>");

            } catch( Exception ignored ) {}
            return buf.toString();
        }

        /**
         * Recursive method to print all the children of a message.
         */
        private String printChildren( TreeWalker walker, Forum forum, ForumThread thread, ForumMessage message, int indentation )
        {
            StringBuffer buf = new StringBuffer();

            buf.append( printChildMessage( forum, thread, message, indentation ) );

            // recursive call
            int numChildren = walker.getChildCount(message);
            if( numChildren > 0 ) {
                for( int i=0; i<numChildren; i++ ) {
                    buf.append(
                        printChildren( walker, forum, thread, walker.getChild(message,i), (indentation+1) )
                    );
                }
            }
            return buf.toString();
        }
%>


<%!	//////////////////////////
        // global vars

        // date formatter for message dates
        private final SimpleDateFormat dateFormatter
            = new SimpleDateFormat( "EEE, MMM d 'at' hh:mm:ss z" );
        private final static int RANGE = 15;
        private final static int START = 0;
%>

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
        boolean isModerator   = permissions.get(ForumPermissions.MODERATOR);

        // redirect to error page if we're not a forum admin or a system admin
        if( !isUserAdmin && !isSystemAdmin && !isModerator ) {
            request.setAttribute("message","No permission to administer forums");
            response.sendRedirect("error.jsp");
            return;
        }
%>

<%	////////////////////
        // get parameters

        int forumID   = ParamUtils.getIntParameter(request,"forum",-1);
        int mforumID   = ParamUtils.getIntParameter(request,"mforum",-1);
        boolean doMoveThread = ParamUtils.getBooleanParameter(request,"doMoveThread");
        int threadID = ParamUtils.getIntParameter(request,"thread",-1);
%>

<%	//////////////////////////////////
        // global error variables

        String errorMessage = "";

        boolean noForumSpecified = (forumID < 0);
%>

<%	//////////////////////////
        // delete an entire thread

        if( doMoveThread ) {
            Forum tempForum = forumFactory.getForum(forumID);
            ForumThread tempThread = tempForum.getThread(threadID);
            Forum targetForum = forumFactory.getForum(mforumID);

            tempForum.moveThread(tempThread,targetForum);
            response.sendRedirect("forumContent.jsp?forum=" + forumID);
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
        String[] pageTitleInfo = { "Forums : move thread to a different forum" };
%>
<%	///////////////////
        // pageTitle include
%><%@ include file="include/pageTitle.jsp" %>

    <p>

<%	//////////////////////
        // show the name of the forum we're working with (if one was selected)
        Forum currentForum = null;
        if( !noForumSpecified ) {
            try {
                currentForum = forumFactory.getForum(forumID);
	%>
                You're currently working with forum: <b><%= currentForum.getName() %></b>,
                thread: <strong><%= currentForum.getThread(threadID).getName() %></strong>
	<%	}
            catch( ForumNotFoundException fnfe ) {
	%>
                <span class="errorText">Forum not found.</span>
	<%	}
            catch( UnauthorizedException ue ) {
	%>
                <span class="errorText">Not authorized to administer this forum.</span>
	<%	}
        }
%>

    <p>
Move the following thread to the forum:
<%	///////////////////////
        // show a pulldown box of forums where this user can manage content:
        Iterator forumIterator = forumFactory.forumsModeration();
        if( isUserAdmin || isSystemAdmin ) {
            forumIterator = forumFactory.forumsWithArticlesForums();
        }
        if( !forumIterator.hasNext() ) {
%>
            No forums!
<%	}
%>

    <p>

    <form action="moveThread.jsp">
    <input type="hidden" name="forum" value="<%=forumID%>">
    <input type="hidden" name="thread" value="<%=threadID%>">
    <input type="hidden" name="doMoveThread" value="true">
        <select size="1" name="mforum">
<%	while( forumIterator.hasNext() ) {
            Forum forum = (Forum)forumIterator.next();
            if(forum.getID()==forumID){
                continue;
            }
%>
            <option value="<%= forum.getID() %>"><%= forum.getName() %>
<%	}
%>
        </select><br><br>
    <input type="submit" name="operation" value="Move Thread">
    </form>

    <p>

<%-- thread table --%>

<%
        ForumThread thread = currentForum.getThread(threadID);
        TreeWalker walker = thread.treeWalker();
        ForumMessage rootMessage = walker.getRoot();
%>

    <table bgcolor="#cccccc" cellpadding=0 cellspacing=0 border=0 width="100%">
    <td>
    <table bgcolor="#cccccc" cellpadding=3 cellspacing=1 border=0 width="100%">
    <tr bgcolor="#dddddd">
        <td class="forumListHeader" width="99%">&nbsp;</td>
    </tr>

        <tr>
            <td class="forumListCell" width="99%">

            <table cellpadding=2 cellspacing=0 border=0 width="100%">
            <tr bgcolor="#dddddd">
                <td><b><%= rootMessage.getSubject() %></b></td>
            </tr>
            <tr bgcolor="#eeeeee">

<%	String rootMsgUsername = "<i>Anonymous</i>";
        User rootMsgUser = rootMessage.getUser();
        if( !rootMessage.getUser().isAnonymous() ) {
            rootMsgUsername = rootMsgUser.getUsername();
        }
%>
                <td><font size="-2"><b>Posted by <%= rootMsgUsername %>, on some date <%= rootMessage.getCreationDate() %></b></font></td>
            </tr>
            <tr>
                <td><%= rootMessage.getBody() %></td>
            </tr>
            </table>

            </td>
        </tr>

<%= printChildren( walker, currentForum, thread, rootMessage, 0 ) %>

    </table></td></table>
<p>
<form action="forumThread.jsp">
<input type="hidden" name="forum" value="<%= forumID %>">
<input type="submit" value="Cancel / Go Back">
</form>
</p>

    </body>
    </html>

