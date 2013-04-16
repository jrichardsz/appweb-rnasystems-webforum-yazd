package com.Yasna.forum.database;


import com.Yasna.forum.ThreadType;
import com.Yasna.forum.Exceptions.ThreadTypeNotFoundException;

import java.util.Iterator;
import java.util.ListIterator;
import java.util.ArrayList;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

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
public class DbThreadTypeIterator implements Iterator, ListIterator {
    private static final String ALL_TYPES = "SELECT typeID from yazdThreadType";

    private int currentIndex = -1;
    private int [] types;
    private DbForumFactory factory;
    protected DbThreadTypeIterator(DbForumFactory factory){
        this.factory=factory;
        ArrayList tempArr = new ArrayList();
        Connection con = null;
        PreparedStatement pstmt = null;
        try {
            con = DbConnectionManager.getConnection();
            pstmt = con.prepareStatement(ALL_TYPES);
            ResultSet rs = pstmt.executeQuery();
            while (rs.next()) {
                tempArr.add(new Integer(rs.getInt("typeID")));
            }
        }
        catch( SQLException sqle ) {
            System.err.println("Error in DbThreadTypeIterator:constructor()-" + sqle);
        }
        finally {
            try {  pstmt.close(); }
            catch (Exception e) { e.printStackTrace(); }
            try {  con.close();   }
            catch (Exception e) { e.printStackTrace(); }
        }
        types = new int[tempArr.size()];
        for (int i=0; i<types.length; i++) {
            types[i] = ((Integer)tempArr.get(i)).intValue();
        }

    }

    public boolean hasNext() {
        return (currentIndex+1 < types.length);
    }

    /**
     * Returns the next Type.
     */
    public Object next() throws java.util.NoSuchElementException {
        currentIndex++;
        if (currentIndex >= types.length) {
            throw new java.util.NoSuchElementException();
        }
        return factory.getThreadType(types[currentIndex]);
    }

    /**
     * For security reasons, the remove operation is not supported. Use
     * ProfileManager.deleteType() instead.
     *
     * @see com.Yasna.forum.ProfileManager
     */
    public void remove() {
        throw new UnsupportedOperationException();
    }

    /**
     * Returns true if there are more types left to iterate through backwards.
     */
    public boolean hasPrevious() {
        return (currentIndex > 0);
    }

    /**
     * For security reasons, the add operation is not supported. Use
     * ProfileManager instead.
     *
     * @see com.Yasna.forum.ProfileManager
     */
    public void add(Object o) throws UnsupportedOperationException {
        throw new UnsupportedOperationException();
    }

    /**
     * For security reasons, the set operation is not supported. Use
     * ProfileManager instead.
     *
     * @see com.Yasna.forum.ProfileManager
     */
    public void set(Object o) throws UnsupportedOperationException {
        throw new UnsupportedOperationException();
    }

    /**
     * Returns the index number that would be returned with a call to next().
     */
    public int nextIndex() {
        return currentIndex+1;
    }

    /**
     * Returns the previous group.
     */
    public Object previous() throws java.util.NoSuchElementException {
        currentIndex--;
        if (currentIndex < 0) {
            currentIndex++;
            throw new java.util.NoSuchElementException();
        }
        return factory.getThreadType(types[currentIndex]);
    }

    /**
     * Returns the index number that would be returned with a call to previous().
     */
    public int previousIndex() {
        return currentIndex-1;
    }

}
