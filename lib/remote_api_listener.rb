require 'logger'
require 'socket'
require 'json'
require 'net/http'
require 'uri'
require 'thread'

class RemoteApiListener
  SEMAPHORE = Mutex.new

  def initialize(logger, endpoint_root)
    @logger = logger
    @endpoint_root = endpoint_root
    URI(endpoint_root) # test parsing
    @logger.debug "Initializing RemoteApiListener for #{@endpoint_root}"
    read_readers_config
  end

  def connect(topology)
    SEMAPHORE.synchronize do
      @logger.info "Connect:    #{topology}"
      if @readers.detect { |reader| reader['topology'] == topology }
        # pass, we already know about it
      else
        uri = URI(endpoint('/readers'))
        params = { 'hostname' => hostname, 'topology' => topology }
        response = Net::HTTP.post_form(uri, params)

        @logger.debug "HTTP POST #{uri} with #{params.inspect}:"
        @logger.debug response.code
        @logger.debug response.body

        if response.code.to_i == 200 || response.code.to_i == 201
	  @readers << { 'topology' => topology, 'reader_id' => response.body }
          write_readers_config
        end
      end
    end
  end

  def disconnect(topology)
    SEMAPHORE.synchronize do
      @logger.info "Disconnect: #{topology}"

      @readers.reject! { |reader| reader['topology'] == topology }
    end
  end

  def scan(topology, rfid_number)
    @logger.info "Scan:       #{topology} #{rfid_number}"
  end

  private

  def endpoint(path)
    @endpoint_root + path
  end

  def config_filename
    'readers.json'
  end

  def read_readers_config
    @readers = JSON.parse(File.open(config_filename, 'r').read) rescue []
    @logger.debug "Read readers config from #{config_filename}: #{@readers.inspect}"
  end

  def write_readers_config
puts "going to write"
    contents = @readers.to_json
    File.open(config_filename, 'w') do |f|
      f.puts contents
    end
    @logger.debug "Wrote readers config to #{config_filename} as JSON: #{contents}"
  end

  def hostname
    @hostname ||= Socket.gethostname
  end
end
