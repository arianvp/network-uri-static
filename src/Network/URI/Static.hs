{-# LANGUAGE RecordWildCards, TemplateHaskell, ViewPatterns #-}

module Network.URI.Static
    ( staticURI
    , uri
    ) where

import Language.Haskell.TH (unType)
import Language.Haskell.TH.Lib (TExpQ)
import Language.Haskell.TH.Quote (QuasiQuoter(..))
import Language.Haskell.TH.Syntax (Lift(..))
import Network.URI (URI(..), URIAuth(..), parseURI)

-- $setup
-- >>> :set -XTemplateHaskell
-- >>> :set -XQuasiQuotes

-- | 'staticURI' parses a specified string at compile time
--   and return an expression representing the URI when it's a valid URI.
--   Otherwise, it emits an error.
--
-- >>> $$(staticURI "http://www.google.com/")
-- http://www.google.com/
--
-- >>> $$(staticURI "http://www.google.com/##")
-- <BLANKLINE>
-- <interactive>...
-- ... Invalid URI: http://www.google.com/##
-- ...
staticURI :: String -- ^ String representation of a URI
          -> TExpQ URI -- ^ URI
staticURI (parseURI -> Just uri) = [|| uri ||]
staticURI uri = fail $ "Invalid URI: " ++ uri

instance Lift URI where
    lift (URI {..}) = [| URI {..} |]

instance Lift URIAuth where
    lift (URIAuth {..}) = [| URIAuth {..} |]

-- | 'uri' is a quasi quoter for 'staticURI'.
--
-- >>> [uri|http://www.google.com/|]
-- http://www.google.com/
--
-- >>> [uri|http://www.google.com/##|]
-- <BLANKLINE>
-- <interactive>...
-- ... Invalid URI: http://www.google.com/##
-- ...
uri :: QuasiQuoter
uri = QuasiQuoter {
    quoteExp = fmap unType . staticURI,
    quotePat = undefined,
    quoteType = undefined,
    quoteDec = undefined
}
