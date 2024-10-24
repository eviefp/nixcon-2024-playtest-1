module Main where

import Control.Alternative ((<$>))
import Control.Apply ((<*>))
import Data.Int (fromString)
import Data.Maybe (maybe)
import HTTPurple (class Generic, RouteDuplex', ServerM, badRequest, mkRoute, ok, segment, serve, string, (/))
import Prelude (show, ($), (+))
import Routing.Duplex.Generic as RG

data Route
  = Home
  | Add String String

derive instance Generic Route _

route :: RouteDuplex' Route
route = mkRoute
  { "Home": RG.noArgs
  , "Add": "add" / string segment / string segment
  }

main :: ServerM
main =
  serve { port: 8080 } { route, router }
  where
  router { route: Home } = ok $ "hi :)"
  router { route: Add a b } = maybe (badRequest "") (\r -> ok $ show r) ((+) <$> fromString a <*> fromString b)
