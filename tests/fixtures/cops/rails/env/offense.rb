Rails.env.production?
^^^^^^^^^^^^^^^^^^^^^ Rails/Env: Use Feature Flags or config instead of `Rails.env`.
Rails.env.development? || Rails.env.test?
                          ^^^^^^^^^^^^^^^ Rails/Env: Use Feature Flags or config instead of `Rails.env`.
^^^^^^^^^^^^^^^^^^^^^^ Rails/Env: Use Feature Flags or config instead of `Rails.env`.
Rails.env.staging?
^^^^^^^^^^^^^^^^^^ Rails/Env: Use Feature Flags or config instead of `Rails.env`.
if Rails.env.local?
   ^^^^^^^^^^^^^^^^ Rails/Env: Use Feature Flags or config instead of `Rails.env`.
  do_something
end
