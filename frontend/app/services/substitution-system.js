import Service from '@ember/service';
import { tracked } from '@glimmer/tracking';

export default class SubstitutionSystemService extends Service {
  @tracked rules = this.initializeDefaultRules();
  @tracked initialGrid = [[0, 0], [0, 0]];
  
  flatExpansions = new Uint8Array(16 * 16);
  _worker = null;
  _progressCallback = null;
  _resolveGenerate = null;
  _isGenerating = false;

  constructor() {
    super(...arguments);
    this.updateCache();
    this.initWorker();
  }

  initWorker() {
    this._worker = new Worker('/substitution-worker.js');
    this._worker.onmessage = (e) => {
      const { type, progress, grid } = e.data;
      
      if (type === 'progress' && this._progressCallback) {
        this._progressCallback(progress);
      } else if (type === 'complete') {
        this._isGenerating = false;
        if (this._resolveGenerate) {
          this._resolveGenerate(grid);
          this._resolveGenerate = null;
        }
        if (this._progressCallback) {
          this._progressCallback(1);
        }
      }
    };
    
    this._worker.onerror = (error) => {
      console.error('Web Worker error:', error);
      this._isGenerating = false;
      if (this._progressCallback) {
        this._progressCallback(0);
      }
      if (this._resolveGenerate) {
        this._resolveGenerate(null);
        this._resolveGenerate = null;
      }
    };
  }

  setProgressCallback(callback) {
    this._progressCallback = callback;
  }

  initializeDefaultRules() {
    const defaultHex = 'E6700000003F0004CDF6F00D000EF7B32032FC04C0B00000';
    
    const bitString = defaultHex.split('').map(h => 
      parseInt(h, 16).toString(2).padStart(4, '0')
    ).join('');
    
    const rules = {};
    let bitIndex = 0;
    
    for (let i = 0; i < 16; i++) {
      const corners = [
        (i >> 3) & 1,
        (i >> 2) & 1,
        (i >> 1) & 1,
        i & 1
      ];
      
      const inner = [];
      for (let j = 0; j < 12; j++) {
        inner.push(bitString[bitIndex++] === '1' ? 1 : 0);
      }
      
      rules[i] = {
        corners: corners,
        inner: inner
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

  getRules() {
    return this.rules;
  }

  setInitialGrid(grid) {
    if (grid.length === 2 && grid[0].length === 2) {
      this.initialGrid = grid;
    }
  }

  getInitialGrid() {
    return this.initialGrid;
  }

  generate(iterations = 1) {
    if (this._isGenerating && this._worker) {
      this._worker.terminate();
      
      if (this._resolveGenerate) {
        this._resolveGenerate(null);
        this._resolveGenerate = null;
      }
      
      this._isGenerating = false;
      this.initWorker();
    }
    
    return new Promise((resolve) => {
      this._isGenerating = true;
      this._resolveGenerate = resolve;
      
      if (this._progressCallback) {
        this._progressCallback(0);
      }
      
      this._worker.postMessage({
        type: 'generate',
        rules: this.rules,
        initialGrid: this.initialGrid,
        iterations: iterations
      });
    });
  }

  willDestroy() {
    super.willDestroy();
    if (this._worker) {
      this._worker.terminate();
    }
  }
}

