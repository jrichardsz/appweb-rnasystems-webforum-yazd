
<%
/**
 *	$RCSfile: main.jsp,v $
 *	$Revision: 1.4 $
 *	$Date: 2006/01/07 00:21:56 $
 */
%>

<%@ page language="java" pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" import="java.util.*,
                 com.Yasna.forum.*" %>
<%@ page import="javax.xml.parsers.DocumentBuilderFactory"%>
<%@ page import="javax.xml.parsers.DocumentBuilder"%>
<%@ page import="org.w3c.dom.Document"%>
<%@ page import="org.w3c.dom.NodeList"%>
<%@ page import="org.w3c.dom.Element"%>

<jsp:useBean id="adminBean" scope="session"
 class="com.Yasna.forum.util.admin.AdminBean"/>

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


<html>
<head>
	<title>main.jsp</title>
</head>

<body background="images/shadowBack.gif" bgcolor="#FFFFFF" text="#000000" link="#0000FF" vlink="#800080" alink="#FF0000">

<p>

<font face="verdana,arial,helvetica,sans-serif">
<b>Welcome to Yazd Admin</b>
</font>

<font face="verdana,arial,helvetica,sans-serif" size="-1">

<p>

You are running Yazd version <b><%= PropertyManager.getYazdVersion() %></b>

<p>

<i>Please send feedback to
	<a href="mailto:yazd@Yasna.com">yazd@Yasna.com</a> about
	this tool.<br>
</i>
<%
    try{
        // We will assume that they are using HTTP portocol.
        DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
        DocumentBuilder parser = factory.newDocumentBuilder();
        Document document = parser.parse("http://www.forumsoftware.ca/yazdversion.xml");
        NodeList sections = document.getElementsByTagName("YazdVersion");
        Element ele = (Element)sections.item(0);
        int MajorVersion = Integer.parseInt(ele.getAttribute("MajorVersion"));
        int MinorVersion = Integer.parseInt(ele.getAttribute("MinorVersion"));
        int Revision = Integer.parseInt(ele.getAttribute("Revision"));
        NodeList list = ele.getChildNodes();
        if(PropertyManager.getYazdVersionMajor() >= MajorVersion && PropertyManager.getYazdVersionMinor() >= MinorVersion && PropertyManager.getYazdVersionRevision() >= Revision){
            out.println("<p>Installed version is current");
        } else {
            out.println("<p><b>New Version of Yazd Forum Software is available to download!</b> (<a href=\"http://www.forumsoftware.ca\" target=\"_blank\">http://www.forumsoftware.ca</a>)");
        }

    } catch(Exception e){
        out.println("Exeption"+e.getMessage());
        e.printStackTrace();
    }

%>

</ul>
</font>

</body>
</html>
