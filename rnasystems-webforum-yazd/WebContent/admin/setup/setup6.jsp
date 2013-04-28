<%
/**
 * Yazd Setup Tool
 * November 28, 2000
 */
%>

<%@ page import="java.io.*,
                 java.util.*,
				 java.sql.*,
                 com.Yasna.forum.*,
				 com.Yasna.forum.util.*,
                 com.Yasna.util.*,
				 com.Yasna.forum.database.*"%>

<% try { %>

<%	boolean setupError = false;
	String errorMessage = "";
	//Make sure the install has not already been completed.
	String setup = PropertyManager.getProperty("setup");
	if( setup != null && setup.equals("true") ) {
%>
	<html>
<head>
	<title>Yazd Setup - Step 5</title>
		<link rel="stylesheet" href="style/global.css">
</head>

<body bgcolor="#FFFFFF" text="#000000" link="#0000FF" vlink="#800080" alink="#FF0000">

<img src="images/setup.gif" width="210" height="38" alt="Yazd Setup" border="0">
<hr size="0"><p>

	<font color="Red">Error!</font>
	<p><font size=2>

	Yazd setup appears to have already been completed. If you'd like to re-run
	this tool, delete the 'setup=true' property from your yazd.properties file.

	</font>

<%
	}
	else {

		boolean error = false;
		String yazdMailSMTPServer = ParamUtils.getParameter(request,"yazdMailSMTPServer");
                String yazdMailFrom = ParamUtils.getParameter(request,"yazdMailFrom");
                String yazdUrl = ParamUtils.getParameter(request,"yazdUrl");
                String yazdMailSubject = ParamUtils.getParameter(request,"yazdMailSubject");
                String yazdMailBody = ParamUtils.getParameter(request,"yazdMailBody");
                String yazdWatchMailBody = ParamUtils.getParameter(request,"yazdWatchMailBody");
                String yazdWatchSubject = ParamUtils.getParameter(request,"yazdWatchSubject");
                String yazdActivateMailSubject = ParamUtils.getParameter(request,"yazdActivateMailSubject");
                String yazdActivateMailBody = ParamUtils.getParameter(request,"yazdActivateMailBody");
		if (yazdMailSMTPServer == null) {
		    yazdMailSMTPServer = PropertyManager.getProperty("yazdMailSMTPServer");
                    yazdMailFrom = PropertyManager.getProperty("yazdMailFrom");
                    yazdMailSubject = PropertyManager.getProperty("yazdMailSubject");
                    yazdMailBody = PropertyManager.getProperty("yazdMailBody");
                    yazdUrl = PropertyManager.getProperty("yazdUrl");
                    yazdWatchMailBody = PropertyManager.getProperty("yazdThreadWatch.MailBody");
                    yazdWatchSubject = PropertyManager.getProperty("yazdThreadWatch.MailSubject");
                    yazdActivateMailSubject =PropertyManager.getProperty("yazdActivate.MailSubject");
                    yazdActivateMailBody = PropertyManager.getProperty("yazdActivate.MailBody");
		}
		boolean setYazdMailSMTPServer = ParamUtils.getBooleanParameter(request,"setYazdMailSMTPServer");
                boolean setYazdMailFrom = ParamUtils.getBooleanParameter(request,"setYazdMailFrom");
		//Look for error case, but only give a new error message if there isn't
		//already an error.
		if(setYazdMailSMTPServer && yazdMailSMTPServer == null ) {
			error = true;
			errorMessage = "No value was entered for Yazd Mail SMTP server.";
		}
		if(setYazdMailFrom && yazdMailFrom == null ) {
			error = true;
			errorMessage = "No value was entered for Yazd Mail From.";
		}

	%>
	<%	if( !error && setYazdMailSMTPServer && setYazdMailFrom) {
                       try{
                          MailSender sender = new MailSender( yazdMailSMTPServer, yazdMailFrom, yazdMailFrom, null, null, yazdMailSubject, yazdMailBody);
                          sender.sendForTest();
                       } catch (Exception e) {
                           error = true;
                           errorMessage = e.getMessage();
                       }
                       if( !error ) {
				PropertyManager.setProperty("yazdMailSMTPServer",yazdMailSMTPServer);
                                PropertyManager.setProperty("yazdMailFrom",yazdMailFrom);
                                PropertyManager.setProperty("yazdMailSubject",yazdMailSubject);
                                PropertyManager.setProperty("yazdMailBody",yazdMailBody);
                                PropertyManager.setProperty("yazdUrl",yazdUrl);
				// redirect
				response.sendRedirect("setup7.jsp");
				return;
			}
		} else {
}
%>


<html>
<head>
	<title>Yazd Setup - Step 6</title>
		<link rel="stylesheet" href="style/global.css">
</head>

<body bgcolor="#FFFFFF" text="#000000" link="#0000FF" vlink="#800080" alink="#FF0000">

<img src="images/setup.gif" width="210" height="38" alt="Yazd Setup" border="0">
<hr size="0"><p>

<b>Yazd Mail Configuration Directory</b>

<ul>

<font size="2">
	Yazd needs a mail configuration to be set so the users can received a
        mail notification when a reply to there message occure.

<%
	if (error) {
%>

	<font color="Red">Error:</font></font>	<i><%= errorMessage %></i>

	<p>

<%	} %>


	<form action="setup6.jsp" method="post">
	<input type="hidden" name="setYazdMailSMTPServer" value="true">
        <input type="hidden" name="setYazdMailFrom" value="true">

	<table cellpadding="3" cellspacing="0" border="0">
	<tr>
		<td><font size="-1">Yazd Mail SMTP Server:</font></td>
		<td><input type="text" size="50" name="yazdMailSMTPServer" value="<%= (yazdMailSMTPServer!=null)?yazdMailSMTPServer:"" %>"></td>
	</tr>
	<tr>
		<td><font size="-1">Yazd Mail From:</font></td>
		<td><input type="text" size="50" name="yazdMailFrom" value="<%= (yazdMailFrom!=null)?yazdMailFrom:"" %>"></td>
	</tr>
	<tr>
		<td><font size="-1">Yazd URL - where forum is runing(e.g http://host:8080/yazd/bay/):<br><i>must end with a slash / </i></font></td>
		<td><input type="text" size="50" name="yazdUrl" value="<%= (yazdUrl!=null)?yazdUrl:"" %>"></td>
	</tr>
	<tr>
		<td><font size="-1">Yazd Mail Subject:</font></td>
		<td><input type="text" size="50" name="yazdMailSubject" value="<%= (yazdMailSubject!=null)?yazdMailSubject:"" %>"></td>
	</tr>
	<tr>
		<td><font size="-1">Yazd Mail Body:</font></td>
		<td><textarea name="yazdMailBody" rows="3" cols="40"><%= (yazdMailBody!=null)?yazdMailBody:"" %></textarea></td>
	</tr>
	<tr>
		<td><font size="-1">Yazd Thread Watch E-mail Subject:</font></td>
		<td><input type="text" size="50" name="yazdWatchSubject" value="<%= (yazdWatchSubject!=null)?yazdWatchSubject:"" %>"></td>
	</tr>
	<tr>
		<td><font size="-1">Yazd Thread Watch Mail Body:</font></td>
		<td><textarea name="yazdWatchMailBody" rows="3" cols="40"><%= (yazdWatchMailBody!=null)?yazdWatchMailBody:"" %></textarea></td>
	</tr>
	<tr>
		<td><font size="-1">Yazd Account Activation E-mail Subject:</font></td>
		<td><textarea name="yazdActivateMailSubject" rows="3" cols="40"><%= (yazdActivateMailSubject!=null)?yazdActivateMailSubject:"" %></textarea></td>
	</tr>
	<tr>
		<td><font size="-1">Yazd Account Activation E-mail Body:</font></td>
		<td><textarea name="yazdActivateMailBody" rows="3" cols="40"><%= (yazdActivateMailBody!=null)?yazdActivateMailBody:"" %></textarea></td>
	</tr>
	</table>

</ul>

<center>
<input type="submit" value="Continue">
</center>
</form>

<% } //end else of setupError %>

<p>
You can <a href="setup7.jsp"> skip this step</a>.
<p>
<hr size="0">
<center><font size="-1"><i>www.forumsoftware.ca</i></font></center>
</font>
</body>
</html>

<%	} catch (Exception e ) {
		e.printStackTrace();
	}
%>
