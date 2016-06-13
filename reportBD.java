/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

/**
 *
 * @author puzzi
 */

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.Vector;
import javax.swing.table.DefaultTableModel;

public class reportBD {
    
    private Connection connection;
    
    public reportBD() { 
        
        this.connection = ConnectionDB.getConnection();
    }
    
    public Connection getConnection() {
        return connection;
    }

    public DefaultTableModel relatorio(String sqlquery) throws SQLException {
                
        //PreparedStatement prepstmt = getConnection().prepareStatement();
        Statement stmt = getConnection().createStatement();
        ResultSet rs = stmt.executeQuery(sqlquery);
        ResultSetMetaData rsmd = rs.getMetaData();
        
        Vector<String> columnNames = new Vector<String>();
        int columnCount = rsmd.getColumnCount();        
        
        for (int column = 1; column <= columnCount; column++) {
            columnNames.add(rsmd.getColumnName(column));
        }  

        Vector<Vector<Object>> data = new Vector<Vector<Object>>();
        while (rs.next()) {
            Vector<Object> vector = new Vector<Object>();
            for (int columnIndex = 1; columnIndex <= columnCount; columnIndex++) {
                vector.add(rs.getObject(columnIndex));
            }
            data.add(vector);
        }

        stmt.close();
        return new DefaultTableModel(data, columnNames);

    }
}
