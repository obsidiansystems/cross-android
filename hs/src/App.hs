{-# LANGUAGE ForeignFunctionInterface #-}
{-# LANGUAGE OverloadedStrings #-}
module App where

import Control.Monad.IO.Class
import Foreign.C.String (CString)
import Foreign.Ptr (FunPtr, Ptr)

import Language.Javascript.JSaddle.CLib
import Reflex.Dom.Core

import System.IO

foreign export ccall appMain :: FunPtr (CString -> IO ()) -> IO (Ptr NativeCallbacks)

appMain :: FunPtr (CString -> IO ()) -> IO (Ptr NativeCallbacks)
appMain evalJs = do
  hSetBuffering stdout LineBuffering
  res <- flip jsaddleInit evalJs $ do
    liftIO $ hPutStrLn stdout "YOUR FACE"
    mainWidget $ do
      text "Hello World!"
  return res

