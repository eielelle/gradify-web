# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    # User is not logged in
    # return unless user.present?

    # # Superadmin has access to everything
    # if user.superadmin?

    # # Admin can manage teachers and students
    # elsif user.admin?
    #   # can :manage, Teacher
    #   # can :manage, Student
    #   # can :read, :all

    # # Teachers can manage students and read their own data
    # elsif user.teacher?
    #   # can :manage, Student
    #   # can :read, Teacher, id: user.id  # Can only read their own profile

    # # Students can only read their own data
    # elsif user.student?
    #   # can :read, Student, id: user.id  # Can only read their own profile
    # end



    # can :manage, :all if user.permission.name == 'SuperAdmin'

    # return unless user.permission.name == 'Admin'

    # cannot :manage, :admin

    # can :manage

    # Define abilities for the user here. For example:
    #
    #   return unless user.present?
    #   can :read, :all
    #   return unless user.admin?
    #   can :manage, :all
    #
    # The first argument to `can` is the action you are giving the user
    # permission to do.
    # If you pass :manage it will apply to every action. Other common actions
    # here are :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on.
    # If you pass :all it will apply to every resource. Otherwise pass a Ruby
    # class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the
    # objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, published: true
    #
    # See the wiki for details:
    # https://github.com/CanCanCommunity/cancancan/blob/develop/docs/define_check_abilities.md
  end
end
