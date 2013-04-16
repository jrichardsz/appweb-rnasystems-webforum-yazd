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


package com.Yasna.forum;

import java.util.*;

/**
 * A protection proxy for ForumMessage objects.
 */
public class ForumMessageProxy implements ForumMessage {

    private ForumMessage message;
    private Authorization authorization;
    private ForumPermissions permissions;
    private boolean canReadText;

    /**
     * Creates a new ForumMessageProxy to protect the supplied message with
     * the specified permissions
     */
    public ForumMessageProxy(ForumMessage message, Authorization authorization,
                             ForumPermissions permissions) {
        this.message = message;
        this.authorization = authorization;
        this.permissions = permissions;
        init();
    }

    /**
     * Initialize some class members.
     */
    private void init() {
        canReadText = false;
        boolean isModerator = false;
        boolean isSystemAdmin = permissions.get(ForumPermissions.SYSTEM_ADMIN);
        boolean isUserAdmin = permissions.get(ForumPermissions.FORUM_ADMIN);
        if (permissions != null) {
            isModerator = permissions.get(ForumPermissions.MODERATOR);
        }
        boolean isAdmin = isSystemAdmin || isUserAdmin || isModerator;
        if (isAdmin ||
            (message.getUser().getID() == authorization.getUserID() &&
             authorization.getUserID() != -1)) {
            canReadText = true;
        } else {
            if (message.isApproved()) {
                //if private message
                if (message.isPrivate()) {
                    //if receiver
                    if (message.getReplyPrivateUserId() ==
                        authorization.getUserID()) {
                        canReadText = true;
                    }
                } else { //not private message
                    canReadText = true;
                }
            }
        } //if
    }

    //FROM THE FORUMMESSAGE INTERFACE//

    public int getID() {
        return message.getID();
    }

    public Date getCreationDate() {
        return message.getCreationDate();
    }

    public void setCreationDate(Date creationDate) throws UnauthorizedException {
        if (permissions.isSystemOrForumAdmin()) {
            this.message.setCreationDate(creationDate);
        } else {
            throw new UnauthorizedException();
        }
    }

    public Date getModifiedDate() {
        return message.getModifiedDate();
    }

    public void setModifiedDate(Date modifiedDate) throws UnauthorizedException {
        if (permissions.isSystemOrForumAdmin()) {
            this.message.setModifiedDate(modifiedDate);
        } else {
            throw new UnauthorizedException();
        }
    }

    public String getSubject() {
        return message.getSubject();
    }

    public int getReplyPrivateUserId() {
        return message.getReplyPrivateUserId();
    }

    public boolean isApproved() {
        return message.isApproved();
    }

    public String getUnfilteredSubject() {
        return message.getUnfilteredSubject();
    }

    public void setSubject(String subject) throws UnauthorizedException {
        if (permissions.isSystemOrForumAdmin() ||
            getUser().hasPermission(ForumPermissions.USER_ADMIN)) {
            this.message.setSubject(subject);
        } else {
            throw new UnauthorizedException();
        }
    }

    public void setReplyPrivateUserId(int replyPrivateUserId) throws
            UnauthorizedException {
        if (permissions.isSystemOrForumAdmin() ||
            getUser().hasPermission(ForumPermissions.USER_ADMIN)) {
            this.message.setReplyPrivateUserId(replyPrivateUserId);
        } else {
            throw new UnauthorizedException();
        }
    }

    public void setApprovment(boolean approved) throws UnauthorizedException {
        if (permissions.isSystemOrForumAdmin() ||
            permissions.get(ForumPermissions.MODERATOR)) {
            this.message.setApprovment(approved);
        } else {
            throw new UnauthorizedException();
        }
    }

    public String getBody() {
        if (canReadText) {
            return message.getBody();
        } else {
            return null;
        }
    }

    public boolean isPrivate() {
        return message.isPrivate();
    }

    public String getUnfilteredBody() {
        if (canReadText) {
            return message.getUnfilteredBody();
        } else {
            return null;
        }
    }

    public void setBody(String body) throws UnauthorizedException {
        if (permissions.isSystemOrForumAdmin() ||
            getUser().hasPermission(ForumPermissions.USER_ADMIN)) {
            this.message.setBody(body);
        } else {
            throw new UnauthorizedException();
        }
    }

    public User getUser() {
        User user = message.getUser();
        ForumPermissions userPermissions = user.getPermissions(authorization);
        ForumPermissions newPermissions =
                new ForumPermissions(permissions, userPermissions);
        return new UserProxy(user, authorization, newPermissions);
    }

    public String getProperty(String name) {
        return message.getProperty(name);
    }

    public String getUnfilteredProperty(String name) {
        return message.getUnfilteredProperty(name);
    }

    public void setProperty(String name, String value) {
        message.setProperty(name, value);
    }

    public Iterator propertyNames() {
        return message.propertyNames();
    }

    public boolean isAnonymous() {
        return message.isAnonymous();
    }

    public ForumThread getForumThread() {
        return message.getForumThread();
    }

    public boolean hasPermission(int type) {
        return permissions.get(type);
    }

    //OTHER METHODS//

    /**
     * Converts the object to a String by returning the subject of the message.
     * This functionality is primarily for Java applications that might be
     * accessing CoolForum objects through a GUI.
     */
    public String toString() {
        return message.toString();
    }

    /**
     * Small violation of our pluggable backend architecture so that database
     * insertions can be made more efficiently and transactional. The fact
     * that this violation is needed probably means that the proxy architecture
     * needs to be adjusted a bit.
     */
    public void insertIntoDb(java.sql.Connection con, ForumThread thread) throws
            java.sql.SQLException {
        ((com.Yasna.forum.database.DbForumMessage) message).insertIntoDb(con,
                thread);
    }
    public MessageRanking getRanking(){
        return message.getRanking();
    }
    public void setRanking(int para) throws UnauthorizedException{
        if (!message.getForumThread().getRootMessage().getUser().isAnonymous() && authorization.getUserID() == message.getForumThread().getRootMessage().getUser().getID() && authorization.getUserID() != message.getUser().getID()){
            message.setRanking(para);
        } else {
            throw new UnauthorizedException("Only the user who created the thread can rank other messages");
        }
    }


}
