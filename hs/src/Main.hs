{-# LANGUAGE ForeignFunctionInterface #-}
{-# LANGUAGE OverloadedStrings #-}
module Main where

import Control.Monad.IO.Class
import Foreign.C.String (CString)
import Foreign.Ptr (FunPtr, Ptr)
import Foreign.Storable (poke)

import Language.Javascript.JSaddle.CLib
import Reflex.Dom.Core

import System.IO

foreign export ccall appMain :: FunPtr (CString -> IO ()) -> Ptr AppCallbacks -> IO (Ptr NativeCallbacks)

appMain :: FunPtr (CString -> IO ()) -> Ptr AppCallbacks -> IO (Ptr NativeCallbacks)
appMain evalJs appCallbacksPtr = do
  hSetBuffering stdout LineBuffering
  res <- flip jsaddleInit evalJs $ mainWidget $ do
    text "Hello World!"
  return res

main :: IO ()
main = return ()
