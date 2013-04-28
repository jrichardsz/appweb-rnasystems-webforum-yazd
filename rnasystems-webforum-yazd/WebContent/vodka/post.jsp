<%
/**
 *	$RCSfile: post.jsp,v $
 *	$Revision: 1.7 $
 *	$Date: 2005/07/17 16:47:23 $
 */
%>
<%@ taglib uri="http://fckeditor.net/tags-fckeditor" prefix="FCK" %>
<%@ page language="java" pageEncoding="UTF-8" contentType="text/html; charset=UTF-8"
	 import="com.Yasna.forum.*,
                 com.Yasna.forum.util.*,
		 com.Yasna.util.*,
                 java.net.*,
                 java.util.Locale,java.util.TimeZone,
                 com.Yasna.forum.locale.YazdLocale"
                 errorPage="error.jsp"
%>
<%@ page import="java.util.Iterator"%>

<%	
     boolean fck=false;
     request.setCharacterEncoding("UTF-8");
	////////////////////////
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

%>

<%	/////////////////
	// get parameters

	int forumID = ParamUtils.getIntParameter(request,"forum",-1);
	int threadID = ParamUtils.getIntParameter(request,"thread",-1);
	int messageID = ParamUtils.getIntParameter(request,"message",-1);
	boolean doPost = ParamUtils.getBooleanParameter(request,"doPost");
	boolean reply = ParamUtils.getBooleanParameter(request,"reply");
	boolean isPrivate = ParamUtils.getBooleanParameter(request,"isPrivate");
    boolean preview = ParamUtils.getBooleanParameter(request,"preview");
    boolean withPreview = request.getParameter("btnPreview") != null;//ParamUtils.getBooleanParameter(request,"withPreview");
	String name = ParamUtils.getParameter(request,"name");
	String email = ParamUtils.getParameter(request,"email");
	String subject = ParamUtils.getParameter(request,"subject");
	String body = ParamUtils.getParameter(request,"body");
    int typeID = ParamUtils.getIntParameter(request,"type",0); // 0 is the default and is considered to be other
    String referringPage = ParamUtils.getParameter(request,"referer");
	String localIP = ParamUtils.getParameter(request,"localip");
    String pageKey = ParamUtils.getParameter(request,"pagekey");
%>

<%	///////////////////////////////////////
	// Create forum, parent message objects

	// Load the forum -- if an exception is thrown, we'll redirect to
	// the error page
	Forum forum = forumFactory.getForum(forumID);
	ForumMessage tmpMsg = forum.createDummyMessage(user);

	// Load the forum message and thread it is associated with. Do
	// this only if we're replying to a message
	ForumThread thread = null;
	ForumMessage parentMessage = null;
	if( reply ) {
		thread = forum.getThread(threadID);
		parentMessage = thread.getMessage(messageID);
        if(thread.isClosed()){
            throw new Exception("This thread is closed and you can not reply to it!");
        }
    }
%>

<%	/////////////////
	// error check

	boolean errors = false;
	String errorMessage = "";
	if( doPost && subject == null ) {
		errors = true;
		errorMessage = YazdLocale.getLocaleKey("Please_enter_a_subject",locale);
	}
	else if( doPost && body == null ) {
		errors = true;
		errorMessage = YazdLocale.getLocaleKey("Sorry_you_cant_post_a_blank_message_please_enter_a_message",locale);
	}
%>

<%	/////////////////////////
	// Create the new message
	if( doPost && (preview || (!withPreview && !errors))) {
		// Create a new message object
		ClientIP clientIP = new ClientIP(localIP,request.getRemoteAddr());
		ForumMessage newMessage = forum.createMessage(user,clientIP);
		if (preview){
		  newMessage.setSubject(URLDecoder.decode(subject));
		  newMessage.setBody(URLDecoder.decode(body));
		} else {
		  newMessage.setSubject(subject);
		  newMessage.setBody(body);
		}
		// add the name and email as an extended property if this user
		// is a guest
		if( user.isAnonymous() ) {
			if( localIP  != null ) {
				newMessage.setProperty("localIP",localIP);
			}
			if( name  != null ) {
				newMessage.setProperty("name",name);
				SkinUtils.store(request,response,"yazd.post.name",name);
			}
			if( email != null ) {
				newMessage.setProperty("email",email);
				SkinUtils.store(request,response,"yazd.post.email",email);
			}
            newMessage.setProperty("IP", request.getRemoteAddr());

		}
		// if this is a reply, add it to the thread
		if( reply ) {
                  	if (isPrivate) {
	                       	if (authToken.getUserID() == -1) {
	                                //When user is logged out and the browser still open, with pressing
        	                        //back button everyone can reach the "reply private" button and try
                	                //to post private message. This last user check eliminates such occasions.
                                	throw new Exception (YazdLocale.getLocaleKey("Anonymous_users_cannot_post_private_messages",locale));
                        	}
        	                //Private massages should know their recipient's user ID.
	                        //Following line sets that value.
                        	newMessage.setReplyPrivateUserId(parentMessage.getUser().getID());
                  	}
			thread.addMessage(parentMessage,newMessage);
		}
		else {
			// it is a new posting

            ForumThread thrd = forum.createThread(newMessage,forumFactory.getThreadType(typeID));
            forum.addThread(thrd);
            if(pageKey!=null){
                forum.addArticleMap(pageKey,thrd);
            }
        }
		// Redirect to the thread list page
        if(referringPage!=null){
            response.sendRedirect(referringPage);
        } else{
            response.sendRedirect("viewForum.jsp?forum="+forumID);
        }
        return;
	}
%>

<%	//////////////////////
	// Header file include

	// The header file looks for the variable "title"
	String title = "Yazd Forums: Post a message";
%>
<%@ include file="header.jsp" %>

<%	//////////////////////
	// breadcrumb variable

	// load up different breadcrumbs based on if this is a reply to a message
	// or a new post.
	String[][] breadcrumbs = null;
	if( reply ) {
		breadcrumbs = new String[][] {
			{ YazdLocale.getLocaleKey("Home",locale), "index.jsp" },
			{ forum.getName(), ("viewForum.jsp?forum=" + forumID) },
			{ thread.getName(), ("viewThread.jsp?forum=" + forumID + "&thread=" + threadID) },
			{ YazdLocale.getLocaleKey("Reply_to_message",locale), "" }
		};
	} else {
		breadcrumbs = new String[][] {
			{ YazdLocale.getLocaleKey("Home",locale), "index.jsp" },
			{ forum.getName(), ("viewForum.jsp?forum="+forumID) },
			{ YazdLocale.getLocaleKey("Post_new_message",locale), "" }
		};
	}
%>
<%@ include file="breadcrumb.jsp" %>

<%	/////////////
	// Toolbar

	// The toolbar file looks for the following variables. To make a particular
	// "button" not appear, set a variable to null.
	boolean showToolbar = true;
	String viewLink = "viewForum.jsp?forum="+forumID;
	String postLink = null;
	String replyLink = null;
	String searchLink = null;
	// we can show a link to a user account if the user is logged in (handled
	// in the toolbar jsp)
	String accountLink = "userAccount.jsp";
%>
<%@ include file="toolbar.jsp" %>

<p>

<h2>
<%	if( reply ) { %>
	<%=YazdLocale.getLocaleKey("Reply_to_message",locale)+":"+ parentMessage.getSubject() %>
<%	} else { %>
	<%=YazdLocale.getLocaleKey("Post_new_message",locale)%>
<%	} %>
</h2>

<form action="post.jsp" name="postForm" method="post">
<input type="hidden" name="localip" id="localip" value="">
<%	if( errors ) { %>
<h4 class="error"><i><%= errorMessage %></i></h4>
<%	} else if (doPost && !errors) {
      preview = true;
	//Preview a message
	//Create a shell message to filter the body
	tmpMsg.setSubject(subject);
	tmpMsg.setBody(body);
	tmpMsg = forum.applyFilters(tmpMsg);
%>

<input type="hidden" name="preview" value="true" />
<input type="hidden" name="body" value="<%= URLEncoder.encode(body) %>">
<input type="hidden" name="type" value="<%= typeID %>" />
<input type="hidden" name="subject" value="<%= URLEncoder.encode(subject) %>" />
<input type="hidden" name="name" value="<%= name %>" />
<input type="hidden" name="email" value="<%= email %>" />
<input type="hidden" name="referer" value="<%= referringPage %>" />

<%  }%>
<!-- <input type="hidden" name="withPreview" id="withPreview" value="true" /> -->
<input type="hidden" name="doPost" value="true">
<input type="hidden" name="reply" value="<%= reply %>">
<input type="hidden" name="isPrivate" value="<%= isPrivate %>">
<input type="hidden" name="referer" value="<%= (!doPost)?request.getHeader("REFERER"):referringPage %>">
<input type="hidden" name="forum" value="<%= forumID %>">
<input type="hidden" name="thread" value="<%= threadID %>">
<input type="hidden" name="message" value="<%= messageID %>">

<table cellpadding="3" cellspacing="0" border="0">
<% if (!preview) { %>
<%	// show name and email textfields if the user is a guest
	if( user.isAnonymous() ) {
		// try to retrieve persisted values of name and email
		String storedName = SkinUtils.retrieve(request,response,"yazd.post.name");
		String storedEmail = SkinUtils.retrieve(request,response,"yazd.post.email");
%>
<tr>
	<td valign="top"><%=YazdLocale.getLocaleKey("Name",locale)%></td>
	<td><input name="name" value="<%= (storedName!=null)?storedName:"" %>" size="30" maxlength="100"></td>
</tr>
<tr>
	<td valign="top"><%=YazdLocale.getLocaleKey("Email",locale)%></td>
	<td><input name="email" value="<%= (storedEmail!=null)?storedEmail:"" %>" size="30" maxlength="100"></td>
</tr>
<%	} %>
<%	// Create the subject in the form we're going to display. If this
	// is a new message, just a blank text field will show up. If this
	// is a reply, the subject of the old message will appear.
	String formSubject = "";
	if( reply ) {
		formSubject = parentMessage.getSubject();
		if( !formSubject.startsWith("Re: ") ) {
			formSubject = "Re: " + formSubject;
		}
	}
	else if( doPost && errors && subject != null ) {
		formSubject = subject;
	}
%>
<tr>
	<td valign="top"><%=YazdLocale.getLocaleKey("Subject",locale)%></td>
	<td><input id="subject1" name="subject" value="<%= formSubject %>" size="40" maxlength="100"></td>
</tr>
<%	if( reply ) {
		// replace \r\n (windows newlines) with unix newlines (\n)
		String parentBody = parentMessage.getUnfilteredBody();
        if (!parentMessage.isApproved()) {
            parentBody = "";
        }
		parentBody = StringUtils.replace(parentBody,"\r\n","\n");
		parentBody = StringUtils.replace(parentBody,"\n","\\n");
		parentBody = StringUtils.replace(parentBody,"\r","");
		// replace quotes
		parentBody = StringUtils.replace(parentBody,"\"","\\\"");
%>
<script language="JavaScript" type="text/javascript">
	var parentMessage = "<%= SkinUtils.quoteOriginal(parentBody,">",50) %>";
	function quoteOrig(ta) {
		ta.value = parentMessage + "\n" + ta.value;
		return false;
	}
</script>
<%	} %>
<tr>
	<td valign="top">&nbsp;</td>
	<td class="toolbar">
<%	// only show a "quote original" link if this is a reply
	if( reply ) { %>
		[ <a href="#" class="toolbar" title="<%=YazdLocale.getLocaleKey("Click_to_quote_the_original_message",locale)%>"
		   onclick="return quoteOrig(document.postForm.body);"
		   ><%=YazdLocale.getLocaleKey("Quote_original",locale)%></a> ]
		&nbsp;&nbsp;
<%	} %>
		<%--
		[ <a href="#" class="toolbar" title="Insert a smiley face">:)</a> ]
		&nbsp;&nbsp;
		[ <a href="#" class="toolbar" title="Insert a sad face">:(</a> ]
		--%>
	</td>
</tr>
<tr>
	<td valign="top"><%= (reply)?YazdLocale.getLocaleKey("Your_reply",locale):YazdLocale.getLocaleKey("Message",locale) %></td>
	<td>        <%if(fck){%>
        <FCK:editor id="body" basePath="FCKeditor/" width="700"
            imageBrowserURL="/vodka/FCKeditor/editor/filemanager/browser/default/browser.html?Type=Image&Connector=connectors/jsp/connector"
            linkBrowserURL="/vodka/FCKeditor/editor/filemanager/browser/default/browser.html?Connector=connectors/jsp/connector"
            flashBrowserURL="/vodka/FCKeditor/editor/filemanager/browser/default/browser.html?Type=Flash&Connector=connectors/jsp/connector"
            imageUploadURL="/vodka/FCKeditor/editor/filemanager/upload/simpleuploader?Type=Image"
            linkUploadURL="/vodka/FCKeditor/editor/filemanager/upload/simpleuploader?Type=File"
            flashUploadURL="/vodka/FCKeditor/editor/filemanager/upload/simpleuploader?Type=Flash"><%= (body != null) ? body : "" %>
        </FCK:editor>
        <%}else{%>
        <textarea name="body" cols="50" rows="13" wrap="virtual"><%= (body != null) ? body : "" %></textarea>
        <%}%>
</td>
</tr>
<%if(!reply){
    Iterator types = forumFactory.getThreadTypeIterator();
    if(types.hasNext()){
%>
<tr>
    <td><%=YazdLocale.getLocaleKey("Message_type",locale)%></td>
    <td><select name="type"><%
        while(types.hasNext()){
            ThreadType type = (ThreadType)types.next();
    %><option value="<%=type.getID()%>"><%=type.getName()%></option>
    <%
        }
    %></select></td>
</tr>
<%
    }
}
%>
<% } else {
	%>
<tr>
<td colspan="2">
	<table bgcolor="#cccccc" cellpadding="0" cellspacing="0" border="0" width="100%" align="right">
	<td><table bgcolor="#cccccc" cellpadding="4" cellspacing="1" border="0" width="100%">
    <tr bgcolor="#eeeeee">
    <td width="1%" nowrap>
    <span class="messageHeader"><%= tmpMsg.getSubject() %></span>
    <br>
    <span class="messageAuthor">
<%
    if( user.isAnonymous() ) {
        String displayName = "<i>"+YazdLocale.getLocaleKey("Anonymous",locale)+"</i>";
        if( name != null ) {
            displayName = "<i>" + name + "</i>";
        }
        if( email != null ) {
            displayName = "<a href=\"mailto:" + email + "\">" + name + "</a>";
        }
        out.print(displayName);
    } else {

        String userName = user.getUsername();
        if( user.isEmailVisible() ) {
            userName = "<a href=\"mailto:" + user.getEmail() + "\">" + userName + "</a>";
        }
        out.print(YazdLocale.getLocaleKey("Posted_by",locale)+": " + userName);
        if( user.isNameVisible() && (user.getName()!=null && !user.getName().equals("")) ) {
            out.print(" ( ");
            if( user.isEmailVisible() ) {
                out.print("&nbsp;<i><a href=\"mailto:" + user.getEmail() + "\">");
            }
            out.print(user.getName());
            if( user.isEmailVisible() ) {
                out.print("</a>");
            }
            out.print(" )");
        }
    }

    Date creationDate = new Date(System.currentTimeMillis());
	SimpleDateFormat dateFormatter = new SimpleDateFormat("EEE, MMM d 'at' hh:mm:ss z");
%>
    </span>
    </td>
    <td width="98%" align="center">
    &nbsp;
    </td>
    <td width="1%" nowrap align="center\">
    <small class="date"><%=YazdLocale.getLocaleKey("Posted",locale)%> <%= SkinUtils.dateToText(creationDate,locale,timezone) %>
    <br><i><%= dateFormatter.format(creationDate) %></i></small>
    </td>
    </tr>
    <tr><td bgcolor="#ffffff" colspan="3">
    <table cellpadding="5" cellspacing="0" border="0" width="100%">
    <td> <%= (body!=null)?tmpMsg.getBody():"" %></td>
    </table>
    </td>
    </tr>
    </table>
    </td>
    </table>
    </td>
</tr>
<% } %>
<tr>
	<td>&nbsp;</td>
	<td>
        <% if (!preview) { %>
        <input type="submit" value="Post <%= YazdLocale.getLocaleKey(((reply)?"Reply":"Message"),locale) %>">
        <input type="submit" name="btnPreview" value="<%=YazdLocale.getLocaleKey("Preview",locale)%>" />
        <% } else {%>
        <input type="submit" value="Post <%= YazdLocale.getLocaleKey(((reply)?"Reply":"Message"),locale) %>">
        <% } %>
		&nbsp;
        <% if (preview) { %>
		<input type="submit" value="<%=YazdLocale.getLocaleKey("Cancel",locale)%>" onclick="history.go(-1);return false;">
        <% } else {%>
		<input type="submit" value="<%=YazdLocale.getLocaleKey("Cancel",locale)%>" onclick="location.href='viewForum.jsp?forum=<%= forumID %>';return false;">
        <% } %>
	</td>
</tr>
</table>

</form>
<applet code="LocalIP.class" name="lip" width=1 height=1>
</applet>

<script language="JavaScript" type="text/javascript" defer="1">
//call the Java applet method and get the local IP address.
document.getElementById("localip").value=document.lip.getLocalIP();
</script>
<script language="JavaScript" type="text/javascript" defer="1">
var obj = document.getElementById("subject1");
if (obj) {
    obj.focus();
}
</script>


<p>


<br clear="all">

<%	/////////////////////
	// page footer
%>
<%@ include file="footer.jsp" %>

