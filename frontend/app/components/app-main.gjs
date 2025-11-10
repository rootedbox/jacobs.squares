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
import { Tooltip } from 'bootstrap';

export default class AppMain extends Component {
  @service('substitution-system') system;

  @tracked grid = null;
  @tracked iterations = 8;
  @tracked isLoading = false;
  @tracked isUpdatingGrid = false;
  @tracked progress = 0;
  @tracked rules = {};
  @tracked initial = [[0, 0], [0, 0]];
  _updateTimeout = null;

  constructor() {
    super(...arguments);
    if (this.args.initialRules) {
      this.system.setRules(this.args.initialRules);
    }
    if (this.args.initialPattern) {
      this.system.setInitialGrid(this.args.initialPattern);
    }
    
    this.rules = this.system.getRules();
    this.initial = this.system.getInitialGrid();
    
    this.system.setProgressCallback((progress) => {
      this.progress = progress;
    });
    
    // Initialize Bootstrap tooltips
    requestAnimationFrame(() => {
      const tooltipTriggerList = document.querySelectorAll('[data-bs-toggle="tooltip"]');
      [...tooltipTriggerList].map(tooltipTriggerEl => new Tooltip(tooltipTriggerEl));
      
      this.updateGrid();
    });
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
    this.rules = newRules;
    this.system.setRules(newRules);
    this.updateUrl(newRules);
    this.isUpdatingGrid = true;
    
    await this.updateGrid();
  }

  @action
  async handleInitialChange(newInitial) {
    this.initial = newInitial;
    this.system.setInitialGrid(newInitial);
    this.isUpdatingGrid = true;
    
    await this.updateGrid();
  }

  @action
  async updateGrid() {
    if (this._updateTimeout) {
      clearTimeout(this._updateTimeout);
    }
    
    this._updateTimeout = setTimeout(() => {
      this.isUpdatingGrid = false;
      this.progress = 0;
    }, 30000);
    
    const result = await this.system.generate(this.iterations);
    
    if (this._updateTimeout) {
      clearTimeout(this._updateTimeout);
      this._updateTimeout = null;
    }
    
    if (result === null) {
      this.isUpdatingGrid = false;
      this.progress = 0;
      return;
    }
    
    this.grid = result;
    
    // Always stop spinner immediately after worker completes
    // Canvas rendering happens asynchronously in background
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
        <div class="d-flex justify-content-between align-items-center">
          <div>
            <h1>Jacobs Squares</h1>
            <p class="lead">A binary substitution system automata</p>
          </div>
          <div class="d-flex gap-3">
            <a href="https://emberjs.com" target="_blank" rel="noopener noreferrer" class="ember-link" data-bs-toggle="tooltip" data-bs-placement="bottom" data-bs-title="Built with Ember.js">
              <svg width="28" height="28" viewBox="0 0 128 128" xmlns="http://www.w3.org/2000/svg">
                <path d="M64.822 85.61c-12.039.302-10.772-7.606-10.772-7.606S98.004 62.962 86.02 33.25c-5.387-7.644-11.645-10.046-20.503-9.87-8.86.172-19.77 5.575-26.894 21.562-3.398 7.63-4.552 14.857-5.245 20.334 0 0-7.785 1.563-11.955-1.904-4.167-3.472-6.36 0-6.36 0s-7.178 8.4-.051 11.183c7.124 2.782 18.218 3.344 18.218 3.344h-.005c1.021 7.398 3.534 14.51 12.668 20.45 15.316 9.965 38.045-.56 38.045-.56 13.622-5.693 22.67-14.507 26.526-18.8a3.535 3.535 0 0 0-.091-4.823l-4.436-4.61a3.537 3.537 0 0 0-4.8-.283c-5.925 4.853-21.5 16.337-36.315 16.337zM51.964 64.586c.523-20.675 14.073-29.71 18.766-25.187 4.693 4.512 2.952 14.24-5.908 20.321-8.858 6.084-12.858 4.866-12.858 4.866z" fill="#ffffff"/>
              </svg>
            </a>
            <a href="https://github.com/rootedbox/jacobs.squares" target="_blank" rel="noopener noreferrer" class="github-link" data-bs-toggle="tooltip" data-bs-placement="bottom" data-bs-title="View source code on GitHub">
              <svg width="24" height="24" viewBox="0 0 16 16" fill="currentColor">
                <path d="M8 0C3.58 0 0 3.58 0 8c0 3.54 2.29 6.53 5.47 7.59.4.07.55-.17.55-.38 0-.19-.01-.82-.01-1.49-2.01.37-2.53-.49-2.69-.94-.09-.23-.48-.94-.82-1.13-.28-.15-.68-.52-.01-.53.63-.01 1.08.58 1.23.82.72 1.21 1.87.87 2.33.66.07-.52.28-.87.51-1.07-1.78-.2-3.64-.89-3.64-3.95 0-.87.31-1.59.82-2.15-.08-.2-.36-1.02.08-2.12 0 0 .67-.21 2.2.82.64-.18 1.32-.27 2-.27.68 0 1.36.09 2 .27 1.53-1.04 2.2-.82 2.2-.82.44 1.1.16 1.92.08 2.12.51.56.82 1.27.82 2.15 0 3.07-1.87 3.75-3.65 3.95.29.25.54.73.54 1.48 0 1.07-.01 1.93-.01 2.2 0 .21.15.46.55.38A8.013 8.013 0 0016 8c0-4.42-3.58-8-8-8z"></path>
              </svg>
            </a>
          </div>
        </div>
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
