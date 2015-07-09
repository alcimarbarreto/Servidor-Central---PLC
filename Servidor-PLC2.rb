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
puts "Dados recebidos do cliente #{s_ip}:#{s_port}: #{data} "
socket.send(data.upcase, 0, s_ip, s_port)
	
	data = data.split
	cons = dbh.execute('SELECT dominio, ip FROM dominio WHERE ("' + data[1] + '", "' + data[2] + '")')
	puts socket.send("dados ja existe")
	
	if (data[0] == "REG")
	dbh.execute('insert into dominio (dominio, ip) values ("' + data[1] + '", "' + data[2] + '")')
	socket.send("REGOK", 0, s_ip, s_port)
   	elsif (data[0] == "IP")
		#cons = dbh.execute('select ip from dominio where dominio = ("' + data[1] + '", "' + data[2] + '")')
		cons = dbh.execute("SELECT ip FROM dominio WHERE dominio like 'acari'")
		socket.send("IP", 0, s_ip, s_port)
		puts cons
	else
		socket.send("REGFALHA", 0, s_ip, s_port)
	end

}
socket.close
dbh.disconnect
