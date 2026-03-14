case x
when 1
  puts 1
when 2
  puts 2
end

# Pattern matching case/in (Ruby 3.0+)
case x
in 1
  :a
in 2
  :b
end
