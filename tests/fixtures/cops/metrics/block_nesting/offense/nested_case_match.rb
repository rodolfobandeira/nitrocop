# nitrocop-expect: 5:8 Metrics/BlockNesting: Avoid more than 3 levels of block nesting.
def foo
  if a
    if b
      if c
        case d
        in 1
          puts 1
        in 2
          puts 2
        end
      end
    end
  end
end
