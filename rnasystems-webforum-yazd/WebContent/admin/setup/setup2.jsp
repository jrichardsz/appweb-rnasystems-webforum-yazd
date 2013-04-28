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
				 com.Yasna.forum.database.*"%>
<%
    String path = ParamUtils.getParameter(request,"path");
    boolean doUpdate = ParamUtils.getBooleanParameter(request,"doUpdate");
    if (doUpdate && path !=null  ){
        PropertyManager.setPath(path+"/yazd.properties");
        response.sendRedirect("setup3.jsp");
    }
%>

<html>
<head>
	<title>Yazd Setup - Step 2</title>
		<link rel="stylesheet" href="style/global.css">
</head>

<body bgcolor="#FFFFFF" text="#000000" link="#0000FF" vlink="#800080" alink="#FF0000">

<img src="images/setup.gif" width="210" height="38" alt="Yazd Setup" border="0">
<hr size="0"><p>

<b>Setup Your Properties File Path</b>
Please Specify Working Directory for the properties file:
<br><i>(if not sure just accept the default)</i> <br><br>
<i>Note: This has to be part of your application classpath.</i>
<center>
<form action="setup2.jsp">
<input type="hidden" name="doUpdate" value="true">
<input type="text" value="<%=application.getRealPath("/WEB-INF/classes/")%>" name="path" size="80"><br><br>
<input type="submit" name="operation" value="Continue &gt;">
</form>
</center>
<hr size="0">
<center><font size="-1"><i>www.forumsoftware.ca</i></font></center>
</font>
</body>
</html>


