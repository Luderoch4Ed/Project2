var myMap = L.map("map", {
    center: [39.011902,	-98.484246], 
    zoom: 4.45
  });
  
  L.tileLayer("https://api.mapbox.com/styles/v1/{id}/tiles/{z}/{x}/{y}?access_token={accessToken}", {
    attribution: "© <a href='https://www.mapbox.com/about/maps/'>Mapbox</a> © <a href='http://www.openstreetmap.org/copyright'>OpenStreetMap</a> <strong><a href='https://www.mapbox.com/map-feedback/' target='_blank'>Improve this map</a></strong>",
    tileSize: 512,
    maxZoom: 18,
    zoomOffset: -1,
    id: "mapbox/streets-v11",
    accessToken: API_KEY
  }).addTo(myMap);
  
  d3.csv("static/data/ACCIDENT2018.csv.csv", function(accidents) {
    console.log(accidents);
    // Format the data
    accidents.forEach(function(data) {
      data.LATITUDE = +data.LATITUDE;
      data.LONGITUD = +data.LONGITUD;
    });
  
    var heatArray = [];
  
    for (var i = 0; i < accidents.length; i++) {
        heatArray.push([accidents[i].LATITUDE, accidents[i].LONGITUD]);
    }
  
    var heat = L.heatLayer(heatArray, {
      radius: 60,
      blur: 30,
      gradient: {0.2: 'blue', 0.4: 'lime', 0.6: 'red'}
    }).addTo(myMap);
  
  });
  