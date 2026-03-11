class UsersController < ApplicationController
  before_action :authenticate, only: [:index]

  def index
  end
end

class Auth::PasswordsController < Devise::PasswordsController
  before_action :redirect, only: :edit, unless: :token_valid?

  def update
    super
  end
end

class DelegateController < ApplicationController
  before_action :auth, only: :show
  delegate :show, to: :other_controller
end

class AliasMethodController < ApplicationController
  before_action :auth, only: :display
  def show; end
  alias_method :display, :show
end

class AliasController < ApplicationController
  before_action :auth, only: :display
  def show; end
  alias display show
end

module AdminModule
  before_action :auth, only: :index
  def index; end
end

module FooMixin
  extend ActiveSupport::Concern

  included do
    before_action proc { authenticate }, only: :foo
  end

  def foo; end
end

class FooController < ApplicationController
  before_action :foo, except: %I[index show]

  def index
  end

  def show
  end
end

class ConditionalController < ActionController
  before_action(:authenticate, only: %i[update cancel]) unless foo

  def update; end

  def cancel; end
end
