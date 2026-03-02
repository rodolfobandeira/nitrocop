items.each do |item|
  puts item
end

[1, 2, 3].map do |n|
  n * 2
end

things.select do |t|
  t > 0
end

data.each_with_object({}) do |item, hash|
  hash[item] = true
end

results.reject do |r|
  r.nil?
end

# Struct.new blocks are always exempt (class_constructor?)
Entry = Struct.new(:type, :body, :ref_type, :ref_id, :user) do
  def foo; 1; end
  def bar; 2; end
  def baz; 3; end
end

# Heredoc content within a block should NOT count toward block body lines.
# The heredoc physically appears between opening/closing but is logically 1 line.
render do
  x1 = 1
  x2 = 2
  x3 = 3
  x4 = 4
  x5 = 5
  x6 = 6
  x7 = 7
  x8 = 8
  x9 = 9
  x10 = 10
  x11 = 11
  x12 = 12
  x13 = 13
  x14 = 14
  x15 = 15
  x16 = 16
  x17 = 17
  x18 = 18
  x19 = 19
  x20 = 20
  x21 = 21
  x22 = 22
  msg = <<~HEREDOC
    line1
    line2
    line3
    line4
    line5
    line6
    line7
    line8
    line9
    line10
  HEREDOC
  x24 = 24
  x25 = 25
end

# Block whose body IS a heredoc literal (body = 1 line, not heredoc content lines)
process do
  <<~RUBY
    line1
    line2
    line3
    line4
    line5
    line6
    line7
    line8
    line9
    line10
    line11
    line12
    line13
    line14
    line15
    line16
    line17
    line18
    line19
    line20
    line21
    line22
    line23
    line24
    line25
    line26
    line27
    line28
    line29
    line30
  RUBY
end
