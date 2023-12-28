function expand() {
    let expanded = document.getElementById("expanded");
    
    if (expanded.style.display == "block") {
        expanded.style.display = "none";
    } else if (expanded.style.display == "none") {
        expanded.style.display = "block";
    }
}