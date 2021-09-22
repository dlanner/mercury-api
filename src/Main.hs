{-# LANGUAGE GADTs                      #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE MultiParamTypeClasses      #-}
{-# LANGUAGE OverloadedStrings          #-}
{-# LANGUAGE QuasiQuotes                #-}
{-# LANGUAGE TemplateHaskell            #-}
{-# LANGUAGE TypeFamilies               #-}
{-# LANGUAGE DerivingStrategies         #-}
{-# LANGUAGE StandaloneDeriving         #-}
{-# LANGUAGE UndecidableInstances       #-}
{-# LANGUAGE DataKinds                  #-}
{-# LANGUAGE FlexibleInstances          #-}
{-# LANGUAGE ViewPatterns               #-}
{-# LANGUAGE ScopedTypeVariables        #-}

module Main where

import Database.Persist
import Database.Persist.Postgresql
import Database.Persist.TH
import Yesod
import Data.Yaml.Config (loadYamlSettings, useEnv)

share [mkPersist sqlSettings, mkMigrate "migrateAll"] [persistLowerCase|
Cat json
    name String
    pictureUrl String
    deriving Show
|]

data App = App
    { persistConfig :: PostgresConf
    , connPool      :: ConnectionPool
    }

instance Yesod App
instance YesodPersist App where
    type YesodPersistBackend App = SqlBackend
    runDB = defaultRunDB persistConfig connPool
instance YesodPersistRunner App where
    getDBRunner = defaultGetDBRunner connPool

mkYesod "App" [parseRoutes|
/cats CatsR GET POST
/cats/#CatId CatR GET
|]

getCatR :: CatId -> Handler Value
getCatR catId = do
    cat <- runDB $ get404 catId
    returnJson cat

getCatsR :: Handler Value
getCatsR = do
    cats :: [Entity Cat] <- runDB $ selectList [] []
    returnJson cats

postCatsR :: Handler Value
postCatsR = do
    cat <- requireCheckJsonBody :: Handler Cat
    catId <- runDB $ insert cat
    returnJson catId

pgConf :: IO PostgresConf
pgConf = loadYamlSettings ["config/database.yml"] [] useEnv

main :: IO ()
main = do
    conf <- pgConf
    pool <- createPoolConfig conf
    flip runSqlPersistMPool pool $ do
        runMigration migrateAll

    warp 3000 App
        { persistConfig = conf
        , connPool      = pool
        }
