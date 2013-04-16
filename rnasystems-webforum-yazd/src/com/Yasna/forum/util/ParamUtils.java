package com.Yasna.forum.util;

import javax.servlet.http.*;
import java.text.SimpleDateFormat;
import java.util.LinkedList;
import java.util.List;
import java.util.Calendar;

/**
 *  This class assists skin writers in getting parameters.
 */
public class ParamUtils {

    /**
     *  Gets a parameter as a string.
     *  @param request The HttpServletRequest object, known as "request" in a
     *  JSP page.
     *  @param paramName The name of the parameter you want to get
     *  @return The value of the parameter or null if the parameter was not
     *  found or if the parameter is a zero-length string.
     */
        public static String getParameter( HttpServletRequest request, String paramName ) {
                return getParameter( request, paramName, false );
        }

    /**
     *  Gets a parameter as a string.
     *  @param request The HttpServletRequest object, known as "request" in a
     *  JSP page.
     *  @param paramName The name of the parameter you want to get
     *  @param emptyStringsOK Return the parameter values even if it is an empty string.
     *  @return The value of the parameter or null if the parameter was not
     *  found.
     */
        public static String getParameter( HttpServletRequest request, String paramName, boolean emptyStringsOK ) {
                String temp = request.getParameter(paramName);
        if( temp != null ) {
            if( temp.equals("") && !emptyStringsOK ) {
                return null;
            }
            else {
                return temp;
            }
        }
        else {
            return null;
        }
    }
        public static java.sql.Date getDateParameter( HttpServletRequest request, String paramName) {
                String temp = request.getParameter(paramName);
                if( temp != null && !temp.equals("") ) {
                SimpleDateFormat df = new SimpleDateFormat("yyyy-MM-dd");

                  try {
                   return new java.sql.Date(df.parse(temp).getTime());
                  }
                  catch( Exception ignored ) {}
                        return null;
                } else {
                        return null;
                }
        }

    public static Calendar getCalendarParameter( HttpServletRequest request, String paramName) {
            String temp = request.getParameter(paramName);
            java.sql.Date tempdt=null;
            if( temp != null && !temp.equals("") ) {
            SimpleDateFormat df = new SimpleDateFormat("yyyy-MM-dd");

              try {
               tempdt = new java.sql.Date(df.parse(temp).getTime());
              }
              catch( Exception ignored ) {}
            } else {
                    return null;
            }
            if (tempdt != null){
                Calendar tempcal = Calendar.getInstance();
                tempcal.setTime(tempdt);
                return tempcal;
            } else {
                return null;
            }
    }


    /**
     *  Gets a parameter as a boolean.
     *  @param request The HttpServletRequest object, known as "request" in a
     *  JSP page.
     *  @param paramName The name of the parameter you want to get
     *  @return True if the value of the parameter was "true", false otherwise.
     */
        public static boolean getBooleanParameter( HttpServletRequest request, String paramName ) {
                String temp = request.getParameter(paramName);
                if( temp != null && temp.equals("true") ) {
                        return true;
                } else {
                        return false;
                }
        }

    /**
     *  Gets a parameter as a int.
     *  @param request The HttpServletRequest object, known as "request" in a
     *  JSP page.
     *  @param paramName The name of the parameter you want to get
     *  @return The int value of the parameter specified or the default value if
     *  the parameter is not found.
     */
        public static int getIntParameter( HttpServletRequest request, String paramName, int defaultNum ) {
                String temp = request.getParameter(paramName);
                if( temp != null && !temp.equals("") ) {
            int num = defaultNum;
            try {
                num = Integer.parseInt(temp);
            }
            catch( Exception ignored ) {}
                        return num;
                } else {
                        return defaultNum;
                }
        }
    public static float getFloatParameter( HttpServletRequest request, String paramName, float defaultNum ) {
        String temp = request.getParameter(paramName);
        if( temp != null && !temp.equals("") ) {
            float num = defaultNum;
            try {
                num = Float.parseFloat(temp);
            }
            catch( Exception ignored ) {}
            return num;
        } else {
            return defaultNum;
        }
    }
    public static String[] getArrayParameter( HttpServletRequest request, String paramName) {
            return request.getParameterValues(paramName);
    }
    public static int[] getIntArrayParameter( HttpServletRequest request, String paramName) {
        String delim = ",";
        String s = request.getParameter(paramName);
        if (s == null) {
            return null;
        }
        if (delim == null) {
            return null;
        }

        List l = new LinkedList();
        int pos = 0;
        int delPos = 0;
        while ((delPos = s.indexOf(delim, pos)) != -1) {
            l.add(s.substring(pos, delPos));
            pos = delPos + delim.length();
        }
        if (pos <= s.length()) {
            // add rest of String
            l.add(s.substring(pos));
        }

        String[] temp = (String[]) l.toArray(new String[l.size()]);
        if (temp == null){
            return null;
        } else {
            int[] tempInt = new int[temp.length];
            for (int i=0; i< temp.length; i++) {
                tempInt[i] = Integer.parseInt(temp[i]);
            }
            return tempInt;
        }
    }

    /**
     *  Gets a checkbox parameter value as a boolean.
     *  @param request The HttpServletRequest object, known as "request" in a
     *  JSP page.
     *  @param paramName The name of the parameter you want to get
     *  @return True if the value of the checkbox is "on", false otherwise.
     */
    public static boolean getCheckboxParameter( HttpServletRequest request, String paramName ) {
        String temp = request.getParameter(paramName);
        if( temp != null && temp.equals("on") ) {
            return true;
        } else {
            return false;
        }
    }

    /**
     *  Gets a parameter as a string.
     *  @param request The HttpServletRequest object, known as "request" in a
     *  JSP page.
     *  @param attribName The name of the parameter you want to get
     *  @return The value of the parameter or null if the parameter was not
     *  found or if the parameter is a zero-length string.
     */
        public static String getAttribute( HttpServletRequest request, String attribName ) {
                return getAttribute( request, attribName, false );
        }

    /**
     *  Gets a parameter as a string.
     *  @param request The HttpServletRequest object, known as "request" in a
     *  JSP page.
     *  @param attribName The name of the parameter you want to get
     *  @param emptyStringsOK Return the parameter values even if it is an empty string.
     *  @return The value of the parameter or null if the parameter was not
     *  found.
     */
        public static String getAttribute( HttpServletRequest request, String attribName, boolean emptyStringsOK ) {
                String temp = (String)request.getAttribute(attribName);
        if( temp != null ) {
            if( temp.equals("") && !emptyStringsOK ) {
                return null;
            }
            else {
                return temp;
            }
        }
        else {
            return null;
        }
    }

    /**
     *  Gets an attribute as a boolean.
     *  @param request The HttpServletRequest object, known as "request" in a
     *  JSP page.
     *  @param attribName The name of the attribute you want to get
     *  @return True if the value of the attribute is "true", false otherwise.
     */
        public static boolean getBooleanAttribute( HttpServletRequest request, String attribName ) {
                String temp = (String)request.getAttribute(attribName);
                if( temp != null && temp.equals("true") ) {
                        return true;
                } else {
                        return false;
                }
        }

    /**
     *  Gets an attribute as a int.
     *  @param request The HttpServletRequest object, known as "request" in a
     *  JSP page.
     *  @param attribName The name of the attribute you want to get
     *  @return The int value of the attribute or the default value if the attribute is not
     *  found or is a zero length string.
     */
        public static int getIntAttribute( HttpServletRequest request, String attribName, int defaultNum ) {
                String temp = (String)request.getAttribute(attribName);
                if( temp != null && !temp.equals("") ) {
            int num = defaultNum;
            try {
                num = Integer.parseInt(temp);
            }
            catch( Exception ignored ) {}
                        return num;
                } else {
                        return defaultNum;
                }
        }

}
