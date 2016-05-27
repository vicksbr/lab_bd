import java.sql.*;    

public class Test {
  private final static String DB_URL = "jdbc:oracle:thin:@grad.icmc.usp.br:15215:orcl";
  private final static String USER = "p6513497";
  private final static String PASS = "p6513497";
  private static String resp;

  public static void main(String[] args) {
    Connection conn = null;  
    try {    
      Class.forName("oracle.jdbc.driver.OracleDriver");    
      System.out.println("Connecting to database…");    
      conn = DriverManager.getConnection(DB_URL,USER,PASS);    
    } catch (Exception e) {    
      e.printStackTrace();    
    } finally {    
      if (conn != null) {    
        try {    
          System.out.println("XUPA ESSA MANGA");
          Statement stmt = conn.createStatement();
          ResultSet rs = stmt.executeQuery("SELECT SUBCATEGORIA_ID FROM SUBCATEGORIA");
          while (rs.next()) {
 			 String lastName = rs.getString("SUBCATEGORIA_ID");
  			 System.out.println(lastName + "\n");
		  }

          CallableStatement login = conn.prepareCall("{ ? = call VERIFICA_LOGIN(?,?) }");
          login.registerOutParameter(1, Types.VARCHAR);
          login.setString(2,"pedropuzzi@gmail.co");
          login.setString(3,"B62F9166349F7B412925ADB95173914A");
          login.execute();
          resp = login.getString(1);
          System.out.println("Tentando login");
          System.out.println(resp);
          login.close();
          
          conn.close();    
        } catch (SQLException e) {    
          // ignore    
        }    
      }   
    }            
  }    
}
