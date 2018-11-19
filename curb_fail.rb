#!/usr/bin/env ruby

require 'curl'
require 'timeout'
require 'openssl'

TARGET_URL = "https://ietf.org"
PROXY_URL = "127.0.0.1:8888"
RUBY_TIMEOUT = ARGV[0] && ARGV[0].to_f || 0.1

puts "RUBY_VERSION: #{RUBY_VERSION}"
puts "Curl::CURB_VERSION: #{Curl::CURB_VERSION}"
puts "OpenSSL::OPENSSL_VERSION: #{OpenSSL::OPENSSL_VERSION}"
puts "TARGET_URL: #{TARGET_URL}"
puts "PROXY_URL: #{PROXY_URL}"
puts "RUBY_TIMEOUT: #{RUBY_TIMEOUT}"

#Thread.abort_on_exception=true

if ENV['JEMALLOC_STATS']
  STDERR.puts "JEMALLOC_STATS enabled"

  require 'jemal'

  if Jemal.jemalloc_builtin?
    STDERR.puts "jemalloc found"
    Thread.new do
      first = true

      while true
        sleep 5
        stats = Jemal.stats
        stats[:ts] = Time.now.utc.to_i

        File.open('jemalloc.log', first ? 'w' : 'a') do |f|
          f.puts stats.to_json
        end

        first = false
				STDERR.puts "captured stats"
      end
    end
  end
end

def create_easy
  easy = Curl::Easy.new(TARGET_URL)
  easy.timeout_ms = 2000
  easy.proxy_url = PROXY_URL
  easy.proxy_type = 0
  easy.on_debug { |a, b| } #puts a, b }
  easy
end

5000.times do

    easy = create_easy
begin
  Timeout.timeout(RUBY_TIMEOUT) do
#   Curl.get(TARGET_URL) do|easy|
#     easy.timeout = 2
#     easy.proxy_url = PROXY_URL
#     easy.proxy_type = 0
#     easy.on_debug { |a, b| } #puts a, b }
#   end
    easy.perform
  end
rescue Timeout::Error => e
  puts e.inspect
ensure
  puts "close"
  easy.close
end

puts "start gc"
GC.start
end

puts 'exiting'
