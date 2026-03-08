foo.object_id == bar.object_id
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Lint/IdentityComparison: Use `equal?` instead of `==` when comparing `object_id`.

foo.object_id != bar.object_id
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Lint/IdentityComparison: Use `!equal?` instead of `!=` when comparing `object_id`.

x.object_id == y.object_id
^^^^^^^^^^^^^^^^^^^^^^^^^^ Lint/IdentityComparison: Use `equal?` instead of `==` when comparing `object_id`.

@foo.object_id != @bar.object_id
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Lint/IdentityComparison: Use `!equal?` instead of `!=` when comparing `object_id`.
