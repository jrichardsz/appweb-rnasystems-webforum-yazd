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

package com.Yasna.util;


import com.Yasna.forum.PropertyManager;

import java.util.*;
import javax.mail.*;
import javax.mail.internet.*;
import javax.naming.*;

public final class  MailSender extends Thread{

    public static final String  TEST_HOST    = "hurricane";
    public static final String  TEST_FROM    = "aflatoon@test.com";
    public static final String  TEST_TO      = "aflatoon@test.com";
    public static final String  TEST_SUBJECT = "SMTPMail Test";
    public static final String  TEST_MESSAGE = "This is a test.";

    private String   host;
    private String   from;
    private String   to;
    private String   cc = null;
    private String   bcc = null;
    private String   subject;
    private String   message;
    private String   smtpusername= PropertyManager.getProperty("yazdMailSMTPServer.username");
    private String   smtppassword= PropertyManager.getProperty("yazdMailSMTPServer.password");


    public MailSender ( String strHost,
                        String strFrom,
                        String strTo,
                        String strCc,
                        String strBcc,
                        String strSubject,
                        String strMessage
    ) {

        host    = strHost    == null ? TEST_HOST    : strHost    ;
        from    = strFrom    == null ? TEST_FROM    : strFrom    ;
        to      = strTo      == null ? TEST_TO      : strTo      ;
        cc = strCc;
        bcc = strBcc;
        subject = strSubject == null ? TEST_SUBJECT : strSubject ;
        message = strMessage == null ? TEST_MESSAGE : strMessage ;
    }

    public void run() {
        try {
            sendIt();
        } catch(Exception e) {
            System.out.println("Yazd MailSender - Exception while sending a mail "+e);
        }
    }

    private void sendIt() throws Exception {
        Properties properties;
        MimeMessage msg;
        Session session;
        /*
        System.out.println("\n-----------------------------------------..." +
                           "\n      ...SENDING MAIL..." +
                           "\n-----------------------------------------..." +
                           "\n      host:    " + host +
                           "\n      to:      " + to +
                           "\n      from:    " + from +
                           "\n      subject: " + subject +
                           "\n-----------------------------------------..." +
                           "\n" + message +
                           "\n-----------------------------------------..."
                           );
        */
        properties = new Properties();
        properties.put("mail.smtp.host", host);
        session = Session.getInstance(properties, null);
        msg = new MimeMessage(session);
        msg.addFrom(new InternetAddress[] {new InternetAddress(from)});
        msg.addRecipient(Message.RecipientType.TO, new InternetAddress(to));
        if (cc != null) {
            msg.addRecipient(Message.RecipientType.CC,
                    new InternetAddress(cc));
        }
        if (bcc != null) {
            msg.addRecipient(Message.RecipientType.BCC,
                    new InternetAddress(bcc));
        }
        msg.setSubject(subject);
        msg.setText(message);
        //msg.setHeader("Content-Type", "text/html");
        //msg.saveChanges();
        if(smtpusername!=null && smtppassword !=null){
            Transport tr = session.getTransport();
            tr.connect(host, smtpusername, smtppassword);
            msg.saveChanges();	// don't forget this
            tr.sendMessage(msg, msg.getAllRecipients());
            tr.close();
            System.out.println("Yazd Forum Software (MailSender.java)-- (authsmtp) Mail sent successfully to:"+to);
        }else{
            Transport.send(msg);
            System.out.println("Yazd Forum Software (MailSender.java)-- Mail sent successfully to:"+to);
        }
    }

    public static void send( String _host, String _from, String _to, String _cc,
                             String _bcc, String _subject, String _message)
    {
        MailSender sender = new MailSender( _host, _from, _to, _cc, _bcc, _subject, _message);
        sender.start();
    }

    public static void send( String _host, String _from, String _to,
                             String _subject, String _message)
    {
        send(_host, _from, _to, null, null, _subject, _message);
    }

    public void sendForTest( ) throws Exception
    {
        sendIt();
    }

    public static void send( String _host, String _from, String _to, String _cc,
                             String _subject, String _message)
    {
        send(_host, _from, _to, _cc, null, _subject, _message);
    }
}
