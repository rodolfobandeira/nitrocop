foo(1 , 2)
     ^ Layout/SpaceBeforeComma: Space found before comma.
x = [1 , 2 , 3]
      ^ Layout/SpaceBeforeComma: Space found before comma.
          ^ Layout/SpaceBeforeComma: Space found before comma.
bar(a , b)
     ^ Layout/SpaceBeforeComma: Space found before comma.
yield  1 , 2
        ^ Layout/SpaceBeforeComma: Space found before comma.
next  1 ,
       ^ Layout/SpaceBeforeComma: Space found before comma.
  2
break  1  , 2
        ^^ Layout/SpaceBeforeComma: Space found before comma.
