{-
Welcome to a Spago project!
You can edit this file as you like.
-}
{ name = "telegram-bot"
, dependencies =
  [ "console"
  , "effect"
  , "node-fs"
  , "node-process"
  , "node-telegram-bot-api"
  , "psci-support"
  , "refs"
  ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs", "test/**/*.purs" ]
}
