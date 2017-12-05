# Pictionary Pixels
Multiplayer drawing and guessing game as an iOS app using real-time wireless communication.

<p align="center">
  <img src="https://github.com/TrinaKat/Pictionary-Pixels/blob/master/Pictionary-Media/launchscreen.png">
</p>

## Meet Team 2K3X
* **_K_**atrina Wijaya
* **_K_**atie Luangkote
* Jason **_X_**u
* Jennifer **_X_**u
* Yun **_X_**u

## How to Play
Clone this git repo and build/deploy to your device(s)! It probably won't be released to the App Store :(

## About the Game
Pictionary Pixels is a fun, mobile twist on the game Pictionary. When out and about with friends, Pictionary is easily accessible on your phones with no need for any paper or pens! 

The game supports from 2-6 players. Rather than the team-based approach of Pictionary, the app has one drawer during each round and everyone else is a guesser. To make it fair, at the start of the game players are randomly assigned to a static ordering that is followed for the order of who is drawing. 

Once everyone has opened the app and joined the game (just by being in the same area on the same network), any player can click the `Start Game` button to advance everyone's app to the next page.

<h3 align="center"><strong>Joining the Game</strong></h3>

<p align="center">
  <img src="https://github.com/TrinaKat/Pictionary-Pixels/blob/master/Pictionary-Media/joinGame1.gif">
  &nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp
  <img src="https://github.com/TrinaKat/Pictionary-Pixels/blob/master/Pictionary-Media/joinGame2.gif">
</p>

After conferring with other players, any player can choose which point value to play to. In other words, play continues until someone wins that many points! 

<h3 align="center"><strong>Starting the Game</strong></h3>
<p align="center">
  <img src="https://github.com/TrinaKat/Pictionary-Pixels/blob/master/Pictionary-Media/startGame1.gif">
  &nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp
  <img src="https://github.com/TrinaKat/Pictionary-Pixels/blob/master/Pictionary-Media/startGame2.gif">
  &nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp
  <img src="https://github.com/TrinaKat/Pictionary-Pixels/blob/master/Pictionary-Media/startGame3.gif">
</p>

Pictionary Pixels is a round-based game, where each round there is a drawer and 1-5 guessers. The drawing is displayed on all screens with the drawer having options for brush colors and the guessers having a 12-letter letter set to help them guess what word is being drawn. 

<h3 align="center"><strong>Playing the Game</strong></h3>
<p align="center">
  <img src="https://github.com/TrinaKat/Pictionary-Pixels/blob/master/Pictionary-Media/playGameG1.gif">
  &nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp
  <img src="https://github.com/TrinaKat/Pictionary-Pixels/blob/master/Pictionary-Media/playGameD.gif">
  &nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp
  <img src="https://github.com/TrinaKat/Pictionary-Pixels/blob/master/Pictionary-Media/playGameG2.gif">
</p>

Whoever guesses the word correctly first wins a point for that round. If the 30s timer runs out before anyone manages to guess correctly, no one wins a point for that round! The next round, the next player in the pre-determined ordering becomes the drawer and everyone else gets ready to guess! 

<h3 align="center"><strong>Beat the Clock!</strong></h3>
<p align="center">
  <img src="https://github.com/TrinaKat/Pictionary-Pixels/blob/master/Pictionary-Media/timeGame1.gif">
  &nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp
  <img src="https://github.com/TrinaKat/Pictionary-Pixels/blob/master/Pictionary-Media/timeGame2.gif">
  &nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp
  <img src="https://github.com/TrinaKat/Pictionary-Pixels/blob/master/Pictionary-Media/timeGame3.gif">
</p>

The cycle continues until one player reaches the score threshold, and then the players can choose to stop playing or start over by choosing another point value to play to!

<h3 align="center"><strong>Winning the Game</strong></h3>
<p align="center">
  <img src="https://github.com/TrinaKat/Pictionary-Pixels/blob/master/Pictionary-Media/gameOver1.gif">
  &nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp
  <img src="https://github.com/TrinaKat/Pictionary-Pixels/blob/master/Pictionary-Media/gameOver2.gif">
  &nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp
  <img src="https://github.com/TrinaKat/Pictionary-Pixels/blob/master/Pictionary-Media/gameOver3.gif">
</p>

## Features / Extended Instructions
#### Points View
Choose how many points to play up to (5, 10, 20). Whoever wins that many points through correct guesses wins the game!

#### Drawing View
Draw the given word on the screen! Use the `Clear All` button to clear the screen, or the `Eraser` to remove brush strokes! Use the colors to make your drawing easier to understand. Be sure to finish before time is up!

#### Guessing View
Given 12 letters, try to guess what the drawing on the screen is before time is up! If you hit a wrong letter, you can `Delete` that letter or `Clear` all the letters if you feel you need to start over. Hurry and guess the word before the other players do! The correct word is displayed at the end of each round so everyone knows what it was.

#### Game Over
Whoever reaches the number of points needed to win first wins the game! The winner will be displayed on all screens and then players will be redirected to the Points View where they can start another game!

## How it Works 
Through Apple's MultipeerConnectivity framework, nearby devices can connect via infrastructure Wi-Fi networks, peer-to-peer Wi-Fi, and Bluetooth personal area networks over which devices can communicate to make Pictionary Pixels possible! Devices send and respond to messages depending on what view they are on and what the message contains. 

Issues with connectivity can result in bugs and unsynchronized devices, resulting in poor gameplay. In this case, try restarting the game (double tap home button and swipe up on Pictionary Pixels and open the app again). As this game is built on the idea of devices in the same area sending data 

In order to update the word set without having to change anything with the app code, the app pulls JSON data from a web server over Wi-Fi/cellular data and uses that data to choose random words for gameplay!
