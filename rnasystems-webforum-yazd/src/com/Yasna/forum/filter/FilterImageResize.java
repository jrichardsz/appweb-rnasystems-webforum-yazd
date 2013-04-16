package com.Yasna.forum.filter;

import com.Yasna.forum.ForumMessageFilter;
import com.Yasna.forum.ForumMessage;

import java.io.Serializable;
import java.util.Properties;
import java.util.Enumeration;
import java.util.regex.Pattern;
import java.util.regex.Matcher;

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

public class FilterImageResize extends ForumMessageFilter implements Serializable {
    /**
       * Property values of the filter.
       */
      private Properties props;

      /**
       * Property descriptions of the filter.
       */
      private Properties propDescriptions;

      /**
       * Creates a new filter not associated with a message. This is
       * generally only useful for defining a template filter that other
       * fitlers will be cloned from.
       */
      public FilterImageResize() {
          super();
          props = new Properties();
          props.put("MaxWidth","200");
          propDescriptions = new Properties();
          propDescriptions.put("MaxWidth","Maximum width of an image tag in the post");
      }
   /**
     * Creates a new filter wrapped around the specified message. This
     * constructor is normally called when cloning a filter template.
     *
     * @param message the ForumMessage to wrap the new filter around.
     */
    public FilterImageResize(ForumMessage message, Properties props,
                             Properties propDescriptions)
    {
        super(message);
        this.props = new Properties(props);
        this.propDescriptions = new Properties(propDescriptions);
    }

    /**
     * Clones a new filter that will have the same properties and that
     * will wrap around the specified message.
     *
     * @param message the ForumMessage to wrap the new filter around.
     */
    public ForumMessageFilter clone(ForumMessage message){
        return new FilterImageResize(message,props,propDescriptions);
    }

    /**
     * Returns the name of the filter.
     */
    public String getName() {
        return "Image Resize Filter";
    }

    /**
     * Returns a description of the filter.
     */
    public String getDescription() {
        return "This filter will look for the &lt;img tag and replace the width with the maximum size allowed and remove the height";
    }

    /**
     * Returns the author of the filter.
     */
    public String getAuthor() {
        return "www.yasna.com";
    }

    /**
     * Returns the major version number of the filter.
     */
    public int getMajorVersion() {
        return 1;
    }

    /**
     * Returns a description of the filter.
     */
    public int getMinorVersion() {
        return 0;
    }

    /**
     * Returns the value of a property of the filter.
     *
     * @param name the name of the property.
     */
    public String getFilterProperty(String name) {
        return props.getProperty(name);
    }

    /**
     * Returns the description of a property of the filter.
     *
     * @param name the name of the property.
     * @return the description of the property.
     */
    public String getFilterPropertyDescription(String name) {
        return propDescriptions.getProperty(name);
    }

    /**
     * Returns an Enumeration of all the property names.
     */
    public Enumeration filterPropertyNames() {
        //No properties, so return null.
        return props.propertyNames();
    }

    /**
     * Sets a property of the filter. Each filter has a set number of
     * properties that are determined by the filter author.
     *
     * @param name the name of the property to set.
     * @param value the new value for the property.
     *
     * @throws IllegalArgumentException if the property trying to be set doesn't
     *    exist.
     */
    public void setFilterProperty(String name, String value)
            throws IllegalArgumentException
    {
        if (props.getProperty(name) == null || Integer.parseInt(value) < 10) {
            throw new IllegalArgumentException();
        }
        props.put(name, value);
    }

    /**
     * <b>Overloaded</b> to return the subject of the message with HTML tags
     * escaped.
     */
    public String getSubject() {
        return checkimagewidth(message.getSubject());
    }

    /**
     * <b>Overloaded</b> to return the body of the message with HTML tags
     * escaped.
     */
    public String getBody() {
        return checkimagewidth(message.getBody());
    }

    /**
     * This method takes a string which may contain script tags (ie, <script>, </script>,
     * javascript) and removes the characters.
     *
     * @param input The text to be converted.
     * @return The input string with the tags removed
     */
    private String checkimagewidth( String input ) {
        //Check if the string is null or zero length -- if so, return
        //what was sent in.
        if( input == null || input.length() == 0 ) {
            return input;
        }
        Pattern pa = Pattern.compile("\\<\\/?(\\s*)(img)(\\s.*?)(([a-z]+)\\s*=\\s*\"([^\"]+)\")(\\s.*?)?\\>",Pattern.CASE_INSENSITIVE);
        Pattern paW = Pattern.compile("(width)\\s*=\\s*(\"|')?([0-9]+)(\"|')?",Pattern.CASE_INSENSITIVE);
        Pattern paH = Pattern.compile("(height)\\s*=\\s*(\"|')?([0-9]+)(\"|')?",Pattern.CASE_INSENSITIVE);
        Matcher match = pa.matcher(input);
        StringBuffer sb=new StringBuffer();
        int maxw = Integer.parseInt(props.getProperty("MaxWidth"));
                while (match.find()) {
                    String tmp = match.group(0);
                    Matcher matchW = paW.matcher(tmp);
                    if(matchW.find()){       //look for width
                      if(Integer.parseInt(matchW.group(3).trim())>maxw){
                         tmp=matchW.replaceAll("width=\""+maxw+"\"");
                          //we now remove the height tag
                          Matcher matchH = paH.matcher(tmp);
                          if(matchH.find()){
                              tmp = matchH.replaceAll("");
                          }
                          //we now replace the original tag with the new tag
                          match.appendReplacement(sb,tmp);
                      }

                    }
                 }
        match.appendTail(sb);

        return sb.toString();
    }

}
