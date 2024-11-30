console.log("basic_gbmap.js loaded successfully.");
console.log("Loaded D3.js version:", d3.version);

Shiny.addCustomMessageHandler("updateGenomeMap", function (data) {  
  console.log("Shiny.addCustomMessageHandler triggered");
  console.log("Data received from R:", data);

  const genes = data.genes;
  const genomeLength = data.genomeLength; // Extract genome length from R
  const filename = data.filename;

  console.log("Parsed genome data:", genes);
  console.log("Genome length:", genomeLength);
  console.log("Genome filename:", filename);

  try {
    // Clear previous visualization
    d3.select("#genome-map").selectAll("*").remove();

    // Get container dimensions
    const container = document.getElementById("genome-map");
    const containerWidth = container.offsetWidth || 800;
    const containerHeight = container.offsetHeight || 800;
    const radius = Math.min(containerWidth, containerHeight) / 2 - 40;

    console.log(`Container dimensions: width=${containerWidth}, height=${containerHeight}`);

    // Create SVG canvas with a group for zoom
    const svg = d3
      .select("#genome-map")
      .append("svg")
      .attr("id", "genome-svg")
      .attr("width", containerWidth)
      .attr("height", containerHeight);

    const zoomableGroup = svg
      .append("g") // Group to apply zoom transformations
      .attr("transform", `translate(${containerWidth / 2}, ${containerHeight / 2})`);

    console.log("SVG canvas created with zoomable group.");

    // Add zoom and pan behavior
    const zoom = d3.zoom()
      .scaleExtent([0.5, 10]) // Min and max zoom levels
      .on("zoom", function (event) {
        zoomableGroup.attr("transform", event.transform);
      });

    svg.call(zoom); // Attach zoom behavior to the SVG

    // Draw circular genome backbone
    zoomableGroup.append("circle")
      .attr("r", radius)
      .attr("fill", "none")
      .attr("stroke", "black")
      .attr("stroke-width", 1.5);

    zoomableGroup.append("circle")
      .attr("r", radius - 20)
      .attr("fill", "none")
      .attr("stroke", "black")
      .attr("stroke-width", 1.5);

    console.log("Genome circle rendered.");

    // Add filename to the center of the circle
    zoomableGroup.append("text")
      .attr("x", 0)
      .attr("y", 0)
      .attr("text-anchor", "middle")
      .attr("font-size", "24px")
      .attr("font-weight", "bold")
      .attr("fill", "black")
      .text(filename);

    console.log("Filename rendered at the center of the circle.");

    // Define angle scale
    const angleScale = d3
      .scaleLinear()
      .domain([0, genomeLength])
      .range([0, 2 * Math.PI]);

    let colors = { plus: "red", minus: "blue" }; // Strand colors

    genes.forEach((gene) => {
      const startAngle = angleScale(gene.start);
      const endAngle = angleScale(gene.end);

      const arc = d3.arc()
        .innerRadius(radius - 20)
        .outerRadius(radius)
        .startAngle(startAngle)
        .endAngle(endAngle);

      zoomableGroup.append("path")
        .attr("d", arc)
        .attr("fill", gene.strand === "+" ? colors.plus : colors.minus)
        .attr("stroke-width", 0.5);
    });

    console.log("Genome map rendered with features.");

    // Add legend with color pickers
    const legend = zoomableGroup.append("g")
      .attr("class", "legend")
      .attr("transform", `translate(${-radius}, ${-radius})`);
    
    // Plus strand legend
    const plusRect = legend.append("rect")
      .attr("x", 0)
      .attr("y", 0)
      .attr("width", 20)
      .attr("height", 20)
      .attr("fill", colors.plus);
    
    legend.append("text")
      .attr("x", 30)
      .attr("y", 15)
      .attr("font-size", "18px")
      .attr("fill", "black")
      .text("Plus strand (+)");
    
    legend.append("foreignObject")
      .attr("x", 0)
      .attr("y", 25)
      .attr("width", 120)
      .attr("height", 40)
      .append("xhtml:div")
      .html(`<input type="color" id="plus-color-picker" value="${colors.plus}" style="border: none; background: ${colors.plus};" />`);
    
    document.getElementById("plus-color-picker").addEventListener("input", function () {
      const newColor = this.value;
      colors.plus = newColor;
    
      plusRect.attr("fill", newColor);
    
      d3.selectAll("path")
        .filter((_, i) => genes[i].strand === "+")
        .attr("fill", newColor);
    });
    
    // Minus strand legend
    const minusRect = legend.append("rect")
      .attr("x", 0)
      .attr("y", 70)
      .attr("width", 20)
      .attr("height", 20)
      .attr("fill", colors.minus);
    
    legend.append("text")
      .attr("x", 30)
      .attr("y", 85)
      .attr("font-size", "18px")
      .attr("fill", "black")
      .text("Minus strand (-)");
    
    legend.append("foreignObject")
      .attr("x", 0)
      .attr("y", 95)
      .attr("width", 190)
      .attr("height", 40)
      .append("xhtml:div")
      .html(`<input type="color" id="minus-color-picker" value="${colors.minus}" style="border: none; background: ${colors.minus};" />`);
    
    document.getElementById("minus-color-picker").addEventListener("input", function () {
      const newColor = this.value;
      colors.minus = newColor;
    
      minusRect.attr("fill", newColor);
    
      d3.selectAll("path")
        .filter((_, i) => genes[i].strand === "-")
        .attr("fill", newColor);
    });
    
      console.log("Legend with color pickers added and updated.");
    } catch (error) {
      console.error("Error in visualization logic:", error);
    }
  });

  // Add a download button for SVG
  d3.select("#genome-map").append("button")
    .attr("id", "download-svg")
    .style("position", "absolute")
    .style("top", "10px")
    .style("right", "150px")
    .text("Download SVG")
    .on("click", function () {
      const svgElement = document.getElementById("genome-svg");
      const serializer = new XMLSerializer();
      const svgString = serializer.serializeToString(svgElement);
      const blob = new Blob([svgString], { type: "image/svg+xml" });
      const url = URL.createObjectURL(blob);

      const link = document.createElement("a");
      link.href = url;
      link.download = `${filename || "genome_map"}.svg`;
      document.body.appendChild(link);
      link.click();
      document.body.removeChild(link);

      console.log("SVG downloaded.");
    });
    
  
  // Add a download button for PNG

  d3.select("#genome-map").append("button")
    .attr("id", "download-png")
    .style("position", "absolute")
    .style("top", "10px")
    .style("right", "20px")
    .text("Download PNG")
    .on("click", function exportToPNG() {
      const svg = document.getElementById("genome-svg");
  
      // Create a canvas
      const canvas = document.createElement("canvas");
      const context = canvas.getContext("2d");
  
      // Match canvas size to SVG size
      const bbox = svg.getBoundingClientRect();
      canvas.width = bbox.width;
      canvas.height = bbox.height;
  
      // Add a white background
      context.fillStyle = "white";
      context.fillRect(0, 0, canvas.width, canvas.height);
  
      // Extract SVG string and embed font styles
      let svgString = new XMLSerializer().serializeToString(svg);
  
      // Add font styles explicitly, including font size
      svgString = svgString.replace(
        "<svg",
        `<svg xmlns="http://www.w3.org/2000/svg">
         <style>
           text {
             font-family: Arial, sans-serif;
             font-size: 20px; /* Match the font size used in the visualization */
           }
         </style>`
      );
  
      const img = new Image();
      img.onload = function () {
        // Draw the SVG onto the canvas
        context.drawImage(img, 0, 0);
  
        // Export the canvas to a PNG data URL
        const pngDataUrl = canvas.toDataURL("image/png");
  
        // Trigger a download
        const link = document.createElement("a");
        link.href = pngDataUrl;
        link.download = `${filename || "genome_map"}.png`;
        document.body.appendChild(link);
        link.click();
        document.body.removeChild(link);
  
        console.log("PNG downloaded.");
      };
  
      // Handle CORS issues by encoding the SVG
      img.crossOrigin = "anonymous";
      img.src = "data:image/svg+xml;base64," + btoa(unescape(encodeURIComponent(svgString)));
    });
  
    
    
  