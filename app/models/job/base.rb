# Stolen shamelessly from Tender
module Job::Base
  mattr_accessor :queue_jobs_automatically
  self.queue_jobs_automatically = Rails.env != 'development'

  def self.new(*args)
    if args.first.is_a?(User)
      user = args.shift
      args.unshift user.id
    end
    s = Struct.new(*args)
    s.send :include, self
    s.extend ClassMethods
    s
  end

  module ClassMethods
    def create(*args)
      if args.first.is_a?(User)
        user = args.shift
        args.unshift user.id
      end
      job = new(*args)
      job.setup
      job.perform_or_queue(user)
      job
    end

    def perform(*args)
      job = new(*args)
      job.setup
      job.perform
      job
    end
  end

  def setup
  end

  def logger
    RAILS_DEFAULT_LOGGER
  end

  def queue!(user = nil)
    Delayed::Job.with_user(user) do
      Delayed::Job.enqueue self
    end
  end

  def perform_or_queue(user = nil)
    queue_jobs_automatically ? queue!(user) : perform
  end
end