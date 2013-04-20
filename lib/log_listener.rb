class LogListener
  def initialize(logger)
    @logger = logger
  end

  def connect(topology)
    @logger.info "Connect:    #{topology}"
  end

  def disconnect(topology)
    @logger.info "Disconnect: #{topology}"
  end

  def scan(topology, rfid_number)
    @logger.info "Scan:       #{topology} #{rfid_number}"
  end
end
