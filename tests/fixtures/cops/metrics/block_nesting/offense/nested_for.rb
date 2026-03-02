# nitrocop-expect: 5:8 Metrics/BlockNesting: Avoid more than 3 levels of block nesting.
def foo
  if a
    if b
      if c
        for x in [1, 2] do
          puts x
        end
      end
    end
  end
end
