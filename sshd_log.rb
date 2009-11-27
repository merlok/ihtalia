require 'file/tail'
require 'thread'
require 'cgi'

class Sshd_log

  def initialize()
    @source_sshd = "/var/log/auth.log"
  end

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
    elsif line[5] == "Accepted"
      log = "<b>#{line[5]}</b> : #{line[8]} @ #{line[10]}<br />"
    end
    #	File.open("auth.html", 'a') {|f| f.write(log) } if log != ""
  end



  def thread_
    File::Tail::Logfile.open(@source_sshd) do |logf|
      logf.backward(0).tail do |line|
        hit = line.chomp.split(/\s+/)
        sshd(hit) if hit[4] =~ /sshd\[/
      end
    end
  end


end