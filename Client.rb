require 'soap/rpc/driver'

NAMESPACE = 'webserver:dataservice'
URL = 'http://54.186.231.191:8080/'

begin
  driver = SOAP::RPC::Driver.new(URL, NAMESPACE)
  driver.add_method('AAA','a','b')
  driver.add_method('GetRepiceList', 'categoryArray', 'ingridientArray')
  puts driver.AAA('gg','kk')
  puts driver.GetRepiceList('1!2!3!4!5!6','12!13')
end