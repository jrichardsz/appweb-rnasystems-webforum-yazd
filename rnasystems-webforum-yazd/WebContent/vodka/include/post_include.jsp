<%@ page import="com.Yasna.forum.locale.YazdLocale"%>
<%@ page import="com.Yasna.util.StringUtils"%>
<%@ page import="com.Yasna.forum.util.SkinUtils"%>
<%@ taglib uri="//WEB-INF/tld/FCKeditor.tld" prefix="FCK" %>
<%
    //This page needs the following variables:
    // Locale yazdlocale
    // String formSubject
    // String pathPost
    // boolean reply
    // int forumID
    // int threadID
    // int messageID
    // User yazduser
    // String pageKey
    boolean fck=false;
%>
<h2>
<%=YazdLocale.getLocaleKey("Post_new_message",yazdlocale)%>
</h2>

<form action="<%=pathtopost%>" name="postForm" method="post">
<input type="hidden" name="localip" id="localip" value="">
    <input type="hidden" name="doPost" value="true">
    <input type="hidden" name="reply" value="<%= reply %>">
    <input type="hidden" name="isPrivate" value="false">
    <input type="hidden" name="referer" value="<%=request.getRequestURI() + (request.getQueryString()!=null?"?"+request.getQueryString():"")%>">
    <input type="hidden" name="forum" value="<%= forumID %>">
    <input type="hidden" name="thread" value="<%= threadID %>">
    <input type="hidden" name="message" value="<%= messageID %>">
    <input type="hidden" name="pagekey" value="<%= pageKey %>">

<table cellpadding="3" cellspacing="0" border="0">
<%	// show name and email textfields if the user is a guest
	if( yazduser.isAnonymous() ) {
		// try to retrieve persisted values of name and email
		String storedName = SkinUtils.retrieve(request,response,"yazd.post.name");
		String storedEmail = SkinUtils.retrieve(request,response,"yazd.post.email");
%>
<tr>
	<td valign="top"><%=YazdLocale.getLocaleKey("Name",yazdlocale)%></td>
	<td><input name="name" value="<%= (storedName!=null)?storedName:"" %>" size="30" maxlength="100"></td>
</tr>
<tr>
	<td valign="top"><%=YazdLocale.getLocaleKey("Email",yazdlocale)%></td>
	<td><input name="email" value="<%= (storedEmail!=null)?storedEmail:"" %>" size="30" maxlength="100"></td>
</tr>
<%	} %>
<tr>
	<td valign="top"><%=YazdLocale.getLocaleKey("Subject",yazdlocale)%></td>
	<td><input id="subject1" name="subject" value="<%= formSubject %>" size="40" maxlength="100"></td>
</tr>
<tr>
	<td valign="top"><%= (reply)?YazdLocale.getLocaleKey("Your_reply",yazdlocale):YazdLocale.getLocaleKey("Message",yazdlocale) %></td>
	<td>
        <%if(fck){%>
        <FCK:editor id="body" basePath="FCKeditor/" width="700"
            imageBrowserURL="/vodka/FCKeditor/editor/filemanager/browser/default/browser.html?Type=Image&Connector=connectors/jsp/connector"
            linkBrowserURL="/vodka/FCKeditor/editor/filemanager/browser/default/browser.html?Connector=connectors/jsp/connector"
            flashBrowserURL="/vodka/FCKeditor/editor/filemanager/browser/default/browser.html?Type=Flash&Connector=connectors/jsp/connector"
            imageUploadURL="/vodka/FCKeditor/editor/filemanager/upload/simpleuploader?Type=Image"
            linkUploadURL="/vodka/FCKeditor/editor/filemanager/upload/simpleuploader?Type=File"
            flashUploadURL="/vodka/FCKeditor/editor/filemanager/upload/simpleuploader?Type=Flash">
        </FCK:editor>
        <%}else{%>
        <textarea name="body" cols="50" rows="13" wrap="virtual"></textarea>
        <%}%>
    </td>
</tr>
<tr>
	<td>&nbsp;</td>
	<td>
        <input type="submit" value="Post <%= YazdLocale.getLocaleKey(((reply)?"Reply":"Message"),yazdlocale) %>">
        <input type="submit" name="btnPreview" value="<%=YazdLocale.getLocaleKey("Preview",yazdlocale)%>" />
		&nbsp;
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
