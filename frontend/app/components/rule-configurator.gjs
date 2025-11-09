import Component from '@glimmer/component';
import { action } from '@ember/object';
import { tracked } from '@glimmer/tracking';
import { on } from '@ember/modifier';
import { fn } from '@ember/helper';
import getItem from '../helpers/get-item';

export default class RuleConfigurator extends Component {
  @tracked showLoadModal = false;
  @tracked savedPatterns = [];
  
  get currentHex() {
    return this.rulesToHex(this.args.rules);
  }
  
  getCellClass(value) {
    return value === 1 ? 'cell-on' : 'cell-off';
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

  hexToRules(hex, baseRules) {
    const bitString = hex.split('').map(h => 
      parseInt(h, 16).toString(2).padStart(4, '0')
    ).join('');
    
    const rules = {};
    let bitIndex = 0;
    
    for (let i = 0; i < 16; i++) {
      const inner = [];
      for (let j = 0; j < 12; j++) {
        inner.push(bitString[bitIndex++] === '1' ? 1 : 0);
      }
      rules[i] = {
        ...baseRules[i],
        inner
      };
    }
    
    return rules;
  }

  loadSavedPatterns() {
    const patterns = [];
    const keys = Object.keys(localStorage);
    
    for (const key of keys) {
      if (key.startsWith('jacobs-squares-hex-')) {
        try {
          const hex = key.replace('jacobs-squares-hex-', '');
          const data = JSON.parse(localStorage.getItem(key));
          patterns.push({
            id: key,
            hex: hex,
            timestamp: data.timestamp,
            rules: data.rules
          });
        } catch (e) {
          // Skip invalid entries
        }
      }
    }
    
    patterns.sort((a, b) => new Date(b.timestamp) - new Date(a.timestamp));
    return patterns;
  }

  @action
  toggleCell(ruleId, cellIndex) {
    const id = String(ruleId);
    const currentInner = [...this.args.rules[id].inner];
    currentInner[cellIndex] = currentInner[cellIndex] === 1 ? 0 : 1;
    
    const rules = { ...this.args.rules };
    rules[id] = { ...rules[id], inner: currentInner };
    this.args.onRulesChange(rules);
  }

  @action
  clearAll() {
    const rules = {};
    for (let i = 0; i < 16; i++) {
      rules[i] = {
        ...this.args.rules[i],
        inner: [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
      };
    }
    this.args.onRulesChange(rules);
  }

  @action
  fillAll() {
    const rules = {};
    for (let i = 0; i < 16; i++) {
      rules[i] = {
        ...this.args.rules[i],
        inner: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
      };
    }
    this.args.onRulesChange(rules);
  }

  @action
  randomize() {
    const rules = {};
    for (let i = 0; i < 16; i++) {
      const inner = [];
      for (let j = 0; j < 12; j++) {
        inner.push(Math.random() < 0.5 ? 0 : 1);
      }
      rules[i] = {
        ...this.args.rules[i],
        inner
      };
    }
    this.args.onRulesChange(rules);
  }

  @action
  savePattern() {
    const hex = this.rulesToHex(this.args.rules);
    const id = `jacobs-squares-hex-${hex}`;
    
    const existing = localStorage.getItem(id);
    if (existing) {
      alert(`Pattern ${hex} is already saved!`);
      return;
    }
    
    const data = {
      rules: this.args.rules,
      timestamp: new Date().toISOString()
    };
    
    localStorage.setItem(id, JSON.stringify(data));
    alert(`Pattern saved as: ${hex}`);
  }

  @action
  openLoadModal() {
    this.savedPatterns = this.loadSavedPatterns();
    this.showLoadModal = true;
  }

  @action
  closeLoadModal() {
    this.showLoadModal = false;
  }

  @action
  loadPattern(pattern) {
    if (pattern.rules) {
      this.args.onRulesChange(pattern.rules);
      this.showLoadModal = false;
    }
  }

  @action
  deletePattern(pattern, event) {
    event.stopPropagation();
    if (confirm(`Delete pattern ${pattern.hex}?`)) {
      localStorage.removeItem(pattern.id);
      this.savedPatterns = this.loadSavedPatterns();
    }
  }

  formatDate(timestamp) {
    const date = new Date(timestamp);
    return date.toLocaleString();
  }

  @action
  copyUrlToClipboard() {
    const hex = this.currentHex;
    const baseUrl = window.location.origin + window.location.pathname;
    const url = `${baseUrl}?rules=${hex}`;
    
    navigator.clipboard.writeText(url).then(() => {
      alert('URL copied to clipboard! Share this link to send your rule configuration.');
    }).catch(() => {
      alert('Failed to copy URL. Please copy manually: ' + url);
    });
  }

  <template>
    <div class="rule-editor">
      <div class="mb-3">
        <div class="d-flex justify-content-between align-items-start mb-1">
          <div>
            <h5 class="mb-1">Rule Configurator</h5>
            <p class="text-muted small mb-0">Click cells to toggle on/off</p>
          </div>
          
          <div class="d-flex gap-2">
            <div class="btn-group btn-group-sm" role="group">
              <button type="button" class="btn btn-outline-secondary" {{on "click" this.clearAll}}>
                Clear
              </button>
              <button type="button" class="btn btn-outline-secondary" {{on "click" this.fillAll}}>
                Fill
              </button>
              <button type="button" class="btn btn-outline-primary" {{on "click" this.randomize}}>
                Random
              </button>
            </div>
            <div class="btn-group btn-group-sm" role="group">
              <button type="button" class="btn btn-outline-success" {{on "click" this.savePattern}}>
                Save
              </button>
              <button type="button" class="btn btn-outline-info" {{on "click" this.openLoadModal}}>
                Load
              </button>
            </div>
          </div>
        </div>
      </div>
      
      <div class="rules-grid-layout">
        {{#each-in @rules as |ruleId rule|}}
          <div class="rule-item-grid">
            <div class="rule-grid-compact">
              {{! Row 0 }}
              <div class="rule-cell-compact corner {{this.getCellClass (getItem rule.corners 0)}}"></div>
              <div class="rule-cell-compact editable {{this.getCellClass (getItem rule.inner 0)}}" {{on "click" (fn this.toggleCell ruleId 0)}}></div>
              <div class="rule-cell-compact editable {{this.getCellClass (getItem rule.inner 1)}}" {{on "click" (fn this.toggleCell ruleId 1)}}></div>
              <div class="rule-cell-compact corner {{this.getCellClass (getItem rule.corners 1)}}"></div>
              
              {{! Row 1 }}
              <div class="rule-cell-compact editable {{this.getCellClass (getItem rule.inner 2)}}" {{on "click" (fn this.toggleCell ruleId 2)}}></div>
              <div class="rule-cell-compact editable {{this.getCellClass (getItem rule.inner 3)}}" {{on "click" (fn this.toggleCell ruleId 3)}}></div>
              <div class="rule-cell-compact editable {{this.getCellClass (getItem rule.inner 4)}}" {{on "click" (fn this.toggleCell ruleId 4)}}></div>
              <div class="rule-cell-compact editable {{this.getCellClass (getItem rule.inner 5)}}" {{on "click" (fn this.toggleCell ruleId 5)}}></div>
              
              {{! Row 2 }}
              <div class="rule-cell-compact editable {{this.getCellClass (getItem rule.inner 6)}}" {{on "click" (fn this.toggleCell ruleId 6)}}></div>
              <div class="rule-cell-compact editable {{this.getCellClass (getItem rule.inner 7)}}" {{on "click" (fn this.toggleCell ruleId 7)}}></div>
              <div class="rule-cell-compact editable {{this.getCellClass (getItem rule.inner 8)}}" {{on "click" (fn this.toggleCell ruleId 8)}}></div>
              <div class="rule-cell-compact editable {{this.getCellClass (getItem rule.inner 9)}}" {{on "click" (fn this.toggleCell ruleId 9)}}></div>
              
              {{! Row 3 }}
              <div class="rule-cell-compact corner {{this.getCellClass (getItem rule.corners 2)}}"></div>
              <div class="rule-cell-compact editable {{this.getCellClass (getItem rule.inner 10)}}" {{on "click" (fn this.toggleCell ruleId 10)}}></div>
              <div class="rule-cell-compact editable {{this.getCellClass (getItem rule.inner 11)}}" {{on "click" (fn this.toggleCell ruleId 11)}}></div>
              <div class="rule-cell-compact corner {{this.getCellClass (getItem rule.corners 3)}}"></div>
            </div>
          </div>
        {{/each-in}}
      </div>

      <div class="hex-editor mt-3">
        <div class="mb-2">
          <label class="form-label small mb-1 d-block">
            <strong>Hex Value (192 bits):</strong>
          </label>
          <code class="user-select-all">{{this.currentHex}}</code>
        </div>
        <button 
          class="btn btn-sm btn-outline-primary" 
          type="button"
          {{on "click" this.copyUrlToClipboard}}
        >
          📋 Copy Shareable URL
        </button>
      </div>

      {{#if this.showLoadModal}}
        <div class="modal-backdrop show" {{on "click" this.closeLoadModal}}></div>
        <div class="modal show d-block" tabindex="-1">
          <div class="modal-dialog modal-dialog-centered modal-dialog-scrollable modal-lg">
            <div class="modal-content">
              <div class="modal-header">
                <h5 class="modal-title">Load Saved Pattern</h5>
                <button type="button" class="btn-close" {{on "click" this.closeLoadModal}}></button>
              </div>
              <div class="modal-body">
                {{#if this.savedPatterns.length}}
                  <div class="saved-patterns-list">
                    {{#each this.savedPatterns as |pattern|}}
                      <div class="saved-pattern-item" {{on "click" (fn this.loadPattern pattern)}}>
                        <div class="pattern-header-row">
                          <code class="pattern-hex">{{pattern.hex}}</code>
                          <small class="text-muted">{{this.formatDate pattern.timestamp}}</small>
                          <button type="button" class="btn btn-sm btn-outline-danger" {{on "click" (fn this.deletePattern pattern)}}>
                            Delete
                          </button>
                        </div>
                        <div class="pattern-preview-grid">
                          {{#each-in pattern.rules as |ruleId rule|}}
                            <div class="preview-rule-grid">
                              <div class="preview-cell corner {{this.getCellClass (getItem rule.corners 0)}}"></div>
                              <div class="preview-cell {{this.getCellClass (getItem rule.inner 0)}}"></div>
                              <div class="preview-cell {{this.getCellClass (getItem rule.inner 1)}}"></div>
                              <div class="preview-cell corner {{this.getCellClass (getItem rule.corners 1)}}"></div>
                              
                              <div class="preview-cell {{this.getCellClass (getItem rule.inner 2)}}"></div>
                              <div class="preview-cell {{this.getCellClass (getItem rule.inner 3)}}"></div>
                              <div class="preview-cell {{this.getCellClass (getItem rule.inner 4)}}"></div>
                              <div class="preview-cell {{this.getCellClass (getItem rule.inner 5)}}"></div>
                              
                              <div class="preview-cell {{this.getCellClass (getItem rule.inner 6)}}"></div>
                              <div class="preview-cell {{this.getCellClass (getItem rule.inner 7)}}"></div>
                              <div class="preview-cell {{this.getCellClass (getItem rule.inner 8)}}"></div>
                              <div class="preview-cell {{this.getCellClass (getItem rule.inner 9)}}"></div>
                              
                              <div class="preview-cell corner {{this.getCellClass (getItem rule.corners 2)}}"></div>
                              <div class="preview-cell {{this.getCellClass (getItem rule.inner 10)}}"></div>
                              <div class="preview-cell {{this.getCellClass (getItem rule.inner 11)}}"></div>
                              <div class="preview-cell corner {{this.getCellClass (getItem rule.corners 3)}}"></div>
                            </div>
                          {{/each-in}}
                        </div>
                      </div>
                    {{/each}}
                  </div>
                {{else}}
                  <div class="alert alert-info mb-0">
                    No saved patterns yet. Create a pattern and click Save!
                  </div>
                {{/if}}
              </div>
              <div class="modal-footer">
                <button type="button" class="btn btn-secondary" {{on "click" this.closeLoadModal}}>Close</button>
              </div>
            </div>
          </div>
        </div>
      {{/if}}
    </div>
  </template>
}
