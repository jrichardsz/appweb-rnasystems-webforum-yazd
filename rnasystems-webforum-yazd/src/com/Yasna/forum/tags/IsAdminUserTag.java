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

package com.Yasna.forum.tags;

import javax.servlet.jsp.tagext.*;
import com.Yasna.forum.*;
import javax.servlet.jsp.*;

public class IsAdminUserTag extends TagSupport implements BooleanTag {

    private boolean result;
    private boolean case_ = false;
    private boolean attrSet = false;

    public int doStartTag() throws JspException {
        if (!attrSet) {
            case_ = false;
        }
        attrSet = false;
        try {
			Authorization authToken = getAuthToken();
            ForumFactory forumFactory = ForumFactory.getInstance(authToken);
            ForumPermissions permissions = forumFactory.getPermissions(authToken);
            boolean isSystemAdmin = permissions.get(ForumPermissions.SYSTEM_ADMIN);
            boolean isUserAdmin   = permissions.get(ForumPermissions.FORUM_ADMIN);
            boolean isModerator   = false;
            Forum forum = getForum();
            if (forum != null) {
                isModerator   = forum.getPermissions(authToken).get(ForumPermissions.MODERATOR);
            }
            boolean isAdmin = isUserAdmin || isSystemAdmin || isModerator;
            result = isAdmin;
            if (isAdmin) return EVAL_BODY_INCLUDE;
        } catch(Exception e) {
        }
        if (case_) {
            return EVAL_BODY_INCLUDE;
        } else {
            return SKIP_BODY;
        }
    }//doStartTag

    private Authorization getAuthToken() {
        YazdState js = (YazdState) pageContext.getAttribute("yazdUserState",PageContext.SESSION_SCOPE);
		return js.getAuthorization();
    }

    private Forum getForum() {
        ForumTag ft = null;
        try {
            ft = (ForumTag)this.findAncestorWithClass(this,
                Class.forName("com.Yasna.forum.tags.ForumTag"));
        } catch(Exception e) {
        }
        if (ft != null) return ft.getForum();
        return null;
    }

 	public boolean getValue() {
 	    return result;
    }

    public void setCase(String v) {
        attrSet = true;
        case_ = false;
        if ("true".equals(v)) case_ = true;
    }
}