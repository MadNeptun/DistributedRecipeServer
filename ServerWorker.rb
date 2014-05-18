require_relative "DataRequest"
require "carrot"
require "thread"
require "pg"
begin
class ServerWorker
  @request
  def setRequest(request)
    @request = request
  end
  def getRequest
    return @request
  end
  def processRequest
    
    xmlTemplate = "<?xml version=\"1.0\" encoding=\"UTF-8\" ?><repices>{content}</repices>"
    repiceTemplate = "<repice><title>{title}</title><category>{category}</category><description>{description}</description><picture>{picture}</picture><ingridients>{ingridients}</ingridients></repice>"
    pictureTemplate = "<fileName>{fileName}</fileName><extension>{extension}</extension><binaryData>{binaryData}</binaryData>"
    ingridientTemplate = "<ingridient><name>{name}</name><category>{category}</category><unit>{unit}</unit><amount>{amount}</amount></ingridient>"
    repicesArray = Array.new
    conn = PGconn.open(:dbname => 'database',:user=>'abis',:password => 'siba')
    categorires = @request.getCategoryArray.split("!")
    ingridiens = @request.getIngridientArray("!")

    sqlQueryCategories = "select id from Przepis where id_kategorii in (-1,"
    len = categorires.length
    i = 0
    tempC = ""
    while i < len do
      tempC = tempC + "," + categories[i]
      i = i + 1
    end
    
    sqlQueryCategories = sqlQueryCategories + tempC + ")"
    repices = conn.exec(sqlQueryCategories)
    if not ingridiens.length == 0
      repices.each do |row|
        query = "select id_skladnik from Przepis_Skladnik where id_przepis = "+row[0]
        ingr = conn.exec(query)
        outcome = true
          ingr.each do |row2|
              if not ingridiens.include? row2[0].to_s
                outcome = false
              end
          end
        if outcome == true
          repicesArray.push(row[0].to_s)
        end
      end
    else
      repices.each do |row|
        repicesArray.push(row[0].to_s)
      end
    end
    output = String.new(xmlTemplate)
    repicesXml = ""
    
    repicesArray.each do |id|
      
    tempTemplate = String.new(repiceTemplate)
    
    query = "select P.nazwa as NN, P.opis as OO, K.rodzaj as RR from Przepis as P join Kategorie as K on P.id_kategorii = K.id where P.id = "+id
    r = conn.exec(query)
    query = "select P.ile as II, P.miara as MM, S.nazwa as NN from Przepis_Skladnik as P join Skladnik as S on P.id_skladnik = S.id where id_przepis = "+id
    s = conn.exec(query)
    
    tempTemplate["{title}"] = r[0]["NN"]
    tempTemplate["{description}"] = r[0]["OO"] 
    tempTemplate["{category}"] = r[0]["RR"] 
    tempTemplate["{picture}"] = ""
      
    ingOut = ""
    s.each do |row|
      tmp = String.new(ingridientTemplate);
      tmp["{amount}"] = row["II"]
      tmp["{unit}"] = row["MM"]
      tmp["{name}"] = row["NN"]
      tempTemplate["{category}"] = ""
      ingOut = ingOut + tmp;
    end
    tempTemplate["{ingridients}"] = ingOut
    repicesXml = repicesXml + tempTemplate
    end
    output["{content}"] = repicesXml
    @request.setOutput(output)
  end
end

  worker = ServerWorker.new
  client = Carrot.new( :host   => 'localhost', :port   => 5672, :user   => 'guest', :pass   => 'guest' )
  q = client.queue("repiceQuery")

  while true
      temp = q.pop(:ack=>true)
    
      if not temp.nil?
        p = client.queue("returnQuery"+temp.getId, :durable =>true)
        begin
        worker.setRequest(temp)
        worker.processRequest()      
        p.publish(worker.getRequest().getOutput)
        rescue => err
          p.publish("Error occured. "+err.to_s)
        end
        
      end
        
      sleep 1.0
  end
end