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

import com.Yasna.forum.Authorization;
import com.Yasna.forum.AuthorizationFactory;
import com.Yasna.forum.UnauthorizedException;
import com.Yasna.forum.Exceptions.UserNotActivatedException;
import com.Yasna.util.StringUtils;

import java.sql.*;
import java.util.Calendar;

/**
 * A subclass of AuthorizationFactory for the default Yazd implementation. It makes an
 * SQL query to the Yazd user table to see if the supplied username and password
 * match a user record. If they do, the appropaite Authorization token is
 * returned. If no matching User record is found an UnauthorizedException is
 * thrown.<p>
 *
 * Because each call to createAuthorization(String, String) makes a database
 * connection, Authorization tokens should be cached whenever possible. When
 * using a servlet or JSP skins, a good method is to cache the token in the
 * session. The SkinUtils.getUserAuthorization() methods automatically handles
 * this logic.<p>
 *
 * If you wish to integrate Yazd with your own user system, you'll need to
 * either modify the class or provide your own implementation of the
 * AuthorizationFactory interface.
 */
public class DbAuthorizationFactory extends AuthorizationFactory {

    /** DATABASE QUERIES **/
    private static final String AUTHORIZE =
        "SELECT "+SystemProperty.getProperty("User.Column.UserID")+" FROM "+
	SystemProperty.getProperty("User.Table")
       	+" WHERE "+SystemProperty.getProperty("User.Column.Username")
	+"=? AND "+SystemProperty.getProperty("User.Column.PasswordHash")+"=?";
    private static final String CHECKLOGIN="select * from yazdUserProp where userID=? and name=?";
    private static final String INSERTLOGIN="insert into yazdUserProp(userID,name,propValue) values (?,?,?)";
    private static final String UPDATELOGIN =
        "update yazdUserProp set propValue=? WHERE userID=? and name=?";

    /**
     * The same token can be used for all anonymous users, so cache it.
     */
    private static final Authorization anonymousAuth = new DbAuthorization(-1);

    /**
     * Creates Authorization tokens for users. This method is implemented by
     * concrete subclasses of AuthorizationFactory.
     *
     * @param username the username to create an Authorization with.
     * @param password the password to create an Authorization with.
     * @return an Authorization token if the username and password are correct.
     * @throws UnauthorizedException if the username and password do not match
     *      any existing user.
     */
    public Authorization createAuthorization(String username, String password)
            throws UnauthorizedException
    {
        if (username == null || password == null) {
            throw new UnauthorizedException();
        }
        //Yazd stores all passwords in hashed form. So, hash the plain text
        //password for comparison.
        password = StringUtils.hash(password);
        int userID = 0;
        Connection con = null;
        PreparedStatement pstmt = null;
        try {
            con = DbConnectionManager.getConnection();
            pstmt = con.prepareStatement(AUTHORIZE);
            pstmt.setString(1, username);
            pstmt.setString(2, password);

            ResultSet rs = pstmt.executeQuery();
            //If the query had no results, the username and password
            //did not match a user record. Therefore, throw an exception.
            if (!rs.next()) {
                throw new UnauthorizedException();
            }
            userID = rs.getInt(1);

	    pstmt = con.prepareStatement(CHECKLOGIN);
        pstmt.setInt(1,userID);
        pstmt.setString(2,"notactive");
        rs = pstmt.executeQuery();
        if(rs.next()){
            //This account is not activated yet and can not be authorized to login.
             throw new UserNotActivatedException("User not yet activated");
        }
	    //pstmt.setInt(1,userID);
	    pstmt.setString(2,"lastlogin");
            rs = pstmt.executeQuery();
            //If the query had no results, insert the lastlogin into properties
            if (!rs.next()) {
               pstmt = con.prepareStatement(INSERTLOGIN);
               pstmt.setInt(1,userID);
               pstmt.setString(2,"lastlogin");
               pstmt.setString(3,Long.toString(Calendar.getInstance().getTimeInMillis()));
               pstmt.executeUpdate();
            }else{
               pstmt = con.prepareStatement(UPDATELOGIN);
               pstmt.setString(1,Long.toString(Calendar.getInstance().getTimeInMillis()));
               pstmt.setInt(2,userID);
               pstmt.setString(3,"lastlogin");
               pstmt.executeUpdate();
	    }

        }
        catch( SQLException sqle ) {
            System.err.println("Exception in DbAuthorizationFactory:" + sqle);
            sqle.printStackTrace();
            throw new UnauthorizedException();
        }
        finally {
            try {  pstmt.close(); }
            catch (Exception e) { e.printStackTrace(); }
            try {  con.close();   }
            catch (Exception e) { e.printStackTrace(); }
        }
        //Got this far, so the user must be authorized.
        return new DbAuthorization(userID);
    }

    /**
     * Creates anonymous Authorization tokens.
     *
     * @return an anonymous Authorization token.
     */
    public Authorization createAnonymousAuthorization() {
        return anonymousAuth;
    }
}
