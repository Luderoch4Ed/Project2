d3.csv("multibar_drunk.csv").then(
    function(data) {
        // Trace1 for the Greek Data
        var trace1 = {
            x: data.map(row => row.post_code),
            y: data.map(row => row.total_count),
            text: data.map(row => row.state),
            name: "Total Accident",
            type: "bar"
        };
        
        // Trace 2 for the Roman Data
        var trace2 = {
            x: data.map(row => row.post_code),
            y: data.map(row => row.DRUNK_DR),
            text: data.map(row => row.state),
            name: "Drunk Driving",
            type: "bar"
        };
        
        // Combining both traces
        var data = [trace1, trace2];
        
        // Apply the group barmode to the layout
        var layout = {
            title: "Total Accidents VS Drunk Driving",
            barmode: "group"
        };
        
        // Render the plot to the div tag with id "plot"
        Plotly.newPlot("multibar", data, layout);
    }
)

  