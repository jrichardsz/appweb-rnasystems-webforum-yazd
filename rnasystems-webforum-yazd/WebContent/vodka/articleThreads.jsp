<%@ page import="com.Yasna.forum.util.SkinUtils"%>
<%@ page import="com.Yasna.forum.*"%>
<%@ page import="java.util.Locale"%>
<%!
    //these parameters need to be manually defined in this page.
    final static String pathtopost = "post.jsp";
    final static int ForumID = 8; // the id to the article forum you want to use to store the threads
%>
<%
    String pageKey=request.getRequestURI() + (request.getQueryString()!=null?"?"+request.getQueryString():"");
%>
<%	////////////////////////
    // Authorization check

    // check for the existence of an authorization token
    Authorization aauthToken = SkinUtils.getUserAuthorization(request,response);

    // if the token was null, they're not authorized. Since this skin will
    // allow guests to view forums, we'll set a "guest" authentication
    // token
    if( aauthToken == null ) {
        aauthToken = AuthorizationFactory.getAnonymousAuthorization();
    }
%>
<%
    ForumFactory afactory = ForumFactory.getInstance(aauthToken);
    Forum aforum = afactory.getForum(ForumID);
    ForumThread athread = null;
    try{
        athread = afactory.getArticleThread(pageKey,aforum);
    }catch(ForumThreadNotFoundException e){}
%>
<%
    User yazduser = afactory.getProfileManager().getUser(aauthToken.getUserID());
    Locale yazdlocale = yazduser.getUserLocale();
    String formSubject="article subject";
    boolean reply=false;
    int forumID = ForumID;
    int threadID = -1;
    int messageID = -1; //this value is set if viewthread_include is called.
    if(athread!=null){
        threadID=athread.getID();
    }
%>
<%
    if(threadID>0){
    reply=true;
%>
<%@include file="include/viewthread_include.jsp"%>
<%
    }
%>
<%@include file="include/post_include.jsp"%>
