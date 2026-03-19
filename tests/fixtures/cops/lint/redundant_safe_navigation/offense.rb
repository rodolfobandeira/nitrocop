Const&.do_something
     ^^ Lint/RedundantSafeNavigation: Redundant safe navigation detected, use `.` instead.

self&.foo
    ^^ Lint/RedundantSafeNavigation: Redundant safe navigation detected, use `.` instead.

foo.to_s&.strip
        ^^ Lint/RedundantSafeNavigation: Redundant safe navigation detected, use `.` instead.

42&.minutes
  ^^ Lint/RedundantSafeNavigation: Redundant safe navigation detected, use `.` instead.

'hello'&.upcase
       ^^ Lint/RedundantSafeNavigation: Redundant safe navigation detected, use `.` instead.

foo&.to_h || {}
   ^^^^^^^^^^^^ Lint/RedundantSafeNavigation: Redundant safe navigation with default literal detected.

foo&.to_a || []
   ^^^^^^^^^^^^ Lint/RedundantSafeNavigation: Redundant safe navigation with default literal detected.

foo&.to_i || 0
   ^^^^^^^^^^^ Lint/RedundantSafeNavigation: Redundant safe navigation with default literal detected.

foo&.to_f || 0.0
   ^^^^^^^^^^^^^ Lint/RedundantSafeNavigation: Redundant safe navigation with default literal detected.

foo&.to_s || ''
   ^^^^^^^^^^^^ Lint/RedundantSafeNavigation: Redundant safe navigation with default literal detected.

foo&.to_h { |k, v| [k, v] } || {}
   ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Lint/RedundantSafeNavigation: Redundant safe navigation with default literal detected.
