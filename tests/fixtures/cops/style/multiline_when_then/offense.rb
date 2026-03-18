case foo
when bar then
         ^^^^ Style/MultilineWhenThen: Do not use `then` for multiline `when` statement.
end

case foo
when bar then
         ^^^^ Style/MultilineWhenThen: Do not use `then` for multiline `when` statement.
  do_something
end

case foo
when bar then
         ^^^^ Style/MultilineWhenThen: Do not use `then` for multiline `when` statement.
  do_something1
  do_something2
end

case foo
when bar, baz then
              ^^^^ Style/MultilineWhenThen: Do not use `then` for multiline `when` statement.
end

# when `then` is on a separate line from `when`
case foo
when bar
  then do_something
  ^^^^ Style/MultilineWhenThen: Do not use `then` for multiline `when` statement.
end

case bookmarkable
when "Work"
  then work_bookmarks_path(bookmarkable)
  ^^^^ Style/MultilineWhenThen: Do not use `then` for multiline `when` statement.
when "ExternalWork"
  then external_work_bookmarks_path(bookmarkable)
  ^^^^ Style/MultilineWhenThen: Do not use `then` for multiline `when` statement.
when "Series"
  then series_bookmarks_path(bookmarkable)
  ^^^^ Style/MultilineWhenThen: Do not use `then` for multiline `when` statement.
end
