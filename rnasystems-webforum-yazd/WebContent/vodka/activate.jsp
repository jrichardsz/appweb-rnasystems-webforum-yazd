<%@ page import="com.Yasna.forum.util.ParamUtils,
                 com.Yasna.forum.ForumFactory,
                 com.Yasna.forum.AuthorizationFactory,
                 com.Yasna.forum.util.SkinUtils"%>
<%
    int userid = ParamUtils.getIntParameter(request,"user",-1);
    String code = ParamUtils.getParameter(request,"code");
    boolean success = false;
    if (userid >-1){
        success = ForumFactory.getInstance(AuthorizationFactory.getAnonymousAuthorization()).getProfileManager().activateUser(userid,code);
    }
    if (success){
        SkinUtils.store(request,response,"message","Successfully activated user");
    } else{
        SkinUtils.store(request,response,"message","Invalid userid and activation code provided");        
    }
    response.sendRedirect("index.jsp");
%>