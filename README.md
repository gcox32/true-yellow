# Pokémon Yellow - Chain Follower System

This is a fork of [pret/pokeyellow](https://github.com/pret/pokeyellow) with a chain follower system that allows Misty and Brock to follow the player.

## Follower System

The system implements a **position trail** approach where followers target specific positions in the player's movement history:

- **Pikachu** follows 1 step behind (trail[0])
- **Misty** follows 2 steps behind (trail[1]) - requires `EVENT_MISTY_FOLLOWING_PLAYER`
- **Brock** follows 3 steps behind (trail[2]) - requires Boulder and Cascade badges

### How It Works

When the player moves, their previous position is recorded in a trail. Each follower checks their target position in the trail and moves toward it, creating a smooth chain effect. The system eliminates 1-frame delays to keep followers perfectly synchronized.

### Special Behavior

- **Cerulean Gym**: Follower Misty is hidden when `EVENT_BEAT_MISTY` is not set, allowing gym leader Misty to appear at her spot. After defeating her, gym leader Misty disappears and follower Misty can appear.
- **Pewter Gym**: Same logic applies to Brock - he disappears from the gym after being defeated.

## Building

See [INSTALL.md](INSTALL.md) for setup instructions.

## Credits

Based on [pret/pokeyellow](https://github.com/pret/pokeyellow) - a disassembly of Pokémon Yellow.
