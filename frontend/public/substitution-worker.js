class SubstitutionWorker {
  constructor() {
    this.rules = null;
    this.initialGrid = null;
    this.flatExpansions = new Uint8Array(16 * 16);
  }

  initializeDefaultRules() {
    const rules = {};
    for (let i = 0; i < 16; i++) {
      const corners = [
        (i >> 3) & 1,
        (i >> 2) & 1,
        (i >> 1) & 1,
        i & 1
      ];
      
      rules[i] = {
        corners: corners,
        inner: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
      };
    }
    return rules;
  }

  updateCache() {
    for (let i = 0; i < 16; i++) {
      const rule = this.rules[i];
      const baseIdx = i * 16;
      const topLeft = rule.corners[0];
      const topRight = rule.corners[1];
      const bottomLeft = rule.corners[2];
      const bottomRight = rule.corners[3];
      
      this.flatExpansions[baseIdx + 0] = topLeft;
      this.flatExpansions[baseIdx + 1] = rule.inner[0];
      this.flatExpansions[baseIdx + 2] = rule.inner[1];
      this.flatExpansions[baseIdx + 3] = topRight;
      
      this.flatExpansions[baseIdx + 4] = rule.inner[2];
      this.flatExpansions[baseIdx + 5] = rule.inner[3];
      this.flatExpansions[baseIdx + 6] = rule.inner[4];
      this.flatExpansions[baseIdx + 7] = rule.inner[5];
      
      this.flatExpansions[baseIdx + 8] = rule.inner[6];
      this.flatExpansions[baseIdx + 9] = rule.inner[7];
      this.flatExpansions[baseIdx + 10] = rule.inner[8];
      this.flatExpansions[baseIdx + 11] = rule.inner[9];
      
      this.flatExpansions[baseIdx + 12] = bottomLeft;
      this.flatExpansions[baseIdx + 13] = rule.inner[10];
      this.flatExpansions[baseIdx + 14] = rule.inner[11];
      this.flatExpansions[baseIdx + 15] = bottomRight;
    }
  }

  setRules(rules) {
    this.rules = rules;
    this.updateCache();
  }

  setInitialGrid(grid) {
    if (grid.length === 2 && grid[0].length === 2) {
      this.initialGrid = grid;
    }
  }

  generate(iterations = 1) {
    let oldSize = 2;
    let flatGrid = new Uint8Array(4);
    flatGrid[0] = this.initialGrid[0][0];
    flatGrid[1] = this.initialGrid[0][1];
    flatGrid[2] = this.initialGrid[1][0];
    flatGrid[3] = this.initialGrid[1][1];

    for (let iter = 0; iter < iterations; iter++) {
      const numBlocks = oldSize >> 1;
      const newSize = numBlocks << 2;
      const newFlatGrid = new Uint8Array(newSize * newSize);
      
      const totalBlocks = numBlocks * numBlocks;
      let processedBlocks = 0;
      
      for (let by = 0; by < numBlocks; by++) {
        const oldRowBase = (by << 1) * oldSize;
        const newRowBase = (by << 2) * newSize;
        
        for (let bx = 0; bx < numBlocks; bx++) {
          const oldColBase = bx << 1;
          
          const topLeft = flatGrid[oldRowBase + oldColBase];
          const topRight = flatGrid[oldRowBase + oldColBase + 1];
          const bottomLeft = flatGrid[oldRowBase + oldSize + oldColBase];
          const bottomRight = flatGrid[oldRowBase + oldSize + oldColBase + 1];
          
          const ruleIdx = (topLeft << 3) | (topRight << 2) | (bottomLeft << 1) | bottomRight;
          const expBase = ruleIdx << 4;
          
          const newColBase = bx << 2;
          
          const r0 = newRowBase + newColBase;
          const r1 = r0 + newSize;
          const r2 = r1 + newSize;
          const r3 = r2 + newSize;
          
          newFlatGrid[r0] = this.flatExpansions[expBase];
          newFlatGrid[r0 + 1] = this.flatExpansions[expBase + 1];
          newFlatGrid[r0 + 2] = this.flatExpansions[expBase + 2];
          newFlatGrid[r0 + 3] = this.flatExpansions[expBase + 3];
          
          newFlatGrid[r1] = this.flatExpansions[expBase + 4];
          newFlatGrid[r1 + 1] = this.flatExpansions[expBase + 5];
          newFlatGrid[r1 + 2] = this.flatExpansions[expBase + 6];
          newFlatGrid[r1 + 3] = this.flatExpansions[expBase + 7];
          
          newFlatGrid[r2] = this.flatExpansions[expBase + 8];
          newFlatGrid[r2 + 1] = this.flatExpansions[expBase + 9];
          newFlatGrid[r2 + 2] = this.flatExpansions[expBase + 10];
          newFlatGrid[r2 + 3] = this.flatExpansions[expBase + 11];
          
          newFlatGrid[r3] = this.flatExpansions[expBase + 12];
          newFlatGrid[r3 + 1] = this.flatExpansions[expBase + 13];
          newFlatGrid[r3 + 2] = this.flatExpansions[expBase + 14];
          newFlatGrid[r3 + 3] = this.flatExpansions[expBase + 15];
          
          processedBlocks++;
          
          if (processedBlocks % 256 === 0 || processedBlocks === totalBlocks) {
            self.postMessage({
              type: 'progress',
              iteration: iter + 1,
              totalIterations: iterations,
              blocksProcessed: processedBlocks,
              totalBlocks: totalBlocks,
              progress: ((iter + (processedBlocks / totalBlocks)) / iterations)
            });
          }
        }
      }
      
      flatGrid = newFlatGrid;
      oldSize = newSize;
    }

    const result = new Array(oldSize);
    for (let i = 0; i < oldSize; i++) {
      result[i] = new Array(oldSize);
      const rowBase = i * oldSize;
      for (let j = 0; j < oldSize; j++) {
        result[i][j] = flatGrid[rowBase + j];
      }
    }
    
    return result;
  }
}

const worker = new SubstitutionWorker();

self.onmessage = function(e) {
  const { type, rules, initialGrid, iterations } = e.data;
  
  if (type === 'generate') {
    worker.setRules(rules);
    worker.setInitialGrid(initialGrid);
    
    const grid = worker.generate(iterations);
    
    self.postMessage({
      type: 'complete',
      grid: grid
    });
  }
};

