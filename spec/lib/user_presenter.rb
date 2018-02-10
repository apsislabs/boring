class UserPresenter < Boring::Presenter
  # Declare the arguments needed to bind to presenter and their type
  arguments user: User

  # Declare pass-through methods
  delegate :birth_date, to: :user

  # Methods to be handled by the presenter
  def name
    "#{user.first_name} #{user.last_name}".strip
  end
end
