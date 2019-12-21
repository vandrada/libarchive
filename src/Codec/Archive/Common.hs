module Codec.Archive.Common ( actFree
                            , actFreeCallback
                            , hmemcpy
                            ) where

import           Codec.Archive.Foreign
import           Control.Composition    ((.**))
import           Control.Monad          (void)
import           Control.Monad.IO.Class (MonadIO (..))
import           Foreign.C.Types        (CSize (..))
import           Foreign.Ptr

foreign import ccall memcpy :: Ptr a -- ^ Destination
                            -> Ptr b -- ^ Source
                            -> CSize -- ^ Size
                            -> IO (Ptr a) -- ^ Pointer to destination

hmemcpy :: Ptr a -> Ptr b -> CSize -> IO ()
hmemcpy = void .** memcpy

-- | Do something with an 'Archive' and then free it
actFree :: MonadIO m
        => (Ptr Archive -> m a)
        -> Ptr Archive
        -> m a
actFree fact a = fact a <* liftIO (archiveFree a)

actFreeCallback :: MonadIO m
                => (Ptr Archive -> m a)
                -> (Ptr Archive, IO ()) -- ^ 'Ptr' to an 'Archive' and an 'IO' action to clean up when done
                -> m a
actFreeCallback fact (a, freeAct) = fact a <* liftIO (archiveFree a) <* liftIO freeAct
