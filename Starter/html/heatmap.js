

var light = L.tileLayer("https://api.mapbox.com/styles/v1/mapbox/{id}/tiles/{z}/{x}/{y}?access_token={accessToken}", {
  attribution: "Map data &copy; <a href=\"https://www.openstreetmap.org/\">OpenStreetMap</a> contributors, <a href=\"https://creativecommons.org/licenses/by-sa/2.0/\">CC-BY-SA</a>, Imagery © <a href=\"https://www.mapbox.com/\">Mapbox</a>",
  maxZoom: 18,
  id: "satellite-streets-v11",
  accessToken: mapKey
});

var dark = L.tileLayer("https://api.mapbox.com/styles/v1/mapbox/{id}/tiles/{z}/{x}/{y}?access_token={accessToken}", {
  attribution: "Map data &copy; <a href=\"https://www.openstreetmap.org/\">OpenStreetMap</a> contributors, <a href=\"https://creativecommons.org/licenses/by-sa/2.0/\">CC-BY-SA</a>, Imagery © <a href=\"https://www.mapbox.com/\">Mapbox</a>",
  maxZoom: 18,
  id: "dark-v10",
  accessToken: mapKey
});

let baseMaps = {
  Light: light,
  Dark: dark
};

let myMap = L.map("map", {
  center: [39.011902,	-98.484246], 
  zoom: 5,
  layers: [dark]
});

L.control.layers(baseMaps).addTo(myMap);

d3.csv("ACCIDENT2018.csv.csv", function(accidents) {
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
    blur: 15,
    gradient: {0.2: 'blue', 0.3: 'lime', 0.4: 'red'}
  }).addTo(myMap);

  L.circle(heatArray,{
    fillOpacity:0.75,
    color:"white",
    fillColor: "blue",
    radius: 500
  }).bindPopup(`<h1></h1>`);

});

var granimInstance = new Granim({
  element: '#Granim',
  direction: 'left-right',
  isPausedWhenNotInView: true,
  states : {
      "default-state": {
          gradients: [
              ['#ff9966', '#ff5e62'],
              ['#00F260', '#0575E6'],
              ['#e1eec3', '#f05053']
          ]
      }
  }
})