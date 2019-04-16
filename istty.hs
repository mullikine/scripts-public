#!/usr/bin/env stack
-- stack --resolver lts-12.21 script
module Main where
 
-- https://rosettacode.org/wiki/Check_output_device_is_a_terminal#Haskell
-- requires the unix package
-- https://hackage.haskell.org/package/unix
import System.Posix.Terminal (queryTerminal)
import System.Posix.IO (stdOutput)
 
main :: IO ()
main = do
  istty <- queryTerminal stdOutput
  putStrLn
    (if istty
       then "stdout is tty"
       else "stdout is not tty")