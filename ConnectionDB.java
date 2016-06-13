/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

/**
 *
 * @author puzzi
 */

import java.sql.*;    

public class ConnectionDB {
    
    private final static String DB_URL = "jdbc:oracle:thin:@grad.icmc.usp.br:15215:orcl";
    private final static String USER = "p6513497";
    private final static String PASS = "p6513497";
    private static String resp;

    public static Connection getConnection() {
   
        try {    
            System.out.println("Conectando na base de dados");    
            Class.forName("oracle.jdbc.driver.OracleDriver");                
            return DriverManager.getConnection(DB_URL,USER,PASS);    
            
        } catch (Exception e) {    
            e.printStackTrace();    
        }   
        return null;
    }   

}