# Example Patterns for Jacobs Squares

Here are some interesting rule configurations to try. You can manually set these in the UI or modify the `initializeDefaultRules()` function in `server/substitution-system.js`.

## Example 1: Simple Cascade

Creates a flowing cascade pattern.

```
Rule 0: topRight=1, bottomLeft=2, bottomRight=3
Rule 1: topRight=2, bottomLeft=3, bottomRight=4
Rule 2: topRight=3, bottomLeft=4, bottomRight=5
Rule 3: topRight=4, bottomLeft=5, bottomRight=6
Rule 4: topRight=5, bottomLeft=6, bottomRight=7
Rule 5: topRight=6, bottomLeft=7, bottomRight=8
Rule 6: topRight=7, bottomLeft=8, bottomRight=9
Rule 7: topRight=8, bottomLeft=9, bottomRight=10
Rule 8: topRight=9, bottomLeft=10, bottomRight=11
Rule 9: topRight=10, bottomLeft=11, bottomRight=12
Rule 10: topRight=11, bottomLeft=12, bottomRight=13
Rule 11: topRight=12, bottomLeft=13, bottomRight=14
Rule 12: topRight=13, bottomLeft=14, bottomRight=15
Rule 13: topRight=14, bottomLeft=15, bottomRight=0
Rule 14: topRight=15, bottomLeft=0, bottomRight=1
Rule 15: topRight=0, bottomLeft=1, bottomRight=2
```

## Example 2: Checker Pattern

Creates a checkerboard-like effect.

```
Rule 0: topRight=1, bottomLeft=1, bottomRight=0
Rule 1: topRight=0, bottomLeft=0, bottomRight=1
Rule 2: topRight=3, bottomLeft=3, bottomRight=2
Rule 3: topRight=2, bottomLeft=2, bottomRight=3
Rule 4: topRight=5, bottomLeft=5, bottomRight=4
Rule 5: topRight=4, bottomLeft=4, bottomRight=5
Rule 6: topRight=7, bottomLeft=7, bottomRight=6
Rule 7: topRight=6, bottomLeft=6, bottomRight=7
Rule 8: topRight=9, bottomLeft=9, bottomRight=8
Rule 9: topRight=8, bottomLeft=8, bottomRight=9
Rule 10: topRight=11, bottomLeft=11, bottomRight=10
Rule 11: topRight=10, bottomLeft=10, bottomRight=11
Rule 12: topRight=13, bottomLeft=13, bottomRight=12
Rule 13: topRight=12, bottomLeft=12, bottomRight=13
Rule 14: topRight=15, bottomLeft=15, bottomRight=14
Rule 15: topRight=14, bottomLeft=14, bottomRight=15
```

## Example 3: Diagonal Sweep

Creates diagonal patterns that sweep across the grid.

```
Rule 0: topRight=4, bottomLeft=4, bottomRight=8
Rule 1: topRight=5, bottomLeft=5, bottomRight=9
Rule 2: topRight=6, bottomLeft=6, bottomRight=10
Rule 3: topRight=7, bottomLeft=7, bottomRight=11
Rule 4: topRight=8, bottomLeft=8, bottomRight=12
Rule 5: topRight=9, bottomLeft=9, bottomRight=13
Rule 6: topRight=10, bottomLeft=10, bottomRight=14
Rule 7: topRight=11, bottomLeft=11, bottomRight=15
Rule 8: topRight=12, bottomLeft=12, bottomRight=0
Rule 9: topRight=13, bottomLeft=13, bottomRight=1
Rule 10: topRight=14, bottomLeft=14, bottomRight=2
Rule 11: topRight=15, bottomLeft=15, bottomRight=3
Rule 12: topRight=0, bottomLeft=0, bottomRight=4
Rule 13: topRight=1, bottomLeft=1, bottomRight=5
Rule 14: topRight=2, bottomLeft=2, bottomRight=6
Rule 15: topRight=3, bottomLeft=3, bottomRight=7
```

## Example 4: Fractal Quarters

Each quadrant becomes a self-similar pattern.

```
Rule 0: topRight=0, bottomLeft=0, bottomRight=0
Rule 1: topRight=1, bottomLeft=1, bottomRight=1
Rule 2: topRight=2, bottomLeft=2, bottomRight=2
Rule 3: topRight=3, bottomLeft=3, bottomRight=3
Rule 4: topRight=0, bottomLeft=0, bottomRight=4
Rule 5: topRight=1, bottomLeft=1, bottomRight=5
Rule 6: topRight=2, bottomLeft=2, bottomRight=6
Rule 7: topRight=3, bottomLeft=3, bottomRight=7
Rule 8: topRight=4, bottomLeft=4, bottomRight=8
Rule 9: topRight=5, bottomLeft=5, bottomRight=9
Rule 10: topRight=6, bottomLeft=6, bottomRight=10
Rule 11: topRight=7, bottomLeft=7, bottomRight=11
Rule 12: topRight=8, bottomLeft=8, bottomRight=12
Rule 13: topRight=9, bottomLeft=9, bottomRight=13
Rule 14: topRight=10, bottomLeft=10, bottomRight=14
Rule 15: topRight=11, bottomLeft=11, bottomRight=15
```

## Example 5: Spiral Pattern

Creates a spiral-like appearance.

```
Rule 0: topRight=1, bottomLeft=3, bottomRight=2
Rule 1: topRight=2, bottomLeft=0, bottomRight=3
Rule 2: topRight=3, bottomLeft=1, bottomRight=0
Rule 3: topRight=0, bottomLeft=2, bottomRight=1
Rule 4: topRight=5, bottomLeft=7, bottomRight=6
Rule 5: topRight=6, bottomLeft=4, bottomRight=7
Rule 6: topRight=7, bottomLeft=5, bottomRight=4
Rule 7: topRight=4, bottomLeft=6, bottomRight=5
Rule 8: topRight=9, bottomLeft=11, bottomRight=10
Rule 9: topRight=10, bottomLeft=8, bottomRight=11
Rule 10: topRight=11, bottomLeft=9, bottomRight=8
Rule 11: topRight=8, bottomLeft=10, bottomRight=9
Rule 12: topRight=13, bottomLeft=15, bottomRight=14
Rule 13: topRight=14, bottomLeft=12, bottomRight=15
Rule 14: topRight=15, bottomLeft=13, bottomRight=12
Rule 15: topRight=12, bottomLeft=14, bottomRight=13
```

## Example 6: Minimalist (Two Colors)

Uses only values 0 and 1 for a stark black and white pattern.

```
Rule 0: topRight=1, bottomLeft=1, bottomRight=0
Rule 1: topRight=0, bottomLeft=0, bottomRight=1
All other rules (2-15): topRight=0, bottomLeft=0, bottomRight=0
```

## How to Apply These Patterns

### Method 1: Manually in the UI

1. Start the application
2. Click on each rule's cells to set the values
3. The pattern updates in real-time

### Method 2: Modify the Code

1. Edit `server/substitution-system.js`
2. Update the `initializeDefaultRules()` method
3. Restart the server
4. Refresh the browser

Example code modification:

```javascript
initializeDefaultRules() {
  return {
    0: { topRight: 1, bottomLeft: 2, bottomRight: 3 },
    1: { topRight: 2, bottomLeft: 3, bottomRight: 4 },
    // ... continue for all 16 rules
  };
}
```

## Experimentation Tips

1. **Start Simple**: Try patterns with just 2-4 different values
2. **Look for Symmetry**: Symmetrical rules often create interesting patterns
3. **Create Cycles**: Make value chains (0→1→2→0)
4. **Mix Stability and Change**: Some rules self-replicate, others transform
5. **Use Contrast**: High-contrast colors make patterns more visible
6. **Lower Iterations First**: Start with iteration 2-3 to see the basic structure

## Analysis Questions

When exploring patterns, consider:

- Does the pattern have symmetry?
- Are there repeating motifs?
- How does it change between iterations?
- Which rules dominate the final pattern?
- Are there stable regions vs. chaotic regions?

## Create Your Own

Try creating rules that:

- Mirror horizontally or vertically
- Create gradient effects
- Form concentric patterns
- Generate maze-like structures
- Produce organic, natural-looking textures

Share your discoveries!
