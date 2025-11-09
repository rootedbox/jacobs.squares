import Service from '@ember/service';
import { tracked } from '@glimmer/tracking';

export default class ApiService extends Service {
  @tracked baseUrl = 'http://localhost:3000/api';

  async getRules() {
    const response = await fetch(`${this.baseUrl}/rules`);
    const data = await response.json();
    return data.rules;
  }

  async setRules(rules) {
    const response = await fetch(`${this.baseUrl}/rules`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ rules }),
    });
    return response.json();
  }

  async getInitialGrid() {
    const response = await fetch(`${this.baseUrl}/initial`);
    const data = await response.json();
    return data.initial;
  }

  async setInitialGrid(initial) {
    const response = await fetch(`${this.baseUrl}/initial`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ initial }),
    });
    return response.json();
  }

  async getGrid(iterations = 1) {
    const useCompact = iterations >= 5;
    const response = await fetch(
      `${this.baseUrl}/grid?iterations=${iterations}&compact=${useCompact}`
    );
    const data = await response.json();
    
    if (data.compressed) {
      const size = data.size;
      const grid = new Array(size);
      let idx = 0;
      for (let i = 0; i < size; i++) {
        grid[i] = new Array(size);
        for (let j = 0; j < size; j++) {
          grid[i][j] = parseInt(data.grid[idx++], 10);
        }
      }
      return { grid, size };
    }
    
    return data;
  }
}
