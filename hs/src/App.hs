{-# LANGUAGE ForeignFunctionInterface #-}
module App where

import Foreign.C.String (CString)
import Foreign.Ptr (FunPtr, Ptr)

import Language.Javascript.JSaddle.CLib

foreign export ccall appMain :: FunPtr (CString -> IO ()) -> IO (Ptr NativeCallbacks)

appMain :: FunPtr (CString -> IO ()) -> IO (Ptr NativeCallbacks)
appMain = jsaddleInit (return ())
