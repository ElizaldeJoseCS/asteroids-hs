{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards #-}

module Game (run) where

import Control.Monad (unless)
import Linear
import SDL (WindowConfig (..), ($=))
import qualified SDL

windowConfig :: WindowConfig
windowConfig =
  SDL.defaultWindow
    { windowHighDPI = True,
      windowGraphicsContext = SDL.OpenGLContext SDL.defaultOpenGL,
      windowPosition = SDL.Centered
    }

delta :: Double
delta = 0.0

-- date structure to try to keep track of the game state so we dont have the weird time issues in our game loops (if someone has a faster computer it would run the game faster and physics can get weird, so we try to avoid this)
data GameState
  = GameState
  { gameStateRenderer :: SDL.Renderer,
    gameStateTicks :: Double,
    gameStateCurrentTime :: Double,
    gameStateAccumulator :: Double
  }
  deriving (Eq, Show)

initGameState :: SDL.Renderer -> IO GameState
initGameState renderer =
    GameState
        <$> pure renderer -- gameStateRenderer
        <*> pure 0.0 -- gameStateTicks
        <*> SDL.time -- gameStateCurrentTime
        <*> pure 0.0 -- gameStateAccumulator

run :: IO ()
run = do
    -- setting up the window
    SDL.initializeAll

    window <- SDL.createWindow "Asteroids" windowConfig
    renderer <- SDL.createRenderer window (-1) SDL.defaultRenderer
    state <- initGameState renderer

    loop state

    SDL.destroyRenderer renderer
    SDL.destroyWindow window
    SDL.quit
    
-- main loop that constantly polling events and rendering things on the screen
loop :: GameState -> IO ()
loop state@GameState {..} = do
    events <- SDL.pollEvents
    let quit = any isQuit events

    newTime <- SDL.time 
    let frameTime   = newTime - gameStateCurrentTime -- total amount of time that has elasped between frames
        state'      = update state { gameStateCurrentTime = newTime, 
                            gameStateAccumulator = gameStateAccumulator + frameTime
                          }
    render gameStateRenderer
    unless quit (loop state')

update :: GameState -> GameState
update state@GameState {..} = 
    let nextState = state { gameStateAccumulator = gameStateAccumulator - delta
                            , gameStateTicks = gameStateTicks + delta
                          } 
    in
        if gameStateAccumulator >= delta
            then state
            else update nextState
-- rendering logic
render :: SDL.Renderer -> IO ()
render renderer = do
  SDL.rendererDrawColor renderer $= V4 0 0 0 255
  SDL.clear renderer
  SDL.present renderer

-- checking if player pressed q to exit out the window (KeycodeQ)
isQuit :: SDL.Event -> Bool
isQuit e = case SDL.eventPayload e of
  SDL.QuitEvent -> True
  SDL.KeyboardEvent k ->
    SDL.keyboardEventKeyMotion k == SDL.Pressed
      && SDL.keysymKeycode (SDL.keyboardEventKeysym k) == SDL.KeycodeQ
  _ -> False
