loop do
  work
end

loop do
  break if done?
end

while condition
  work
end

until condition
  work
end

# Variable assigned inside while true, referenced after loop — scoping exemption
def parse_sequence
  save = self.pos
  while true
    tmp = apply(:rule)
    unless tmp
      self.pos = save
      break
    end
  end
  puts tmp
end

# Variable assigned inside until false, referenced after loop
def process
  until false
    result = compute
    break if result
  end
  result
end

# Multiple variables assigned inside loop, one referenced after
def multi_var
  while true
    a, b = 42, 43
    break
  end
  puts a, b
end

# Modifier form: variable assigned inside while true, referenced after
def modifier_form
  a = next_value or break while true
  p a
end
