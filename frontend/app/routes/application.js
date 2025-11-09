import Route from '@ember/routing/route';
import { service } from '@ember/service';

export default class ApplicationRoute extends Route {
  @service('substitution-system') system;

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

  model(params) {
    let rules = this.system.getRules();
    const initial = this.system.getInitialGrid();
    
    if (params.rules && params.rules.length === 48 && /^[0-9A-F]+$/i.test(params.rules)) {
      try {
        const urlRules = this.hexToRules(params.rules.toUpperCase(), rules);
        this.system.setRules(urlRules);
        rules = urlRules;
      } catch (e) {
        console.error('Failed to load rules from URL:', e);
      }
    }
    
    return {
      rules,
      initial,
    };
  }
}
