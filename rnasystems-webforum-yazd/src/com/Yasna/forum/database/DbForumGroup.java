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

package com.Yasna.forum.database;

import java.util.Iterator;
import java.util.Enumeration;
import java.util.Properties;
import java.util.ArrayList;
import java.util.Date;
import java.sql.*;
import java.io.*;

import com.Yasna.forum.*;
import com.Yasna.forum.filter.*;
import com.Yasna.util.Cache;
import com.Yasna.util.Cacheable;
import com.Yasna.util.CacheSizes;

/**
 * Database implementation of the ForumGroup interface. It loads and stores forumGroup
 * information from the database.
 *
 * @see ForumGroup
 */
public class DbForumGroup implements ForumGroup, Cacheable {

    /** DATABASE QUERIES **/
    private static final String LOAD_FORUM_GROUP_BY_ID =
        "SELECT forumGroupID, name, description, creationDate, modifiedDate,grporder FROM yazdForumGroup WHERE forumGroupID=?";
    private static final String UPDATE_FORUM_GROUP_MODIFIED_DATE =
        "UPDATE yazdForumGroup SET modifiedDate=? WHERE forumGroupID=?";
    private static final String ADD_FORUM_GROUP =
        "INSERT INTO yazdForumGroup(forumGroupID, categoryID, name, description, creationDate, " +
        "modifiedDate,grporder) VALUES (?,?,?,?,?,?,0)";
    private static final String SAVE_FORUM_GROUP =
        "UPDATE yazdForumGroup SET name=?, description=?, creationDate=?, " +
        "modifiedDate=?,grporder=? WHERE forumGroupID=?";

    private int id = -1;
    private String name;
    private String description;
    private int categoryID;
    private int grporder=0;
    private java.util.Date creationDate;
    private java.util.Date modifiedDate;

    private DbForumFactory factory;
    private DbCategory category;

    /**
     * Loads a forumGroup with the specified id.
     */
    protected DbForumGroup(int id,  DbCategory category, DbForumFactory factory)
            throws ForumGroupNotFoundException
    {
        this.id = id;
        this.category = category;
        this.factory = factory;
        loadFromDb();
    }

    /**
     * Creats new  forumGroup.
     */
    protected DbForumGroup(String name, String description, DbCategory category, DbForumFactory factory)
            throws UnauthorizedException
    {
        this.id = DbSequenceManager.nextID("ForumGroup");
        this.name = name;
        this.categoryID = category.getID();
        this.description = description;
        long now = System.currentTimeMillis();
        creationDate = new java.util.Date(now);
        modifiedDate = new java.util.Date(now);
        this.category = category;
        this.factory = factory;
        insertIntoDb();
    }

    //FROM THE CATEGORY INTERFACE//

    public int getID() {
        return id;
    }

    public String getName() {
        return name;
    }
    public int getOrder(){
        return grporder;
    }
    public void setOrder(int param){
        this.grporder = param;
        saveToDb();
    }
    public void setName(String name) throws UnauthorizedException {
        this.name = name;
        saveToDb();
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) throws UnauthorizedException
    {
        this.description = description;
        saveToDb();
    }

    public java.util.Date getCreationDate() {
        return creationDate;
    }

    public void setCreationDate(java.util.Date creationDate)
            throws UnauthorizedException
    {
       this.creationDate = creationDate;
       saveToDb();
    }

    public java.util.Date getModifiedDate() {
        return modifiedDate;
    }

    public void setModifiedDate(java.util.Date modifiedDate)
            throws UnauthorizedException
    {
        this.modifiedDate = modifiedDate;
        saveToDb();
    }
    public Iterator forumGroups() {
        return null;//new DbForumIterator(this, factory);
    }


    //FROM THE CACHEABLE INTERFACE//

    public int getSize() {
        //Approximate the size of the object in bytes by calculating the size
        //of each field.
        int size = 0;
        size += CacheSizes.sizeOfObject();              //overhead of object
        size += CacheSizes.sizeOfInt();                 //id
        size += CacheSizes.sizeOfString(name);          //name
        size += CacheSizes.sizeOfString(description);   //description
        size += CacheSizes.sizeOfDate();                //creation date
        size += CacheSizes.sizeOfDate();                //modified date
        size += CacheSizes.sizeOfObject();              //save lock
        size += CacheSizes.sizeOfInt();                 //group order

        return size;
    }

    /**
     * Updates the modified date but doesn't require a security check since
     * it is a protected method.
     */
    protected void updateModifiedDate(java.util.Date modifiedDate) {
        this.modifiedDate = modifiedDate;
        Connection con = null;
        PreparedStatement pstmt = null;
        try {
            con = DbConnectionManager.getConnection();
            pstmt = con.prepareStatement(UPDATE_FORUM_GROUP_MODIFIED_DATE);
            pstmt.setString(1, ""+modifiedDate.getTime());
            pstmt.setInt(2, id);
            pstmt.executeUpdate();
        }
        catch( SQLException sqle ) {
            System.err.println("Error in DbCategory:updateModifiedDate()-" + sqle);
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
     * Loads group data from the database.
     */
    private void loadFromDb() throws ForumGroupNotFoundException {
        Connection con = null;
        PreparedStatement pstmt = null;
        try {
            con = DbConnectionManager.getConnection();
            //See if we should load by categoryID or by name

            pstmt = con.prepareStatement(LOAD_FORUM_GROUP_BY_ID);
            pstmt.setInt(1, id);
            ResultSet rs = pstmt.executeQuery();
            if( !rs.next() ) {
                throw new ForumGroupNotFoundException("Category " + getID() +
                    " could not be loaded from the database.");
            }
            id = rs.getInt("forumGroupID");
            name = rs.getString("name");
            description = rs.getString("description");
            this.creationDate =
                new java.util.Date(Long.parseLong(rs.getString("creationDate").trim()));
            this.modifiedDate =
                new java.util.Date(Long.parseLong(rs.getString("modifiedDate").trim()));
            this.grporder = rs.getInt("grporder");
        }
        catch( SQLException sqle ) {
            sqle.printStackTrace();
            throw new ForumGroupNotFoundException("Category " + getID() +
                " could not be loaded from the database.");
        }
        catch (NumberFormatException nfe) {
            System.err.println("WARNING: In DbCAtegory.loadFromDb() -- there " +
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
     * Inserts a new record into the database.
     */
    private void insertIntoDb() {
        Connection con = null;
        PreparedStatement pstmt = null;
        try {
            con = DbConnectionManager.getConnection();
            pstmt = con.prepareStatement(ADD_FORUM_GROUP);
            pstmt.setInt(1,id);
            pstmt.setInt(2,categoryID);
            pstmt.setString(3,name);
            pstmt.setString(4,description);
            pstmt.setString(5, Long.toString(creationDate.getTime()));
            pstmt.setString(6, Long.toString(modifiedDate.getTime()));
            pstmt.executeUpdate();
        }
        catch( SQLException sqle ) {
            System.err.println("Error in DbCategory:insertIntoDb()-" + sqle);
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
     * Saves group data to the database.
     */
    private synchronized void saveToDb() {
        Connection con = null;
        PreparedStatement pstmt = null;
        try {
            con = DbConnectionManager.getConnection();
            pstmt = con.prepareStatement(SAVE_FORUM_GROUP);
            pstmt.setString(1, name);
            pstmt.setString(2, description);
            pstmt.setString(3, Long.toString(creationDate.getTime()));
            pstmt.setString(4, Long.toString(modifiedDate.getTime()));
            pstmt.setInt(5,this.grporder);
            pstmt.setInt(6, id);
            pstmt.executeUpdate();
        }
        catch( SQLException sqle ) {
            System.err.println("Error in DbForum:saveToDb()-" + sqle);
            sqle.printStackTrace();
        }
        finally {
            try {  pstmt.close(); }
            catch (Exception e) { e.printStackTrace(); }
            try {  con.close();   }
            catch (Exception e) { e.printStackTrace(); }
        }
    }

    public Iterator forums() {
        return new DbForumFactoryIterator(this, factory);
    }

}
