class StructuredLogFormatter < ActiveSupport::Logger::SimpleFormatter
  def call(severity, timestamp, _progname, msg)
    log_entry = {
      timestamp: timestamp.iso8601(3),
      severity: severity,
      message: msg.to_s.strip
    }

    if Thread.current[:request_id]
      log_entry[:request_id] = Thread.current[:request_id]
    end

    "#{log_entry.to_json}\n"
  end
end
