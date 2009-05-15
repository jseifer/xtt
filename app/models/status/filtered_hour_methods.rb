class Status
  module FilteredHourMethods
    def self.extended(hours)
      hours.collect! do |(grouped, hour)|
        user_id, date = grouped.split("::")
        [user_id.to_i, Time.parse(date), hour]
      end
      hours.sort! { |x, y| x.last <=> y.last }
    end

    def total(user_id = 0)
      user_id = case user_id
        when User then user_id.id
        when ActiveRecord::Base then user_id.user_id
        else user_id
      end.to_i
      @total ||= inject({}) do |total, (user, date, hour)|
        user        = user.to_i
        total[user] = hour.to_f + total[user].to_f
        total[0]    = hour.to_f + total[0].to_f unless user.zero?
        total
      end
      @total[user_id].to_f
    end
  end
end