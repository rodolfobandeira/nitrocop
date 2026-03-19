create :user
^^^^^^ FactoryBot/ConsistentParenthesesStyle: Prefer method call with parentheses
build :user
^^^^^ FactoryBot/ConsistentParenthesesStyle: Prefer method call with parentheses
build_list :user, 10
^^^^^^^^^^ FactoryBot/ConsistentParenthesesStyle: Prefer method call with parentheses
create_list :user, 10
^^^^^^^^^^^ FactoryBot/ConsistentParenthesesStyle: Prefer method call with parentheses
build_stubbed :user
^^^^^^^^^^^^^ FactoryBot/ConsistentParenthesesStyle: Prefer method call with parentheses

[
  (build :discord_server_role_response, position: 1),
   ^^^^^ FactoryBot/ConsistentParenthesesStyle: Prefer method call with parentheses
  (build :discord_server_role_response, position: 2),
   ^^^^^ FactoryBot/ConsistentParenthesesStyle: Prefer method call with parentheses
]

# Factory call inside parentheses in hash value (assoc)
create :item, owner: (create :user)
^^^^^^ FactoryBot/ConsistentParenthesesStyle: Prefer method call with parentheses
                      ^^^^^^ FactoryBot/ConsistentParenthesesStyle: Prefer method call with parentheses

# Factory call inside parentheses in or expression
x = foo || (create :user)
            ^^^^^^ FactoryBot/ConsistentParenthesesStyle: Prefer method call with parentheses

# Factory call inside assignment in if body
if condition
  result = create :item
           ^^^^^^ FactoryBot/ConsistentParenthesesStyle: Prefer method call with parentheses
end

# Factory call inside lambda body (lambda clears ambiguity)
trigger: -> { create :user }
              ^^^^^^ FactoryBot/ConsistentParenthesesStyle: Prefer method call with parentheses
in_stage(stage, trigger: -> { create :item })
                              ^^^^^^ FactoryBot/ConsistentParenthesesStyle: Prefer method call with parentheses
