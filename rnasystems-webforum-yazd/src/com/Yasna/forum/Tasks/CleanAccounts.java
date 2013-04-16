package com.Yasna.forum.Tasks;

import com.Yasna.forum.database.SystemProperty;
import com.Yasna.forum.database.DbConnectionManager;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.sql.ResultSet;

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
 * This class is used to remove the accounts that haven't been activated.
 */
public class CleanAccounts {
    private static final String GET_NOTACTIVE= "select distinct userID from yazdUserProp where name=?";
    private static final String DELETE_PERMISSIONS =
            "DELETE FROM yazdUserPerm WHERE userID=?";
    private static final String DELETE_PROPERTIES =
            "DELETE FROM yazdUserProp WHERE userID=?";
    private static final String DELETE_GROUPS=
            "delete from yazdGroupUser where userID=?";
    private static final String DELETE_USER=
             "delete from "+ SystemProperty.getProperty("User.Table")+" where "+SystemProperty.getProperty("User.Column.UserID")+"=?";
    public CleanAccounts(){
        Connection con = null;
        PreparedStatement pstmt = null;
        try {
            con = DbConnectionManager.getConnection();
            pstmt = con.prepareStatement(GET_NOTACTIVE);
            pstmt.setString(1,"notactive");
            ResultSet rs = pstmt.executeQuery();
            while(rs.next()){
                int userid=rs.getInt("userID");
                pstmt = con.prepareStatement(DELETE_PERMISSIONS);
                pstmt.setInt(1,userid);
                pstmt.executeUpdate();
                pstmt = con.prepareStatement(DELETE_PROPERTIES);
                pstmt.setInt(1,userid);
                pstmt.executeUpdate();
                pstmt = con.prepareStatement(DELETE_GROUPS);
                pstmt.setInt(1,userid);
                pstmt.executeUpdate();
                pstmt = con.prepareStatement(DELETE_USER);
                pstmt.setInt(1,userid);
                pstmt.executeUpdate();
            }
        }
        catch( SQLException sqle ) {
            System.err.println("CleanAccounts (3) Exception:"+sqle.getMessage());
            sqle.printStackTrace();
        }
        catch (Exception e) {
            System.err.println("CleanAccounts (92) Exception:"+e.getMessage());
        }
        finally {
            try {  pstmt.close(); }
            catch (Exception e) { e.printStackTrace(); }
            try {  con.close();   }
            catch (Exception e) { e.printStackTrace(); }
        }

    }
    
}
