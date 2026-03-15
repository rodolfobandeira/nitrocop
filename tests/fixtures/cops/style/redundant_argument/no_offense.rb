array.join(', ')
array.join
exit
exit!
exit(false)
exit!(true)

# Receiverless calls are skipped (except exit/exit!)
parts = split(" ")
chomp("\n")

# Single-quoted newline is literal '\n', not a newline character
str.chomp('\n')
str.chomp!('\n')

# Block argument changes semantics, not redundant
"a b".split(" ", &proc {})
"a b".split(" ", &block)
