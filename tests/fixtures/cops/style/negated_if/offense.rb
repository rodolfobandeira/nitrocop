if !x
^^ Style/NegatedIf: Favor `unless` over `if` for negative conditions.
  do_something
end

if !condition
^^ Style/NegatedIf: Favor `unless` over `if` for negative conditions.
  foo
end

if !finished?
^^ Style/NegatedIf: Favor `unless` over `if` for negative conditions.
  retry
end

if (!column_exists?(:users, :confirmed_at))
^^ Style/NegatedIf: Favor `unless` over `if` for negative conditions.
  add_column :users, :confirmed_at, :datetime
end

if(!file[:directory])
^^ Style/NegatedIf: Favor `unless` over `if` for negative conditions.
  return root
end

do_something if not condition
^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Style/NegatedIf: Favor `unless` over `if` for negative conditions.

if not a_condition
^^^^^^^^^^^^^^^^^^ Style/NegatedIf: Favor `unless` over `if` for negative conditions.
  some_method
end

something if (!x.even?)
^^^^^^^^^^^^^^^^^^^^^^^ Style/NegatedIf: Favor `unless` over `if` for negative conditions.
