require 'socket'
require 'rdbi-driver-sqlite3'
DB_NAME = 'banco.db'
dbh = RDBI.connect(:SQLite3, :database => DB_NAME)
socket = UDPSocket.new
socket.bind("", 2100)
retorno = nil
loop {
	recebe, sender = socket.recvfrom(1024)
	data = recebe.split
	s_ip = sender[3]
	s_port = sender[1]
	if data[0] == "REG" && data.length == 3
		if data[1] != nil && data[2] != nil
			begin
		dbh.execute('insert into dominio (dominio, ip) values ("' + data[1] + '", "' + data[2] + '")')
		socket.send "REGOK", 0 , s_ip, s_port
		rescue
		socket.send "REGFALHA", 0, s_ip, s_port
			end
		end
	elsif data[0] == "IP" && data.length == 2
		if data[1] != nil
			sel = dbh.execute("select IP from dominio where dominio = '" + data[1] + "'")
			sel.fetch(:all).each do |row|
			retorno = row[0]
			end
		puts retorno
		if retorno != nil
		socket.send("IPOK #{retorno}", 0, s_ip, s_port)
			elsif retorno == nil
		socket.send "IPFALHA", 0, s_ip, s_port
			end
	end
	else
		socket.send "FALHA", 0, s_ip, s_port	
	end
}
socket.close
dbh.disconnect
