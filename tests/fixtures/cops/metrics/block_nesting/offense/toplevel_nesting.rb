# nitrocop-expect: 4:6 Metrics/BlockNesting: Avoid more than 3 levels of block nesting.
if a
  if b
    if c
      if d
        puts d
      end
    end
  end
end
