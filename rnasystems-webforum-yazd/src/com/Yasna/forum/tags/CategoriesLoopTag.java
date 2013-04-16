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
import java.util.*;

/**
 * Jsp tag used to iterate through categories in database.
 * Implements the BooleanTag interface and its single method getValue()
 * returns true if any category exits in the database. Otherwise returns false.
 */
public class CategoriesLoopTag extends TagSupport implements BooleanTag {

    boolean hasCategories;
    private Iterator categoryIterator;
    private Category category;
    private String name;
    private final String BLANK = "&nbsp;";
    private String id;

    public int doStartTag() throws JspException {
    	ForumFactory forumFactory = ForumFactory.getInstance(getAuthToken());
        categoryIterator = forumFactory.categories();
        hasCategories = categoryIterator.hasNext();
        if (hasCategories) {
            category = (Category)categoryIterator.next();
            name = category.getName();
            pageContext.setAttribute(id, this, PageContext.PAGE_SCOPE);
        }
        return EVAL_BODY_INCLUDE;
    }

    /**
     * Returns the name of current category only once. Every other call on the
     * same category will result in "&nbsp" string.
     * @return Category name.
     */
    public String getName() {
        String toReturn = name;
        name = BLANK;
        return toReturn;
    }

    /**
     * Returns the Category object of current category.
     * @return Category object.
     */
    public Category getCategory() {
        return category;
    }

    public int doAfterBody() throws JspException {
        if (categoryIterator.hasNext()) {
            category = (Category) categoryIterator.next();
            name = category.getName();
            return EVAL_BODY_AGAIN;
        } else {
            return SKIP_BODY;
        }
    }

    public int doEndTag() throws JspException {
        return EVAL_PAGE;
    }

    public void release() {
        category = null;
        categoryIterator = null;
    }

    /**
     * Retrieve Authorization object from pageContext which give the information
     * for currently logged user.
     *
     * @return Authorization object.
     */
    private Authorization getAuthToken() {
        YazdState js = (YazdState) pageContext.getAttribute("yazdUserState",PageContext.SESSION_SCOPE);
		return js.getAuthorization();
    }

    /**
     * The BooleanTag interface method.
     * @return true if any category found in database, false otherwise.
     */
    public boolean getValue() {
        return hasCategories;
    }

    /**
     * The id that will be used for saving the current object in pageContext.
     * @param id String value.
     */
    public void setId(String id) {
        this.id = id;
    }

}