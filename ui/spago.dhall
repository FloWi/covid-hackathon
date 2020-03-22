{-
Welcome to a Spago project!
You can edit this file as you like.
-}
{ name = "my-project"
, dependencies =
    [ "aff-promise"
    , "affjax"
    , "console"
    , "effect"
    , "globals"
    , "psci-support"
    , "react-basic-hooks"
    , "simple-json"
    ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs", "test/**/*.purs" ]
}
