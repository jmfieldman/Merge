Merge
=====

<a href="http://www.fieldman.org/merge">Website</a>

<a href="https://itunes.apple.com/us/app/merge-game-about-togetherness/id849818479">App Store</a>

I stumbled across <a href="http://en.wikipedia.org/wiki/2048_(video_game)">2048</a> while browsing r/programming. It was a pretty simple game that was getting traction, and I thought it would fun to make as an iPhone app (before I realized it was based on existing, similar games).

I decided it would be a good time to experiment with the new iOS 7 sliding animations, and CAShapeLayer path animations. Instead of numbers, I was going to make the squares be polygons that mutated into other polygons.

Halfway through development, I felt the game I was making was lame. I arcadified it and make it a real-time tetris-like goal in which you need to keep the board from filling up.  I also got impatient and started throwing spaghetti code everywhere.

I also realized that the game was too easy/boring with just polygons. I put in ice blocks (that couldn't merge) and bombs (to help you clear ice blocks). This also let me experiment with CAEmitterLayer stuff for bomb smoke.
