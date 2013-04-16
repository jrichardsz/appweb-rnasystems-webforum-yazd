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

import com.Yasna.util.*;
import com.Yasna.forum.*;
import com.Yasna.forum.util.ClientIP;
import com.Yasna.forum.Tasks.EmailWatchManager;
import com.Yasna.forum.Tasks.SessionManager;
import com.Yasna.forum.Tasks.CleanAccounts;

import java.sql.*;
import java.util.*;
import java.io.*;

/**
 * Database implementation of the ForumFactory interface.
 */
public class DbForumFactory extends ForumFactory {

    /** DATABASE QUERIES **/
    private static final String FORUM_COUNT = "SELECT count(*) FROM yazdForum";
    private static final String DELETE_FORUM = "DELETE FROM yazdForum WHERE forumID=?";
    private static final String DELETE_CATEGORY = "DELETE FROM yazdCategory WHERE categoryID=?";
    private static final String DELETE_FORUM_USER_PERMS =
        "DELETE FROM yazdUserPerm WHERE forumID=?";
    private static final String DELETE_FORUM_GROUP_PERMS =
        "DELETE FROM yazdGroupPerm WHERE forumID=?";
    private static final String DELETE_FORUM_PROPERTIES =
        "DELETE FROM yazdForumProp WHERE forumID=?";
    private static final String GET_USER_PERMS =
         "SELECT DISTINCT permission FROM yazdUserPerm WHERE forumID=? " +
         "AND userID=?";
    private static final String USERS_WITH_PERM =
        "SELECT DISTINCT userID FROM yazdUserPerm WHERE forumID=? AND permission=?";
    private static final String GET_GROUP_PERMS =
        "SELECT DISTINCT permission from yazdGroupPerm WHERE forumID=? " +
        "AND groupID=?";
    private static final String GROUPS_WITH_PERM =
        "SELECT DISTINCT groupID FROM yazdGroupPerm WHERE forumID=? AND permission=?";
    private static final String ALL_MESSAGES =
        "SELECT messageID FROM yazdMessage";
    private static final String DELETE_MESSAGE =
        "DELETE FROM yazdMessage WHERE messageID=?";
    private static final String INSERT_BLACK_LIST="insert into yazdBlackList(ip,blockcount) values (?,?)";
    private static final String DELETE_BLACK_LIST="delete from yazdBlackList where ip=?";
    private static final String SELECT_BLACK_LIST="select blockcount from yazdBlackList where ip=?";
    private static final String SELECT_ARTICLE_MAP="select threadID from yazdArticleMap where pageKey=? and forumID=?";
    private static final String SESSION_LIST = "select sessionID,IP,userID from yazdSessions";
    private static final String YESTERDAY_SESSION_COUNT = "select usercount from yazdUserStats where day_dt=?";

    protected DbCacheManager cacheManager;
    protected EmailWatchManager watchManager;
    protected SessionManager sessionManager;

    /**
     * The profile manager provides access to users and groups.
     */
    private ProfileManager profileManager;

    /**
     * The search indexer periodically runs to index forum content
     */
    private DbSearchIndexer searchIndexer;

    /**
     * Creates a new DbForumFactory.
     */
    public DbForumFactory() {
        watchManager = new EmailWatchManager(this);
        cacheManager = new DbCacheManager();

        profileManager = new DbProfileManager(this);
        searchIndexer = new DbSearchIndexer(this);
        sessionManager = new SessionManager();
        if(Boolean.valueOf(SystemProperty.getProperty("RemoveNotActiveAccounts")).booleanValue()){
            new CleanAccounts();
        }
    }

    //FROM THE FORUMFACTORY INTERFACE//

    public Forum createForum(String name, String description,
                             boolean moderated, int forumGroupID,boolean article)
            throws UnauthorizedException, ForumAlreadyExistsException
    {
        Forum newForum = null;
        try {
            Forum existingForum = getForum(name);

            //The forum already exists since now exception, so:
            throw new ForumAlreadyExistsException();
        }
        catch (ForumNotFoundException fnfe) {
            //The forum doesn't already exist so we can create a new one
            newForum = new DbForum(name, description, moderated, forumGroupID, this,article);
        }
        return newForum;
    }

    public void deleteForum(Forum forum) throws UnauthorizedException {
        //First, remove forum from memory.
        cacheManager.remove(DbCacheManager.FORUM_CACHE, new Integer(forum.getID()));
        cacheManager.remove(DbCacheManager.USER_PERMS_CACHE, new Integer(forum.getID()));
        cacheManager.remove(DbCacheManager.FORUM_ID_CACHE, forum.getName());

        //Delete all messages and threads in the forum.
        Iterator threads = forum.threads();
        while (threads.hasNext()) {
            ForumThread thread = (ForumThread)threads.next();
            forum.deleteThread(thread);
        }

        //Now, delete all filters associated with the forum. We delete in
        //reverse order since filter indexes will change if we don't delete
        //the last filter entry.
        int filterCount = forum.getForumMessageFilters().length;
        for (int i=filterCount-1; i>=0; i--) {
            forum.removeForumMessageFilter(i);
        }

        //Finally, delete the forum itself and all permissions and properties
        //associated with it.
        Connection con = null;
        PreparedStatement pstmt = null;
        try {
            con = DbConnectionManager.getConnection();
            pstmt = con.prepareStatement(DELETE_FORUM);
            pstmt.setInt(1,forum.getID());
            pstmt.execute();
            pstmt.close();
            //User perms
            pstmt = con.prepareStatement(DELETE_FORUM_USER_PERMS);
            pstmt.setInt(1,forum.getID());
            pstmt.execute();
            pstmt.close();
            //Group perms
            pstmt = con.prepareStatement(DELETE_FORUM_GROUP_PERMS);
            pstmt.setInt(1,forum.getID());
            pstmt.execute();
            pstmt.close();
            //Properties
            pstmt = con.prepareStatement(DELETE_FORUM_PROPERTIES);
            pstmt.setInt(1,forum.getID());
            pstmt.execute();
        }
        catch( Exception sqle ) {
            System.err.println("Error in DbForumFactory:deleteForum()-" + sqle);
        }
        finally {
            try {  pstmt.close(); }
            catch (Exception e) { e.printStackTrace(); }
            try {  con.close();   }
            catch (Exception e) { e.printStackTrace(); }
        }
    }

    public void deleteCategory(Category category) throws UnauthorizedException {
        //First, remove forum from memory.
        cacheManager.remove(DbCacheManager.CATEGORY_CACHE, new Integer(category.getID()));
        cacheManager.remove(DbCacheManager.CATEGORY_ID_CACHE, category.getName());

        //Delete all forumgroups and forums in the cayegory.
        Iterator categories = category.forumGroups();
        while (categories.hasNext()) {
            ForumGroup forumGroup = (ForumGroup)categories.next();
            category.deleteForumGroup(forumGroup);
        }


        //Finally, delete the category itself
        Connection con = null;
        PreparedStatement pstmt = null;
        try {
            con = DbConnectionManager.getConnection();
            pstmt = con.prepareStatement(DELETE_CATEGORY);
            pstmt.setInt(1,category.getID());
            pstmt.execute();
            pstmt.close();
        }
        catch( Exception sqle ) {
            System.err.println("Error in DbForumFactory:deleteCategory()-" + sqle);
        }
        finally {
            try {  pstmt.close(); }
            catch (Exception e) { e.printStackTrace(); }
            try {  con.close();   }
            catch (Exception e) { e.printStackTrace(); }
        }
    }

    public Iterator forumsModeration(){ //this has to be revisited again
	return null;
    }
    public Forum getForum(int forumID)
            throws ForumNotFoundException, UnauthorizedException
    {
        //If cache is not enabled, do a new lookup of object
        if (!cacheManager.isCacheEnabled()) {
            return new DbForum(forumID, this);
        }
        //Cache is enabled.
        Integer forumIDInteger = new Integer(forumID);
        DbForum forum = (DbForum)cacheManager.get(DbCacheManager.FORUM_CACHE, forumIDInteger);
        if(forum == null) {
            forum = new DbForum(forumID, this);
            cacheManager.add(DbCacheManager.FORUM_CACHE, forumIDInteger, forum);
        }
        return forum;
    }

    public Forum getForum(String name)
            throws ForumNotFoundException, UnauthorizedException
    {
        //If cache is not enabled, do a new lookup of object
        if (!cacheManager.isCacheEnabled()) {
            Forum forum = new DbForum(name, this);
            return forum;
        }
        //Cache is enabled.
        CacheableInteger forumIDInteger = (CacheableInteger)cacheManager.get(
                DbCacheManager.FORUM_ID_CACHE,
                name
        );
        //if id wan't found in cache, load it up and put it there.
        if (forumIDInteger == null) {
            Forum forum = new DbForum(name, this);
            forumIDInteger = new CacheableInteger(new Integer(forum.getID()));
            cacheManager.add(DbCacheManager.FORUM_ID_CACHE, name, forumIDInteger);
        }
        return getForum(forumIDInteger.getInteger().intValue());
    }

    public int getForumCount() {
        int forumCount = 0;
        Connection con = null;
        PreparedStatement pstmt = null;
        try {
            con = DbConnectionManager.getConnection();
            pstmt = con.prepareStatement(FORUM_COUNT);
            ResultSet rs = pstmt.executeQuery();
            rs.next();
            forumCount = rs.getInt(1);
        }
        catch( SQLException sqle ) {
            System.err.println("DbForumFactory:getForumCount() failed: " + sqle);
        }
        finally {
            try {  pstmt.close(); }
            catch (Exception e) { e.printStackTrace(); }
            try {  con.close();   }
            catch (Exception e) { e.printStackTrace(); }
        }
        return forumCount;
    }

    public Iterator forums() {
        return new DbForumFactoryIterator(this);
    }
    public Iterator forumsWithArticlesForums(){
        return new DbForumFactoryIterator(this);
    }
    public Category getCategory(int categoryID)
            throws CategoryNotFoundException, UnauthorizedException
    {
        //If cache is not enabled, do a new lookup of object
        if (!cacheManager.isCacheEnabled()) {
            return new DbCategory(categoryID, this);
        }
        //Cache is enabled.
        Integer categoryIDInteger = new Integer(categoryID);
        DbCategory category = (DbCategory)cacheManager.get(DbCacheManager.CATEGORY_CACHE, categoryIDInteger);
        if(category == null) {
            category = new DbCategory(categoryID, this);
            cacheManager.add(DbCacheManager.CATEGORY_CACHE, categoryIDInteger, category);
        }
        return category;
    }

    public Category getCategory(String name)
            throws CategoryNotFoundException, UnauthorizedException
    {
        //If cache is not enabled, do a new lookup of object
        if (!cacheManager.isCacheEnabled()) {
            Category category = new DbCategory(name, this);
            return category;
        }
        //Cache is enabled.
        CacheableInteger categoryIDInteger = (CacheableInteger)cacheManager.get(
                DbCacheManager.CATEGORY_ID_CACHE,
                name
        );
        //if id wan't found in cache, load it up and put it there.
        if (categoryIDInteger == null) {
            Category category = new DbCategory(name, this);
            categoryIDInteger = new CacheableInteger(new Integer(category.getID()));
            cacheManager.add(DbCacheManager.CATEGORY_ID_CACHE, name, categoryIDInteger);
        }
        return getCategory(categoryIDInteger.getInteger().intValue());
    }

    public Iterator categories() {
        return new DbCategoryIterator(this);
    }

    public Category createCategory(String name, String description)
            throws UnauthorizedException, CategoryAlreadyExistsException
    {
        Category newCategory = null;
        try {
            Category existingCategory = getCategory(name);

            //The forum already exists since now exception, so:
            throw new CategoryAlreadyExistsException();
        }
        catch (CategoryNotFoundException fnfe) {
            //The forum doesn't already exist so we can create a new one
            newCategory = new DbCategory(name, description, this);
        }
        return newCategory;
    }

    public ProfileManager getProfileManager() {
        return profileManager;
    }

    public SearchIndexer getSearchIndexer() {
        return searchIndexer;
    }

    public int[] usersWithPermission(int permissionType)
            throws UnauthorizedException
    {
        int [] users = new int[0];
        Connection con = null;
        PreparedStatement pstmt = null;
        try {
            con = DbConnectionManager.getConnection();
            pstmt = con.prepareStatement(USERS_WITH_PERM);
            pstmt.setInt(1,-1);
            pstmt.setInt(2,permissionType);
            ResultSet rs = pstmt.executeQuery();
            ArrayList userList = new ArrayList();
            while (rs.next()) {
                userList.add(new Integer(rs.getInt("userID")));
            }
            users = new int[userList.size()];
            for (int i=0; i<users.length; i++) {
                users[i] = ((Integer)userList.get(i)).intValue();
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
        return users;
    }

    public int[] groupsWithPermission(int permissionType)
            throws UnauthorizedException
    {
        int [] groups = new int[0];
        Connection con = null;
        PreparedStatement pstmt = null;
        try {
            con = DbConnectionManager.getConnection();
            pstmt = con.prepareStatement(GROUPS_WITH_PERM);
            pstmt.setInt(1,-1);
            pstmt.setInt(2,permissionType);
            ResultSet rs = pstmt.executeQuery();
            ArrayList groupList = new ArrayList();
            while (rs.next()) {
                groupList.add(new Integer(rs.getInt("groupID")));
            }
            groups = new int[groupList.size()];
            for (int i=0; i<groups.length; i++) {
                groups[i] = ((Integer)groupList.get(i)).intValue();
            }
        }
        catch( SQLException sqle ) {
            System.err.println("Error in DbForum.groupsWithPermission:" + sqle);
            sqle.printStackTrace();
        }
        finally {
            try {  pstmt.close(); }
            catch (Exception e) { e.printStackTrace(); }
            try {  con.close();   }
            catch (Exception e) { e.printStackTrace(); }
        }
        return groups;
    }

    public ForumPermissions getPermissions(Authorization authorization) {
        int userID = authorization.getUserID();

        //Get the user perm cache for this forum
        Cache userPermCache = (Cache)getCacheManager().get(
            DbCacheManager.USER_PERMS_CACHE,
            new Integer(-1)
        );

        //Simple case: if cache is turned on and the user is already cached,
        //we can simply return the cached permissions.
        if (userPermCache != null) {
            ForumPermissions permissions =
                    (ForumPermissions)userPermCache.get(new Integer(userID));
            if (permissions != null) {
                return permissions;
            }
        }

        //Not so simple case: cache is not turned on or the user permissions
        //have not been cached yet.
        boolean isAnonymous = (userID == -1);
        boolean isUser = !isAnonymous;

        ForumPermissions finalPermissions = ForumPermissions.none();
	// check each forum for a specific permission
	/*Iterator allForums = this.forums();
	Forum forum;
	ForumPermissions forumUserPermissions;
	while (allForums.hasNext()){
		forum = (Forum)allForums.next();
		forumUserPermissions = getUserPermissions(userID,forum.getID());
            	finalPermissions = new ForumPermissions(finalPermissions, forumUserPermissions);
	}      */


        //Step 1 - Get permissions for the User. This includes anonymous
        //perms, "special user" perms, and the specific perms for the user.
        if (isUser) {
            ForumPermissions userPermissions = getUserPermissions(userID, -1);
            //Combine permissions
            finalPermissions = new ForumPermissions(finalPermissions, userPermissions);
        }
        //Add in anonymous perms.
        ForumPermissions anonyPermissions = null;
        if (userPermCache != null) {
            anonyPermissions = (ForumPermissions)userPermCache.get(new Integer(-1));
        }
        //Otherwise, do our own lookup.
        if (anonyPermissions == null) {
            anonyPermissions = getUserPermissions(-1, -1);
            //Add to cache so it will be there next time.
            if (userPermCache != null) {
                userPermCache.add(new Integer(-1), anonyPermissions);
            }
        }
        //Combine permissions
        finalPermissions = new ForumPermissions(finalPermissions, anonyPermissions);

        //If they are a valid user, figure out "any user" permissions.
        if (isUser) {
            ForumPermissions specialUserPermissions = null;
            //Check for cache
            if (userPermCache != null) {
                specialUserPermissions = (ForumPermissions)userPermCache.get(new Integer(0));
            }
            //Otherwise, do our own lookup.
            if (specialUserPermissions == null) {
                specialUserPermissions = getUserPermissions(0, -1);
                //Add to cache so it will be there next time.
                if (userPermCache != null) {
                    userPermCache.add(new Integer(0), specialUserPermissions);
                }
            }
            //Combine permissions
            finalPermissions = new ForumPermissions(finalPermissions, specialUserPermissions);
        }

        //Step 2 -- get Permissions for all groups the user is in.
        int [] groups = ((DbProfileManager)getProfileManager()).getUserGroups(userID);
        for (int i=0; i<groups.length; i++) {
            ForumPermissions groupPermissions = getGroupPermissions(groups[i], -1);
            finalPermissions = new ForumPermissions(finalPermissions, groupPermissions);
        }

        //Finally, add user to cache so it will be there next time.
        if (isUser && userPermCache != null) {
            userPermCache.add(new Integer(userID), finalPermissions);
        }

        return finalPermissions;
    }

    public boolean hasPermission(int type) {
        return true;
    }

    //OTHER METHODS//

    /**
     * Returns the cache manager object.
     */
    public DbCacheManager getCacheManager() {
        return cacheManager;
    }
    /**
     * returns the watch manager. This is only used by this package.
     * @return watchmanager
     */
    public EmailWatchManager getWatchManager(){
        return watchManager;
    }
    public SessionManager getSessionManager(){
        return sessionManager;
    }

    /**
     * Cleans the Yazd database of "junk". This is currently defined as: <ul>
     *      <li> Messages with no subject or body.
     *      <li> Messages that do not belong to a thread.</ul>
     *
     * Please be aware that this method will <b>permanently</b> delete forum
     * content. You may want to perform a database backup before calling this
     * method.<p>
     *
     * This method requires two database connections and may take a long time
     * to execute, as it must iterate through ever message record in the
     * database.
     */
    public void cleanDatabase() {
        //Iterate through all forums, threads to delete unwanted messages.
        Iterator forums = forums();
        while (forums.hasNext()) {
            Forum forum = (Forum)forums.next();
            Iterator threads = forum.threads();
            while (threads.hasNext()) {
                try {
                    ForumThread thread = (ForumThread)threads.next();
                    Iterator messages = thread.messages();
                    while (messages.hasNext()) {
                        try {
                            ForumMessage message = (ForumMessage)messages.next();
                            //System.err.println("Evaluating message " + message.getID() + " for deletion");
                            if (/*message.getSubject() == null ||*/ message.getBody() == null) {
                                //System.err.println("Deleting message...");
                                thread.deleteMessage(message);
                            }
                        }
                        catch (Exception me) {
                            me.printStackTrace();
                        }
                    }
                }
                catch (Exception te) {
                    te.printStackTrace();
                }
            }
        }

/*
        //Select all message ID's directly from the message table.
        Connection con = null;
        PreparedStatement pstmt = null;
        try {
            con = DbConnectionManager.getConnection();
            pstmt = con.prepareStatement(ALL_MESSAGES);
            ResultSet rs = pstmt.executeQuery();
            while(rs.next()) {
                try {
                    int messageID = rs.getInt(1);
                    //Convert to object
                    ForumMessage message = new DbForumMessage(messageID, this);
                    ForumThread thread = message.getForumThread();
                    if (thread == null) {
                        //manually delete this message from the database. It won't
                        //appear in any search indexes or in any threads, so this
                        //shouldn't have any side effects.
                        Connection con2 = null;
                        PreparedStatement pstmt2 = null;
                        try {
                            con2 = DbConnectionManager.getConnection();
                            pstmt2 = con.prepareStatement(DELETE_MESSAGE);
                            pstmt2.setInt(1, messageID);
                            pstmt2.execute();
                        }
                        catch( SQLException sqle ) {
                            sqle.printStackTrace();
                        }
                        finally {
                            try {  pstmt2.close(); }
                            catch (Exception e) { e.printStackTrace(); }
                            try {  con2.close();   }
                            catch (Exception e) { e.printStackTrace(); }
                        }
                    }
                }
                catch (ForumMessageNotFoundException fmnfe) {
                    fmnfe.printStackTrace();
                }
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
*/
    }

    /**
     * Returns a thread specified by its id. Will return null
     * if the thread is not in the forum. If cache is turned
     * on, it will use it.
     */
    public DbForumThread getThread(int threadID, DbForum forum) throws
            ForumThreadNotFoundException
    {
        //If cache is not enabled, do a new lookup of object
        if (!cacheManager.isCacheEnabled()) {
            return new DbForumThread(threadID, forum, this);
        }
        //Cache is enabled.
        Integer threadIDInteger = new Integer(threadID);
        DbForumThread thread = (DbForumThread)cacheManager.get(
                DbCacheManager.THREAD_CACHE,
                threadIDInteger
        );
        if(thread == null) {
            thread = new DbForumThread(threadID, forum, this);
            //System.err.println("Aflatoon adding to cache");
            cacheManager.add(DbCacheManager.THREAD_CACHE, threadIDInteger, thread);
        }
        return thread;
    }

    /**
     * Returns a forumgroup specified by its id. Will return null
     * if the forumgroup is not in the category. If cache is turned
     * on, it will use it.
     */
    public DbForumGroup getForumGroup(int forumGroupID, DbCategory category) throws
            ForumGroupNotFoundException
    {
        //If cache is not enabled, do a new lookup of object
        if (!cacheManager.isCacheEnabled()) {
            return new DbForumGroup(forumGroupID, category, this);
        }
        //Cache is enabled.
        Integer forumGroupIDInteger = new Integer(forumGroupID);
        DbForumGroup forumGroup = (DbForumGroup)cacheManager.get(
                DbCacheManager.FORUM_GROUP_CACHE,
                forumGroupIDInteger
        );
        if(forumGroup == null) {
            forumGroup = new DbForumGroup(forumGroupID, category, this);
            cacheManager.add(DbCacheManager.FORUM_GROUP_CACHE, forumGroupIDInteger, forumGroup);
        }
        return forumGroup;
    }

    /**
     * Returns a message from the thread based on its id. If cache is turned
     * on, it will use it.
     *
     * @param messageID the ID of the message to get from the thread.
     */
    protected DbForumMessage getMessage(int messageID)
            throws ForumMessageNotFoundException
    {
        //If cache is not enabled, do a new lookup of object
        if (!cacheManager.isCacheEnabled()) {
            return new DbForumMessage(messageID, this);
        }
        //Cache is enabled.
        Integer messageIDInteger = new Integer(messageID);
        DbForumMessage message = (DbForumMessage)cacheManager.get(
                DbCacheManager.MESSAGE_CACHE,
                messageIDInteger
        );
        if(message == null) {
            //Load the message
            message = new DbForumMessage(messageID, this);
            //Add it to cache.
            cacheManager.add(DbCacheManager.MESSAGE_CACHE, messageIDInteger, message);
        }
        return message;
    }

    /**
     * Logs events in the system. Very beginnings here....
     */
    protected void log(String message, Exception e) {
        System.err.println("Log event : " + message);
        e.printStackTrace();
    }

    /**
     * Returns the permissions that a particular user has for the forum.
     */
    protected ForumPermissions getUserPermissions(int userID, int forumID) {
        Connection con = null;
        PreparedStatement pstmt = null;
        //Initialize a permissions array with no permissions.
        boolean [] permissions = new boolean[8];
        for (int i=0; i<permissions.length; i++) {
            permissions[i] = false;
        }
        try {
            con = DbConnectionManager.getConnection();
            pstmt = con.prepareStatement(GET_USER_PERMS);
            pstmt.setInt(1, forumID);
            pstmt.setInt(2, userID);
            ResultSet rs = pstmt.executeQuery();
            while(rs.next()) {
                int newPerm = rs.getInt("permission");
                permissions[newPerm] = true;
            }
        }
        catch( SQLException sqle ) {
            System.err.println("Error in DbForum.java:" + sqle);
            sqle.printStackTrace();
        }
        finally {
            try {  pstmt.close(); }
            catch (Exception e) { e.printStackTrace(); }
            try {  con.close();   }
            catch (Exception e) { e.printStackTrace(); }
        }
        return new ForumPermissions(permissions);
    }

    /**
     * Returns the permissions that a particular group has for the forum.
     */
    protected ForumPermissions getGroupPermissions(int groupID, int forumID) {
        Connection con = null;
        PreparedStatement pstmt = null;
        //Initialize a permissions array with no permissions.
        boolean [] permissions = new boolean[8];
        for (int i=0; i<permissions.length; i++) {
            permissions[i] = false;
        }
        try {
            con = DbConnectionManager.getConnection();
            pstmt = con.prepareStatement(GET_GROUP_PERMS);
            pstmt.setInt(1, forumID);
            pstmt.setInt(2, groupID);
            ResultSet rs = pstmt.executeQuery();
            while(rs.next()) {
                int newPerm = rs.getInt("permission");
                permissions[newPerm] = true;
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
        return new ForumPermissions(permissions);
    }
    public Query createQuery(){
        return new DbQuery(this);
    }
    public void BlackListIP(ClientIP cip,boolean add) throws UnauthorizedException{
        Connection con = null;
        PreparedStatement pstmt = null;
        try {
            con = DbConnectionManager.getConnection();
            if(add){
                pstmt = con.prepareStatement(INSERT_BLACK_LIST);
                pstmt.setString(1,cip.getRemoteIP());
                pstmt.setInt(2,0);
            }else{
                pstmt = con.prepareStatement(DELETE_BLACK_LIST);
                pstmt.setString(1,cip.getRemoteIP());
            }
            pstmt.executeUpdate();
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

    }
    public boolean isBlackListed(ClientIP cip){
        boolean bl=false;

        Connection con = null;
        PreparedStatement pstmt = null;
        try {
            con = DbConnectionManager.getConnection();
            pstmt = con.prepareStatement(SELECT_BLACK_LIST);
            pstmt.setString(1,cip.getRemoteIP());
            ResultSet rs = pstmt.executeQuery();
            if(rs.next()){
                bl = true;
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

        return bl;

    }
    public ForumThread getArticleThread(String pageKey,Forum forum) throws ForumThreadNotFoundException,UnauthorizedException{
        Connection con = null;
        PreparedStatement pstmt = null;
        ForumThread thread=null;
        try {
            con = DbConnectionManager.getConnection();
            pstmt = con.prepareStatement(SELECT_ARTICLE_MAP);
            pstmt.setString(1,pageKey);
            pstmt.setInt(2,forum.getID());
            ResultSet rs = pstmt.executeQuery();
            if(rs.next()){
                thread=this.getThread(rs.getInt("threadID"),(DbForum)this.getForum(forum.getID()));
            } else{
                throw new ForumThreadNotFoundException();
            }
        }catch( SQLException sqle ) {
            sqle.printStackTrace();
        }
        catch(ForumNotFoundException e){

        }
        finally {
            try {  pstmt.close(); }
            catch (Exception e) { e.printStackTrace(); }
            try {  con.close();   }
            catch (Exception e) { e.printStackTrace(); }
        }
        return thread;

    }
    public ThreadType getThreadType(int typeid){
        //If cache is not enabled, do a new lookup of object
        if (!cacheManager.isCacheEnabled()) {
            return new DbThreadType(typeid);
        }
        //Cache is enabled.
        Integer typeIDInteger = new Integer(typeid);
        DbThreadType type = (DbThreadType)cacheManager.get(
                DbCacheManager.THREAD_TYPE_ID_CACHE,
                typeIDInteger
        );
        if(type == null) {
            //Load the message
            type = new DbThreadType(typeid);
            //Add it to cache.
            cacheManager.add(DbCacheManager.THREAD_TYPE_ID_CACHE, typeIDInteger, type);
        }
        return type;

    }
    public Iterator getThreadTypeIterator(){
        return new DbThreadTypeIterator(this);
    }
    public Iterator getSessionList(){
        Connection con = null;
        PreparedStatement pstmt = null;
        ArrayList sessions=new ArrayList();
        try {
            con = DbConnectionManager.getConnection();
            pstmt = con.prepareStatement(SESSION_LIST);
            ResultSet rs = pstmt.executeQuery();
            while(rs.next()){
                sessions.add(
                        new SessionVO(rs.getString("sessionID"),rs.getString("IP"),rs.getInt("userID"))
                );
            }
        }catch( SQLException sqle ) {
            sqle.printStackTrace();
        }
        finally {
            try {  pstmt.close(); }
            catch (Exception e) { e.printStackTrace(); }
            try {  con.close();   }
            catch (Exception e) { e.printStackTrace(); }
        }
        return sessions.iterator();

    }
    public int getYesterdayUserCount(){
        Connection con = null;
        PreparedStatement pstmt = null;
        int usercount=0;
        Calendar now = Calendar.getInstance();
        int now_in_minutes = (int)(now.getTimeInMillis()*1.0/(1000.0 * 60.0));
        int now_today = (int)(now_in_minutes * 1.0/(60.0 * 24.0));
        try {
            con = DbConnectionManager.getConnection();
            pstmt = con.prepareStatement(YESTERDAY_SESSION_COUNT);
            pstmt.setInt(1,now_today-1);
            ResultSet rs = pstmt.executeQuery();
            if(rs.next()){
                usercount = rs.getInt("usercount");
            }
        }catch( SQLException sqle ) {
            sqle.printStackTrace();
        }
        finally {
            try {  pstmt.close(); }
            catch (Exception e) { e.printStackTrace(); }
            try {  con.close();   }
            catch (Exception e) { e.printStackTrace(); }
        }
        return usercount;

    }

}
