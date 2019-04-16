#!/usr/bin/env runhaskell

-- main = readLn >>= print . subsequences

main = translateLn <$> getLine >>= putStrLn

translateLn :: String -> String
translateLn = unwords . map t . words

t :: String -> String -- t(ranslate)

-- historical accurate naming
-- Robert Recorde and His Invention of the "Equals Sign" in 1557
t "=" = "(| = is equal too |)" -- The Whetstone of Witte - Robert Recorde (1557)

-- proposed namings
-- src http://stackoverflow.com/a/7747115/1091457
t ">>=" = "(| >>= bind |)"
t "*>"  = "(| *> then |)"
t "->"  = "(| -> to |)"              -- a -> b: a to b
t "<$"  = "(| <$ map-replace by |)"  -- 0 <$ f: "f map-replace by 0"
t "<*>" = "(| <*> ap(ply) |)"        -- (as it is the same as Control.Monad.ap)
t "!!"  = "(| !! index |)"
t "!"   = "(| ! index/strict |)"     -- a ! b: "a index b", foo !x: foo strict x
t "<|>" = "(| <|> or/alternative |)" -- expr <|> term: "expr or term"
t "[]"  = "(| [] empty list |)"
t ":"   = "(| : cons |)"
t "\\"  = "(| \\ lambda |)"
t "@"   = "(| @ as |)"               -- go ll@(l:ls): go ll as l cons ls
t "~"   = "(| ~ lazy |)"             -- go ~(a,b): go lazy pair a, b
-- t ">>"  = "(| >> then |)"
-- t "<-"  = "(| <- bind |)"               -- (as it desugars to >>=)
-- t "<$>" = "(| <$> (f)map |)"
-- t "$"   = ""                            -- (none, just as " " [whitespace])
-- t "."   = "(| . pipe to |)"             -- a . b: "b pipe-to a"
-- t "++"  = "(| ++ concat/plus/append |)"
-- t "::"  = "(| :: ofType/as |)"          -- f x :: Int: f x of type Int

-- additional names
-- src http://stackoverflow.com/a/16801782/1091457
t "|"   = "(| | such that |)"
t "<-"  = "(| <- is drawn from |)"
t "::"  = "(| :: is of type |)"
t "_"   = "(| _ whatever |)"
t "++"  = "(| ++ append |)"
t "=>"  = "(| => implies |)"
t "."   = "(| . compose |)"
t "<=<" = "(| <=< left fish |)"
t ">=>" = "(| >=> right fish |)"
-- t "="   = "(| = is defined as |)"
-- t "<$>" = "(| <$> (f)map |)"

-- src http://stackoverflow.com/a/7747149/1091457
t "$"   = "(| $ of |)" 

-- src http://stackoverflow.com/questions/28471898/colloquial-terms-for-haskell-operators-e-g?noredirect=1&lq=1#comment45268311_28471898
t ">>"  = "(| >> sequence |)"
-- t "<$>" = "(| <$> infix fmap |)"
-- t ">>=" = "(| >>= bind |)"

--------------
-- Examples --
--------------

-- "(:) <$> Just 3 <*> Just [4]" 
-- meaning "Cons applied to just three applied to just list with one element four"
t "(:)"  = "(| (:) Cons |)"
t "Just" = "(| Just just |)"
t "<$>"  = "(| <$> applied to |)"
t "3"    = "(| 3 three |)" -- this is might go a bit too far
t "[4]"  = "(| [4] list with one element four |)" -- this one too, let's just see where this gets us

-- additional expressions to translate from
-- src http://stackoverflow.com/a/21322952/1091457
-- delete (0, 0) $ (,) <$> [-1..1] <*> [-1..1]
-- (,) <$> [-1..1] <*> [-1..1] & delete (0, 0)
-- liftA2 (,) [-1..1] [-1..1] & delete (0, 0)
t "(,)" = "(| (,) tuple constructor |)"
t "&"   = "(| & then |)" -- flipped `$`

-- everything not matched until this point stays at it is
t x = x