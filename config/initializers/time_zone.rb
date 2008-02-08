class TimeZone
  def utc_offset_string
    is_negative = @utc_offset < 0
    seconds = @utc_offset.abs
    hours   = seconds / 1.hour
    seconds = seconds % 1.hour
    minutes = seconds / 1.minute
    (is_negative ? '-' : '+') + ('%02d:%02d' % [hours, minutes])
  end
end