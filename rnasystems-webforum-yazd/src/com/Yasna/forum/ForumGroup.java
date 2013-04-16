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

import java.util.Iterator;
import java.util.Date;

public interface ForumGroup {

  /**
   * Returns the unique id of the ForumGroup.
   *
   * @return the unique id of the ForumGroup.
   */
  public int getID();

  /**
   * Returns the name of the ForumGroup.
   *
   * @return the name of the ForumGroup.
   */
  public String getName();

  /**
   * Sets the name of the ForumGroup.
   *
   * @param name the name of the ForumGroup.
   * @throws UnauthorizedException if does not have ADMIN permissions.
   */
  public void setName(String name) throws UnauthorizedException;

  /**
   * Returns the description of the ForumGroup.
   *
   * @return the description of the ForumGroup.
   */
  public String getDescription();

    /**
     * This returns the order of the group. This number is used to order the groups by.
     * @return order of the group
     */
  public int getOrder();

    /**
     * This method is used to set the order of the group. This number is used to order the groups by.
     * @param param
     */
  public void setOrder(int param) throws UnauthorizedException;
  /**
   * Sets the description of the ForumGroup.
   *
   * @param description the description of the ForumGroup.
   * @throws UnauthorizedException if does not have ADMIN permissions.
   */
  public void setDescription(String description) throws UnauthorizedException;

  /**
   * Returns the Date that the ForumGroup was created.
   *
   * @return the Date the ForumGroup was created.
   */
  public Date getCreationDate();

  /**
   * Sets the creation date of the ForumGroup.
   *
   * @param creationDate the date the ForumGroup was created.
   * @throws UnauthorizedException if does not have ADMIN permissions.
   */
  public void setCreationDate(Date creationDate) throws UnauthorizedException;

  /**
   * Returns the Date that the ForumGroup was last modified.
   *
   * @return the Date the ForumGroup was last modified.
   */
  public Date getModifiedDate();

  /**
   * Sets the date the ForumGroup was last modified.
   *
   * @param modifiedDate the date the ForumGroup was modified.
   * @throws UnauthorizedException if does not have ADMIN permissions.
   */
  public void setModifiedDate(Date modifiedDate) throws UnauthorizedException;

  /**
   * Returns an Iterator for the ForumGroup to move through the forums.
   */
  public Iterator forums();

}
