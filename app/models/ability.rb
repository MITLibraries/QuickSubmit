class Ability
  include CanCan::Ability

  def initialize(user)
    can :manage, Submission if user.admin?
    can [:create, :read], Submission, user: user
    # See the wiki for details:
    # https://github.com/CanCanCommunity/cancancan/wiki/Defining-Abilities
  end
end
