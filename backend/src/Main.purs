module Main where

import Control.Alternative ((<$>))
import Control.Apply ((<*>))
import Control.Bind ((>>=))
import Data.Function ((<<<))
import Data.Int (fromString)
import Data.Maybe (maybe)
import Data.Semigroup ((<>))
import Data.String as String
import Data.UUID as UUID
import Effect.Class (liftEffect)
import HTTPurple (class Generic, RouteDuplex', ServerM, badRequest, mkRoute, ok, segment, serve, string, (/))
import Node.Buffer.Class as Buffer
import Node.ChildProcess as Process
import Node.Encoding as Encoding
import Prelude (show, ($), (*), (+))
import Routing.Duplex.Generic as RG

data Route
  = Home
  | Add String String
  | Mult String String
  | Cowsay String
  | Uuid

derive instance Generic Route _

route :: RouteDuplex' Route
route = mkRoute
  { "Home": RG.noArgs
  , "Add": "add" / string segment / string segment
  , "Mult": "mult" / string segment / string segment
  , "Cowsay": "cowsay" / string segment
  , "Uuid": "uuid" / RG.noArgs
  }

main :: ServerM
main =
  serve { port: 8080 } { route, router }
  where
  router { route: Home } = ok $ "hi :)"
  router { route: Add a b } = maybe (badRequest "") (\r -> ok $ show r) ((+) <$> fromString a <*> fromString b)
  router { route: Mult a b } = maybe (badRequest "") (\r -> ok $ show r) ((*) <$> fromString a <*> fromString b)
  router { route: Cowsay message } =
    liftEffect (Process.execSync ("cowsay " <> message) >>= Buffer.toString Encoding.ASCII) >>= ok <<< String.replaceAll (String.Pattern " \n") (String.Replacement "\n")
  router { route: Uuid } = liftEffect UUID.genUUID >>= ok <<< show
