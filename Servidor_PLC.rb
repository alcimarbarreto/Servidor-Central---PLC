require 'socket'
require 'rdbi-driver-sqlite3'
socket = UDPSocket.new
socket.bind("", 2000)

DB_NAME = 'dns.db'
dbh = RDBI.connect(:SQLite3, :database => DB_NAME)
inse = dbh.execute('insert into dominio (id, dominio, ip) values ("01", "uol", "192.1.1.2")')
dbh.disconnect

loop{
data, sender = socket.recvfrom(1024)
s_ip = sender[3]
s_port = sender[1]
puts "Dados recebidos do cliente #{s_ip}:#{s_port}: #{data} "
socket.send(data.upcase, 0, s_ip, s_port)
}
socket.close
