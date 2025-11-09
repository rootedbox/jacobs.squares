import { helper } from '@ember/component/helper';

export default helper(function getItem([array, index]) {
  return array ? array[index] : undefined;
});
