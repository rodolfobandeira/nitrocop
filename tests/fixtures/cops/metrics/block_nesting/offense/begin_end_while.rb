# nitrocop-expect: 5:8 Metrics/BlockNesting: Avoid more than 3 levels of block nesting.
def foo
  if a
    if b
      if c
        begin
          puts d
        end while d
      end
    end
  end
end
