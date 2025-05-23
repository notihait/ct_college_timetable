module AdminChecker
    def admin?(telegram_id)
        user = User.find_by(telegram_id: telegram_id)
        user&.role == 'admin'
    end
      
  end
  