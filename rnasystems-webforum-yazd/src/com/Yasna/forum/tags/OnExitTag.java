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

package com.Yasna.forum.tags;

import java.io.*;
import java.util.*;
import javax.servlet.*;
import javax.servlet.jsp.*;
import javax.servlet.jsp.tagext.*;
import javax.servlet.http.*;
import com.Yasna.forum.*;
import com.Yasna.forum.tags.*;

/**
 * JSP Tag <b>on_exit</b>, used to include content on the last iteration
 * of a <b>forum_loop</b>, <b>thread_loop</b>, <b>message_loop</b>,
 * or <b>walk</b> tag.
 * <p>
 * Includes body of tag if this is the last time through the loop.
 * <p>
 * Must be nested inside a <b>forum_loop</b>, <b>thread_loop</b>,
 * <b>message_loop</b>, or <b>walk</b> tag.
 * <p>
 * JSP Tag Lib Descriptor
 * <p><pre>
 *  &lt;name&gt;on_exit&lt;/name&gt;
 *  &lt;tagclass&gt;com.Yasna.forum.tags.OnExitTag&lt;/tagclass&gt;
 *  &lt;bodycontent&gt;JSP&lt;/bodycontent&gt;
 *  &lt;info&gt;
 *       When looping using forum_loop, thread_loop, or walk tag;
 *       includes body of tag on last iteration of loop if there are more
 *       items to be displayed.
 *  &lt;/info&gt;
 * </pre>
 *
 * @see Paging
 * @see WalkTag
 * @see ForumLoopTag
 * @see ThreadLoopTag
 * @see MessageLoopTag
 *
 * @author Glenn Nielsen
 */

public class OnExitTag extends TagSupport
{

  /**
   * Method called at start of on_exit Tag
   *
   * @return EVAL_BODY if this is the last time through the loop or SKIP_BODY if this isn't the last time.
   */
  public final int doStartTag() throws JspException
  {
    // Find the parent tag that implements Paging,
    // then see if this is the last time through the loop
    Paging pa = null;
    try {
      pa = (Paging)this.findAncestorWithClass(this,
        Class.forName("com.Yasna.forum.tags.Paging"));
      if( pa.isExit() )
        return EVAL_BODY_INCLUDE;
    } catch(Exception e) {
    }

    return SKIP_BODY;
  }
}
