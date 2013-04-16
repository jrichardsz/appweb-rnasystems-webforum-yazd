package com.Yasna.forum.Tasks;

import com.Yasna.forum.*;
import com.Yasna.forum.database.DbConnectionManager;
import com.Yasna.util.MailSender;

import java.util.LinkedList;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

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
 * This class is meant to handle all people watching the forum.
 * This will be added to add the handle for people also watching a thread.
 * Currently the forum only supports notification of a reply!
 */
public class EmailWatchManager {
    private LinkedList newMessages;
    // This linked list will retain all the new messages and will notify the people that needs to be notified.
    private Thread worker;
    private ForumFactory factory;
    public EmailWatchManager(ForumFactory factory){
        // this is called from the factory and it will retain a handle on it.
        this.factory = factory;
        newMessages = new LinkedList();
        // We are going to start a new worker thread to handle all the emails.
        worker = new Thread(new EmailWatchWorker(this,factory));
        worker.setDaemon(true);
        worker.start();
    }
    public synchronized void addMessage(ForumMessage message){
        newMessages.addLast(message);
        // There is now a message to be processed and the Thread needs to be notified
        notify();
    }
    public synchronized ForumMessage getNextMessage(){
        if(newMessages.isEmpty()){
            try{
                System.out.println("waiting for a new message");
                wait();
                //System.out.println("finished waiting");
            }catch (InterruptedException ie) {}
        }
        return (ForumMessage)newMessages.removeFirst();
    }

    public class EmailWatchWorker implements Runnable{
        private static final String GET_USERLIST=
                "select distinct userID from yazdUserProp where (name=? or name=?) and propValue=?";

        private EmailWatchManager manager;
        private ForumFactory factory;
        public EmailWatchWorker(EmailWatchManager m,ForumFactory factory){
            this.manager=m;
            this.factory = factory;
        }
        public void run(){
            while(true){
                sendEmailsForMessage(manager.getNextMessage());
            }
        }
        private void sendEmailsForMessage(ForumMessage message){
            //send out all the emails necessary
            if(PropertyManager.getProperty("yazdMailSMTPServer")==null || "".equals(PropertyManager.getProperty("yazdMailSMTPServer"))) {
                return;
                // don't do anything if there is no setting for smtp server
            }
            int ForumID = message.getForumThread().getForum().getID();
            int ThreadID = message.getForumThread().getID();
            int OriginalUserID = message.getUser().getID();
            Connection con = null;
            PreparedStatement pstmt = null;
            try {
                con = DbConnectionManager.getConnection();
                pstmt = con.prepareStatement(GET_USERLIST);
                pstmt.setString(1,"WatchForum"+Integer.toString(ForumID));
                pstmt.setString(2,"WatchThread"+Integer.toString(ThreadID));
                pstmt.setString(3, "true");
                ResultSet rs = pstmt.executeQuery();

                while( rs.next() ) {
                    User user = factory.getProfileManager().getUser(rs.getInt("userID"));
                    if (user.getEmail()!=null && !"".equals(user.getEmail()) && user.getID()!=OriginalUserID){
                        // ok ready to send mail to user
                        String emailBody = PropertyManager.getProperty("yazdThreadWatch.MailBody") +
                                "             \n\r"+PropertyManager.getProperty("yazdUrl")+
                                "viewThread.jsp?forum="+ForumID+"&thread="+ThreadID;
                        MailSender.send(PropertyManager.getProperty("yazdMailSMTPServer"),
                                PropertyManager.getProperty("yazdMailFrom"),
                                user.getEmail(),
                                PropertyManager.getProperty("yazdThreadWatch.MailSubject"),
                                emailBody);
                    }

                }
            }
            catch( SQLException sqle ) {
                System.err.println("EmailWatchException (394) Exception:"+sqle.getMessage());
                sqle.printStackTrace();
            }
            catch (Exception e) {
                System.err.println("EmailWatchManager (3847) Exception:"+e.getMessage());
            }
            finally {
                try {  pstmt.close(); }
                catch (Exception e) { e.printStackTrace(); }
                try {  con.close();   }
                catch (Exception e) { e.printStackTrace(); }
            }


        }

    }
}
