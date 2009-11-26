# /var/log/auth.log
# Nov 24 13:47:04 eee-kubox sshd[7806]: Failed   password 	for invalid user apache from 189.112.177.3 port 58158 ssh2
# Nov 24 20:11:12 eee-kubox sshd[22056]:  Failed password 	for 		root from 192.168.0.2 port 47160 ssh2
# Nov 24 21:09:54 arch-sheep sshd[16555]: Failed none 		for invalid user lol from 127.0.0.1 port 42105 ssh2
# Nov 24 20:32:05 arch-sheep sshd[15047]: Failed password 	for invalid user lol from 127.0.0.1 port 48045 ssh2
# Nov 24 16:51:09 eee-kubox sshd[14521]: Accepted password for ronfini from 192.168.0.2 port 43899 ssh2
# Nov 24 13:46:51 eee-kubox sshd[7801]: Invalid user newsletter from 189.112.177.3
# # # # # # # # # # #
# 
require 'file/tail'
require 'thread'
require 'cgi'

source_auth = "/var/log/auth.log"
source_httpd = "/var/log/lighttpd/access.log"


def sshd(line)
	log = ""
        if line[5] == "Failed"
		if line[8] == "invalid"
			log = "<b>#{line[5]}</b> : #{line[10]} -> #{line[12]}<br />"
			puts log
		else
			log = "<b>#{line[5]}</b> : #{line[8]} -> #{line[10]}<br />"
			puts log
		end
		#File.open("auth.html", 'a') {|f| f.write(log) } 
        elsif line[5] == "Accepted"
                log = "<b>#{line[5]}</b> : #{line[8]} @ #{line[10]}<br />"
		#File.open("auth.html", 'a') {|f| f.write(log) }
        end
#	File.open("auth.html", 'a') {|f| f.write(log) } if log != ""
end


def httpd(line)
	# Apache - Lighttpd
	ip = line[0]
	request = CGI.unescape(line[6])
	if request =~ /.*(and|or).*(\s|\/\*\*\/).*[1-9A-z]|.*\'.*|.*select.*(\s|\/\*\*\/).*(from|).*[1-9A-z].*|.*insert.*(\s|\/\*\*\/).*into.*(\s|\/\*\*\/).*values.*/i
		puts "SQL Injection Detected  ---->  #{request} from #{ip}"
	elsif request =~ /(http(s|)\:\/\/|ftp\:\/\/)/
                puts "Remote File Inclusion Detected ----> #{request} from #{ip}"
	elsif request =~ /(\<.*\>|\"\>)/
		puts "Cross Site Scripting Detected ---->  #{request} from #{ip}"
        elsif request =~ /.*(\.\.\/|\?.*\=.*(\/|\S)[1-9A-z].*\/.*([1-9A-z]|)).*/
                puts "Local File Inclusion Detected ---->  #{request} from #{ip}"
	end
end



sshd_thr = Thread.new {
	File::Tail::Logfile.open(source_auth) { |logf|
        	logf.backward(0).tail { |line| 
    			hit = line.chomp.split(/\s+/)
        		sshd(hit) if hit[4] =~ /sshd\[/
		}
	}
}

httpd_thr = Thread.new {
        File::Tail::Logfile.open(source_httpd) { |logf|
                logf.backward(0).tail { |line|
                        hit = line.chomp.split(/\s+/)	
                        httpd(hit) if hit[5] =~ /\"GET/
                }
        }
}

