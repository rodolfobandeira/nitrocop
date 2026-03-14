(1..4).reduce(0) do |acc, el|
  el
  ^^ Lint/UnmodifiedReduceAccumulator: Ensure the accumulator `acc` will be modified by `reduce`.
end
(1..4).inject(0) do |acc, el|
  el
  ^^ Lint/UnmodifiedReduceAccumulator: Ensure the accumulator `acc` will be modified by `inject`.
end
(1..4).reduce do |acc, el|
  el
  ^^ Lint/UnmodifiedReduceAccumulator: Ensure the accumulator `acc` will be modified by `reduce`.
end
%w(a b c).reduce({}) do |acc, letter|
  acc[foo]
  ^^^^^^^^ Lint/UnmodifiedReduceAccumulator: Do not return an element of the accumulator in `reduce`.
end
%w(a b c).inject({}) do |acc, letter|
  acc[foo] = bar
  ^^^^^^^^^^^^^^ Lint/UnmodifiedReduceAccumulator: Do not return an element of the accumulator in `inject`.
end
(1..4).reduce(0) do |acc, el|
  next el if el.even?
       ^^ Lint/UnmodifiedReduceAccumulator: Ensure the accumulator `acc` will be modified by `reduce`.
  acc += 1
end
