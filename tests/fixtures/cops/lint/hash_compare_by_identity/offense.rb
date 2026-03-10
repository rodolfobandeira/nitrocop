hash[foo.object_id] = :bar
^^^^^^^^^^^^^^^^^^^^^^^^^^^ Lint/HashCompareByIdentity: Use `Hash#compare_by_identity` instead of using `object_id` for keys.

hash.key?(baz.object_id)
^^^^^^^^^^^^^^^^^^^^^^^^ Lint/HashCompareByIdentity: Use `Hash#compare_by_identity` instead of using `object_id` for keys.

hash.fetch(x.object_id)
^^^^^^^^^^^^^^^^^^^^^^^ Lint/HashCompareByIdentity: Use `Hash#compare_by_identity` instead of using `object_id` for keys.

hash[object_id]
^^^^^^^^^^^^^^^ Lint/HashCompareByIdentity: Use `Hash#compare_by_identity` instead of using `object_id` for keys.

hash&.key?(object_id)
^^^^^^^^^^^^^^^^^^^^^ Lint/HashCompareByIdentity: Use `Hash#compare_by_identity` instead of using `object_id` for keys.

memo[foo.object_id] ||= :value
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Lint/HashCompareByIdentity: Use `Hash#compare_by_identity` instead of using `object_id` for keys.

memo[object_id] ||= :value
^^^^^^^^^^^^^^^^^^^^^^^^^^ Lint/HashCompareByIdentity: Use `Hash#compare_by_identity` instead of using `object_id` for keys.
