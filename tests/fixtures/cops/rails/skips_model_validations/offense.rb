user.update_attribute(:name, "new")
     ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Rails/SkipsModelValidations: Avoid using `update_attribute` because it skips validations.
user.touch
     ^^^^^ Rails/SkipsModelValidations: Avoid using `touch` because it skips validations.
user.update_column(:name, "new")
     ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Rails/SkipsModelValidations: Avoid using `update_column` because it skips validations.
User.update_all(name: "new")
     ^^^^^^^^^^^^^^^^^^^^^^^ Rails/SkipsModelValidations: Avoid using `update_all` because it skips validations.
record.toggle!(:active)
       ^^^^^^^^^^^^^^^^ Rails/SkipsModelValidations: Avoid using `toggle!` because it skips validations.
User.increment_counter(:views_count, user.id)
     ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Rails/SkipsModelValidations: Avoid using `increment_counter` because it skips validations.
User.decrement_counter(:views_count, user.id)
     ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Rails/SkipsModelValidations: Avoid using `decrement_counter` because it skips validations.
User.update_counters(user.id, views_count: 1)
     ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Rails/SkipsModelValidations: Avoid using `update_counters` because it skips validations.
# touch_all is also a forbidden method
User.touch_all
     ^^^^^^^^^ Rails/SkipsModelValidations: Avoid using `touch_all` because it skips validations.
# No-receiver calls are flagged (implicit self in model methods)
insert(attributes, returning: false)
^^^^^^ Rails/SkipsModelValidations: Avoid using `insert` because it skips validations.
insert(attributes, unique_by: :username)
^^^^^^ Rails/SkipsModelValidations: Avoid using `insert` because it skips validations.
insert(attributes, returning: false, unique_by: :username)
^^^^^^ Rails/SkipsModelValidations: Avoid using `insert` because it skips validations.
# Methods without required arguments are flagged even without args
User.touch
     ^^^^^ Rails/SkipsModelValidations: Avoid using `touch` because it skips validations.
User.touch_all
     ^^^^^^^^^ Rails/SkipsModelValidations: Avoid using `touch_all` because it skips validations.
# Safe navigation calls are also flagged
user&.update_attribute(:website, 'example.com')
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Rails/SkipsModelValidations: Avoid using `update_attribute` because it skips validations.
