/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

/**
 *
 * @author puzzi
 */

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Types;
import java.util.Vector;
import java.util.logging.Level;
import java.util.logging.Logger;
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

    public DefaultTableModel relatorio_simu(String sqlquery) throws SQLException {
                
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
    
    
    public void gera_simulacao_produto(String prod_id,String prod_valor) throws SQLException {
        
        CallableStatement cstm = null;
        try { 
          
          cstm = getConnection().prepareCall("{ call produto_altera_preco(?,?) }");
          cstm.setString(1,prod_id);
          cstm.setString(2,prod_valor);
          cstm.execute();            
          cstm.close();
        
        }
        catch (SQLException ex) {
            Logger.getLogger(reportBD.class.getName()).log(Level.SEVERE, null, ex);
        }
    }
    
    public void gera_simulacao_produto_subcat(String subcat,String prod_valor) throws SQLException {
        
        CallableStatement cstm = null;
        try { 
          
          cstm = getConnection().prepareCall("{ call PROC_SUBCAT_MUDA_PRECO(?,?) }");
          cstm.setString(1,subcat);
          cstm.setString(2,prod_valor);
          cstm.execute();            
          cstm.close();
        
        }
        catch (SQLException ex) {
            Logger.getLogger(reportBD.class.getName()).log(Level.SEVERE, null, ex);
        }
    }
    
        public void gera_simulacao_produto_cat(String cat,String prod_valor) throws SQLException {
        
        CallableStatement cstm = null;
        try { 
          
          cstm = getConnection().prepareCall("{ call PROC_CAT_MUD_PRECO(?,?) }");
          cstm.setString(1,cat);
          cstm.setString(2,prod_valor);
          cstm.execute();            
          cstm.close();
        
        }
        catch (SQLException ex) {
            Logger.getLogger(reportBD.class.getName()).log(Level.SEVERE, null, ex);
        }
    }
    

    public void gera_simulacao_frete_acima(String sqlquery)  {
        
        
        
    }
        
        
    public void gerar_base() throws SQLException {
        
        CallableStatement cStmt = null;
        
        try {
            cStmt = getConnection().prepareCall("{call GERA_TABELA_SIMU()}");           
            cStmt.execute();            
            cStmt.close();
        } 
        catch (SQLException ex) {
            Logger.getLogger(reportBD.class.getName()).log(Level.SEVERE, null, ex);
        }     

    }

    public String autenticar(String user_email,String user_senha) throws SQLException {
        
         CallableStatement login = getConnection().prepareCall("{ ? = call VERIFICA_LOGIN(?,?) }");
         login.registerOutParameter(1, Types.VARCHAR);
         login.setString(2,user_email);
         login.setString(3,user_senha);
         login.execute();
         System.out.println("Autenticando..");
         String resp = login.getString(1);                           
         login.close();        
         return resp;
    }

    public void criarTriggers() throws SQLException { 
        
        String sqlquery;

        Statement stmt = getConnection().createStatement();       
        sqlquery = 
            "create or replace TRIGGER \"ALTERA_METODO_ENTREGA_CUSTO\" AFTER UPDATE OF CUSTO_LIBRA ON SIMU_METODO_ENTREGA \n" +
            "REFERENCING OLD AS OLD NEW AS NEW \n" +
            "FOR EACH ROW\n" +
            "DECLARE\n" +
            "v_frete NUMBER(38,2);\n" +
            "v_novo_frete NUMBER(38,2);\n" +
            "CURSOR vcursor IS SELECT vi.VENDA_ID, vi.FRETE FROM SIMU_VENDA vi WHERE vi.METODO_ENTREGA_ID = :OLD.METODO_ENTREGA_ID;\n" +
            "BEGIN\n" +
            "FOR venda IN vcursor LOOP\n" +
            "v_novo_frete := (:NEW.CUSTO_LIBRA*venda.FRETE)/(:OLD.CUSTO_LIBRA);\n" +
            "UPDATE SIMU_VENDA SET FRETE=v_novo_frete WHERE VENDA_ID = venda.VENDA_ID;\n" +
            "END LOOP;\n" +
            "END;";
       
        stmt.execute(sqlquery);
        stmt.close();
        
        stmt = getConnection().createStatement();
        sqlquery =  "create or replace TRIGGER ALTERA_PRODUTO_PRECO \n" +
                    "AFTER UPDATE OF PRECO \n" +
                    "ON SIMU_PRODUTO \n" +
                    "REFERENCING OLD AS OLD NEW AS NEW\n" +
                    "FOR EACH ROW\n" +
                    "DECLARE\n" +
                    "v_new_total_unitario NUMBER(38,2);\n" +
                    "CURSOR vcursor IS SELECT vi.VENDA_ITEM_ID, vi.QUANTIDADE, vi.DESCONTO_UNITARIO FROM SIMU_VENDA_ITEM vi WHERE vi.PRODUTO_ID = :OLD.PRODUTO_ID;\n" +
                    "BEGIN\n" +
                    "FOR v_item IN vcursor LOOP\n" +
                    "v_new_total_unitario := (:NEW.PRECO - v_item.DESCONTO_UNITARIO) * v_item.QUANTIDADE;\n" +
                    "UPDATE SIMU_VENDA_ITEM SET TOTAL_UNITARIO=v_new_total_unitario, PRECO_UNITARIO=:NEW.PRECO WHERE VENDA_ITEM_ID = v_item.VENDA_ITEM_ID;\n" +
                    "END LOOP;\n" +
                    "END;";
        
        stmt.execute(sqlquery);
        stmt.close();
        
        stmt = getConnection().createStatement();
        sqlquery =  "create or replace TRIGGER altera_venda_item\n" +
                    "AFTER DELETE OR INSERT OR UPDATE OF DESCONTO_UNITARIO,QUANTIDADE,PRECO_UNITARIO,PRODUTO_ID \n" +
                    "ON SIMU_VENDA_ITEM \n" +
                    "REFERENCING OLD AS OLD NEW AS NEW\n" +
                    "FOR EACH ROW\n" +
                    "DECLARE\n" +
                    "u_preco_unitario NUMBER;\n" +
                    "u_desconto_unitario NUMBER;\n" +
                    "u_total_unitario NUMBER;\n" +
                    "u_quantidade NUMBER;\n" +
                    "u_conta_antiga NUMBER;\n" +
                    "u_conta_nova NUMBER;\n" +
                    "u_subtotal NUMBER;\n" +
                    "u_frete NUMBER;\n" +
                    "u_impostos NUMBER;\n" +
                    "CURSOR vcursor IS SELECT subtotal,FRETE,IMPOSTOS FROM SIMU_VENDA WHERE VENDA_ID=:OLD.VENDA_ID;\n" +
                    "BEGIN\n" +
                    "u_conta_antiga := :OLD.QUANTIDADE*(:OLD.PRECO_UNITARIO - :OLD.DESCONTO_UNITARIO);\n" +
                    "u_conta_nova := :NEW.QUANTIDADE*(:NEW.PRECO_UNITARIO - :NEW.DESCONTO_UNITARIO);\n" +
                    "OPEN vcursor;\n" +
                    "FETCH vcursor INTO u_subtotal,u_frete,u_impostos; \n" +
                    "CLOSE vcursor;  \n" +
                    "UPDATE SIMU_VENDA set subtotal=u_subtotal + (u_conta_nova - u_conta_antiga) WHERE VENDA_ID=:OLD.VENDA_ID;\n" +
                    "UPDATE SIMU_VENDA set total_devido=subtotal+FRETE+IMPOSTOS;\n" +
                    "END;";
        
        stmt.execute(sqlquery);
        stmt.close();
    
    }
}
