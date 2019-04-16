#!/usr/bin/env stack
-- stack --resolver lts-12.21 script
{-# LANGUAGE OverloadedStrings #-}
import qualified Data.ByteString.Lazy.Char8 as L8
import           Network.HTTP.Simple

-- # disabled # stack --resolver lts-12.5 script
-- You can see what version of ghc it will use here: https://www.stackage.org/lts-12.21
-- These are the versions I have installed: $HOME/.stack/programs/x86_64-linux

main :: IO ()  
main = do
    response <- httpLBS "http://httpbin.org/get"

    putStrLn $ "The status code was: " ++
               show (getResponseStatusCode response)
    print $ getResponseHeader "Content-Type" response
    L8.putStrLn $ getResponseBody response