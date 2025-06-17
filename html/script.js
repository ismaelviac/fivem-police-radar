window.addEventListener('message', function(event) {
  const data = event.data;
  if (data.type === 'radar') {
    document.getElementById('front-plate').textContent = data.front.plate;
    document.getElementById('front-model').textContent = data.front.model;
    document.getElementById('front-speed').textContent = data.front.speed + ' km/h';
    document.getElementById('rear-plate').textContent = data.rear.plate;
    document.getElementById('rear-model').textContent = data.rear.model;
    document.getElementById('rear-speed').textContent = data.rear.speed + ' km/h';
    document.getElementById('radar-panel').style.display = data.show ? 'block' : 'none';
  }
});