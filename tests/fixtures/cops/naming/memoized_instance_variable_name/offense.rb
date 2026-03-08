def foo
  @bar ||= compute
  ^^^^ Naming/MemoizedInstanceVariableName: Memoized variable `@bar` does not match method name `foo`.
end
def something
  @other ||= calculate
  ^^^^^^ Naming/MemoizedInstanceVariableName: Memoized variable `@other` does not match method name `something`.
end
def value
  @cached ||= fetch
  ^^^^^^^ Naming/MemoizedInstanceVariableName: Memoized variable `@cached` does not match method name `value`.
end
def issue_token!
  return @token if defined?(@token)
                            ^^^^^^ Naming/MemoizedInstanceVariableName: Memoized variable `@token` does not match method name `issue_token!`. Use `@issue_token` instead.
         ^^^^^^ Naming/MemoizedInstanceVariableName: Memoized variable `@token` does not match method name `issue_token!`. Use `@issue_token` instead.
  @token = create_token
  ^^^^^^ Naming/MemoizedInstanceVariableName: Memoized variable `@token` does not match method name `issue_token!`. Use `@issue_token` instead.
end
define_method(:values) do
  @foo ||= do_something
  ^^^^ Naming/MemoizedInstanceVariableName: Memoized variable `@foo` does not match method name `values`.
end
klass.define_method(:values) do
  @bar ||= do_something
  ^^^^ Naming/MemoizedInstanceVariableName: Memoized variable `@bar` does not match method name `values`.
end
define_singleton_method(:values) do
  @baz ||= do_something
  ^^^^ Naming/MemoizedInstanceVariableName: Memoized variable `@baz` does not match method name `values`.
end
def self.records
  @other ||= fetch_records
  ^^^^^^ Naming/MemoizedInstanceVariableName: Memoized variable `@other` does not match method name `records`.
end
