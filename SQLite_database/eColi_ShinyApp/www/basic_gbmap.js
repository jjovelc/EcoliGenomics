// Review this code and fix any syntax or logical errors.

Shiny.addCustomMessageHandler("updateGenomeMap", function (data) {
  console.log("Shiny.addCustomMessageHandler triggered");
  console.log("Data received from R:", data);

  const genes = data.genes;
  const genomeLength = data.genomeLength;
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

    // Create SVG canvas with zoom functionality
    const svg = d3
      .select("#genome-map")
      .append("svg")
      .attr("id", "genome-svg")
      .attr("width", containerWidth)
      .attr("height", containerHeight);

    // Create a main group for zooming
    const zoomGroup = svg.append("g");

    // Add zoom functionality
    const zoom = d3.zoom()
      .scaleExtent([0.5, 5]) // Limit zoom levels
      .on("zoom", function(event) {
        zoomGroup.attr("transform", event.transform);
      });

    svg.call(zoom);

    // Create the main zoomable group, centered in the SVG
    const zoomableGroup = zoomGroup
      .append("g")
      .attr("transform", `translate(${containerWidth / 2}, ${containerHeight / 2})`);

    console.log("SVG canvas created.");

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
    const filenameText = zoomableGroup.append("text")
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

    let colors = { plus: "#FF0000", minus: "#0000FF" }; // Strand colors

    // Draw genes
    const genePaths = zoomableGroup.selectAll(".gene-path")
      .data(genes)
      .enter()
      .append("path")
      .attr("class", "gene-path")
      .each(function(gene) {
        const startAngle = angleScale(gene.start);
        const endAngle = angleScale(gene.end);

        const arc = d3.arc()
          .innerRadius(radius - 20)
          .outerRadius(radius)
          .startAngle(startAngle)
          .endAngle(endAngle);

        d3.select(this)
          .attr("d", arc)
          .attr("fill", gene.strand === "+" ? colors.plus : colors.minus)
          .attr("stroke-width", 0.5);
      });

    console.log("Genome map rendered with features.");

    // Improved gene label deployment
    function deployGeneLabels() {
      // Remove existing labels
      zoomableGroup.selectAll(".gene-label").remove();

      // Add labels
      const labels = zoomableGroup.selectAll(".gene-label")
        .data(genes)
        .enter()
        .append("text")
        .attr("class", "gene-label")
        .attr("x", d => {
          const midAngle = (angleScale(d.start) + angleScale(d.end)) / 2;
          return (radius + 10) * Math.cos(midAngle - Math.PI / 2);
        })
        .attr("y", d => {
          const midAngle = (angleScale(d.start) + angleScale(d.end)) / 2;
          return (radius + 10) * Math.sin(midAngle - Math.PI / 2);
        })
        .attr("text-anchor", "middle")
        .attr("font-size", "10px")
        .attr("fill", "black")
        .text(d => d.name)
        .attr("pointer-events", "none"); // Prevent labels from interfering with zooming
    }

    // Call the deployGeneLabels function
    deployGeneLabels();

    // Add legend with color pickers (now part of the zoomable group)
    const legend = zoomableGroup.append("g")
      .attr("class", "legend")
      .attr("transform", `translate(${-containerWidth / 2 + 20}, ${-containerHeight / 2 + 20})`);
    
    // Plus strand legend
    const plusRect = legend.append("rect")
      .attr("x", 0)
      .attr("y", 0)
      .attr("width", 20)
      .attr("height", 20)
      .attr("fill", colors.plus)
      .attr("stroke", "#000000");
    
    const plusLegendText = legend.append("text")
      .attr("x", 30)
      .attr("y", 15)
      .attr("font-size", "12px")
      .attr("fill", "black")
      .text("Plus strand (+)");
    
    // Add color picker for the plus strand
    legend.append("foreignObject")
      .attr("x", 0)
      .attr("y", 25)
      .attr("width", 120)
      .attr("height", 40)
      .append("xhtml:div")
      .html(`<input type="color" id="plus-color-picker" value="${colors.plus}" style="border: none;" />`);
    
    // Minus strand legend
    const minusRect = legend.append("rect")
      .attr("x", 0)
      .attr("y", 70)
      .attr("width", 20)
      .attr("height", 20)
      .attr("fill", colors.minus)
      .attr("stroke", "#000000");
    
    const minusLegendText = legend.append("text")
      .attr("x", 30)
      .attr("y", 85)
      .attr("font-size", "12px")
      .attr("fill", "black")
      .text("Minus strand (-)");
    
    // Add color picker for the minus strand
    legend.append("foreignObject")
      .attr("x", 0)
      .attr("y", 95)
      .attr("width", 120)
      .attr("height", 40)
      .append("xhtml:div")
      .html(`<input type="color" id="minus-color-picker" value="${colors.minus}" style="border: none;" />`);
    
    // Color picker event listeners
    document.getElementById("plus-color-picker").addEventListener("input", function () {
      const newColor = this.value;
      colors.plus = newColor;
    
      plusRect.attr("fill", newColor);
      zoomableGroup.selectAll("path")
        .filter((_, i) => genes[i].strand === "+")
        .attr("fill", newColor);
    });
    
    document.getElementById("minus-color-picker").addEventListener("input", function () {
      const newColor = this.value;
      colors.minus = newColor;
    
      minusRect.attr("fill", newColor);
      zoomableGroup.selectAll("path")
        .filter((_, i) => genes[i].strand === "-")
        .attr("fill", newColor);
    });

    // Existing download functionality remains the same
    function formatText() {
      // Synchronize colors for download
      plusRect.attr("fill", colors.plus);
      minusRect.attr("fill", colors.minus);
      
      // Ensure text styles are consistent
      filenameText
        .attr("font-size", "24px")
        .attr("font-weight", "bold")
        .attr("font-family", "Arial, sans-serif");
      
      plusLegendText
        .attr("font-size", "18px")
        .attr("font-family", "Arial, sans-serif");
      
      minusLegendText
        .attr("font-size", "18px")
        .attr("font-family", "Arial, sans-serif");
    }
    
    // Add buttons for downloading SVG and PNG
    d3.select("#genome-map")
      .style("position", "relative") // Ensure parent is positioned for absolute positioning
      .append("div")
      .attr("id", "button-container") // Add a unique ID for the container
      .style("position", "absolute")
      .style("top", "10px")
      .style("right", "20px")
      .style("z-index", "10") // Ensure it appears above the SVG
      .html(`
        <button id="download-svg" style="margin-right: 10px;">Download SVG</button>
        <button id="download-png">Download PNG</button>
      `);


    // Download buttons functionality
    document.getElementById("download-svg").addEventListener("click", function () {
      formatText();
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
    });

    document.getElementById("download-png").addEventListener("click", function () {
      formatText();
      const svg = document.getElementById("genome-svg");
      const canvas = document.createElement("canvas");
      const context = canvas.getContext("2d");
      const bbox = svg.getBoundingClientRect();
      canvas.width = bbox.width;
      canvas.height = bbox.height;

      context.fillStyle = "white";
      context.fillRect(0, 0, canvas.width, canvas.height);

      const svgString = new XMLSerializer().serializeToString(svg);
      const img = new Image();
      img.onload = function () {
        context.drawImage(img, 0, 0);
        const pngDataUrl = canvas.toDataURL("image/png");
        const link = document.createElement("a");
        link.href = pngDataUrl;
        link.download = `${filename || "genome_map"}.png`;
        document.body.appendChild(link);
        link.click();
        document.body.removeChild(link);
      };
      img.src = "data:image/svg+xml;base64," + btoa(svgString);
    });

  } catch (error) {
    console.error("Error in visualization logic:", error);
  }
});