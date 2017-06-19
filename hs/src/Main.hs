{-# LANGUAGE ForeignFunctionInterface #-}
{-# LANGUAGE OverloadedStrings #-}
module Main where

import Control.Concurrent
import Control.Monad
import Control.Monad.IO.Class
import Foreign.C.String (CString)
import Foreign.Ptr (FunPtr, Ptr)
import Foreign.Storable (poke)

import Language.Javascript.JSaddle.CLib
import Reflex.Dom.Core

import System.IO

--foreign export ccall appMain :: FunPtr (CString -> IO ()) -> Ptr AppCallbacks -> IO (Ptr NativeCallbacks)

foreign import ccall mainStarted :: Ptr NativeCallbacks -> IO ()

foreign import ccall evaluateJavascript :: CString -> IO ()

main :: IO ()
main = do
  hSetBuffering stdout LineBuffering
  res <- flip jsaddleInit evaluateJavascript $ mainWidget $ do
    text "Hello World!"
  mainStarted res
  forever $ threadDelay maxBound
  -- TODO: If I write @forever $ return ()@ instead of @forever $ threadDelay 1000000@, it crashes with an illegal operation; why?
