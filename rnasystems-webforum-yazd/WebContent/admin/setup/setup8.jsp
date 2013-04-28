<%
/**
 * Yazd Setup Tool
 * November 28, 2000
 */
%>

<%@ page import="com.Yasna.forum.*"%>

<html>
<head>
	<title>Yazd Setup - Step 8</title>
		<link rel="stylesheet" href="style/global.css">
</head>

<body bgcolor="#FFFFFF" text="#000000" link="#0000FF" vlink="#800080" alink="#FF0000">

<img src="images/setup.gif" width="210" height="38" alt="Yazd Setup" border="0">
<hr size="0">

<p>
<b>Setup Complete!</b>

<font size="2">
<ul>
	Yazd setup is now complete. Click the button below to jump to the admin tool
	where you'll be able to create and administer your forums.
</ul>
</font>

<form action="../index.jsp" type=get>

<%
	PropertyManager.setProperty( "setup", "true" );
    PropertyManager.setProperty( "User.DisableActivation", "false" );
    PropertyManager.setProperty( "yazdMailFrom", "notvalid@forumsoftware.ca" );
    PropertyManager.setProperty( "yazdThreadWatch.MailSubject", "Default Thread Watch Message" );
    PropertyManager.setProperty( "yazdMailSMTPServer", "localhost" );
    PropertyManager.setProperty( "yazdThreadWatch.MailBody", "Default Body - Change it in property manager" );
    PropertyManager.setProperty( "yazdUrl", "http://localhost/" );
    PropertyManager.setProperty( "Sequence.UseDatabase", "false" );
    PropertyManager.setProperty( "yazdMailSubject", "Default Yazd Subject" );
    PropertyManager.setProperty( "DefaultLocale", "en,CA" );

%>

<center>
<input type="submit" value="Login to Yazd Admin">
</center>

<br>
<hr size="0">
<center><font size="-1"><i>www.forumsoftware.ca</i></font></center>
</font>
</body>
</html>
