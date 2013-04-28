
<%
/**
 *	$RCSfile: login.jsp,v $
 *	$Revision: 1.5 $
 *	$Date: 2004/12/21 02:22:53 $
 */
%>

<%@	page import="com.Yasna.forum.*,
                 com.Yasna.forum.util.*,
                    com.Yasna.forum.locale.YazdLocale,
                    java.util.Locale"
	errorPage="error.jsp"
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

<%	/////////////////////////////
	// get parameters, do a login

	// do a login if a login is requested
	boolean doLogin = ParamUtils.getBooleanParameter(request,"doLogin");
	String loginUsername = ParamUtils.getParameter(request,"username");
	String loginPassword = ParamUtils.getParameter(request,"password");
	boolean autoLogin = ParamUtils.getCheckboxParameter(request,"autoLogin");
	String referringPage = ParamUtils.getParameter(request,"referer");
	boolean errors = false;
	String errorMessage = "";
	if (referringPage==null || "".equals(referringPage) || "null".equals(referringPage)){
	   // This is to correct the problem that there was no referer was sent.
           referringPage="index.jsp";
        }
	if( doLogin ) {
		if( loginUsername == null || loginPassword == null ) {
			errors = true;
			errorMessage = YazdLocale.getLocaleKey("Please_enter_a_username_and_password",locale);
		}
		if( !errors ) {
			try {
				SkinUtils.setUserAuthorization(
					request,response,loginUsername,loginPassword,autoLogin
				);
				// at this point if no exceptions were thrown, the user is
				// logged in, so redirect to the page that sent us here:
				response.sendRedirect(referringPage);
				return;
			}
			catch( UnauthorizedException e ) {
				errors = true;
				errorMessage = YazdLocale.getLocaleKey("Invalid_username_or_password",locale);
			}
		}
	}
%>

<%	//////////////////////
	// Header file include

	// The header file looks for the variable "title"
	String title = "Yazd Forums: Login";
%>
<%@ include file="header.jsp" %>


<%	////////////////////
	// Breadcrumb bar

	// The breadcrumb file looks for the variable "breadcrumbs" which
	// represents a navigational path, ie "Home > My Forum > Hello World"
	String[][] breadcrumbs = {
		{ YazdLocale.getLocaleKey("Home",locale), "index.jsp" },
		{ YazdLocale.getLocaleKey("Login",locale), "" }
	};
%>
<%@ include file="breadcrumb.jsp" %>

<%	///////////////////////
	// breadcrumb variables

	// change these values to customize the look of your breadcrumb bar

	// Colors
	String loginBgcolor = "#999999";
	String loginFgcolor = "#ffffff";
	String loginHeaderColor = "#ccccdd";
%>

<h2><%=YazdLocale.getLocaleKey("Login",locale)%></h2>

<%	if( errors ) { %>
<h4><i><%=YazdLocale.getLocaleKey("Error",locale)%>: <%= errorMessage %></i></h4>
<%	} %>

<form action="login.jsp" method="post" name="loginForm">
<input type="hidden" name="doLogin" value="true">
<input type="hidden" name="referer" value="<%= (!errors)?request.getHeader("REFERER"):referringPage %>">

<center>

<table bgcolor="<%= loginBgcolor %>" cellpadding="1" cellspacing="0" border="0" width="350">
<td>
<table bgcolor="<%= loginFgcolor %>" cellpadding="4" cellspacing="0" border="0" width="100%">
<tr>
	<td align="right" width="50%">
	<%=YazdLocale.getLocaleKey("Username",locale)%>
	</td>
	<td width="50%">
	<input type="text" name="username" size="15" maxlength="25"
	 value="<%= (loginUsername!=null)?loginUsername:"" %>">
	</td>
</tr>
<tr>
	<td align="right" width="50%">
	<%=YazdLocale.getLocaleKey("Password",locale)%>
	</td>
	<td width="50%">
	<input type="password" name="password" size="15" maxlength="25"
	 value="<%= (loginPassword!=null)?loginPassword:"" %>">
	</td>
</tr>
<tr>
	<td align="right" width="50%">
	<label for="cb01"><%=YazdLocale.getLocaleKey("Enable_auto_login",locale)%></label>
	</td>
	<td width="50%">
	<input type="checkbox" name="autoLogin" id="cb01">
	<span class="label">
	(<a href=""
	  onclick="alert('<%=YazdLocale.getLocaleKey("Warning_this_stores_your_username_and_password_in_a_cookie_on_your_hard_drive",locale)%>');return false;"
	  ><b>?</b></a>)
	</span>
	</td>
</tr>
<tr bgcolor="<%= loginHeaderColor %>">
	<td align="right" colspan="2">
	<input type="submit" value="<%=YazdLocale.getLocaleKey("Login",locale)%>">
	</td>
</tr>
</table>
</td>
</table>

</center>

<p>

<script language="JavaScript" type="text/javascript">
<!--
	document.loginForm.username.focus();
//-->
</script>

<center>
<i><%=YazdLocale.getLocaleKey("Dont_have_an_account",locale)%> <a href="createAccount.jsp"><%=YazdLocale.getLocaleKey("Create_one",locale)%></a>.</i>
</center>

</form>

<p>

<%	/////////////////////
	// page footer
%>
<%@ include file="footer.jsp" %>


