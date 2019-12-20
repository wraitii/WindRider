# WindRider

This is a FLOSS game inspired by Escape Velocity Nova, but in 3D™.  

Inspirations mainly taken from EV Nova, Sid Meier's Pirates and Crusader Kings. Some more ideas you'll find in `docs`
In particular, `Ramblings about what this game should be.txt` is a long but interesting (imo) read.

Uses Godot Engine (3.2) because I've decided that I wanted to actually try and make something playable this time. I've tried this as a pet project coding my own engine recently, but it's just too time-consuming :p

## Data
To function, the godot project needs a data/ folder at the root. You can find it over at https://github.com/wraitii/WindRider-data

## Done so far, in various quality levels:
- [x] simple editors
- [x] auto-aim and auto-intercept
- [x] weapons firing projectiles, and turreted weapons.
- [x] Ships have an actual hold, made of cells, that items can be stored in, with specific areas for engine parts and hardpoint.
  - This is one area where I'm taking a different road from the Escape Velocity concept of 'Mass' and 'Cargo Space'.
- [x] (very simple) AI ships that you can kill.
- [x] Basic architecture of a trait/event system
- [x] Functional commodity market (ish)
- [x] The outfitter is technically in there though probably broken at the moment of writing this.

## tentative TODO, vaguely ordered by what should be done next:
- [ ] Several pathfinding improvements -> letting player pick target systems, having a proper autopilot.
- [ ] AI improvements, such as some actual collision avoidance and/or pathing (ties in with pathfinding improvements).
- [ ] Many missions need to be added.
- [ ] Missiles of all kind and beam weapons.
- [ ] Trade needs to actually be useful.
- [ ] Add a bar, with a 'fighting' mechanic somewhat inspired by Sid Meier's Pirates -> So that you can bounty-hunt in bars.
  - Also this ought to tie in with danger in stations and such. Some places will be too dangerous to go.
  - Might have a low-sec and a high-sec bar in some stations.
- [ ] Add a boarding mechanic. Again, might do something like Sid Meier's Pirates to make it more fun (should probably be optional though).
- [ ] Have stations where you actually need to stop and jump zones that you actually need to go through.
- [ ] Expand the map.
- [ ] Add more 'governments', and actually have opinion do something.
- [ ] Write more of a story too.
- [ ] Actually simulate the outside world a bit better
- [ ] Add a lot of content. I need outfits, ships, stations, asteroids, weapons, things like that.
  - I actually might go and fetch some existing content from NAEV as a placeholder.
- [ ] Add sounds. Currently there exists a single 'pew' sound, which is actually a recording of me saying "whoosh".
- [ ] Add music. I ambition some actual tracks, and some procedural music generation.
- [ ] Ultimately the goal is to have _some_ procedural content. 
