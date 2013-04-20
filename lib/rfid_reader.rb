require 'evdev'
require 'ostruct'

# What happens if you #open, #on, #close, #open -- should the subscriptions persist?
class RfidReader
  attr_reader :devices, :subscriptions
  attr_accessor :logger, :debug

  def initialize(listener, logger)
    @listener = listener
    @logger = logger
    @devices = []
  end

  def open
    if @devices.any?
      close
    end

    @connect_listener_thread = Thread.new do
      while(true) do
        logger.debug "Polling for new devices..."

        device_filenames.each do |filename|
          is_new_device = @devices.none? { |device| device.filename == filename }

          if is_new_device
            register_device(filename)
          end
        end

        sleep 1
      end
    end

    if block_given?
      begin
        yield
      ensure
        close
      end
    end
  end

  def close
    @connect_listener_thread.kill

    @devices.each do |device|
      logger.debug("Killing thread for #{device.filename} #{device.thread}")
      logger.debug("Closing handle for #{device.filename} #{device.handle}")

      device.thread.kill
      device.handle.close
    end

    @devices = []
    @subscriptions = {}
  end

  private

  def device_filenames
    devices = Dir['/dev/input/event*']
  end

  def register_device(filename)
    logger.debug("#{filename} connecting...")
    handle = Evdev::EventDevice.open(filename, "a+")
    topology = handle.topology

    thread = Thread.new do
      connected = true
      while(connected) do
        begin
          rfid_number = ""
          event = nil
          until (event && event.feature.name == "ENTER" && event.value == 0)
            event = handle.read_event
            if %w(0 1 2 3 4 5 6 7 8 9).include?(event.feature.name) && event.value == 1
              rfid_number += event.feature.name
            end
          end
          @listener.scan(topology, rfid_number)
        rescue Errno::ENODEV => e
          @devices.reject! { |device| device.filename == filename }
          connected = false
          @listener.disconnect(topology)
          logger.debug("#{filename} disconnected.")
          logger.debug("#{@devices.size} still connected.")
        rescue Exception => e
          logger.error("#{filename} Exception in reader thread:")
          logger.error("#{e.class}: #{e.message}")
          e.backtrace.each { |line| logger.error("  #{line}") }
        end
      end
    end

    device = OpenStruct.new({
      filename: filename,
      handle: handle,
      topology: topology,
      thread: thread
    })

    @devices << device

    @listener.connect(device.topology)
    logger.debug("#{@devices.size} now connected.")
  end
end
