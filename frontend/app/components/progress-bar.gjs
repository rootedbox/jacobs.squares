import Component from '@glimmer/component';

export default class ProgressBar extends Component {
  get progressPercent() {
    return Math.round((this.args.progress || 0) * 100);
  }

  get isVisible() {
    const progress = this.args.progress || 0;
    return progress > 0 && progress < 1;
  }

  <template>
    {{#if this.isVisible}}
      <div class="progress-bar-container">
        <div class="progress-bar-fill" style="width: {{this.progressPercent}}%"></div>
      </div>
    {{/if}}
  </template>
}

