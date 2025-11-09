import { modifier } from 'ember-modifier';

export default modifier(function dragScroll(element) {
  let isDragging = false;
  let startX, startY, scrollLeft, scrollTop;

  function handleMouseDown(e) {
    isDragging = true;
    element.style.cursor = 'grabbing';
    element.style.userSelect = 'none';
    
    startX = e.pageX - element.offsetLeft;
    startY = e.pageY - element.offsetTop;
    scrollLeft = element.scrollLeft;
    scrollTop = element.scrollTop;
  }

  function handleMouseMove(e) {
    if (!isDragging) return;
    e.preventDefault();
    
    const x = e.pageX - element.offsetLeft;
    const y = e.pageY - element.offsetTop;
    const walkX = (x - startX) * 1.5;
    const walkY = (y - startY) * 1.5;
    
    element.scrollLeft = scrollLeft - walkX;
    element.scrollTop = scrollTop - walkY;
  }

  function handleMouseUp() {
    isDragging = false;
    element.style.cursor = 'grab';
    element.style.userSelect = '';
  }

  function handleMouseLeave() {
    if (isDragging) {
      isDragging = false;
      element.style.cursor = 'grab';
      element.style.userSelect = '';
    }
  }

  element.style.cursor = 'grab';
  
  element.addEventListener('mousedown', handleMouseDown);
  document.addEventListener('mousemove', handleMouseMove);
  document.addEventListener('mouseup', handleMouseUp);
  element.addEventListener('mouseleave', handleMouseLeave);

  return () => {
    element.removeEventListener('mousedown', handleMouseDown);
    document.removeEventListener('mousemove', handleMouseMove);
    document.removeEventListener('mouseup', handleMouseUp);
    element.removeEventListener('mouseleave', handleMouseLeave);
  };
});

