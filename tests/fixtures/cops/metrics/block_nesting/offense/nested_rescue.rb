# nitrocop-expect: 7:8 Metrics/BlockNesting: Avoid more than 3 levels of block nesting.
def foo
  if a
    if b
      if c
        begin
          puts d
        rescue
          puts x
        end
      end
    end
  end
end
