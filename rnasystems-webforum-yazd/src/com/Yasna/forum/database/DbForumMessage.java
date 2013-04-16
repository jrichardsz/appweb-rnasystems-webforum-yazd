/**
 * Copyright (C) 2001 Yasna.com. All rights reserved.
 *
 * ===================================================================
 * The Apache Software License, Version 1.1
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in
 *    the documentation and/or other materials provided with the
 *    distribution.
 *
 * 3. The end-user documentation included with the redistribution,
 *    if any, must include the following acknowledgment:
 *       "This product includes software developed by
 *        Yasna.com (http://www.yasna.com)."
 *    Alternately, this acknowledgment may appear in the software itself,
 *    if and wherever such third-party acknowledgments normally appear.
 *
 * 4. The names "Yazd" and "Yasna.com" must not be used to
 *    endorse or promote products derived from this software without
 *    prior written permission. For written permission, please
 *    contact yazd@yasna.com.
 *
 * 5. Products derived from this software may not be called "Yazd",
 *    nor may "Yazd" appear in their name, without prior written
 *    permission of Yasna.com.
 *
 * THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESSED OR IMPLIED
 * WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 * OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED.  IN NO EVENT SHALL YASNA.COM OR
 * ITS CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF
 * USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT
 * OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 * ====================================================================
 *
 * This software consists of voluntary contributions made by many
 * individuals on behalf of Yasna.com. For more information
 * on Yasna.com, please see <http://www.yasna.com>.
 */

/**
 * Copyright (C) 2000 CoolServlets.com. All rights reserved.
 *
 * ===================================================================
 * The Apache Software License, Version 1.1
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in
 *    the documentation and/or other materials provided with the
 *    distribution.
 *
 * 3. The end-user documentation included with the redistribution,
 *    if any, must include the following acknowledgment:
 *       "This product includes software developed by
 *        CoolServlets.com (http://www.coolservlets.com)."
 *    Alternately, this acknowledgment may appear in the software itself,
 *    if and wherever such third-party acknowledgments normally appear.
 *
 * 4. The names "Jive" and "CoolServlets.com" must not be used to
 *    endorse or promote products derived from this software without
 *    prior written permission. For written permission, please
 *    contact webmaster@coolservlets.com.
 *
 * 5. Products derived from this software may not be called "Jive",
 *    nor may "Jive" appear in their name, without prior written
 *    permission of CoolServlets.com.
 *
 * THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESSED OR IMPLIED
 * WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 * OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED.  IN NO EVENT SHALL COOLSERVLETS.COM OR
 * ITS CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF
 * USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT
 * OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 * ====================================================================
 *
 * This software consists of voluntary contributions made by many
 * individuals on behalf of CoolServlets.com. For more information
 * on CoolServlets.com, please see <http://www.coolservlets.com>.
 */

package com.Yasna.forum.database;

import java.sql.*;
import java.util.*;
import java.text.SimpleDateFormat;

import com.Yasna.forum.*;
import com.Yasna.forum.Exceptions.RapidPostingException;
import com.Yasna.forum.Exceptions.UserBlackListedException;
import com.Yasna.forum.util.ClientIP;
import com.Yasna.util.Cacheable;
import com.Yasna.util.CacheSizes;
import com.Yasna.util.StringUtils;

/**
 * Database implementation of the ForumMessage interface. It stores messages
 * in the YazdMessage database table, and message properties in yazdMessageProp
 * table.
 */
public final class DbForumMessage implements ForumMessage, Cacheable {

    /** DATABASE QUERIES **/
    private static final String CHECK_LASTPOST=
            "select max(a.creationDate) as lastpost from yazdMessage a,yazdMessageProp b where a.messageID=b.messageID and b.name=? and b.propValue=?";
    private static final String CHECK_LASTPOSTWITHUSER =
            "select max(creationDate) as lastpost from yazdMessage where userID=?";
    private static final String LOAD_PROPERTIES =
        "SELECT name, propValue FROM yazdMessageProp WHERE messageID=?";
    private static final String DELETE_PROPERTIES =
        "DELETE FROM yazdMessageProp WHERE messageID=?";
    private static final String INSERT_PROPERTY =
        "INSERT INTO yazdMessageProp(messageID,name,propValue) VALUES(?,?,?)";
    private static final String LOAD_MESSAGE =
        "SELECT userID, creationDate, modifiedDate, subject, body, threadID, " +
        "replyPrivateUserId, approved,ranking FROM yazdMessage WHERE messageID=?";
    private static final String INSERT_MESSAGE =
        "INSERT INTO yazdMessage(messageID, threadID,creationDate,modifiedDate,userID," +
        "subject,body,approved, replyPrivateUserId,ranking) VALUES(?,?,?,?,?,?,?,?,?,0)";
    private static final String SAVE_MESSAGE =
        "UPDATE yazdMessage SET userID=?, subject=?, body=?, creationDate=?, " +
        "modifiedDate=?, replyPrivateUserId = ?, approved = ?,ranking=? WHERE messageID=?";
    private static final String GET_FORUM_BY_THREAD =
        "SELECT forumID FROM yazdThread where threadID=?";
    private static final String CHECK_BLACK_LIST_IP="select ip from yazdBlackList where ip=?";
    private static final String UPDATE_BLACK_LIST_IP="update yazdBlackList set blockcount=blockcount+1 where ip=?";
    private static final String CHECK_BLACK_LIST_USER="select userID from yazdUserProp where userID=? and name=? and propValue=?";
    private static final String CHECK_SESSION="select initime from yazdSessions where IP=?";

    private int id = -1;
    private java.util.Date creationDate;
    private java.util.Date modifiedDate;
    private String subject = "";
    private int replyPrivateUserId = 0;
    private boolean approved;
    private String body = "";
    private int userID;
    private int threadID;
    private Map properties;
    private Object propertyLock = new Object();
    private DbForumFactory factory;
    private ForumThread thread = null;
    private int ranking = MessageRanking.NOTRANKED; // default to neutral

    /**
     * Indicates if the object is ready to be saved or not. An object is not
     * ready to be saved if it has just been created and has not yet been added
     * to its container. For example, a message added to a thread, etc.
     */
    private boolean isReadyToSave = false;

    /**
     * Creates a new dummy DbForumMessage object.
     * this is used to obtain the filtered message
     */
    protected DbForumMessage(User user, DbForumFactory factory) {
        this.id = -1;
        long now = System.currentTimeMillis();
        creationDate = new java.util.Date(now);
        modifiedDate = new java.util.Date(now);
        this.userID = user.getID();
        this.factory = factory;
        this.approved = true;
        properties = Collections.synchronizedMap(new HashMap());
        isReadyToSave = false;
    }

    /**
     * Creates a new DbForumMessage object.
     */
    protected DbForumMessage(User user, DbForumFactory factory, boolean approved,ClientIP clientIP) throws RapidPostingException,UserBlackListedException {
        checkBlackList(user,clientIP);
        checkForRapidPosts(user,clientIP);
        checkForSession(user,clientIP);
        this.id = DbSequenceManager.nextID("ForumMessage");
        long now = System.currentTimeMillis();
        creationDate = new java.util.Date(now);
        modifiedDate = new java.util.Date(now);
        this.userID = user.getID();
        this.factory = factory;
        this.approved = approved;
        properties = Collections.synchronizedMap(new HashMap());
    }

    /**
     * Loads the specified DbForumMessage by its message id.
     */
    protected DbForumMessage(int id, DbForumFactory factory)
            throws ForumMessageNotFoundException
    {
        this.id = id;
        this.factory = factory;
        loadFromDb();
        loadProperties();
        isReadyToSave = true;
    }

    //FROM THE FORUMMESSAGE INTERFACE//

    public int getID() {
        return id;
    }

    public java.util.Date getCreationDate() {
        return creationDate;
    }

    public void setCreationDate(java.util.Date creationDate)
            throws UnauthorizedException
    {
        this.creationDate = creationDate;
        //Only save to the db if the object is read
        if (!isReadyToSave) {
            return;
        }
        saveToDb();
    }

    public java.util.Date getModifiedDate() {
        return modifiedDate;
    }

    public void setModifiedDate(java.util.Date modifiedDate)
            throws UnauthorizedException
    {
        this.modifiedDate = modifiedDate;
        //Only save to the db if the object is read
        if (!isReadyToSave) {
            return;
        }
        saveToDb();
    }

    public String getSubject() {
        return subject;
    }

    public int getReplyPrivateUserId() {
        return replyPrivateUserId;
    }

    public boolean isPrivate() {
        return replyPrivateUserId > 0;
    }

    public String getUnfilteredSubject() {
        return subject;
    }

    public void setSubject(String subject) throws UnauthorizedException {
        this.subject = subject;
        //Only save to the db if the object is read
        if (!isReadyToSave) {
            return;
        }
        //Update modifiedDate to the current time.
        modifiedDate.setTime(System.currentTimeMillis());
        saveToDb();
    }

    public void setReplyPrivateUserId(int replyPrivateUserId) throws UnauthorizedException {
        this.replyPrivateUserId = replyPrivateUserId;
        //Only save to the db if the object is read
        if (!isReadyToSave) {
            return;
        }
        //Update modifiedDate to the current time.
        modifiedDate.setTime(System.currentTimeMillis());
        saveToDb();
    }

    public void setApprovment(boolean approved) throws UnauthorizedException {
        this.approved = approved;
        //Only save to the db if the object is read
        if (!isReadyToSave) {
            return;
        }
        //Update modifiedDate to the current time.
        modifiedDate.setTime(System.currentTimeMillis());
        saveToDb();
    }

    public boolean isApproved() {
        return approved;
    }

    public String getBody() {
        return body;
    }

    public String getUnfilteredBody() {
        return body;
    }

    public void setBody(String body) throws UnauthorizedException {
        this.body = body;
        //Only save to the db if the object is read
        if (!isReadyToSave) {
            return;
        }
        //Update modifiedDate to the current time.
        modifiedDate.setTime(System.currentTimeMillis());
        saveToDb();
    }

    public User getUser() {
        User user = null;
        try {
            if (userID == -1) {
                user = factory.getProfileManager().getAnonymousUser();
            }
            else {
                user = factory.getProfileManager().getUser(userID);
            }
        }
        catch (UserNotFoundException unfe) {
            unfe.printStackTrace();
        }
        return user;
    }

    public String getProperty(String name) {
        //For security reasons, pass through the HTML filter.
        return StringUtils.escapeHTMLTags((String)properties.get(name));
    }

    public String getUnfilteredProperty(String name) {
        return (String)properties.get(name);
    }

    public void setProperty(String name, String value) {
        properties.put(name, value);
        //Only save to the db if the object is read
        if (!isReadyToSave) {
            return;
        }
        saveProperties();
    }

    public Iterator propertyNames() {
        return Collections.unmodifiableSet(properties.keySet()).iterator();
    }

    public boolean isAnonymous() {
        return (userID == -1);
    }

    public ForumThread getForumThread() {
        if (thread != null) {
            return thread;
        }
        //Load the thread since this is the first time the method has been
        //called.
        else {
            //First, we need a handle on the parent Forum object based
            //on the threadID.

            int forumID = -1;
            Connection con = null;
            PreparedStatement pstmt = null;
            try {
                con = DbConnectionManager.getConnection();
                pstmt = con.prepareStatement(GET_FORUM_BY_THREAD);
                pstmt.setInt(1, threadID);
                ResultSet rs = pstmt.executeQuery();
                if (rs.next()) {
                    forumID = rs.getInt("forumID");
                }
             }
            catch( SQLException sqle ) {
                sqle.printStackTrace();
            }
            finally {
                try {  pstmt.close(); }
                catch (Exception e) { e.printStackTrace(); }
                try {  con.close();   }
                catch (Exception e) { e.printStackTrace(); }
            }
            //If the forumID for the message is less than 1, we have problems.
            //Print a warning and return null
            if (forumID < 1) {
                System.err.println("WARNING: forumID of " + forumID +
                    " found for message " + id + " in DbForumMessage.getForumThread()." +
                    " You may wish to delete the message from your database."
                );
                return null;
            }

            Forum forum = null;
            ForumThread thread = null;
            try {
                forum = factory.getForum(forumID);
                //Now, get the thread
                thread = forum.getThread(threadID);
            }
            catch (Exception e) {
                e.printStackTrace();
                return null;
            }
            this.thread = thread;
            return thread;
        }
    }

    public boolean hasPermission(int type) {
        return true;
    }

    //FROM CACHEABLE INTERFACE//

    public int getSize() {
        //Approximate the size of the object in bytes by calculating the size
        //of each field.
        int size = 0;
        size += CacheSizes.sizeOfObject();              //overhead of object
        size += CacheSizes.sizeOfInt();                 //id
        size += CacheSizes.sizeOfString(subject);       //subject
        size += CacheSizes.sizeOfString(body);          //body
        size += CacheSizes.sizeOfDate();                //creation date
        size += CacheSizes.sizeOfDate();                //modified date
        size += CacheSizes.sizeOfInt();                 //userID
        size += CacheSizes.sizeOfInt();                 //threadID
        size += CacheSizes.sizeOfInt();                 //replyPrivateUserId
        size += CacheSizes.sizeOfBoolean();             //approved
        size += CacheSizes.sizeOfMap(properties);       //map object
        size += CacheSizes.sizeOfObject();              //property lock
        size += CacheSizes.sizeOfObject();              //ref to factory

        return size;
    }

    //OTHER METHODS//

    /**
     * Returns a String representation of the message object using the subject.
     *
     * @return a String representation of the ForumMessage object.
     */
    public String toString() {
        return subject;
    }

    public int hashCode() {
        return id;
    }

    public boolean equals(Object object) {
        if (this == object) {
            return true;
        }
        if (object != null && object instanceof DbForumMessage) {
            return id == ((DbForumMessage)object).getID();
        }
        else {
            return false;
        }
    }

    /**
     * Loads message properties from the database.
     */
    private void loadProperties() {
        synchronized(propertyLock) {
            Properties newProps = new Properties();
            Connection con = null;
            PreparedStatement pstmt = null;
            try {
                con = DbConnectionManager.getConnection();
                pstmt = con.prepareStatement(LOAD_PROPERTIES);
                pstmt.setInt(1, id);
                ResultSet rs = pstmt.executeQuery();
                while(rs.next()) {
                    String name = rs.getString("name");
                    String value = rs.getString("propValue");
                    newProps.put(name, value);
                }
            }
            catch( SQLException sqle ) {
                System.err.println("Error in DbForumMessage:loadProperties():" + sqle);
                sqle.printStackTrace();
            }
            finally {
                try {  pstmt.close(); }
                catch (Exception e) { e.printStackTrace(); }
                try {  con.close();   }
                catch (Exception e) { e.printStackTrace(); }
            }
            this.properties = newProps;
        }
    }

    /**
     * Saves message properties to the database.
     */
    private void saveProperties() {
        synchronized(propertyLock) {
            Connection con = null;
            PreparedStatement pstmt = null;
            try {
                con = DbConnectionManager.getConnection();
                //Delete all old values.
                pstmt = con.prepareStatement(DELETE_PROPERTIES);
                pstmt.setInt(1, id);
                pstmt.execute();
                pstmt.close();
                //Now insert new values.
                pstmt = con.prepareStatement(INSERT_PROPERTY);
                Iterator iter = properties.keySet().iterator();
                while (iter.hasNext()) {
                    String name = (String)iter.next();
                    String value = (String)properties.get(name);
                    pstmt.setInt(1, id);
                    pstmt.setString(2, name);
                    pstmt.setString(3, value);
                    pstmt.executeUpdate();
                }
            }
            catch( SQLException sqle ) {
                System.err.println(sqle);
            }
            finally {
                try {  pstmt.close(); }
                catch (Exception e) { e.printStackTrace(); }
                try {  con.close();   }
                catch (Exception e) { e.printStackTrace(); }
            }
        }
    }

    /**
     *  Loads message and user data from the database.
     */
    private void loadFromDb() throws ForumMessageNotFoundException {
        // Based on the id in the object, get the message data from the database.
        Connection con = null;
        PreparedStatement pstmt = null;
        try {
            con = DbConnectionManager.getConnection();
            pstmt = con.prepareStatement(LOAD_MESSAGE);
            pstmt.setInt(1, id);
            ResultSet rs = pstmt.executeQuery();
            if( !rs.next() ) {
                throw new ForumMessageNotFoundException("Message " + id +
                    " could not be loaded from the database.");
            }
            //Get the query results. We use int indexes into the ResultSet
            //because it is slightly faster. Care should be taken so that the
            //SQL query is not modified without modifying these indexes.
            this.userID = rs.getInt(1);
            //We trim() the dates before trying to parse them because some
            //databases pad with extra characters when returning the data.
            this.creationDate =
                new java.util.Date(Long.parseLong(rs.getString(2).trim()));
            this.modifiedDate =
                new java.util.Date(Long.parseLong(rs.getString(3).trim()));
            this.subject = rs.getString(4);
            this.body = rs.getString(5);
            this.threadID = rs.getInt(6);
            this.replyPrivateUserId = rs.getInt(7);
            this.approved = rs.getInt(8) == 1 ? true : false;
            this.ranking = rs.getInt("ranking");
         }
        catch( SQLException sqle ) {
            throw new ForumMessageNotFoundException( "Message of id "
                    + id + " was not found in the database."
            );
        }
        catch (NumberFormatException nfe) {
            System.err.println("WARNING: In DbForumMessage.loadFromDb() -- there " +
                "was an error parsing the dates returned from the database. Ensure " +
                "that they're being stored correctly.");
        }
        finally {
            try {  pstmt.close(); }
            catch (Exception e) { e.printStackTrace(); }
            try {  con.close();   }
            catch (Exception e) { e.printStackTrace(); }
        }
    }

    /**
     * Inserts a new message into the database. A connection object must
     * be passed in. The connection must be open when passed in, and will
     * remain open when passed back. This method allows us to make insertions
     * be transactional.
     *
     * @param con an open Connection used to insert the thread to the db.
     * @param thread the ForumThread the message is being added to.
     */
    public void insertIntoDb(Connection con, ForumThread thread)
            throws SQLException
    {
        //Set the message threadID to the thread that the message is being
        //added to.
        this.threadID = thread.getID();
        PreparedStatement pstmt = con.prepareStatement(INSERT_MESSAGE);
        pstmt.setInt(1, id);
        pstmt.setInt(2, threadID);
        pstmt.setString(3, Long.toString(creationDate.getTime()));
        pstmt.setString(4, Long.toString(modifiedDate.getTime()));
        pstmt.setInt(5, userID);
        pstmt.setString(6, subject);
        pstmt.setString(7, body);
        pstmt.setInt(8, approved ? 1 : 0);
        pstmt.setInt(9, replyPrivateUserId);
        pstmt.executeUpdate();
        pstmt.close();

        //We're done inserting the message, so now save any extended
        //properties to the database.
        saveProperties();

        //Now add the message to the watch list so that the proper users are notified.
        factory.getWatchManager().addMessage(this);
        //since we're done inserting the object to the database, it is ready
        //for future insertions.
        isReadyToSave = true;
    }

    /**
     *  Saves message data to the database.
     */
    private synchronized void saveToDb() {
        Connection con = null;
        PreparedStatement pstmt = null;
        try {
            con = DbConnectionManager.getConnection();
            pstmt = con.prepareStatement(SAVE_MESSAGE);
            pstmt.setInt(1, userID);
            pstmt.setString(2, subject);
            pstmt.setString(3, body);
            pstmt.setString(4, Long.toString(creationDate.getTime()));
            pstmt.setString(5, Long.toString(modifiedDate.getTime()));
            pstmt.setInt(6, replyPrivateUserId);
            pstmt.setInt(7, approved ? 1 : 0);
            pstmt.setInt(8,this.ranking);
            pstmt.setInt(9, id);
            pstmt.executeUpdate();
        }
        catch( SQLException sqle ) {
            System.err.println( "SQLException in DbForumMessage:saveToDb()- " + sqle );
            sqle.printStackTrace();
        }
        finally {
            try {  pstmt.close(); }
            catch (Exception e) { e.printStackTrace(); }
            try {  con.close();   }
            catch (Exception e) { e.printStackTrace(); }
        }
    }
    /**
     * this method checks to see if the user has already posted another message in the restricted window.
     * @param user
     * @param clientIP
     * @throws RapidPostingException
     */
    private void checkForRapidPosts(User user,ClientIP clientIP) throws RapidPostingException{
        // there is minor problem with this method:
        // A user who is logged in can post a message, then logout and post another message without a problem.
            // We need to check against the IP addresses of the messages.
            Connection con = null;
            PreparedStatement pstmt = null;
            try {
                con = DbConnectionManager.getConnection();
                int ranking=10; //This would be anonymous ranking
                if(user.isAnonymous()){
					pstmt = con.prepareStatement(CHECK_LASTPOST);
					pstmt.setString(1, "IP");
					pstmt.setString(2,clientIP.getRemoteIP());
                } else {
					pstmt = con.prepareStatement(CHECK_LASTPOSTWITHUSER);
					pstmt.setInt(1, user.getID());
                    ranking=Integer.parseInt(user.getProperty("ranking"));
                }
                ResultSet rs = pstmt.executeQuery();
                if( rs.next() ) {
                    if (rs.getString("lastpost")!=null && !rs.getString("lastpost").toUpperCase().equals("NULL") && !rs.getString("lastpost").equals("")){
                     if(Calendar.getInstance().getTimeInMillis()-Long.parseLong(rs.getString("lastpost")) < Long.parseLong(SystemProperty.getProperty("PeriodBetweenPosts"))*ranking){
                      long timediff = (Calendar.getInstance().getTimeInMillis() - Long.parseLong(rs.getString("lastpost")))/1000;
                      throw new RapidPostingException("Rapid Posting Error. There was a post already posted at " + Long.toString(timediff)+" seconds ago!");
                     }
                    }
                }
            }
            catch( SQLException sqle ) {
                System.err.println("an error occured in DbForumMessage (0934):"+sqle.getMessage());
                sqle.printStackTrace();
            }
            finally {
                try {  pstmt.close(); }
                catch (Exception e) { e.printStackTrace(); }
                try {  con.close();   }
                catch (Exception e) { e.printStackTrace(); }
            }
    }
    private void checkForSession(User user,ClientIP clientIP) throws RapidPostingException{
            Connection con = null;
            PreparedStatement pstmt = null;
            try {
                con = DbConnectionManager.getConnection();
		pstmt = con.prepareStatement(CHECK_SESSION);
		pstmt.setString(1,clientIP.getRemoteIP());
                ResultSet rs = pstmt.executeQuery();
                if( rs.next() ) {
                     if(Calendar.getInstance().getTimeInMillis()-Long.parseLong(rs.getString("initime"))*1000.0 < Long.parseLong(SystemProperty.getProperty("WaitPeriod"))){
                      throw new RapidPostingException("Rapid Posting Error. Wait period is " + SystemProperty.getProperty("WaitPeriod")+"!");
                     }
                }
            }
            catch( SQLException sqle ) {
                System.err.println("an error occured in DbForumMessage (0936):"+sqle.getMessage());
                sqle.printStackTrace();
            }
            finally {
                try {  pstmt.close(); }
                catch (Exception e) { e.printStackTrace(); }
                try {  con.close();   }
                catch (Exception e) { e.printStackTrace(); }
            }
    }
    
    private void checkBlackList(User user,ClientIP clientIP) throws UserBlackListedException {
        System.err.println("checking blacklist");
        Connection con = null;
        PreparedStatement pstmt = null;
        try {
            con = DbConnectionManager.getConnection();
            pstmt = con.prepareStatement(CHECK_BLACK_LIST_IP);
            pstmt.setString(1,clientIP.getRemoteIP());
            ResultSet rs = pstmt.executeQuery();
            if(rs.next()){
                pstmt = con.prepareStatement(UPDATE_BLACK_LIST_IP);
                pstmt.setString(1,clientIP.getRemoteIP());
                pstmt.executeUpdate();
                throw new UserBlackListedException("User Black Listed Error. The IP address "+clientIP.getRemoteIP()+" has been black listed");
            }
            pstmt = con.prepareStatement(CHECK_BLACK_LIST_USER);
            pstmt.setInt(1,user.getID());
            pstmt.setString(2,"BLOCKED");
            pstmt.setString(3,"true");
            rs = pstmt.executeQuery();
            if(rs.next()){
                throw new UserBlackListedException("User Black Listed Error. This user has been black listed from the sytem");
            }
        }
        catch( SQLException sqle ) {
            System.err.println("an error occured in DbForumMessage (0935):"+sqle.getMessage());
            sqle.printStackTrace();
        }
        finally {
            try {  pstmt.close(); }
            catch (Exception e) { e.printStackTrace(); }
            try {  con.close();   }
            catch (Exception e) { e.printStackTrace(); }
        }
    }
    public MessageRanking getRanking(){
        return new MessageRanking(this.ranking);
    }
    public void setRanking(int para) throws UnauthorizedException{
        this.ranking=para;
        saveToDb();

    }

}