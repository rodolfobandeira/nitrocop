x.match?(/foo\z/)
^^^^^^^^^^^^^^^^^ Performance/EndWith: Use `end_with?` instead of a regex match anchored to the end of the string.
str.match?(/bar\z/)
^^^^^^^^^^^^^^^^^^^ Performance/EndWith: Use `end_with?` instead of a regex match anchored to the end of the string.
name.match?(/rb\z/)
^^^^^^^^^^^^^^^^^^^ Performance/EndWith: Use `end_with?` instead of a regex match anchored to the end of the string.
# =~ with regex on the right
str =~ /abc\z/
^^^^^^^^^^^^^^ Performance/EndWith: Use `end_with?` instead of a regex match anchored to the end of the string.
# =~ with regex on the left (reversed)
/icc\z/ =~ config
^^^^^^^^^^^^^^^^^^ Performance/EndWith: Use `end_with?` instead of a regex match anchored to the end of the string.
/_content\z/ =~ name
^^^^^^^^^^^^^^^^^^^^ Performance/EndWith: Use `end_with?` instead of a regex match anchored to the end of the string.
/_new\z/ =~ event
^^^^^^^^^^^^^^^^^^ Performance/EndWith: Use `end_with?` instead of a regex match anchored to the end of the string.
# Escaped metacharacters
str.match?(/\)\z/)
^^^^^^^^^^^^^^^^^^ Performance/EndWith: Use `end_with?` instead of a regex match anchored to the end of the string.
str.match?(/\.\z/)
^^^^^^^^^^^^^^^^^^ Performance/EndWith: Use `end_with?` instead of a regex match anchored to the end of the string.
str.match?(/\$\z/)
^^^^^^^^^^^^^^^^^^ Performance/EndWith: Use `end_with?` instead of a regex match anchored to the end of the string.
# .match (without ?)
str.match(/abc\z/)
^^^^^^^^^^^^^^^^^^ Performance/EndWith: Use `end_with?` instead of a regex match anchored to the end of the string.
/abc\z/.match(str)
^^^^^^^^^^^^^^^^^^ Performance/EndWith: Use `end_with?` instead of a regex match anchored to the end of the string.
