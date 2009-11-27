require 'file/tail'
require 'thread'
require 'cgi'

class Httpd_log

  def initialize()
    @source_httpd = "/var/log/lighttpd/access.log"
  end

  def httpd(line)
	# Apache - Lighttpd
    ip = line[0]
    request = CGI.unescape(line[6])
    if request =~ /.*(and|or).*(\s|\/\*\*\/).*[1-9A-z]|.*\'.*|.*select.*(\s|\/\*\*\/).*(from|).*[1-9A-z].*|.*insert.*(\s|\/\*\*\/).*into.*(\s|\/\*\*\/).*values.*/i
      puts "SQL Injection Detected  ---->  #{request} from #{ip}"
    elsif request =~ /(http(s|)\:\/\/|ftp\:\/\/)/i
      puts "Remote File Inclusion Detected ----> #{request} from #{ip}"
    elsif request =~ /(\<.*\>|\"\>)/i
      puts "Cross Site Scripting Detected ---->  #{request} from #{ip}"
    elsif request =~ /.*(\.\.\/|\?.*\=.*(\/|\S)[1-9A-z].*\/.*([1-9A-z]|)).*/
      puts "Local File Inclusion Detected ---->  #{request} from #{ip}"
    end
  end


  def thread_
    File::Tail::Logfile.open(@source_httpd) do |logf|
      logf.backward(0).tail do |line|
        hit = line.chomp.split(/\s+/)
        httpd(hit) if hit[5] =~ /\"GET/
      end
    end
  end


end