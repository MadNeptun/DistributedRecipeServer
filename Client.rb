require 'soap/rpc/driver'

NAMESPACE = 'webserver:dataservice'
URL = 'http://localhost:8027/'

begin
  driver = SOAP::RPC::Driver.new(URL, NAMESPACE)
  driver.add_method('AAA','a','b')
  driver.add_method('GetRepiceList', 'categoryArray', 'ingridientArray')
  puts driver.AAA('gg','kk')
  
  #here puts your test code
end