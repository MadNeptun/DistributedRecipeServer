require "soap/rpc/standaloneServer"
require "thread"
require_relative "DataRequest"
require "carrot"
begin
  
class WebService < SOAP::RPC::StandaloneServer
  
  @@idstore = 1;
  
  def initialize(*args)
     super
          add_method(self, 'AAA', 'a', 'b')
          add_method(self, 'GetRepiceList', 'categoryArray','ingridientArray')
       end

       def AAA(a,b)
         return a + b
       end
       
       def GetRepiceList(categoryArray, ingridientArray)
         
          request = DataRequest.new
          request.setCategoryArray(categoryArray)
          request.setIngridientArray(ingridientArray)
          request.setId(@@idstore)
          tempId = @@idstore
          @@idstore = @@idstore + 1
          if @@idstore > 100000
            @@idstore = 1
          end
          
          client = Carrot.new( :host   => 'localhost', :port   => 5672,  :user   => 'guest', :pass   => 'guest' )
          iterations = 0.0
          begin
            q = client.queue("repiceQuery", :durable => true)
            q.publish(request, :persistent => true)
            sleep 5.0
            p = client.queue("returnQuery" + request.getId, :durable => true)
            i = 0
            while i < 300
              temp = p.pop(:ack=>true)
              if not temp.nil?
                p.delete
                return temp.getOutput
              end
              i = i + 1
              sleep 1.0
            end
            return "timeout"
          rescue => err
            puts err
          end
         
       end
end

  server = WebService.new("RepiceWebService", 
              'webserver:dataservice', 'localhost', 8027)
    trap('INT'){
       server.shutdown
    }
    server.start
end