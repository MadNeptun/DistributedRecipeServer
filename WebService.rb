require "soap/rpc/standaloneServer"
require "thread"
require "carrot"
require "pg"
begin
  
class WebService < SOAP::RPC::StandaloneServer

  def initialize(*args)
     super
          add_method(self, 'AAA', 'a', 'b')
          add_method(self, 'GetRepiceList', 'categoryArray','ingridientArray')
  end

	def processRequest(a,b)
    begin
    xmlTemplate = "<?xml version=\"1.0\" encoding=\"UTF-8\" ?><repices>{content}</repices>"
    repiceTemplate = "<repice><title>{title}</title><id>{id}</id><category>{category}</category><categoryId>{categoryId}</categoryId><description>{description}</description><picture>{picture}</picture><ingridients>{ingridients}</ingridients></repice>"
    pictureTemplate = "<fileName>{fileName}</fileName><extension>{extension}</extension><binaryData>{binaryData}</binaryData>"
    ingridientTemplate = "<ingridient><name>{name}</name><id>{id}</id><category>{category}</category><unit>{unit}</unit><amount>{amount}</amount></ingridient>"
    repicesArray = Array.new
    conn = PGconn.open(:dbname => 'database')
    categorires = a.split("!")
    ingridiens = b.split("!")

    sqlQueryCategories = "select id from Przepis where id_kategorii in (-1"
    len = categorires.length
    i = 0
    tempC = ""
    while i < len do
      tempC = tempC + "," + categorires[i]
      i = i + 1
    end
    
    sqlQueryCategories = sqlQueryCategories + tempC + ");"
    repices = conn.exec(sqlQueryCategories)
    if not ingridiens.length == 0
      repices.each do |row|
        query = "select id_skladnik from Przepis_Skladnik where id_przepisu = "+row["id"]+";"
          ingr = conn.exec(query)
          outcome = true
          if ingr.ntuples == 0
            outcome = false
          end
          count = 0
          ingr.each do |row2|
              if not ingridiens.include? row2["id_skladnik"].to_s
                count = count + 1
              end
          end
          if count == ingr.ntuples 
            outcome = false
          end
        if outcome == true
          repicesArray.push(row["id"].to_s)
        end
      end
    else
      repices.each do |row|
        repicesArray.push(row["id"].to_s)
      end
    end
    output = String.new(xmlTemplate)
    repicesXml = ""
    
    repicesArray.each do |id|
      
    tempTemplate = String.new(repiceTemplate)
    
    query = "select P.nazwa as NN, P.opis as OO, K.rodzaj as RR, P.id_kategorii as SS, P.id as KK from Przepis as P join Kategorie as K on P.id_kategorii = K.id where P.id = "+id+";"
    r = conn.exec(query)

    query = "select P.ile as II, P.miara as MM, S.nazwa as NN, P.id_skladnik as WW from Przepis_Skladnik as P left join Skladnik as S on (P.id_skladnik = S.id) where P.id_przepisu = "+id+";"
    s = conn.exec(query)

    tempTemplate["{title}"] = r[0]["nn"]
    tempTemplate["{description}"] = r[0]["oo"] 
    tempTemplate["{category}"] = r[0]["rr"] 
    tempTemplate["{id}"] = r[0]["kk"]
    tempTemplate["{categoryId}"] = r[0]["ss"]
    tempTemplate["{picture}"] = ""
      
    ingOut = ""
    s.each do |row|
      tmp = String.new(ingridientTemplate);
      tmp["{amount}"] = row["ii"]
      tmp["{unit}"] = row["mm"]
        if row["nn"].nil? 
          tmp["{name}"] = ""
        else
          tmp["{name}"] = row["nn"]
        end  
      if row["ww"].nil? 
         tmp["{id}"] = ""
      else
         tmp["{id}"] = row["ww"]
      end
      tmp["{category}"] = ""
      ingOut = ingOut + tmp;
    end
    tempTemplate["{ingridients}"] = ingOut
    repicesXml = repicesXml + tempTemplate
    end
    output["{content}"] = repicesXml
    return output
rescue => err
  return err.backtrace
end
  end

       def AAA(a,b)
         return a + b
       end
       
       def GetRepiceList(categoryArray, ingridientArray)    
         return processRequest(categoryArray,ingridientArray)
      end
end

  server = WebService.new("RepiceWebService", 
              'webserver:dataservice', '0.0.0.0', 8080)
    trap('INT'){
       server.shutdown
    }
    server.start
end