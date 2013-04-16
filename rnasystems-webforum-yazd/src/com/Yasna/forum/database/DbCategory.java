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
 * Database implementation of the Category interface. It loads and stores category
 * information from the database.
 *
 * @see Category
 */
public class DbCategory implements Category, Cacheable {

    /** DATABASE QUERIES **/
    private static final String LOAD_CATEGORY_BY_ID =
        "SELECT categoryID, name, description, creationDate, modifiedDate,catorder FROM yazdCategory WHERE CategoryID=?";
    private static final String LOAD_CATEGORY_BY_NAME =
        "SELECT categoryID, name, description, creationDate, modifiedDate,catorder FROM yazdCategory WHERE name=?";
    private static final String UPDATE_CATEGORY_MODIFIED_DATE =
        "UPDATE yazdCategory SET modifiedDate=? WHERE categoryID=?";
    private static final String ADD_CATEGORY =
        "INSERT INTO yazdCategory(categoryID, name, description, creationDate, " +
        "modifiedDate,catorder) VALUES (?,?,?,?,?,0)";
    private static final String SAVE_CATEGORY =
        "UPDATE yazdCategory SET name=?, description=?, creationDate=?, " +
        "modifiedDate=?,catorder=? WHERE categoryID=?";
    private static final String DELETE_FORUM_GROUP =
        "DELETE FROM yazdForumGroup WHERE forumGroupID=?";

    private int id = -1;
    private String name;
    private String description;
    private java.util.Date creationDate;
    private java.util.Date modifiedDate;

    private DbForumFactory factory;
    private int catorder=0;

    /**
     * Creates a new category with the specified name and description.
     *
     * @param name the name of the category.
     * @param description the description of the category.
     * @param factory the DbForumFactory that will hold the category.
     */
    protected DbCategory(String name, String description, DbForumFactory factory) {
        this.id = DbSequenceManager.nextID("Category");
        this.name = name;
        this.description = description;
        long now = System.currentTimeMillis();
        creationDate = new java.util.Date(now);
        modifiedDate = new java.util.Date(now);
        this.factory = factory;
        insertIntoDb();
    }

    /**
     * Loads a category with the specified id.
     */
    protected DbCategory(int id, DbForumFactory factory)
            throws CategoryNotFoundException
    {
        this.id = id;
        this.factory = factory;
        loadFromDb();
    }

    /**
     * Loads a category with the specified name.
     */
    protected DbCategory(String name, DbForumFactory factory)
            throws CategoryNotFoundException
    {
        this.name = name;
        this.factory = factory;
        loadFromDb();
    }

    //FROM THE CATEGORY INTERFACE//

    public int getID() {
        return id;
    }

    public String getName() {
        return name;
    }
    public int getOrder(){
        return this.catorder;
    }
    public void setOrder(int param) throws UnauthorizedException{
        this.catorder=param;
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
        return new DbForumGroupIterator(this, factory);
    }

    public ForumGroup getForumGroup(int forumGroupID) throws
            ForumGroupNotFoundException
    {
        return factory.getForumGroup(forumGroupID, this);
    }

    public ForumGroup createForumGroup(String name, String description) throws UnauthorizedException
    {
        return new DbForumGroup(name, description, this, factory);
    }


    public void deleteForumGroup(ForumGroup forumGroup) throws UnauthorizedException
    {
        Iterator forumIterator = forumGroup.forums();
        while(forumIterator.hasNext()){
            Forum forumTmp = (Forum)forumIterator.next();
            factory.deleteForum(forumTmp);
        }

        Connection con = null;
        PreparedStatement pstmt = null;
        try {
            con = DbConnectionManager.getConnection();
            pstmt = con.prepareStatement(DELETE_FORUM_GROUP);
            pstmt.setInt(1,forumGroup.getID());
            pstmt.execute();
            pstmt.close();
        }
        catch( Exception sqle ) {
            System.err.println("Error in DbForumFactory:deleteForumGroup()-" + sqle);
        }
        finally {
            try {  pstmt.close(); }
            catch (Exception e) { e.printStackTrace(); }
            try {  con.close();   }
            catch (Exception e) { e.printStackTrace(); }
        }

    }


    //FROM THE CACHEABLE INTERFACE//

    public int getSize() {
        //Approximate the size of the object in bytes by calculating the size
        //of each field.
        int size = 0;
        size += CacheSizes.sizeOfObject();              //overhead of object
        size += CacheSizes.sizeOfObject();              //ref to category
        size += CacheSizes.sizeOfInt();                 //id
        size += CacheSizes.sizeOfString(name);          //name
        size += CacheSizes.sizeOfString(description);   //description
        size += CacheSizes.sizeOfDate();                //creation date
        size += CacheSizes.sizeOfDate();                //modified date
        size += CacheSizes.sizeOfObject();              //save lock
        size += CacheSizes.sizeOfInt();                 //catorder

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
            pstmt = con.prepareStatement(UPDATE_CATEGORY_MODIFIED_DATE);
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
     * Loads category data from the database.
     */
    private void loadFromDb() throws CategoryNotFoundException {
        Connection con = null;
        PreparedStatement pstmt = null;
        try {
            con = DbConnectionManager.getConnection();
            //See if we should load by categoryID or by name
            if (id == -1) {
                pstmt = con.prepareStatement(LOAD_CATEGORY_BY_NAME);
                pstmt.setString(1,name);
            }
            else {
                pstmt = con.prepareStatement(LOAD_CATEGORY_BY_ID);
                pstmt.setInt(1, id);
            }
            ResultSet rs = pstmt.executeQuery();
            if( !rs.next() ) {
                throw new CategoryNotFoundException("Category " + getID() +
                    " could not be loaded from the database.");
            }
            id = rs.getInt("categoryID");
            name = rs.getString("name");
            description = rs.getString("description");
            this.creationDate =
                new java.util.Date(Long.parseLong(rs.getString("creationDate").trim()));
            this.modifiedDate =
                new java.util.Date(Long.parseLong(rs.getString("modifiedDate").trim()));
            catorder=rs.getInt("catorder");
        }
        catch( SQLException sqle ) {
            sqle.printStackTrace();
            throw new CategoryNotFoundException("Category " + getID() +
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
            pstmt = con.prepareStatement(ADD_CATEGORY);
            pstmt.setInt(1,id);
            pstmt.setString(2,name);
            pstmt.setString(3,description);
            pstmt.setString(4, Long.toString(creationDate.getTime()));
            pstmt.setString(5, Long.toString(modifiedDate.getTime()));
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
     * Saves category data to the database.
     */
    private synchronized void saveToDb() {
        Connection con = null;
        PreparedStatement pstmt = null;
        try {
            con = DbConnectionManager.getConnection();
            pstmt = con.prepareStatement(SAVE_CATEGORY);
            pstmt.setString(1, name);
            pstmt.setString(2, description);
            pstmt.setString(3, Long.toString(creationDate.getTime()));
            pstmt.setString(4, Long.toString(modifiedDate.getTime()));
            pstmt.setInt(5,catorder);
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
}
