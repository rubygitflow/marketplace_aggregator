# frozen_string_literal: true

module MaBenchmarking
  def benchmarking(log_string)
    back_time = Time.now
    yield
    Rails.logger.info format("(in %.3f sec) #{log_string.call}", Time.now - back_time)
  end
end
