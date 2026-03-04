# nitrocop-expect: 5:29 Metrics/BlockNesting: Avoid more than 3 levels of block nesting.
def foo
  if a
    if b
      if c
        value = parse(input) rescue nil
      end
    end
  end
end
