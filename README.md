# True Yellow

_Pokemon Yellow Version: Special Pikachu Edition_ was Nintendo's attempt to build on the groundwork of the first generation games, still beholden to the hardware constraints of their time. Their goal was to squash the obvious bugs and, more ambitiously, mirror the anime to some degree. Pokemon True Yellow attempts to take the baton and run farther, finding novel ways to emulate the anime even more. The key feature: an extended **chain follower** system. Misty wants her bike back--she'll be following you on your journey until she gets it (she'll never get it.) Brock defeated and his deadbeat father actually came home? He'll be right behind you.

This is a fork of [pret/pokeyellow](https://github.com/pret/pokeyellow).

## The Chain Follower System

The signature feature of True Yellow is the chain follower system. After defeating gym leaders, they join you on your journey, creating a party that walks together through the overworld:

```
[Brock] -> [Misty] -> [Pikachu] -> [You]
```

### Your Growing Party

- **Pikachu** - Your starter, always 1 step behind you
- **Misty** - Joins after you get your Pokedex from Oak
- **Brock** - Joins after earning the Boulder Badge, follows 3 steps behind

### Seamless Integration

The followers behave naturally in every situation:

- **Walking**: Followers form a smooth chain, speeding up to catch you if they fall behind
- **Ledge jumping**: Each follower hops the ledge in sequence with a satisfying arc
- **Spinning tiles**: The whole party spins together in sync
- **Doorways**: Followers arrange intelligently when entering/exiting buildings
- **Surfing & Biking**: Followers wait for you and rejoin when you return to walking
- **Talking**: Press A to chat with your companions

### Gym Leader Logic

The system handles the "two Mistys" problem elegantly - when you enter Cerulean Gym before defeating Misty, your follower Misty is hidden so the gym leader can appear at her spot. After the battle, the gym leader disappears and your companion Misty can reappear. Same logic applies to Brock in Pewter Gym.

## Technical Details

The follower system uses a **position trail** approach rather than command mirroring. When you move, your previous position is recorded in a trail buffer. Each follower walks toward their target position in that history, creating fluid synchronized movement without the 1-frame delays that plague simpler implementations.

For the full technical breakdown, see [engine/followers/README.md](engine/followers/README.md).

## Building

See [INSTALL.md](INSTALL.md) for setup instructions.

## Credits

Based on [pret/pokeyellow](https://github.com/pret/pokeyellow) - a disassembly of Pokemon Yellow.
