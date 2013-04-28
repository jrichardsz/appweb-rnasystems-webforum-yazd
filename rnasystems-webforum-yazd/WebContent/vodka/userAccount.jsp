
<%
/**
 *	$RCSfile: userAccount.jsp,v $
 *	$Revision: 1.6 $
 *	$Date: 2004/12/21 02:22:53 $
 */
%>

<%@	page import="java.net.URLEncoder,
                 com.Yasna.forum.*,
                 com.Yasna.forum.util.*,java.util.TimeZone,
                    java.util.Locale,com.Yasna.forum.locale.YazdLocale,
                    java.util.Iterator" %>


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

<%	////////////////////
	// get parameters

    boolean showEmail = ParamUtils.getBooleanParameter(request,"showEmail");
    boolean showName = ParamUtils.getBooleanParameter(request,"showName");
    boolean receiveMail = ParamUtils.getBooleanParameter(request,"receiveMail");
    boolean saveChanges = ParamUtils.getBooleanParameter(request,"saveChanges");
    String  password 	= ParamUtils.getParameter(request, "password");		// required to create account
    String  password2 	= ParamUtils.getParameter(request, "password2");		// required to create account
    String  email    	= ParamUtils.getParameter(request, "email");		// required to create account
    String  URL			= ParamUtils.getParameter(request, "URL");
    String  name		= ParamUtils.getParameter(request, "name");
    String  sig			= ParamUtils.getParameter(request, "signature");
    String  colour		= ParamUtils.getParameter(request, "colour");
    String  city		= ParamUtils.getParameter(request, "city");
    String  country			= ParamUtils.getParameter(request, "country");
    String  gender		= ParamUtils.getParameter(request, "gender");
    String vlocale = ParamUtils.getParameter(request,"locale");
    String timezone = ParamUtils.getParameter(request,"timezone");
    String newNickname = ParamUtils.getParameter(request,"nickname");
    // Note about avatar, you can specify a list of images and icons in a select list instead.
    // We just didn't have the funding to purchase a sample icons. We are enabling the feature for your benefit.
    String newAvatar = ParamUtils.getParameter(request,"avatar");


    String message = ParamUtils.getParameter(request,"msg");
%>

<%	///////////////////
	// error/page variables

	boolean unauthorized = false;
	boolean showMessage = (message!=null);
	    boolean emailOK				= ( email != null && email.length() != 0 );
    	boolean passwordOK			= ( password != null && password.length() != 0 );
    	passwordOK 					= (!saveChanges || ((password == null && password2 == null) || (passwordOK && password.equals(password2))));

    	boolean requiredParamsOK	= ( emailOK && passwordOK );
    	boolean createSuccess 		= false;

%>

<%	/////////////////////
	// create user object
	ForumFactory forumFactory = ForumFactory.getInstance(authToken);
	ProfileManager manager = forumFactory.getProfileManager();
    User user = null;
    try {
        user = manager.getUser(authToken.getUserID());
    }
    catch( UserNotFoundException unfe ) {}
    // get the locale for the forum
    // please note that even if the user is anonymous, the locale that will be returned will be the default
    // Locale for the forum.
    Locale locale = user.getUserLocale();

    boolean isEmailVisible = user.isEmailVisible();
    boolean isNameVisible = user.isNameVisible();
    boolean isReceiveEmail = user.getThreadSubscribe();
%>

<%	////////////////////
	// save changes if necessary

	if( saveChanges && user!=null ) {
		try {
			if( showName != isNameVisible ) {
				user.setNameVisible(showName);
			}
			if( showEmail != isEmailVisible ) {
				user.setEmailVisible(showEmail);
			}
            if( receiveMail != isReceiveEmail ) {
                user.setThreadSubscribe(receiveMail);
            }
            if (name != null && !name.equals(user.getName())) {
                user.setName(name);
            }

            if (password !=null && passwordOK) {
                user.setPassword(password);
            }
            if (email != null && !email.equals(user.getEmail())) {
                user.setEmail(email);
            }
            // IP, URL and Signature are extended properties:
            if (!request.getRemoteAddr().equals(user.getProperty("IP"))) {
                user.setProperty("IP", request.getRemoteAddr());
            }
            if (URL != null && !URL.equals(user.getProperty("URL"))) {
                user.setProperty("URL", URL);
            }
            if (sig != null && !sig.equals(user.getProperty("sig"))) {
                user.setProperty("sig", sig);
            }
            if (colour != null && !colour.equals(user.getProperty("colour"))) {
                user.setProperty("colour", colour);
            }
            if (city != null && !city.equals(user.getProperty("city"))) {
                user.setProperty("city", city);
            }
            if (country != null && !country.equals(user.getProperty("country"))) {
                user.setProperty("country", country);
            }
            if (gender != null && !gender.equals(user.getProperty("gender"))) {
                user.setProperty("gender", gender);
            }
            if(newAvatar!=null && !newAvatar.equals(user.getProperty("avatar"))){
                user.setProperty("avatar",newAvatar);
            }
            if(newNickname!=null && !newNickname.equals(user.getProperty("ssnickname"))){
                user.setProperty("ssnickname",newNickname);
            }
            if (vlocale != null && !vlocale.equals(user.getProperty("locale"))) {
                user.setProperty("locale", vlocale);
                // Update locale to ensure that the information is correct if it is changed
                locale = user.getUserLocale();
            }
            if (timezone != null && !timezone.equals(user.getUserTimeZone().getID())) {
                user.setUserTimeZone(timezone);
            }


            response.sendRedirect("userAccount.jsp?msg="
				+ URLEncoder.encode(YazdLocale.getLocaleKey("Changes_saved_successfully",locale)) );
			return;
		}
		catch( UnauthorizedException ue ) {
			unauthorized = true;
		}
	}
%>
<%	/////////////////////
	// page title
	String title = "Yazd User Account";
%>
<%	/////////////////////
	// page header
%>
<%@ include file="header.jsp" %>

<%	////////////////////
	// breadcrumb array & include
	String[][] breadcrumbs = {
		{YazdLocale.getLocaleKey("Home",locale) , "index.jsp" },
		{YazdLocale.getLocaleKey("User_account",locale), "" }
	};
%>
<%@ include file="breadcrumb.jsp" %>

<%	///////////////////
	// toolbar variables
	boolean showToolbar = true;
	String viewLink = null;
	String postLink = null;
	String replyLink = null;
	String searchLink = null;
	String accountLink = null;
%>
<%@ include file="toolbar.jsp" %>

<p>

<span class="pageHeader">
	<%=YazdLocale.getLocaleKey("User_account",locale)%>
</span>

<p>

<%	if( showMessage ) { %>
	<span class="pageMessage">
	<%= message %>
	</span>
	<p>
<%	} %>

<%	if( unauthorized && saveChanges ) { %>
	<span class="error">
		<%=YazdLocale.getLocaleKey("You_are_not_authorized_to_make_changes_to_this_user_account",locale)%>.
	</span>
<%	} %>

<p>


<p>

<form action="userAccount.jsp">
<input type="hidden" name="saveChanges" value="true">
<center>
<table bgcolor="#666666" align="center" cellpadding="0" cellspacing="0" border="0" width="80%">
<td align="center">
<table bgcolor="#ffffff" cellpadding="3" cellspacing="1" border="0" width="100%">
		<tr>
			<td width="40%" align="right">
				<b><%=YazdLocale.getLocaleKey("Username",locale)%>:</b>
			</td>
			<td>
					<%= user.getUsername() == null ? "[error]" : user.getUsername() %>
			</td>
		</tr>

		<tr>
			<td align="right">
				<b><%=YazdLocale.getLocaleKey("Password",locale)%>:</b>
				<%	if( !passwordOK && saveChanges ) { %>
				<font size=4 color="#ff0000" face="arial,helvetica"><b>*</b></font>
				<%	} %>
			</td>
			<td><input type="password" name="password" value="">
			</td>
		</tr>
		<tr>
			<td align="right">
				<b><%=YazdLocale.getLocaleKey("Confirm_password",locale)%>:</b>
				<%	if( !passwordOK && saveChanges ) { %>
				<font size=4 color="#ff0000" face="arial,helvetica"><b>*</b></font>
				<%	} %>
			</td>
			<td><input type="password" name="password2" value="">
		</tr>
		<tr>
			<td align="right">
				<b><%=YazdLocale.getLocaleKey("Email",locale)%>:</b>
				<%	if( !emailOK && saveChanges ) { %>
				<font size=4 color="#ff0000" face="arial,helvetica"><b>*</b></font>
				<%	} %>
			</td>
			<td><input type="text" name="email" value="<%= user.getEmail() == null ? "" : user.getEmail() %>" size=30 maxlength=30>
				<i>(<%=YazdLocale.getLocaleKey("Required",locale)%>)</i>
			</td>
		</tr>
		<tr>
			<td align="right"><%=YazdLocale.getLocaleKey("Name",locale)%>:</td>
			<td><input type="text" name="name" value="<%= user.getName() == null ? "" : user.getName() %>" size=40 maxlength=50></td>
		</tr>
        <tr>
            <td align="right"><span class="label"><%=YazdLocale.getLocaleKey("Avatar",locale)%>:</span></td>
            <td>
                <input type="text" name="avatar" size="30" maxlength="50"
                 value="<%= (user.getProperty("avatar")!=null)?user.getProperty("avatar"):"" %>">
            </td>
        </tr>
    <tr>
        <td align="right"><span class="label"><%=YazdLocale.getLocaleKey("SSNickname",locale)%>:</span></td>
        <td>
            <input type="text" name="nickname" size="30" maxlength="50"
             value="<%= (user.getProperty("ssnickname")!=null)?user.getProperty("ssnickname"):"" %>">
        </td>
    </tr>

        <tr>
			<td align="right"><%=YazdLocale.getLocaleKey("URL",locale)%>:</td>
			<td><input type="text" name="URL" value="<%= user.getProperty("URL") == null ? "" : user.getProperty("URL") %>" size=40 maxlength=255></td>
		</tr>
		<tr>
			<td align="right"><%=YazdLocale.getLocaleKey("City",locale)%>:</td>
			<td><input type="text" name="city" value="<%= user.getProperty("city") == null ? "" : user.getProperty("city") %>" size=40 maxlength=255></td>
		</tr>
		<tr>
			<td align="right"><%=YazdLocale.getLocaleKey("Country",locale)%>:</td>
			<td><input type="text" name="country" value="<%= user.getProperty("country") == null ? "" : user.getProperty("country") %>" size=40 maxlength=255></td>
		</tr>
		<tr>
			<td align="right"><%=YazdLocale.getLocaleKey("Gender",locale)%>:</td>
			<td><select name="gender" size="1">
                <option><%= user.getProperty("gender") == null ? "" : user.getProperty("gender") %>
                <option><%=YazdLocale.getLocaleKey("Female",locale)%>
                <option><%=YazdLocale.getLocaleKey("Male",locale)%>
                </select>
            </td>
		</tr>
		<tr>
			<td align="right"><%=YazdLocale.getLocaleKey("Locale",locale)%>:</td>
			<td><select name="locale" size="1">
                <option>
                <%
                    for (int i=0; i<YazdLocale.supportedLocales.length; i++) {
                        Locale tl = YazdLocale.supportedLocales[i];
                 %>
                        <option value="<%=tl.getLanguage()%><%="".equals(tl.getCountry())?"":","+tl.getCountry()%><%="".equals(tl.getVariant())?"":","+tl.getVariant()%>" <%=locale.equals(tl)?"selected":""%>><%=tl.getDisplayLanguage()%> <%="".equals(tl.getDisplayCountry())?"":", "+tl.getDisplayCountry()%> <%="".equals(tl.getDisplayVariant())?"":", "+tl.getDisplayVariant()%>
                <%
                    }
                %>
                </select>
            </td>
		</tr>
		<tr>
			<td align="right"><%=YazdLocale.getLocaleKey("Time_zone",locale)%>:</td>
			<td><select name="timezone" size="1">
                <option>
                <%
		    int offset =0;
		    String[] timezones = TimeZone.getAvailableIDs();
                    for (int i=0; i<timezones.length ; i++) {
                 %>
			<option value="<%=timezones[i]%>" <%=timezones[i].equals(user.getUserTimeZone().getID())?"selected":""%>><%=TimeZone.getTimeZone(timezones[i]).getDisplayName(locale)%> (<%=timezones[i]%>)
                <%
                    }
                %>
                </select>
            </td>
		</tr>		
		<tr>
			<td align="right"><%=YazdLocale.getLocaleKey("Signature",locale)%>:<br><font size=1>(<%=YazdLocale.getLocaleKey("255_characters_only",locale)%>)</font></td>
			<td><textarea cols=40 rows=4 name="signature" wrap="virtual"><%= user.getProperty("sig") == null ? "" : user.getProperty("sig") %></textarea></td>
		</tr>
		<tr>
			<td align="right"><%=YazdLocale.getLocaleKey("Message_colour",locale)%>:<br><font size=1>(<%=YazdLocale.getLocaleKey("Hex_value",locale)%>)</font></td>
			<td><input type="text" name="colour" value="<%= user.getProperty("colour") == null ? "" : user.getProperty("colour") %>" size=40 maxlength=255></td>
		</tr>
</table>
</td>
</table>
<p>
<table bgcolor="#666666" align="center" cellpadding="0" cellspacing="0" border="0" width="80%">
<td>
<table bgcolor="#666666" cellpadding="3" cellspacing="1" border="0" width="100%">

<tr bgcolor="#eeeeee">
	<td width="60%">&nbsp;</td>
	<td width="20%" align="center"><b><%=YazdLocale.getLocaleKey("Yes",locale)%></b></td>
	<td width="20%" align="center"><b><%=YazdLocale.getLocaleKey("No",locale)%></b></td>
</tr>
<tr bgcolor="#ffffff">
	<td width="60%">
		<%=YazdLocale.getLocaleKey("Show_my_email_address_in_the_forums",locale)%>
	</td>
	<td width="20%" align="center"><input type="radio" name="showEmail" value="true"<%= isEmailVisible?" checked":"" %>></td>
	<td width="20%" align="center"><input type="radio" name="showEmail" value="false"<%= !isEmailVisible?" checked":"" %>></td>
</tr>
<tr bgcolor="#ffffff">
	<td width="60%">
		<%=YazdLocale.getLocaleKey("Show_my_name_in_the_forums",locale)%>
	</td>
	<td width="20%" align="center"><input type="radio" name="showName" value="true"<%= isNameVisible?" checked":"" %>></td>
	<td width="20%" align="center"><input type="radio" name="showName" value="false"<%= !isNameVisible?" checked":"" %>></td>
</tr>
<tr bgcolor="#ffffff">
	<td width="60%">
		<%=YazdLocale.getLocaleKey("Subscribe_to_threads_that_you_post_a_message_in",locale)%>
	</td>
	<td width="20%" align="center"><input type="radio" name="receiveMail" value="true"<%= isReceiveEmail?" checked":"" %>></td>
	<td width="20%" align="center"><input type="radio" name="receiveMail" value="false"<%= !isReceiveEmail?" checked":"" %>></td>
</tr>
<tr bgcolor="#ffffff">
	<td colspan="3" align="center">
		<i><%=YazdLocale.getLocaleKey("You_will_still_see_your_name_and_email_address_in_the_forums",locale)%>.</i>
	</td>
</tr>
</table>
</td>
</table>

<p>

<center>
<input type="submit" value="<%=YazdLocale.getLocaleKey("Save_changes",locale)%>">
&nbsp;
<input type="submit" value="<%=YazdLocale.getLocaleKey("Cancel",locale)%>" onclick="location.href='index.jsp';return false;">
</center>

</form>

<br><br>


<%	/////////////////////
	// page footer
%>
<%@ include file="footer.jsp" %>
