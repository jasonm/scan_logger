
require 'json'
class Config
  def initialize(filename = 'readers.json')
    @hash = JSON.parse(File.open(filename).reader))
    puts "Read config file #{filename}:"
    p @hash
  end

  def log_level
    Logger::INFO
  end

  def known_readers
  end
end

require 'logger'
class StdoutOutput
  def initialize(config)
    @logger = Logger.new(STDOUT)
    @logger.level = config.log_level
  end

  def write(event_hash)
    @logger.info("Emitting event: #{event_hash.inspect}")
  end
end

require 'logger'
class RemoteApiOutput
  def initialize(config)
    @logger = Logger.new(STDOUT)
    @logger.level = config.log_level
  end

  def write(event_hash)
    response = @db.save_doc(event_hash)
    @logger.debug("Emitting event: #{event_hash.inspect} - saved to CouchDB as #{response.inspect}")
  end
end

require 'logger'
require 'socket'
require_relative './rfid_reader'
class Scanner
  def initialize(config, output)
    @config = config
    @output = output
  end

  def start
    @rfid_reader = RfidReader.new
    @rfid_reader.debug_mode = (@config.log_level == Logger::DEBUG) # TODO just use logger::levels throughout

    # listen_for_new_readers # => Thread.new { ... }

    @config.known_readers.each do |topology, reader_id|
      @rfid_reader.on(topology: topology) do |_, _, rfid_number|
        @output.write({
          reader_id: reader_id,
          rfid_number: rfid_number,
          timestamp: Time.now.to_s
        })
      end
    end

    @rfid_reader.open
  end

  def stop
    @rfid_reader.close
  end

  private

  def hostname
    @hostname ||= Socket.gethostname
  end
end
