foo(a: 1, b: 2)
bar(**hash)
foo(a: 1, **hash)
method_call(key: value)
method_call(**options)
foo(x, **options)
foo(x, **options.merge!(other_options))
bar(x, y: 1, **opts)
# kwsplat with merge not first element — preceding keyword arg
notify(name, payload, caller_depth: 1, **kwargs.merge(yield))
# block argument after keyword splat — RuboCop does not flag these
build_object(**options.merge(column_type: :integer, value: 1), &block)
build_object(**options.merge(column_options: { null: true }), &block)
process(**opts.merge(key: val), &callback)
