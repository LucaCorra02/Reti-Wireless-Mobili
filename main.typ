// Example usage of the academic-notes template
// This demonstrates how to use the template for academic notes

#import "template.typ": *

#show: academic-notes.with(
  // Required parameters
  title: "Reti Wireless e Mobili",
  subtitle: "Unimi - Master's Degree in Computer Science",
  authors: (
    ("Luca Corradini", "LucaCorra02"),
    ("Andrea Galliano", "terrons"),
  ),

  // Optional parameters (these have defaults if not specified)
  repo-url: "https://github.com/LucaCorra02/Reti-Wireless-Mobili",
  license: "CC-BY-4.0",
  license-url: "https://creativecommons.org/licenses/by/4.0/",
  last-modified-label: "Last modified", // Customize this (e.g., "Ultima modifica" for Italian)

  // Custom introduction (optional - if omitted, a default one is generated)
  introduction: [
    #show link: underline
  ],

  // Styling options (optional - these have sensible defaults)
  heading-numbering: "1.1.",
  figure-supplement: "Figure",
)

// ============================================================================
// YOUR CONTENT STARTS HERE
// ============================================================================

#part("Introduzione")
#include "chapters/Lezione1.typ"

#include "chapters/Lezione2.typ"
#include "chapters/Lezione3.typ"

