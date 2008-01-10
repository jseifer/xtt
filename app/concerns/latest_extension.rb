module LatestExtension
  def latest
    @__latest__ ||= find(:first) || :false
    @__latest__ == :false ? nil : @__latest__
  end
end