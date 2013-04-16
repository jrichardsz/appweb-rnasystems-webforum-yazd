package com.Yasna.forum.Tasks;

import com.Yasna.forum.ForumFactory;
import com.Yasna.forum.ForumMessage;
import com.Yasna.forum.SessionVO;
import com.Yasna.forum.database.DbConnectionManager;

import java.util.LinkedList;
import java.util.Calendar;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.sql.ResultSet;

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

public class SessionManager {
    private LinkedList newSessions;
    // This linked list will retain all the new messages and will notify the people that needs to be notified.
    private Thread worker;
    private static int counter=0;
    public SessionManager(){
        // this is called from the factory and it will retain a handle on it.
        if(counter==0){
            System.out.println("Starting Session Manager (you should only see this message once)");
            counter++;
            newSessions = new LinkedList();
            // We are going to start a new worker thread to handle all the emails.
            worker = new Thread(new SessionWatchWorker(this));
            worker.setDaemon(true);
            worker.start();
        }
    }
    public synchronized void addMessage(String sID,String IP,int uID){
        newSessions.addLast(new SessionVO(sID,IP,uID));
        // There is now a message to be processed and the Thread needs to be notified
        notify();
    }
    public synchronized SessionVO getNextMessage(){
        if(newSessions.isEmpty()){
            try{
                //System.out.println("waiting for a new sessions");
                wait();
                //System.out.println("finished waiting");
            }catch (InterruptedException ie) {}
        }
        return (SessionVO)newSessions.removeFirst();
    }

    public class SessionWatchWorker implements Runnable{
        private static final String GET_SESSION=
                "select sessionID from yazdSessions where sessionID=?";
        private static final String UPDATE_SESSION="update yazdSessions set userID=?,IP=?,lasttime=? where sessionID=?";
        private static final String INSERT_SESSION="insert into yazdSessions (sessionID,userID,IP,lasttime,initime) values (?,?,?,?,?)";
        private static final String DELETE_SESION="delete from yazdSessions where lasttime < ?";
        private static final String GET_CURRENT_COUNT="select count(*) as cnt from yazdSessions";
        private static final String GET_STATS="select maxusercount from yazdUserStats where day_dt=?";
        private static final String INSERT_STATS="insert into yazdUserStats(day_dt,usercount,maxusercount,maxuserdt) values(?,?,?,?)";
        private static final String UPDATE_COUNT="update yazdUserStats set usercount=usercount+1 where day_dt=?";
        private static final String UPDATE_COUNT_MAX="update yazdUserStats set maxusercount=?,maxuserdt=? where day_dt=?";

        private SessionManager manager;
        public SessionWatchWorker(SessionManager m){
            this.manager=m;
        }
        public void run(){
            while(true){
                updatesssions(manager.getNextMessage());
            }
        }
        private void updatesssions(SessionVO session){
            Calendar now = Calendar.getInstance();
            int now_in_minutes = (int)(now.getTimeInMillis()*1.0/(1000.0 * 60.0));
            int now_in_seconds = (int)(now.getTimeInMillis()*1.0/1000.0);
            int now_today = (int)(now_in_minutes * 1.0/(60.0 * 24.0));
            Connection con = null;
            PreparedStatement pstmt = null;
            boolean newsession = false;
            try {
                con = DbConnectionManager.getConnection();
                pstmt = con.prepareStatement(GET_SESSION);
                pstmt.setString(1,session.getSessionID());
                ResultSet rs = pstmt.executeQuery();
                if(rs.next()){
                    pstmt = con.prepareStatement(UPDATE_SESSION);
                    pstmt.setInt(1,session.getUserID());
                    pstmt.setString(2,session.getIP());
                    pstmt.setInt(3,now_in_minutes);
                    pstmt.setString(4,session.getSessionID());
                    pstmt.executeUpdate();
                }else{
                    newsession=true;
                    pstmt = con.prepareStatement(INSERT_SESSION);
                    pstmt.setString(1,session.getSessionID());
                    pstmt.setInt(2,session.getUserID());
                    pstmt.setString(3,session.getIP());
                    pstmt.setInt(4,now_in_minutes);
		    pstmt.setInt(5,now_in_seconds);
                    pstmt.executeUpdate();
                }
                // We now delete the old sessions
                pstmt = con.prepareStatement(DELETE_SESION);
                pstmt.setInt(1,now_in_minutes - 6);
                pstmt.executeUpdate();
                //get the count of current sessions
                pstmt = con.prepareStatement(GET_CURRENT_COUNT);
                rs = pstmt.executeQuery();
                int sessioncount=0;
                if(rs.next()){
                    sessioncount=rs.getInt("cnt");
                }
                //get max session count
                int maxcount=0;
                pstmt = con.prepareStatement(GET_STATS);
                pstmt.setInt(1,now_today);
                rs = pstmt.executeQuery();
                if(rs.next()){
                    maxcount = rs.getInt("maxusercount");
                    if(maxcount < sessioncount){
                        //update the session max count and user count
                        pstmt = con.prepareStatement(UPDATE_COUNT_MAX);
                        pstmt.setInt(1,sessioncount);
                        pstmt.setString(2,Long.toString(now.getTimeInMillis()));
                        pstmt.setInt(3,now_today);
                        pstmt.executeUpdate();
                    }
                    if(newsession){
                        //just update the user count
                        pstmt = con.prepareStatement(UPDATE_COUNT);
                        pstmt.setInt(1,now_today);
                        pstmt.executeUpdate();
                    }
                }else{
                    //insert max user count
                    pstmt = con.prepareStatement(INSERT_STATS);
                    pstmt.setInt(1,now_today);
                    pstmt.setInt(2,sessioncount);
                    pstmt.setInt(3,sessioncount);
                    pstmt.setString(4,Long.toString(now.getTimeInMillis()));
                    pstmt.executeUpdate();
                }
                
            }
            catch( SQLException sqle ) {
                System.err.println("SessionManager (394) Exception:"+sqle.getMessage());
                sqle.printStackTrace();
            }
            catch (Exception e) {
                System.err.println("SessionManager (3847) Exception:"+e.getMessage());
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
