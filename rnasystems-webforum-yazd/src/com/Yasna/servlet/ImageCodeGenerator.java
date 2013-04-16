package com.Yasna.servlet;

import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.ServletConfig;
import javax.servlet.ServletException;
import javax.imageio.ImageIO;
import java.awt.*;
import java.awt.font.FontRenderContext;
import java.awt.geom.Rectangle2D;
import java.awt.image.BufferedImage;
import java.io.OutputStream;
import java.io.FileInputStream;
import java.io.File;
import java.io.InputStream;

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
 * This servlet serves the images for the random code. This is to fight spamming new accounts with software tools.
 */
public class ImageCodeGenerator  extends HttpServlet{
    private Font font;
    private BufferedImage buffer;
    private Graphics2D g2;
    public void init (ServletConfig config)
        throws ServletException {
        System.setProperty( "java.awt.headless", "true" );
        buffer = new BufferedImage(1,1,BufferedImage.TYPE_INT_RGB);
        g2 = buffer.createGraphics();
        try{
            font = Font.createFont(Font.TRUETYPE_FONT,getClass().getResourceAsStream("Teenick.ttf"));     //part of the jar file relative path to the class
            font = font.deriveFont(29.0f);
            System.err.println("Yazd Initialized Font");
        } catch (Exception e){
            System.err.println("Exception in Yazd Servlet 0: " + e.getMessage());
            e.printStackTrace();
        }
        super.init (config);
    }


    public void service (HttpServletRequest request,
                         HttpServletResponse response){
        String code = (String)request.getSession().getAttribute("YazdCode");
        
        sendImage(response,code);

    }

    private void sendImage(HttpServletResponse response,String code){
        try{


// prepare some output
buffer = new BufferedImage(90, 50,
                           BufferedImage.TYPE_INT_RGB);
g2 = buffer.createGraphics();
g2.setRenderingHint(RenderingHints.KEY_ANTIALIASING,
                    RenderingHints.VALUE_ANTIALIAS_ON);
g2.setFont(font);
// actually do the drawing
            g2.setColor(Color.BLUE);
            g2.fillRect(0,0,90,50);
            g2.setColor(Color.WHITE);
            g2.drawString(code,3,35);


// set the content type and get the output stream
            response.setContentType("image/png");
            OutputStream os = response.getOutputStream();

// output the image as png
            ImageIO.write(buffer, "png", os);
            os.close();


        } catch (Exception e){
            System.err.println("Exception in Yazd Servlet: " + e.getMessage());
            e.printStackTrace();
        }
    }
}
