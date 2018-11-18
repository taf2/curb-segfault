require 'curl'
TARGET_URL = "https://ietf.org"
PROXY_URL = "127.0.0.1:8888"
puts "TARGET_URL: #{TARGET_URL}"
puts "PROXY_URL: #{PROXY_URL}"
multi = Curl::Multi.new
easy = Curl::Easy.new(TARGET_URL)
easy.timeout = 2
easy.proxy_url = PROXY_URL
easy.proxy_type = 0
easy.on_debug { |a, b| puts a, b }
multi.add easy
multi.remove easy
multi.add easy
multi.perform
1000.times do
multi.remove easy
#easy.perform
easy.close
GC.start
end
