import Component from '@glimmer/component';

export default class HowItWorks extends Component {
  get seedRuleIndex() {
    const seed = this.args.seed;
    if (!seed) return 0;
    
    const topLeft = seed[0][0];
    const topRight = seed[0][1];
    const bottomLeft = seed[1][0];
    const bottomRight = seed[1][1];
    
    return (topLeft << 3) | (topRight << 2) | (bottomLeft << 1) | bottomRight;
  }

  get matchingRule() {
    return this.args.rules[this.seedRuleIndex];
  }

  getCellClass(value) {
    return value === 1 ? 'cell-on' : 'cell-off';
  }

  <template>
    <div class="how-it-works-visual">
      <h5 class="mb-3">How it works</h5>
      
      <div class="how-it-works-content">
        <div class="d-flex align-items-center justify-content-center gap-3 mb-2">
          {{! Seed Grid }}
          <div class="demo-grid seed-demo">
            {{#each @seed as |row|}}
              {{#each row as |cell|}}
                <div class="demo-cell {{this.getCellClass cell}}"></div>
              {{/each}}
            {{/each}}
          </div>
          
          {{! Arrow }}
          <div class="arrow-symbol">=&gt;</div>
          
          {{! Matching Rule }}
          <div class="demo-grid rule-demo">
            {{! Row 0 }}
            <div class="demo-cell {{this.getCellClass this.matchingRule.corners.[0]}}"></div>
            <div class="demo-cell {{this.getCellClass this.matchingRule.inner.[0]}}"></div>
            <div class="demo-cell {{this.getCellClass this.matchingRule.inner.[1]}}"></div>
            <div class="demo-cell {{this.getCellClass this.matchingRule.corners.[1]}}"></div>
            
            {{! Row 1 }}
            <div class="demo-cell {{this.getCellClass this.matchingRule.inner.[2]}}"></div>
            <div class="demo-cell {{this.getCellClass this.matchingRule.inner.[3]}}"></div>
            <div class="demo-cell {{this.getCellClass this.matchingRule.inner.[4]}}"></div>
            <div class="demo-cell {{this.getCellClass this.matchingRule.inner.[5]}}"></div>
            
            {{! Row 2 }}
            <div class="demo-cell {{this.getCellClass this.matchingRule.inner.[6]}}"></div>
            <div class="demo-cell {{this.getCellClass this.matchingRule.inner.[7]}}"></div>
            <div class="demo-cell {{this.getCellClass this.matchingRule.inner.[8]}}"></div>
            <div class="demo-cell {{this.getCellClass this.matchingRule.inner.[9]}}"></div>
            
            {{! Row 3 }}
            <div class="demo-cell {{this.getCellClass this.matchingRule.corners.[2]}}"></div>
            <div class="demo-cell {{this.getCellClass this.matchingRule.inner.[10]}}"></div>
            <div class="demo-cell {{this.getCellClass this.matchingRule.inner.[11]}}"></div>
            <div class="demo-cell {{this.getCellClass this.matchingRule.corners.[3]}}"></div>
          </div>
        </div>
        
        <p class="iteration-label">First Iteration</p>
      </div>
    </div>
  </template>
}

