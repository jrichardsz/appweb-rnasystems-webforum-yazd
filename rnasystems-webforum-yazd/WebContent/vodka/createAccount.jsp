
<%
/**
 *	$RCSfile: createAccount.jsp,v $
 *	$Revision: 1.6 $
 *	$Date: 2005/09/26 18:26:26 $
 */
%>

<%@	page import="com.Yasna.forum.*,
                 com.Yasna.forum.util.*,
                    java.util.Locale,
                    com.Yasna.forum.locale.YazdLocale,
                    com.Yasna.util.StringUtils"

%>

<%!	///////////////////
	// global variables

	private final static String errorFieldColor = "#D5E9FD";
    private final static boolean useImageCode = true;  //this variable dictates if Image Code should be used or turned off

%>

<%	////////////////////////
	// Authorization check

	// check for the existence of an authorization token
	Authorization authToken = SkinUtils.getUserAuthorization(request,response);


	// if the token was null, they're not authorized. Since this skin will
	// allow guests to view forums, we'll set a "guest" authentication
	// token. This way, either registered users or guests can create a new account.
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
%>

<%	//////////////////
	// get parameters


    boolean doCreate = ParamUtils.getBooleanParameter(request,"doCreate");
	String newUsername = ParamUtils.getParameter(request,"username");
	String newPassword = ParamUtils.getParameter(request,"password");
	String confirmPassword = ParamUtils.getParameter(request,"confirmPassword");
	String newEmail = ParamUtils.getParameter(request,"email");
	String newName = ParamUtils.getParameter(request,"name");
    String newNickname = ParamUtils.getParameter(request,"nickname");
    // Note about avatar, you can specify a list of images and icons in a select list instead.
    // We just didn't have the funding to purchase a sample icons. We are enabling the feature for your benefit.
    String newAvatar = ParamUtils.getParameter(request,"avatar");
    String code = ParamUtils.getParameter(request,"code");
	boolean autoLogin = ParamUtils.getCheckboxParameter(request,"autoLogin");
%>

<%	//////////////////
	// global error vars

	String errorMessage = "";

	boolean errorUsername         = (newUsername == null);
	boolean errorPassword         = (newPassword == null);
	boolean errorConfirmPassword  = (confirmPassword == null);
    boolean errorCode = true;
    if( session.getAttribute("YazdCode")!=null) {
        errorCode = !session.getAttribute("YazdCode").equals(code);
    }
    if(!useImageCode)errorCode=false; // We are not using Image Code, therefore reset the error.
    boolean errorEmail = true;
    if (newEmail!=null && newEmail.indexOf('@')>0){   //This is not a true check for e-mail, but anything is better than nothing.
        errorEmail= false;
    }
	boolean errorName             = (newName == null);
	boolean errorNoMatchPasswords = true;
	if( !errorPassword && !errorConfirmPassword ) {
		errorNoMatchPasswords = !newPassword.equals(confirmPassword);
	}
	boolean errors = (errorUsername || errorPassword || errorConfirmPassword ||errorCode
						|| errorEmail || errorName || errorNoMatchPasswords );
%>

<%	//////////////////
	// error message
	if( errors ) {
		errorMessage = YazdLocale.getLocaleKey("oops_there_were_errors_in_the_form_please_check_field",locale);
	}
%>

<%	//////////////////////////
	// create user, if no errors
	if( !errors ) {
		try {
			User newUser = forumFactory.getProfileManager()
			                           .createUser(newUsername,newPassword,newEmail);
			newUser.setName( newName );
            newUser.setThreadSubscribe(true);
            if (!request.getRemoteAddr().equals(user.getProperty("IP"))) {
                  newUser.setProperty("IP", request.getRemoteAddr());
            }
            if(newAvatar!=null){
                newUser.setProperty("avatar",newAvatar);
            }
            if(newNickname!=null){
                newUser.setProperty("ssnickname",newNickname);
            }

            // getting to this point means the account was created successfully.
			// We store a success message so the main page can display it.
			SkinUtils.store(request,response,"message",
				YazdLocale.getLocaleKey("Account_created_successfully_need_to_be_activated",locale));
			// set this new user's authorization token
			// SkinUtils.setUserAuthorization(request,response,newUsername,newPassword,autoLogin);
			// redirect to main page
			response.sendRedirect("index.jsp");
			return;
		}
		catch( UserAlreadyExistsException uaee ) {
			errorMessage = YazdLocale.getLocaleKey("Sorry_the_username",locale)+" \"" + newUsername + "\""+ YazdLocale.getLocaleKey("already_exists_try_a_different_username",locale);
			errorUsername = true;
			errors = true;
		}
	}
%>


<%	//////////////////////
	// Header file include

	// The header file looks for the variable "title"
	String title = "Yazd Forums: Example Skin";
    session.setAttribute("YazdCode",StringUtils.randomString(4));

%>
<%@ include file="header.jsp" %>

<%	////////////////////
	// Breadcrumb bar

	// The breadcrumb file looks for the variable "breadcrumbs" which
	// represents a navigational path, ie "Home > My Forum > Hello World"
	String[][] breadcrumbs = {
		{ YazdLocale.getLocaleKey("Home",locale), "index.jsp" },
		{ YazdLocale.getLocaleKey("Create_user_account",locale), "" }
	};
%>
<%@ include file="breadcrumb.jsp" %>

<h2><%=YazdLocale.getLocaleKey("yazd_forum_account_creation",locale)%></h2>

<%	//////////////////
	// print error message if there is one
	if( doCreate && errors ) {
%>
	<h4><i><%= errorMessage %></i></h4>
<%	}
%>

<p>

<center>
	<i><%=YazdLocale.getLocaleKey("All_fields_are_required",locale)%></i>
</center>

<p>

<form action="createAccount.jsp" method="post" name="userForm">
<input type="hidden" name="doCreate" value="true">

	<table cellpadding="3" cellspacing="0" border="0" width="100%">
	<tr>
		<td align="right">
		<span class="label">
			<%=YazdLocale.getLocaleKey("Your_name",locale)%>:
		</span>
		</td>
		<td>
		<%	if( doCreate && errorName ) { %>
		    <input type="text" name="name" size="30" maxlength="50"
			 value="<%= (newName!=null)?newName:"" %>" style="background-color:<%= errorFieldColor %>">
		<%	} else { %>
		    <input type="text" name="name" size="30" maxlength="50"
			 value="<%= (newName!=null)?newName:"" %>">
		<%	} %>
		</td>
	</tr>
	<tr>
		<td align="right"><span class="label"><%=YazdLocale.getLocaleKey("Email",locale)%>:</span></td>
		<td>
		<%	if( doCreate && errorEmail ) { %>
		    <input type="text" name="email" size="30" maxlength="50"
			 value="<%= (newEmail!=null)?newEmail:"" %>" style="background-color:<%= errorFieldColor %>">
		<%	} else { %>
		    <input type="text" name="email" size="30" maxlength="50"
			 value="<%= (newEmail!=null)?newEmail:"" %>">
		<%	} %>
		</td>
	</tr>
	<tr>
		<td align="right"><span class="label"><%=YazdLocale.getLocaleKey("Desired_username",locale)%>:</span></td>
		<td>
		<%	if( doCreate && errorUsername ) { %>
		    <input type="text" name="username" size="30" maxlength="50"
			 value="<%= (newUsername!=null)?newUsername:"" %>" style="background-color:<%= errorFieldColor %>">
		<%	} else { %>
		    <input type="text" name="username" size="30" maxlength="50"
			 value="<%= (newUsername!=null)?newUsername:"" %>">
		<%	} %>
		</td>
	</tr>
	<tr>
		<td align="right"><span class="label"><%=YazdLocale.getLocaleKey("Password",locale)%>:</span></td>
		<td>
		<%	if( doCreate && (errorPassword || errorNoMatchPasswords) ) { %>
		    <input type="password" name="password" size="30" maxlength="50"
			 value="<%= (newPassword!=null)?newPassword:"" %>" style="background-color:<%= errorFieldColor %>">
		<%	} else { %>
		    <input type="password" name="password" size="30" maxlength="50"
			 value="<%= (newPassword!=null)?newPassword:"" %>">
		<%	} %>
		</td>
	</tr>
	<tr>
		<td align="right"><span class="label"><%=YazdLocale.getLocaleKey("Confirm_password",locale)%>:</span></td>
		<td>
		<%	if( doCreate && (errorConfirmPassword || errorNoMatchPasswords) ) { %>
		    <input type="password" name="confirmPassword" size="30" maxlength="50"
			 value="<%= (confirmPassword!=null)?confirmPassword:"" %>" style="background-color:<%= errorFieldColor %>">
		<%	} else { %>
		    <input type="password" name="confirmPassword" size="30" maxlength="50"
			 value="<%= (confirmPassword!=null)?confirmPassword:"" %>">
		<%	} %>
		</td>
	</tr>
        <tr>
            <td align="right"><span class="label"><%=YazdLocale.getLocaleKey("Avatar",locale)%>:</span></td>
            <td>
                <input type="text" name="avatar" size="30" maxlength="50"
                 value="<%= (doCreate && newAvatar!=null)?newAvatar:"" %>">
            </td>
        </tr>
    <tr>
        <td align="right"><span class="label"><%=YazdLocale.getLocaleKey("SSNickname",locale)%>:</span></td>
        <td>
            <input type="text" name="nickname" size="30" maxlength="50"
             value="<%= (doCreate && newNickname!=null)?newNickname:"" %>">
        </td>
    </tr>
<% if(useImageCode){  // We are only going to show these lines if we are using the Image Code%>
	<tr>
		<td align="right"><span class="label"><%=YazdLocale.getLocaleKey("Enter_code",locale)%></span>
        <img src="yazd.yazdcodegenerator?no-cache">
		</td>
		<td>
		    <input type="input" name="code" size="30" maxlength="50" <%=(doCreate && errorCode)?"style=\"background-color:"+ errorFieldColor+"\"":""%>>
		</td>
	</tr>
<%}%>
	<tr>
		<td align="right"><label for="cb01"><span class="label"><%=YazdLocale.getLocaleKey("Auto_login",locale)%>:</span></label></td>
		<td>
			<input id="cb01" type="checkbox" name="autoLogin"<%= autoLogin?" checked":"" %>>
		</td>
	</tr>
	<tr>
		<td align="center" colspan="2">
			<br>
			<input type="submit" value="<%=YazdLocale.getLocaleKey("Create_account",locale)%>">
		</td>
	</tr>
	</table>
	<script language="JavaScript" type="text/javascript">
	<!--
		document.userForm.name.focus();
	//-->
	</script>
</form>


<%	/////////////////////
	// page footer
%>
<%@ include file="footer.jsp" %>



