# frozen_string_literal: true

module MaBenchmarking
  def benchmarking(log_string)
    back_time = Time.now.to_f
    yield
    Rails.logger.info format("(in %.3f sec) #{log_string.call}", Time.now.to_f - back_time)
  end
end
