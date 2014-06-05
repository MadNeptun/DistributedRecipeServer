/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

package WebService;

import java.io.PrintStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.LinkedList;
import javax.jws.WebMethod;
import javax.jws.WebParam;
import javax.jws.WebService;
/**
 *
 * @author Piotr Rachwał
 */
@WebService(serviceName = "RecipeService")
public class RecipeService {

    /**
     * This is a sample web service operation
     */
    @WebMethod(operationName = "GetRepiceList")
    public String GetRepiceList(@WebParam(name = "categories") String categories, @WebParam(name = "ingridients") String ingridients, @WebParam(name = "user") String user, @WebParam(name = "pass") String pass) throws ClassNotFoundException, SQLException
    {
        // *********************************************************************
        String xmlTemplate = "<?xml version=\"1.0\" encoding=\"UTF-8\" ?><repices>{content}</repices>";
        String repiceTemplate = "<repice><title>{title}</title><id>{id}</id><category>{category}</category><categoryId>{categoryId}</categoryId><description>{description}</description><picture>{picture}</picture><ingridients>{ingridients}</ingridients></repice>";
        String pictureTemplate = "<fileName>{fileName}</fileName><extension>{extension}</extension><binaryData>{binaryData}</binaryData>";
        String ingridientTemplate = "<ingridient><name>{name}</name><id>{id}</id><category>{category}</category><unit>{unit}</unit><amount>{amount}</amount></ingridient>";
        // *********************************************************************
        Class.forName("org.postgresql.Driver");
        Connection connection = null;
        connection = DriverManager.getConnection("jdbc:postgresql://127.0.0.1:5432/database",user, pass);
        String [] cat = categories.split("!");
        String [] ing = null;
        boolean x = false;
        String outcome = xmlTemplate;
        if(ingridients != null && ingridients.compareTo("") != 0)
        {
            ing = ingridients.split("!");
            x = true;
        }
        Statement st1 = connection.createStatement();
        String query = "";   
        String repicesXml = "";
        LinkedList<String> repicesToCheck = new LinkedList<String>();
        //**********************************************************************
        query = "select id from Przepis where id_kategorii in (-1";
        for(String s : cat)
        {
           query += ","+s; 
        }
        query += ");";
        ResultSet rs1 = st1.executeQuery(query);
        if(x)
        {
            while(rs1.next())
            {
               boolean result = true;
               String id = rs1.getString(1);
               
               Statement stT = connection.createStatement();
               ResultSet rsT = stT.executeQuery("select id_skladnik from Przepis_Skladnik where id_przepisu = "+id+";");
               int amount = 0;
               int count = 0;
               while(rsT.next())
               {
                   boolean contains = false;
                   for(int i=0; i<ing.length; i++)
                   {
                       if(ing[i].compareTo(rsT.getString(1))==0)
                       {
                           contains = true;
                       }
                       else
                       {
                           count++;
                       }
                   }
                   amount++;
               }
               if(amount == count) result = false;
               
               if(result) repicesToCheck.add(id);           
            }          
        }
        else
        {
           while(rs1.next())
           { 
               repicesToCheck.add(rs1.getString(1));
           }
        }

        for(String s : repicesToCheck)
        {
            String repTem = repiceTemplate;
            Statement st2 = connection.createStatement();
            ResultSet rs2 = st2.executeQuery("select P.nazwa as NN, P.opis as OO, K.rodzaj as RR, P.id_kategorii as SS, P.id as KK from Przepis as P join Kategorie as K on P.id_kategorii = K.id where P.id = "+s+";");
            while(rs2.next())
            {
                repTem = repTem.replace("{title}", rs2.getString(1));
                repTem = repTem.replace("{description}", rs2.getString(2));
                repTem = repTem.replace("{category}", rs2.getString(3));
                repTem = repTem.replace("{id}", rs2.getString(5));
                repTem = repTem.replace("{categoryId}", rs2.getString(4));
                repTem = repTem.replace("{picture}", "http://54.186.231.191/food.jpg");
            }
            Statement st3 = connection.createStatement();
            ResultSet rs3 = st3.executeQuery("select P.ile as II, P.miara as MM, S.nazwa as NN, P.id_skladnik as WW from Przepis_Skladnik as P left join Skladnik as S on (P.id_skladnik = S.id) where P.id_przepisu = "+s+";");
            String ingridientsStr = "";
            while(rs3.next())
            {
                String ingTem = ingridientTemplate;
                ingTem = ingTem.replace("{amount}",rs3.getString(1));
                ingTem = ingTem.replace("{unit}",rs3.getString(2));
                String tmp = rs3.getString(3) == null ? "" : rs3.getString(3);
                ingTem = ingTem.replace("{name}",tmp);
                ingTem = ingTem.replace("{id}",rs3.getString(4));
                ingTem = ingTem.replace("{category}","");
                ingridientsStr += ingTem;
            }
            repTem = repTem.replace("{ingridients}",ingridientsStr);
            repicesXml += repTem;
        }
      
        outcome = outcome.replace("{content}", repicesXml);
        return outcome;
      
    }

    /**
     * Web service operation
     */
    @WebMethod(operationName = "CanalTest")
    public String CanalTest() {
        return "Connection test OK";
    }
}
