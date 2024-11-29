// Custom JavaScript for BGviewer
console.log("custom.js loaded successfully.");

Shiny.addCustomMessageHandler("updateGenomeMap", function (data) {
  console.log("Shiny.addCustomMessageHandler triggered");
  console.log("Raw JSON data received from R:", data);

  try {
    const genes = JSON.parse(data);
    console.log("Parsed genome data:", genes);

    // Clear previous visualization
    d3.select("#genome-map").selectAll("*").remove();

    // Get container dimensions
    const container = document.getElementById("genome-map");
    const containerWidth = container.offsetWidth || 800;
    const containerHeight = container.offsetHeight || 800;

    console.log(`Container dimensions: width=${containerWidth}, height=${containerHeight}`);

    // Create SVG canvas
    const svg = d3
      .select("#genome-map")
      .append("svg")
      .attr("width", containerWidth)
      .attr("height", containerHeight);

    console.log("SVG canvas created.");

    // Draw a filled rectangle for the genome background
    const rectPadding = 20; // Padding around the rectangle
    svg.append("rect")
      .attr("x", rectPadding)
      .attr("y", rectPadding)
      .attr("width", containerWidth - 2 * rectPadding)
      .attr("height", containerHeight - 2 * rectPadding)
      .attr("fill", "#f5f5f5") // Background color
      .attr("stroke", "black") // Border color
      .attr("stroke-width", 2);

    console.log("Genome rectangle rendered.");

    // Visualization logic for genes
    const genomeLength = Math.max(...genes.map((d) => d.end));
    const angleScale = d3
      .scaleLinear()
      .domain([0, genomeLength])
      .range([rectPadding, containerWidth - rectPadding]);

    genes.forEach((gene) => {
      // Map gene positions to rectangle dimensions
      const startX = angleScale(gene.start);
      const endX = angleScale(gene.end);

      // Draw a filled bar (gene) on the rectangle
      svg.append("rect")
        .attr("x", startX)
        .attr("y", rectPadding + 10) // Offset genes slightly below the rectangle border
        .attr("width", endX - startX)
        .attr("height", 20) // Gene bar height
        .attr("fill", "steelblue")
        .attr("stroke", "black")
        .attr("stroke-width", 1);

      // Add a label for each gene (optional)
      svg.append("text")
        .attr("x", (startX + endX) / 2) // Center the label
        .attr("y", rectPadding + 40) // Offset below the bar
        .attr("text-anchor", "middle")
        .attr("font-size", "10px")
        .text(gene.attributes); // Display gene name/ID
    });

    console.log("Genome map rendered with gene bars.");
  } catch (error) {
    console.error("Error in visualization logic:", error);
  }
});