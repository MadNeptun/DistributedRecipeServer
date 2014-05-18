
begin 
state = 0
workersId = Array.new
loop = true
while loop
  puts ">> "
  command = gets.chomp
  temp = command.split("-")
  command = temp[0]
  args = Array.new
  if temp.length == 2
    args = temp[1].split(",")
  end
  if command == "start" #use only on queue server
    system("sudo rabbitmq-server -detached")
    state = 1
  elsif command == "status"
    puts "+++++++++++++++++++++++++++++++++++++++++++++++++"
    puts "System status: "+state.to_s
    puts "+++++++++++++++++++++++++++++++++++++++++++++++++"
    puts "Currently running workers: "+workersId.length.to_s
    workersId.each do |pid|
      puts " - "+pid+" - "
    end
    puts "+++++++++++++++++++++++++++++++++++++++++++++++++"
  elsif command == "add"
    i = args[0].to_i
    puts i
    j = 0
    while j < i
      pid = Process.fork do 
        require_relative 'ServerWorker.rb'
      end
      j = j + 1
      workersId.push(pid.to_s)
    end
  elsif command == "remove"
    args.each do |pid|
      system("kill "+pid.to_s)
      workersId.delete(pid.to_s)
    end
  elsif command == "exit"
    workersId.each do |pid|
      system("kill "+pid.to_s)
      workersId.delete(pid.to_s)
    end
    loop = false
  elsif command == "stop" #use only on queue server
    system("sudo rabbitmqctl stop")
    state = 0
  else
    puts "CMD error"
end
end
end