import Component from '@glimmer/component';
import { service } from '@ember/service';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import { on } from '@ember/modifier';
import { eq } from 'ember-truth-helpers';
import RuleConfigurator from './rule-configurator';
import GridDisplay from './grid-display';
import InitialGridSelector from './initial-grid-selector';
import ProgressBar from './progress-bar';
import HowItWorks from './how-it-works';

export default class AppMain extends Component {
  @service('substitution-system') system;

  @tracked grid = null;
  @tracked iterations = 8;
  @tracked isLoading = false;
  @tracked isUpdatingGrid = false;
  @tracked progress = 0;

  constructor() {
    super(...arguments);
    if (this.args.initialRules) {
      this.system.setRules(this.args.initialRules);
    }
    if (this.args.initialPattern) {
      this.system.setInitialGrid(this.args.initialPattern);
    }
    
    this.system.setProgressCallback((progress) => {
      this.progress = progress;
    });
    
    // Generate initial grid after component setup
    requestAnimationFrame(() => {
      this.updateGrid();
    });
  }

  get rules() {
    return this.system.getRules();
  }

  get initial() {
    return this.system.getInitialGrid();
  }

  rulesToHex(rules) {
    let bitString = '';
    for (let i = 0; i < 16; i++) {
      const rule = rules[i];
      for (let j = 0; j < 12; j++) {
        bitString += rule.inner[j] ? '1' : '0';
      }
    }
    
    let hex = '';
    for (let i = 0; i < bitString.length; i += 4) {
      const nibble = bitString.substr(i, 4);
      hex += parseInt(nibble, 2).toString(16);
    }
    return hex.toUpperCase();
  }

  updateUrl(rules) {
    const hex = this.rulesToHex(rules);
    const url = new URL(window.location);
    url.searchParams.set('rules', hex);
    window.history.replaceState({}, '', url);
  }

  @action
  async handleRulesChange(newRules) {
    this.system.setRules(newRules);
    this.updateUrl(newRules);
    this.isUpdatingGrid = true;
    
    await this.updateGrid();
  }

  @action
  async handleInitialChange(newInitial) {
    this.system.setInitialGrid(newInitial);
    this.isUpdatingGrid = true;
    
    await this.updateGrid();
  }

  @action
  async updateGrid() {
    this.grid = await this.system.generate(this.iterations);
    
    const size = this.grid?.length || 0;
    if (size <= 64) {
      this.isUpdatingGrid = false;
    }
  }

  @action
  handleRenderComplete() {
    this.isUpdatingGrid = false;
  }

  @action
  async changeIterations(event) {
    this.iterations = parseInt(event.target.value, 10);
    this.isUpdatingGrid = true;
    
    await this.updateGrid();
  }

  <template>
    <ProgressBar @progress={{this.progress}} />
    
    <div class="container-fluid">
      <header>
        <h1>Jacobs Squares</h1>
        <p class="lead">A binary substitution system automata</p>
      </header>

      <div class="row g-0">
        <div class="col-lg-9">
          <div class="controls-compact">
            <div class="d-flex align-items-center gap-3">
              <label for="iterations" class="form-label mb-0 text-nowrap">
                <strong>Iterations:</strong>
              </label>
              <select 
                class="form-select" 
                id="iterations"
                style="width: auto;"
                {{on "change" this.changeIterations}}
              >
                <option value="1" selected={{eq this.iterations 1}}>1 (4×4)</option>
                <option value="2" selected={{eq this.iterations 2}}>2 (8×8)</option>
                <option value="3" selected={{eq this.iterations 3}}>3 (16×16)</option>
                <option value="4" selected={{eq this.iterations 4}}>4 (32×32)</option>
                <option value="5" selected={{eq this.iterations 5}}>5 (64×64)</option>
                <option value="6" selected={{eq this.iterations 6}}>6 (128×128)</option>
                <option value="7" selected={{eq this.iterations 7}}>7 (256×256)</option>
                <option value="8" selected={{eq this.iterations 8}}>8 (512×512)</option>
                <option value="9" selected={{eq this.iterations 9}}>9 (1024×1024)</option>
                <option value="10" selected={{eq this.iterations 10}}>10 (2048×2048)</option>
                <option value="11" selected={{eq this.iterations 11}}>11 (4096×4096)</option>
                <option value="12" selected={{eq this.iterations 12}}>12 (8192×8192)</option>
              </select>
              {{#if this.isUpdatingGrid}}
                <span class="spinner-border spinner-border-sm" role="status"></span>
              {{/if}}
              {{#if this.grid}}
                <small class="text-muted text-nowrap ms-auto">{{this.grid.length}}×{{this.grid.length}}</small>
              {{/if}}
            </div>
          </div>

          <GridDisplay 
            @grid={{this.grid}} 
            @iterations={{this.iterations}}
            @onRenderComplete={{this.handleRenderComplete}}
          />
        </div>

        <div class="col-lg-3">
          <div class="row g-0 top-section-row">
            <div class="col-6">
              <InitialGridSelector 
                @initial={{this.initial}}
                @onChange={{this.handleInitialChange}}
              />
            </div>
            <div class="col-6">
              <HowItWorks 
                @seed={{this.initial}}
                @rules={{this.rules}}
              />
            </div>
          </div>

          {{#if this.isLoading}}
            <div class="text-center p-5">
              <div class="spinner-border" role="status">
                <span class="visually-hidden">Loading...</span>
              </div>
            </div>
          {{else}}
            <RuleConfigurator 
              @rules={{this.rules}} 
              @onRulesChange={{this.handleRulesChange}}
            />
          {{/if}}
        </div>
      </div>
    </div>
  </template>
}
