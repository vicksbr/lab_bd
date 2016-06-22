/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

/**
 *
 * @author puzzi
 */

import java.math.BigDecimal;
import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.sql.Types;
import java.util.Iterator;
import java.util.Vector;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.swing.table.DefaultTableModel;
import org.jfree.data.xy.XYBarDataset;
import org.jfree.data.xy.XYDataset;
import org.jfree.data.xy.XYSeries;
import org.jfree.data.xy.XYSeriesCollection;

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
    
    
    public String dashboard_valor_diario(String sqlquery) throws SQLException {
        
        Statement stmt = getConnection().createStatement();
        ResultSet rs = stmt.executeQuery(sqlquery);
        ResultSetMetaData rsmd = rs.getMetaData();
        String resposta = null;
        while(rs.next()) {
             resposta = rs.getString("SOMA_DIARIA");
        }
        stmt.close();
        return resposta;                              
    }
    
    public String dashboard_valor_mensal(String sqlquery) throws SQLException {
        
        Statement stmt = getConnection().createStatement();
        ResultSet rs = stmt.executeQuery(sqlquery);
        ResultSetMetaData rsmd = rs.getMetaData();
        String resposta = null;
        while(rs.next()) {
             resposta = rs.getString("SOMA_MENSAL");
        }
        stmt.close();
        return resposta;                              
    }

    public String dashboard_valor_anual(String sqlquery) throws SQLException {
        
        Statement stmt = getConnection().createStatement();
        ResultSet rs = stmt.executeQuery(sqlquery);
        ResultSetMetaData rsmd = rs.getMetaData();
        String resposta = null;
        while(rs.next()) {
             resposta = rs.getString("SOMA_ANUAL");
        }
        stmt.close();
        return resposta;                              
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
    
    public void gera_simulacao_estoque_produto(String prod_id,String prod_estoque) throws SQLException {
        
        CallableStatement cstm = null;
        try { 
          
          cstm = getConnection().prepareCall("{ call PRODUTO_ALTERA_QUANTIDADE(?,?) }");
          cstm.setString(1,prod_id);
          cstm.setString(2,prod_estoque);
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
    
    public void gera_simulacao_produto_altera_subcat(String subcat,String nova_subcat) throws SQLException {
        
        CallableStatement cstm = null;
        try { 
          
          cstm = getConnection().prepareCall("{ call PRODUTO_ALTERA_SUBCAT(?,?) }");
          cstm.setString(1,subcat);
          cstm.setString(2,nova_subcat);
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
    

    public void gera_simulacao_frete_acima(String valor_frete, String desconto)  {
        CallableStatement cStmt = null;
        try{
            cStmt = getConnection().prepareCall("{call VENDA_DESC_FRETE_ACIMA_VALOR(?, ?)}");
            cStmt.setString(1, valor_frete);
            cStmt.setString(2, desconto);
            cStmt.execute();
            cStmt.close();
        } catch(SQLException ex){
            Logger.getLogger(reportBD.class.getName()).log(Level.SEVERE, null, ex);
        }
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

    public void gera_simulacao_alterar_subcategoria (String subcat_id, String categoria_novo_nome) throws SQLException{
        try{
            CallableStatement cStmt = null;
            cStmt = getConnection().prepareCall("{call SUBCATEGORIA_ALTERA_CATEGORIA(?, ?)}");
            cStmt.setString(1, subcat_id);
            cStmt.setString(2, categoria_novo_nome);
            cStmt.execute();
            cStmt.close();
        } catch(SQLException ex){
            Logger.getLogger(reportBD.class.getName()).log(Level.SEVERE, null, ex);
        }
    }
    
    public void gera_simulacao_alterar_valor_carga_minima (String metodo_entrega_id, String nova_carga_minima) throws SQLException{
        /*
        try{
            CallableStatement cStmt = null;
            cStmt = getConnection().prepareCall("{call SUBCATEGORIA_ALTERA_CATEGORIA(?, ?)}");
            cStmt.setString(1, subcat_id);
            cStmt.setString(2, categoria_novo_nome);
            cStmt.execute();
            cStmt.close();
        } catch(SQLException ex){
            Logger.getLogger(reportBD.class.getName()).log(Level.SEVERE, null, ex);
        }
        */
    }
    
    public XYDataset gerar_grafico(String sqlquery) throws SQLException {
        int i;
        
        DefaultTableModel dftm = relatorio_simu(sqlquery);
        XYSeries series = new XYSeries("total");
        System.out.println("count of rows: " + dftm.getRowCount());
        Vector raw_data = dftm.getDataVector();

        for(i=0; i<raw_data.size()-1; i++){
            //series.add(1.0, 1.0);
            //((Vector)getDataVector().elementAt(1)).elementAt(5);
            /*
            series.add(
                    ((Timestamp)dftm.getValueAt(i, 0)).toLocalDateTime().getDayOfMonth(),
                    (BigDecimal)dftm.getValueAt(i, 1)
            );
            */
            series.add(
                    new Double(((Timestamp)dftm.getValueAt(i, 0)).getTime()),
                    (BigDecimal)dftm.getValueAt(i, 1)
            );
            
        }

/*        
        XYSeries series = new XYSeries("First");
        series.add(1.0, 1.0);
        series.add(2.0, 4.0);
        series.add(3.0, 3.0);
        series.add(4.0, 5.0);
        series.add(5.0, 5.0);
        series.add(6.0, 7.0);
        series.add(7.0, 7.0);
        series.add(8.0, 8.0);
        series.add(9.0, 1.0);
        series.add(10.0, 4.0);
        series.add(11.0, 3.0);
        series.add(12.0, 5.0);
        series.add(13.0, 5.0);
        series.add(14.0, 7.0);
        series.add(15.0, 7.0);
        series.add(16.0, 8.0);
        series.add(20.0, 15.0);
*/
                
        XYSeriesCollection dataset = new XYSeriesCollection();
        dataset.addSeries(series);
        
        return dataset;
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

    public void gera_simulacao_maior_uma_unidade(String desconto) {
        CallableStatement cstm = null;
        try { 
          
          cstm = getConnection().prepareCall("{ call VENDA_DESCONTO_MAIS_DE_UMA_UN(?) }");
          cstm.setString(1,desconto);
          cstm.execute();                    
          cstm.close();
        
        }
        catch (SQLException ex) {
            Logger.getLogger(reportBD.class.getName()).log(Level.SEVERE, null, ex);
        }
    }

    public void gera_simulacao_desconto_entre_datas(String inicio, String fim, String desconto) {
        CallableStatement cstm = null;
        try { 
          
          cstm = getConnection().prepareCall("{ call VENDA_DESCONTO_ENTRE_DATAS(?, ?, ?) }");
          cstm.setString(1,inicio);
          cstm.setString(2,fim);
          cstm.setString(3,desconto);
          cstm.execute();                    
          cstm.close();
        
        }
        catch (SQLException ex) {
            Logger.getLogger(reportBD.class.getName()).log(Level.SEVERE, null, ex);
        }
    }

    void gera_simulacao_desconto_pais(String pais, String desconto) {
        CallableStatement cstm = null;
        try { 
          
          cstm = getConnection().prepareCall("{ call VENDA_DESCONTO_PAIS(?, ?) }");
          cstm.setString(1,pais);
          cstm.setString(2,desconto);
          cstm.execute();                    
          cstm.close();
        
        }
        catch (SQLException ex) {
            Logger.getLogger(reportBD.class.getName()).log(Level.SEVERE, null, ex);
        }
    }

    void gera_simulacao_desconto_estado(String estado, String desconto) {
        CallableStatement cstm = null;
        try { 
          
          cstm = getConnection().prepareCall("{ call VENDA_DESCONTO_ESTADO(?, ?) }");
          cstm.setString(1,estado);
          cstm.setString(2,desconto);
          cstm.execute();
          cstm.close();
        
        }
        catch (SQLException ex) {
            Logger.getLogger(reportBD.class.getName()).log(Level.SEVERE, null, ex);
        }
    }
}
