# nitrocop-expect: 5:8 Metrics/BlockNesting: Avoid more than 3 levels of block nesting.
# nitrocop-expect: 10:8 Metrics/BlockNesting: Avoid more than 3 levels of block nesting.
def foo
  if a
    if b
      if c
        if d
          puts d
        end
      end
      if e
        if f
          puts f
        end
      end
    end
  end
end
