def foo(bar,
^^^^^^^^^^^ Style/MultilineMethodSignature: Avoid multi-line method signatures.
        baz)
end

def method_name(arg1,
^^^^^^^^^^^^^^^ Style/MultilineMethodSignature: Avoid multi-line method signatures.
                arg2,
                arg3)
end

def another(a,
^^^^^^^^^^^ Style/MultilineMethodSignature: Avoid multi-line method signatures.
            b)
  a + b
end

# nitrocop-expect: 15:17 Style/MultilineMethodSignature: Avoid multi-line method signatures.
register_element def animate(
  attribute_name: nil,
  repeat_count: nil,
  fallback_value: nil,
  **attributes,
  &content
) = nil
