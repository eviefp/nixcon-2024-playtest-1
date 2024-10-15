module Main where

import HTTPurple (class Generic, RouteDuplex', ServerM, mkRoute, ok, segment, serve, (/))
import Routing.Duplex.Generic as RG

import Prelude (($), (<>))

data Route = Default

derive instance Generic Route _

route :: RouteDuplex' Route
route = mkRoute
  { "Default": RG.noArgs
  }

main :: ServerM
main =
  serve { port: 8080 } { route, router }
  where
  router { route: Default } = ok $ ""
