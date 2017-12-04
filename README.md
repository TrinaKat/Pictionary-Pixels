# Pictionary Pixels
Multiplayer drawing and guessing game as an iOS app using real-time wireless communication.

![Launch Screen](https://github.com/TrinaKat/Pictionary-Pixels/blob/multipeer/launchscreen.png)

![Launch Screen](../blob/multipeer/launchscreen.png | width=100)

## How to Play
Clone this git repo and build/deploy to your device(s)! We don't have any plans to release it to the App Store as of now. 

## About the Game
Pictionary Pixels is a fun, mobile twist on the game Pictionary. When out and about with friends, Pictionary is easily accessible on your phones with no need for any paper or pens! 

The game supports from 2-6 players. Rather than the team-based approach of Pictionary, the app has one drawer during each round and everyone else is a guesser. To make it fair, at the start of the game players are randomly assigned to a static ordering that is followed for the order of who is drawing. 

Once everyone has opened the app and joined the game (just by being in the same area on the same network), any player can click the `Start Game` button to advance everyone's app to the next page.

#### Joining the Game
INSERT JOINGAME.MOV

After conferring with other players, any player can choose which point value to play to. In other words, play continues until someone wins that many points! 

#### Starting the Game
INSERT STARTGAME.MOV

Pictionary Pixels is a round-based game, where each round there is a drawer and 1-5 guessers. The drawing is displayed on all screens with the drawer having options for brush colors and the guessers having a 12-letter letter set to help them guess what word is being drawn.

Whoever guesses the word correctly first wins a point for that round. If the 30s timer runs out before anyone manages to guess correctly, no one wins a point for that round! The next round, the next player in the pre-determined ordering becomes the drawer and everyone else gets ready to guess! 

#### Playing the Game
INSERT DRAWER.MOV GUESSER.MOV

The cycle continues until one player reaches the score threshold, and then the players can choose to stop playing or start over by choosing another point value to play to!

#### Winning the Game
INSERT GAMEOVER.MOV

## How it Works 
Through Apple's MultipeerConnectivity framework, nearby devices can connect via infrastructure Wi-Fi networks, peer-to-peer Wi-Fi, and Bluetooth personal area networks over which devices can communicate to make Pictionary Pixels possible! Devices send and respond to messages depending on what view they are on and what the message contains. Issues with connectivity can result in bugs and unsynchronized devices, resulting in poor gameplay. In this case, try restarting the game (double tap home button and swipe up on Pictionary Pixels and open the app again). As this game is built on the idea of devices in the same area sending data 

In order to update the wordset without having to change anything with the app code, the app pulls JSON data from a web server over Wi-Fi/cellular data and uses that data to choose random words for gameplay!
