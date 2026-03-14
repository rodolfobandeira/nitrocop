case x
  when 1
  ^^^^ Layout/CaseIndentation: Indent `when` as deep as `case`.
    puts 1
  when 2
  ^^^^ Layout/CaseIndentation: Indent `when` as deep as `case`.
    puts 2
  when 3
  ^^^^ Layout/CaseIndentation: Indent `when` as deep as `case`.
    puts 3
end

# Pattern matching case/in (Ruby 3.0+)
case x
  in 1
  ^^ Layout/CaseIndentation: Indent `in` as deep as `case`.
    :a
  in 2
  ^^ Layout/CaseIndentation: Indent `in` as deep as `case`.
    :b
  in 3
  ^^ Layout/CaseIndentation: Indent `in` as deep as `case`.
    :c
end
