package com.Yasna.forum.database;

import com.Yasna.forum.ThreadType;
import com.Yasna.forum.ForumNotFoundException;
import com.Yasna.util.Cacheable;
import com.Yasna.util.CacheSizes;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.sql.ResultSet;

/**
 * Created by IntelliJ IDEA.
 * User: aaflatooni
 * Date: Oct 26, 2006
 * Time: 5:56:04 PM
 * To change this template use File | Settings | File Templates.
 */
public class DbThreadType implements ThreadType, Cacheable {
    private static final String SELECT="select name from yazdThreadType where typeID=?";
    private int ID;
    private String name;
    public DbThreadType(int ID){
        this.ID=ID;
        Connection con = null;
        PreparedStatement pstmt = null;
        try {
            con = DbConnectionManager.getConnection();
            pstmt = con.prepareStatement(SELECT);
            pstmt.setInt(1,ID);
            ResultSet rs = pstmt.executeQuery();
            if(rs.next()){
                this.name=rs.getString("name");
            }
        } catch( SQLException sqle ) {
            sqle.printStackTrace();
        }
        finally {
            try {  pstmt.close(); }
            catch (Exception e) { e.printStackTrace(); }
            try {  con.close();   }
            catch (Exception e) { e.printStackTrace(); }
        }

    }
    public int getID(){
        return ID;
    }
    public String getName(){
        return name;
    }
    public int getSize() {
        //Approximate the size of the object in bytes by calculating the size
        //of each field.
        int size = 0;
        size += CacheSizes.sizeOfInt();                 //id
        size += CacheSizes.sizeOfString(name);          //name
        return size;
    }


}
