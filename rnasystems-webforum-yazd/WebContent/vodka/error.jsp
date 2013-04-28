
<%
/**
 *	$RCSfile: error.jsp,v $
 *	$Revision: 1.4 $
 *	$Date: 2005/07/17 16:47:23 $
 */
%>

<%@ page isErrorPage="true" %>

<%@ page import="java.io.*,
                 java.util.*,
                 java.net.*,
                 com.Yasna.forum.*,
                 com.Yasna.forum.util.*,
				 com.Yasna.forum.util.admin.*,
                 com.Yasna.forum.locale.YazdLocale,
                 com.Yasna.forum.Exceptions.RapidPostingException"
%>
<%@ page import="com.Yasna.forum.Exceptions.UserBlackListedException"%>

<%! /////////////
	// Debug mode will print out full error messages useful for an administrator or developer.
	// When debug is false, a generic error message more suitable for an end user is printed and
	// stack traces go to System.err.
	boolean debug = false;
%>
<%	//////////////////
	// get parameters
	String errorMessage = ParamUtils.getParameter(request,"msg");
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
	long userLastVisitedTime = SkinUtils.getLastVisited(request,response);
%>

<%	//////////////////////
	// Header file include

	// The header file looks for the variable "title"
	String title = "Yazd Forums: Error";
%>
<%@ include file="header.jsp" %>


<%	////////////////////
	// Breadcrumb bar

	// The breadcrumb file looks for the variable "breadcrumbs" which
	// represents a navigational path, ie "Home > My Forum > Hello World"
	String[][] breadcrumbs = {
		{ YazdLocale.getLocaleKey("Home",locale), "index.jsp" },
		{ YazdLocale.getLocaleKey("Error",locale), "" }
	};
%>
<%@ include file="breadcrumb.jsp" %>

<p>

<font color="red" size="-1" face="verdana,arial,helvetica">
<b><%=YazdLocale.getLocaleKey("The_following_exception_occured",locale)%>:</b>
<%	if( errorMessage != null ) { %>

	error message: <%= errorMessage %>

<%	}  %>

</font>
<p>

<%	if (exception != null && debug) {
		StringWriter sout = new StringWriter();
		PrintWriter pout = new PrintWriter(sout);
		exception.printStackTrace(pout);
%>
	<pre>
	<%= sout.toString() %>
	</pre>

<%	}
	else if (exception!=null){
   		exception.printStackTrace();
%>

	<%	if( exception instanceof UnauthorizedException ) { %>

		<%=YazdLocale.getLocaleKey("You_were_not_authorized_to_that_action",locale)%>

	<%	}else if( exception instanceof RapidPostingException ) { %>

		<%=exception.getMessage()%>

	<%	}else if( exception instanceof UserBlackListedException ) { %>

		<%=exception.getMessage()%>

	<%	} else { %>

		<%=YazdLocale.getLocaleKey("An_error_occured_while_processing_your_request",locale)%>

	<%	} %>

<% } //end else %>

<p>

<%	/////////////////////
	// page footer
%>
<%@ include file="footer.jsp" %>
