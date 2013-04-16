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

import java.util.Date;
import java.util.Iterator;
import java.util.Enumeration;

/**
 * A protection proxy for ForumGroup. A proxy has a set of permissions that are
 * specified at creation time of the proxy. Subsequently, those permissions
 * are used to restrict access to protected Category methods. If a user does
 * not have the right to execute a particular method, and UnauthorizedException
 * is thrown.
 *
 * @see Forum
 * @see ForumPermissions
 * @see UnauthorizedException
 */
public class ForumGroupProxy implements ForumGroup {

    private ForumGroup forumGroup;
    private Authorization authorization;
    private ForumPermissions permissions;

    /**
     * Creates a new ForumGroupProxy object.
     *
     * @param forumGroup the forumGroup to protect by proxy
     * @param authorization the user's authorization token
     * @param permissions the permissions to use with this proxy.
     */
    public ForumGroupProxy(ForumGroup forumGroup, Authorization authorization,
            ForumPermissions permissions)
    {
        this.forumGroup = forumGroup;
        this.authorization = authorization;
        this.permissions = permissions;
    }

    //** Methods from interface below**//
    public String getName() {
        return forumGroup.getName();
    }

    public int getID() {
        return forumGroup.getID();
    }

    public String getDescription() {
        return forumGroup.getDescription();
    }

    public Date getCreationDate() {
        return forumGroup.getCreationDate();
    }

    public Date getModifiedDate() {
        return forumGroup.getModifiedDate();
    }
    public int getOrder(){
        return forumGroup.getOrder();
    }
    public void setOrder(int param) throws UnauthorizedException{
        if (permissions.isSystemOrForumAdmin()) {
            forumGroup.setOrder(param);
        }
        else {
            throw new UnauthorizedException();
        }
    }
    public void setModifiedDate(Date modifiedDate) throws UnauthorizedException {
        if (permissions.isSystemOrForumAdmin()) {
            forumGroup.setModifiedDate(modifiedDate);
        }
        else {
            throw new UnauthorizedException();
        }
    }

    public void setCreationDate(Date creationDate) throws UnauthorizedException {
        if (permissions.isSystemOrForumAdmin()) {
            forumGroup.setCreationDate(creationDate);
        }
        else {
            throw new UnauthorizedException();
        }
    }

    public void setName(String name) throws UnauthorizedException {
        if (permissions.isSystemOrForumAdmin()) {
            forumGroup.setName(name);
        }
        else {
            throw new UnauthorizedException();
        }
    }

    public void setDescription(String description) throws UnauthorizedException {
        if (permissions.isSystemOrForumAdmin()) {
            forumGroup.setDescription(description);
        }
        else {
            throw new UnauthorizedException();
        }
    }

    public Iterator forums() {
        Iterator iterator = forumGroup.forums();
        return new ForumIteratorProxy(iterator, authorization, permissions,false);
    }
}
