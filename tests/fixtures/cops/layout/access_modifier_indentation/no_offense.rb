class Foo
  private
  def bar; end
end

class Baz
  protected
  def qux; end
end

class Quux
  public
  def corge; end
end

Test = Class.new do
  private
  def grault; end
end

included do
  private
  def garply; end
end
