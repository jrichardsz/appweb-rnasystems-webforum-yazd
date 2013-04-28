<%@ page import="com.Yasna.forum.util.SkinUtils,
org.w3c.dom.Document,org.w3c.dom.Element,java.util.Iterator,com.Yasna.forum.*,
com.Yasna.forum.locale.YazdLocale,java.util.Locale,javax.xml.transform.dom.DOMSource,
javax.xml.transform.TransformerFactory,javax.xml.transform.stream.StreamResult,
javax.xml.transform.Transformer,javax.xml.parsers.ParserConfigurationException,
javax.xml.parsers.DocumentBuilderFactory,javax.xml.parsers.DocumentBuilder"
         %><%
    response.setContentType("text/xml; charset=UTF-8");
    response.setHeader("Cache-Control","no-cache");

    Authorization authToken = SkinUtils.getUserAuthorization(request,response);

    // if the token was null, they're not authorized. Since this skin will
    // allow guests to view forums, we'll set a "guest" authentication
    // token
    if( authToken == null ) {
        authToken = AuthorizationFactory.getAnonymousAuthorization();
    }
    ForumFactory factory = ForumFactory.getInstance(authToken);
    ProfileManager profile = factory.getProfileManager();
    Document doc=null;
    try {
        DocumentBuilderFactory xfactory=DocumentBuilderFactory.newInstance();
        DocumentBuilder builder = xfactory.newDocumentBuilder();
        doc=builder.newDocument();
    } catch (ParserConfigurationException pce) {
        pce.printStackTrace();
    }

    Element users = doc.createElement("CurrentSessionList");
    Locale locale = profile.getUser(authToken.getUserID()).getUserLocale();


    Iterator sessions = factory.getSessionList();
    SessionVO tsess;
    String userinfo;
    int usercount=0;
    while(sessions.hasNext()){
	usercount++;
        tsess=(SessionVO)sessions.next();
        if(tsess.getUserID() > 1){
            userinfo=profile.getUser(tsess.getUserID()).getUsername();
        } else {
            userinfo=YazdLocale.getLocaleKey("Anonymous",locale);
        }
        userinfo=userinfo+"<br><small>("+tsess.getIP()+")</small>";
        Element userele = doc.createElement("UserInfo");
        userele.setAttribute("User",userinfo);
        users.appendChild(userele);
    }
    users.setAttribute("Count",Integer.toString(usercount));
    users.setAttribute("YesterdayCount",Integer.toString(factory.getYesterdayUserCount()));
    doc.appendChild(users);
    doc.getDocumentElement().normalize();
    TransformerFactory tFactory = TransformerFactory.newInstance();
    Transformer transformer = tFactory.newTransformer();

    DOMSource source = new DOMSource(doc);

    StreamResult result = new StreamResult(out);
    transformer.transform(source, result);

 //   StreamResult dbgResult = new StreamResult(System.out);
 //   transformer.transform(source, dbgResult);
 //   System.out.println("");
 //   System.out.println("--- END DOGET ---");
//    out.flush();



%>