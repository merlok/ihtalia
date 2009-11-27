@pwd  = File.dirname(File.expand_path(__FILE__))

require 'file/tail'
require 'thread'
require 'cgi'

@file_threads = @pwd + '/gen_thread.rb'



def load_plugins
	return plugins = ['Sshd_log', 'Httpd_log']
end

def gen_thread( plugins )
	#Create script
	
	var_plugins = "\t"
	var_threads= "["
	var_threads_name = "\t"
  var_decl_threads = "\t"
	
	plugins.each do |plugin|
		p_name = plugin.downcase
		var_plugins += "@#{p_name} = #{plugin}.new\n\t\t\t\t"
		var_threads += "\tt_#{p_name}, "
		var_threads_name += "t_#{p_name} = Thread.new{ @#{p_name}.thread_ }\n\t\t\t\t"
	end
	
	var_threads += "]\n"
	#puts var_plugins
	header = <<-EOF_
		@pwd  = File.dirname(File.expand_path(__FILE__))
		
		require 'thread'
		require @pwd + '/httpd_log.rb'
		require @pwd + '/sshd_log.rb'
		
		class Gen_thread
			@a_threads
			
			def initialize
			#{var_plugins}
			end
			
			def start_threads
			#{var_threads_name}
        @a_threads = #{var_threads}
        @a_threads.each { |thread| thread.join }
			end
		end
	EOF_
	
	File.open(@file_threads,"w+") { |file| file.write header }					
end


plugins = load_plugins

gen_thread(plugins)

require @file_threads

generate_thread = Gen_thread.new
generate_thread.start_threads