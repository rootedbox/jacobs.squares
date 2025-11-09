# Jacobs Squares 🔲

A fun little pattern generator that creates wild fractals from super simple rules. Think cellular automata meets kaleidoscope!

## What's This All About? 🤔

So here's the deal - you start with a tiny 2×2 grid of black and white squares. Then magic happens:

- Each 2×2 chunk expands into a 4×4 chunk
- You control what goes in the middle (the corners stay the same)
- Do this a bunch of times and boom 💥 - crazy fractal patterns
- 16 rules total, one for each possible 2×2 corner combo

The best part? Just click around and see what happens. No math degree required 😎

## Getting Started 🚀

First, install everything:

```bash
npm run install-all
```

Then fire it up:

**Easy mode** (Mac/Linux):

```bash
./start-dev.sh
```

**Manual mode** (if you like to live dangerously):

```bash
# Terminal 1
npm run dev

# Terminal 2 (open a new one)
npm run frontend
```

Then hit up:

- Frontend: <http://localhost:4200> 👈 this is where ALL the fun is
- Backend: <http://localhost:3000> (just serves the app, all the magic happens in your browser!)

## How Does It Work? ⚙️

It's actually pretty straightforward:

1. **Start** with a 2×2 seed pattern (black/white squares)
2. **Find** each 2×2 chunk in your grid
3. **Match** those corners to one of your 16 rules
4. **Expand** it to 4×4 (corners stay, middle 12 cells follow your rule)
5. **Repeat** as many times as you want (up to 12 iterations!)

Each iteration doubles the size. So things get BIG fast 📈

## Size Chart 📏

Watch your pattern explode:

- Iteration 1: 4×4 (tiny)
- Iteration 2: 8×8 (still smol)
- Iteration 3: 16×16 (getting there)
- Iteration 4: 32×32 (nice)
- Iteration 5: 64×64 (pretty big)
- Iteration 6: 128×128 (whoa)
- Iteration 7: 256×256 (okay now we're talking)
- Iteration 8: 512×512 (262k cells! 🤯)
- Iteration 9-12: 1024×1024 up to 8192×8192 (absolute units)

At iteration 12 you're looking at over 67 MILLION cells. Your computer might need a coffee break ☕

## The Rules 📋

You get 16 rules total - one for every possible corner combo (2^4 = 16). Each rule is basically a 4×4 template where you control the middle 12 squares. The corners are locked to match what you're replacing.

Play around with them! There's no wrong answers, just interesting patterns 🎨

## Using It 🎮

**Seed (top right)**: Click the 2×2 grid to set your starting pattern. This is where it all begins.

**Rules (right side)**: Your 16 rules in a neat 4×4 grid. Click the cells to toggle black/white. The dimmed corners show what you're matching, the bright ones are what you control.

**Iterations (top left)**: Pick how many times to repeat (1-12). Higher = bigger = cooler (usually).

**Quick buttons**:

- **Clear**: Fill everything with black ⬛
- **Fill**: Empty everything to white ⬜
- **Random**: Surprise me! 🎲
- **Save/Load**: Keep your favorites

The pattern updates live as you click around. No "submit" button needed - just instant gratification ⚡

Pro tip: Start with iteration 8 and work backwards to see what you're doing.

## Performance Notes 🏎️

Everything runs in your browser (no server calls after the initial load!):

- Small patterns get chunky pixels for visibility
- Big patterns (iteration 7+) use Canvas rendering with 1px squares
- Rule changes happen instantly - the grid regenerates in the background
- We cache aggressively and use bit-shifting magic + chunked rendering to keep things snappy
- If iteration 12 takes a moment, that's because you're crunching through 67 million cells! ✨

The UI stays responsive even when generating huge patterns because we use `requestAnimationFrame` to break up the work.

## Tech Stack 🛠️

Built with:

- **Node.js + Express** for serving the app
- **Ember.js** (Octane) for the frontend (where ALL the computation happens)
- **HTML5 Canvas** for rendering large patterns efficiently
- **Swiss design** principles for the aesthetic (Josef Müller-Brockmann vibes)
- **Zero external libraries** for the core algorithm (just good old JavaScript + Uint8Arrays)

## Sharing Is Caring 🔗

Hit that "Copy Shareable URL" button to grab a link with your exact rule configuration. The whole rule set gets encoded into the URL as a 48-character hex string. Send it to friends, bookmark your favorites, whatever!

## Have Fun! 🎉

There's no "correct" way to use this. Just click around, see what happens, and enjoy the ride. Some patterns are symmetric, some are chaotic, some look like aliens 👾

Made by someone who thinks generative art is neat ✌️
