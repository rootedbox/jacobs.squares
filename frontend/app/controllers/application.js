import Controller from '@ember/controller';

export default class ApplicationController extends Controller {
  queryParams = ['rules'];
  rules = null;
}

