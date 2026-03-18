run if cond

run unless cond

run if cond &&
       cond2

run unless cond &&
           cond2

if cond
  something
end

unless cond
  something
end

# Backslash continuation makes it a single logical line
raise ArgumentError, "missing discovery method" \
  unless opts.has_key?('discovery')

raise ArgumentError, "invalid method" \
  if opts['method'] != 'base'

do_something(arg1, arg2) \
  unless condition && other_condition

# Method chain with block on continuation line — block braces on same line
encryptor.decrypt_and_verify(ciphertext)
  .yield_self { |cleartext| subtype.deserialize(cleartext) } unless ciphertext.nil?

# Method call with multiline args and single-line block
opts.on("--max-conns NUM", "Maximum number of open file descriptors " +
                            "(default: 100)",
                            "Might require sudo to set higher than 1024")  { |num| @options[:max_conns] = num.to_i } unless Thin.win?
