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

public interface Category {

  /**
   * Returns the unique id of the Category.
   *
   * @return the unique id of the Category.
   */
  public int getID();

  /**
   * Returns the name of the Category. Every category name in the system must be
   * unique. However, this restriction allows one to lookup a category by name
   * as well as by ID.
   *
   * @return the name of the category.
   */
  public String getName();

  /**
   * Sets the name of the Category. Every category name in the system must be
   * unique.
   *
   * An exception will be thrown if a category with the same name as the new
   * name already exists.
   *
   * @param name the name of the category.
   * @throws UnauthorizedException if does not have ADMIN permissions.
   * @throws CategoryAlreadyExistsException if a category with the specified name
   *      already exists.
   */
  public void setName(String name) throws UnauthorizedException,
          CategoryAlreadyExistsException;

    /**
     * this returns the value of the order of Category. This value is used to sort the categories.
     * @return category order
     */
    public int getOrder();

    /**
     * you can use this method to set the value of the category order. This value is used to sort the categories.
     * @param param
     * @throws UnauthorizedException
     */
    public void setOrder(int param) throws UnauthorizedException;

  /**
   * Returns the description of the Category.
   *
   * @return the description of the Category.
   */
  public String getDescription();

  /**
   * Sets the description of the Category.
   *
   * @param description the description of the Category.
   * @throws UnauthorizedException if does not have ADMIN permissions.
   */
  public void setDescription(String description) throws UnauthorizedException;

  /**
   * Returns the Date that the Category was created.
   *
   * @return the Date the Category was created.
   */
  public Date getCreationDate();

  /**
   * Sets the creation date of the Category.
   *
   * @param creationDate the date the Category was created.
   * @throws UnauthorizedException if does not have ADMIN permissions.
   */
  public void setCreationDate(Date creationDate) throws UnauthorizedException;

  /**
   * Returns the Date that the Category was last modified.
   *
   * @return the Date the Category was last modified.
   */
  public Date getModifiedDate();

  /**
   * Sets the date the Category was last modified.
   *
   * @param modifiedDate the date the Category was modified.
   * @throws UnauthorizedException if does not have ADMIN permissions.
   */
  public void setModifiedDate(Date modifiedDate) throws UnauthorizedException;

  /**
   * Returns the forumGroup specified by id. The method will return null
   * if the forumGroup is not in the Category.
   */
  public ForumGroup getForumGroup(int forumGroupID)
          throws ForumGroupNotFoundException;

  /**
   * Deletes a forumGroup and all forums that belongs to it.
   *
   * @param forumGroup the forumGroup to delete.
   * @throws UnauthorizedException if does not have ADMIN permissions.
   */
  public void deleteForumGroup(ForumGroup forumGroup) throws UnauthorizedException;

  /**
   * Creates a new Forum Group.
   *
   * @param name the name of the ForumGroup.
   * @param description the description of the ForumGroup.
   * @throws UnauthorizedException if not allowed to create a ForumGroup.
   */
  public abstract ForumGroup createForumGroup(String name, String description)
          throws UnauthorizedException;

  /**
   * Returns a Iterator for the Category to move through the forumGroups.
   */
  public Iterator forumGroups();

}