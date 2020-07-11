

//set the dimensions and margins of the graph
var margin = {top: 10, right: 30, bottom: 30, left: 60},
    width = 800 - margin.left - margin.right,
    height = 600 - margin.top - margin.bottom;

// append the svg object to the body of the page
var svg = d3.select("#scatter_weather")
  .append("svg")
    .attr("width", width + margin.left + margin.right)
    .attr("height", height + margin.top + margin.bottom)
   .append("g")
     .attr("transform",
           "translate(" + margin.left + "," + margin.top + ")");


//Read the data
d3.csv("weather_scatter2.csv").then(function(weather) {
    console.log(weather);
    var tempVisibilityCounts = {};

    weather.forEach(function(data) {
        var t = Math.round(+data["Temperature(F)"]);
        var v = Math.round(+data["Visibility(mi)"]);
        var key = `t${t}v${v}`;
        if(!tempVisibilityCounts[key]) {
            tempVisibilityCounts[key] = {
                "Temperature": t,
                "Visibility": v,
                "Count": 0
            };
        }
        tempVisibilityCounts[key]["Count"]++;
      });
      console.log(tempVisibilityCounts);
      console.log(Object.keys(tempVisibilityCounts).length);
  // Add X axis
  var x = d3.scaleLinear()
    .domain([-20, 120])
    .range([ 0, width ]);
  svg.append("g")
    .attr("transform", "translate(0," + height + ")")
    .call(d3.axisBottom(x));

  // Add Y axis
  var y = d3.scaleLinear()
    .domain([0, 13])
    .range([ height, 0]);
  svg.append("g")
    .call(d3.axisLeft(y));

  // Add dots
   svg.append('g')
     .selectAll("circle")
     .data(Object.values(tempVisibilityCounts))
     .enter()
    .append("circle")
      .attr("cx", d => x(d["Temperature"]) )
      .attr("cy", d => y(d["Visibility"]) )
      .attr("r", d => d["Count"]/300)
      .style("fill", "#69b3a2")

})
.catch(function(err) { console.log(err) ;});
