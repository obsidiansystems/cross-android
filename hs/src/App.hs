{-# LANGUAGE ForeignFunctionInterface #-}
module App where

foreign export ccall "hello_world" helloWorld :: IO ()

helloWorld :: IO ()
helloWorld = return ()
