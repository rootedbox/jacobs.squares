import Component from '@glimmer/component';
import { action } from '@ember/object';
import { on } from '@ember/modifier';
import { fn } from '@ember/helper';
import getItem from '../helpers/get-item';

export default class InitialGridSelector extends Component {
  getCellClass(value) {
    return value === 1 ? 'cell-on' : 'cell-off';
  }

  @action
  toggleCell(row, col) {
    const newGrid = this.args.initial.map(r => [...r]);
    newGrid[row][col] = newGrid[row][col] === 1 ? 0 : 1;
    this.args.onChange(newGrid);
  }

  <template>
    <div class="initial-grid-selector">
      <h5>Seed</h5>
      <p class="text-muted small">Click to toggle cells</p>
      <div class="initial-grid">
        {{#each @initial as |row rowIndex|}}
          {{#each row as |cell colIndex|}}
            <div 
              class="initial-cell {{this.getCellClass cell}}"
              {{on "click" (fn this.toggleCell rowIndex colIndex)}}
            ></div>
          {{/each}}
        {{/each}}
      </div>
    </div>
  </template>
}
