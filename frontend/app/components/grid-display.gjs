import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { eq } from 'ember-truth-helpers';
import dragScroll from '../modifiers/drag-scroll';

export default class GridDisplay extends Component {
  @tracked cachedDataUrl = null;
  _isRendering = false;
  _lastGridKey = null;

  get cellSize() {
    const iteration = this.args.iterations || 0;
    
    if (iteration > 8) return 1;
    if (iteration === 7 || iteration === 8) return 2;
    
    const size = this.args.grid?.length || 0;
    
    if (size > 128) return 5;
    if (size > 64) return 6;
    if (size > 32) return 8;
    if (size > 16) return 10;
    return 15;
  }

  get canvasRendering() {
    const size = this.args.grid?.length || 0;
    return size > 64;
  }

  get gridKey() {
    if (!this.args.grid) return null;
    const grid = this.args.grid;
    return `${grid.length}-${grid[0]?.join('')}-${grid[grid.length-1]?.join('')}`;
  }

  get gridAsDataUrl() {
    if (!this.canvasRendering || !this.args.grid) return null;
    
    const currentKey = this.gridKey;
    if (this._lastGridKey === currentKey && this.cachedDataUrl) {
      return this.cachedDataUrl;
    }

    if (!this._isRendering) {
      this._lastGridKey = currentKey;
      this._isRendering = true;
      
      requestAnimationFrame(() => {
        this.renderCanvas();
      });
    }
    
    return this.cachedDataUrl;
  }

  renderCanvas() {
    try {
      const grid = this.args.grid;
      if (!grid) {
        this._isRendering = false;
        return;
      }
      
      const size = grid.length;
      const cellSize = this.cellSize;
      
      const canvas = document.createElement('canvas');
      canvas.width = size * cellSize;
      canvas.height = size * cellSize;
      const ctx = canvas.getContext('2d', { alpha: false, willReadFrequently: false });
      
      ctx.fillStyle = '#fff';
      ctx.fillRect(0, 0, canvas.width, canvas.height);
      
      ctx.fillStyle = '#000';
      
      const chunkSize = 100;
      let rowIndex = 0;
      
      const renderChunk = () => {
        const endRow = Math.min(rowIndex + chunkSize, size);
        
        for (let i = rowIndex; i < endRow; i++) {
          const y = i * cellSize;
          for (let j = 0; j < size; j++) {
            if (grid[i][j] === 1) {
              ctx.fillRect(j * cellSize, y, cellSize, cellSize);
            }
          }
        }
        
        rowIndex = endRow;
        
        if (rowIndex < size) {
          requestAnimationFrame(renderChunk);
        } else {
          this.cachedDataUrl = canvas.toDataURL();
          this._isRendering = false;
        }
      };
      
      renderChunk();
    } catch (e) {
      console.error('Canvas rendering error:', e);
      this._isRendering = false;
    }
  }

  get displayInfo() {
    const size = this.args.grid?.length || 0;
    const cellSize = this.cellSize;
    const totalCells = size * size;
    return `${size}×${size} grid (${cellSize}px cells, ${totalCells.toLocaleString()} total)`;
  }

  <template>
    <div class="pattern-display-area">
      <div class="pattern-header">
        <h3>Generated Pattern</h3>
        <p class="text-muted mb-0">Iteration: {{@iterations}}</p>
        {{#if @grid}}
          <small class="text-muted">{{this.displayInfo}}</small>
        {{/if}}
      </div>
      
      {{#if @grid}}
        <div class="grid-scroll-container" {{dragScroll}}>
          {{#if this.canvasRendering}}
            <img src={{this.gridAsDataUrl}} alt="Generated Pattern" class="pattern-canvas" draggable="false" />
          {{else}}
            <div class="grid-display" style="grid-template-columns: repeat({{@grid.length}}, {{this.cellSize}}px); grid-template-rows: repeat({{@grid.length}}, {{this.cellSize}}px);">
              {{#each @grid as |row|}}
                {{#each row as |cell|}}
                  <div class="grid-cell {{if (eq cell 1) "cell-on" "cell-off"}}" style="width: {{this.cellSize}}px; height: {{this.cellSize}}px;"></div>
                {{/each}}
              {{/each}}
            </div>
          {{/if}}
        </div>
      {{else}}
        <div class="alert alert-warning m-4">
          <p>No grid data available</p>
        </div>
      {{/if}}
    </div>
  </template>
}
