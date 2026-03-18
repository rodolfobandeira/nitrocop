class Foo
  PRIVATE_CONST = 42
  private_constant :PRIVATE_CONST
end

class Bar
  PUBLIC_CONST = 42
end

class Baz
  private
  def my_method; end
end

class Provider
  private
  self::QUERY_FORMAT = "'${Status}\\n'"
  private_constant :QUERY_FORMAT
end
