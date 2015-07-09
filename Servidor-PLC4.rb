require 'socket'
require 'rdbi-driver-sqlite3'
DB_NAME = 'dns.db'
dbh = RDBI.connect(:SQLite3, :database => DB_NAME)
socket = UDPSocket.new
socket.bind("", 2100)

loop{
        data, sender = socket.recvfrom(1024)
        s_ip = sender[3]
        s_port = sender[1]
        puts "Dados recebidos do cliente #{s_ip}:#{s_port}: #{data}"

        #Verificar comando
        data = data.split
        if (data[0] == "REG")
    		sel = dbh.execute("select * from dominio where dominio = '" + data[1] + "' or ip = '" + data[2] + "'")
    		if (sel.count != 0)
    			socket.send("REGFALHA", 0, s_ip, s_port)
    		else
    			dbh.execute('insert into dominio (dominio, ip) values ("' + data[1] + '", "' + data[2] + '")')
    			socket.send("REGOK", 0, s_ip, s_port)
    		end
        elsif (data[0] == "IP")
        	selc = dbh.execute("select * from dominio where dominio = '" + data[1] + "'")
        	if (selc.count != 0)
        		selc.fetch(:all, :Struct).each do |row|
					socket.send("IPOK " + row.ip, 0, s_ip, s_port)
				end
        	else
        		socket.send("IPFALHA", 0, s_ip, s_port)
        	end
        else
        	socket.send("FALHA", 0, s_ip, s_port)
        end
}

socket.close
dbh.disconnect
