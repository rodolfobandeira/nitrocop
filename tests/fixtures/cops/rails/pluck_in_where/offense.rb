Post.where(user_id: User.pluck(:id))
                         ^^^^^ Rails/PluckInWhere: Use `select` instead of `pluck` within `where` query method.

Comment.where(post_id: Post.pluck(:id))
                            ^^^^^ Rails/PluckInWhere: Use `select` instead of `pluck` within `where` query method.

Order.where(customer_id: Customer.pluck(:id))
                                  ^^^^^ Rails/PluckInWhere: Use `select` instead of `pluck` within `where` query method.

Post.where(user_id: User.active.ids)
                                ^^^ Rails/PluckInWhere: Use `select(:id)` instead of `ids` within `where` query method.

Post.where.not(user_id: User.active.pluck(:id))
                                    ^^^^^ Rails/PluckInWhere: Use `select` instead of `pluck` within `where` query method.

Post.where.not(user_id: User.active.ids)
                                    ^^^ Rails/PluckInWhere: Use `select(:id)` instead of `ids` within `where` query method.

Post.rewhere('user_id IN (?)', User.active.pluck(:id))
                                           ^^^^^ Rails/PluckInWhere: Use `select` instead of `pluck` within `where` query method.

Post.rewhere('user_id IN (?)', User.active.ids)
                                           ^^^ Rails/PluckInWhere: Use `select(:id)` instead of `ids` within `where` query method.
