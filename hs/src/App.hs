{-# LANGUAGE ForeignFunctionInterface #-}
{-# LANGUAGE OverloadedStrings #-}
module App where

import Foreign.C.String (CString)
import Foreign.Ptr (FunPtr, Ptr)

import Language.Javascript.JSaddle.CLib
import Reflex.Dom.Core

foreign export ccall appMain :: FunPtr (CString -> IO ()) -> IO (Ptr NativeCallbacks)

appMain :: FunPtr (CString -> IO ()) -> IO (Ptr NativeCallbacks)
appMain = jsaddleInit $ mainWidget $ do
  text "Hello World!"
