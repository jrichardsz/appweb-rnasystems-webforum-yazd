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

import java.util.*;
//JDK1.1// import com.sun.java.util.collections.*;
import java.sql.*;

import com.Yasna.util.*;
import com.Yasna.forum.*;

/**
 * Database implementation to iterate through forumGroups in a Category.
 */
public class DbForumGroupIterator implements Iterator, ListIterator {

    /** DATABASE QUERIES **/
    private static final String GET_FORUM_GROUPS =
        "SELECT forumGroupID, creationDate FROM yazdForumGroup WHERE categoryID=? " +
        "ORDER BY grporder DESC";

    //A reference to the Category object that the iterator was created from.
    //This is used to load forumGroup objects.
    private DbCategory category;
    //maintain an array of forumgroup ids to iterator through.
    private int [] forumGroups;
    //points to the current forumgroup id that the user has iterated to.
    private int currentIndex = -1;

    DbForumFactory factory;

    public DbForumGroupIterator(DbCategory category, DbForumFactory factory)
    {
        this.category = category;
        this.factory = factory;
        //We don't know how many results will be returned, so store them
        //in an ArrayList.
        ArrayList tempForumGroups = new ArrayList();
        Connection con = null;
        PreparedStatement pstmt = null;
        try {
            con = DbConnectionManager.getConnection();
            pstmt = con.prepareStatement(GET_FORUM_GROUPS);
            pstmt.setInt(1,category.getID());
            ResultSet rs = pstmt.executeQuery();

            while (rs.next()) {
                tempForumGroups.add(new Integer(rs.getInt("forumGroupID")));
            }
        }
        catch( SQLException sqle ) {
            System.err.println("Error in DbForumGroupIterator:constructor()-" + sqle);
        }
        finally {
            try {  pstmt.close(); }
            catch (Exception e) { e.printStackTrace(); }
            try {  con.close();   }
            catch (Exception e) { e.printStackTrace(); }
        }
        forumGroups = new int[tempForumGroups.size()];
        for (int i=0; i<forumGroups.length; i++) {
            forumGroups[i] = ((Integer)tempForumGroups.get(i)).intValue();
        }
    }

    public void add(Object o) throws UnsupportedOperationException {
        throw new UnsupportedOperationException();
    }

    public boolean hasNext() {
        return (currentIndex+1 < forumGroups.length);
    }

    public boolean hasPrevious() {
        return (currentIndex > 0);
    }

    public Object next() throws java.util.NoSuchElementException {
        ForumGroup forumGroup = null;
        currentIndex++;
        if (currentIndex >= forumGroups.length) {
            currentIndex--;
            throw new java.util.NoSuchElementException();
        }
        try {
            forumGroup = category.getForumGroup(forumGroups[currentIndex]);
        }
        catch (ForumGroupNotFoundException tnfe) {
            System.err.println(tnfe);
        }
        return forumGroup;
    }

    public int nextIndex() {
        return currentIndex+1;
    }

    public Object previous() throws java.util.NoSuchElementException {
        ForumGroup forumGroup = null;
        currentIndex--;
        if (currentIndex < 0) {
            currentIndex++;
            throw new java.util.NoSuchElementException();
        }
        try {
            forumGroup = category.getForumGroup(forumGroups[currentIndex]);
        }
        catch (ForumGroupNotFoundException tnfe) {
            System.err.println(tnfe);
        }
        return forumGroup;
    }

    public int previousIndex() {
        return currentIndex-1;
    }

    public void remove() throws UnsupportedOperationException {
        throw new UnsupportedOperationException();
    }

    public void set(Object o) throws UnsupportedOperationException {
        throw new UnsupportedOperationException();
    }
}
