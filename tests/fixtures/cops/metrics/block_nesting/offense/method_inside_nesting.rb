# Methods inside nesting constructs inherit the outer depth.
# RuboCop does NOT reset nesting at method boundaries.
# nitrocop-expect: 9:12 Metrics/BlockNesting: Avoid more than 3 levels of block nesting.
unless guard_condition
  module Parser
    class Base
      def process(arg)
        while running
          if check_a
            if check_b
              do_something
            end
          end
        end
      end
    end
  end
end
