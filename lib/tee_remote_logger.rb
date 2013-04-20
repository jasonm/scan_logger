# require 'logger'
#
# class TeeRemoteLogger < Logger
#   def initialize(logger, endpoint)
#     @logger = logger
#     @endpoint = endpoint
#   end
#
#   def add(severity, message = nil, progname = nil, &block)
#     @logger.add(severity, message, progname, block)
#     # TODO: server.post(endpoint, severity, message || block.call)
#   end
# end
