#import "template.typ": *

#show: academic-notes.with(
  // --- Required
  title: "Reti Wireless e Mobili",
  subtitle: "Unimi - Master's Degree in Computer Science",
  authors: (
    ("Luca Corradini", "LucaCorra02"),
    ("Andrea Galliano", "gallja"),
  ),
  lang: "it",

  // --- Optional, uncomment to change
  repo-url: "https://github.com/LucaCorra02/Reti-Wireless-Mobili",
  course-url: "https://www.unimi.it/it/corsi/insegnamenti-dei-corsi-di-laurea/2026/reti-wireless-e-mobili-0",
  year: "2025/26",
  lecturer: "Christian Quadri",
  // date: datetime.today(),
  // license: "CC-BY-4.0",
  // license-url: "https://creativecommons.org/licenses/by/4.0/",
  // heading-numbering: "1.1.",
  // equation-numbering: none,
  // page-numbering: "1",

  // --- Optional with language-based defaults, uncomment to change
  // introduction: auto,
  // last-modified-label: auto,
  // outline-title: auto,
  // part-label: auto,
  // note-title: auto,
  // warning-title: auto,
  // informally-title: auto,
  // example-title: auto,
  // proof-title: auto,
  // theorem-title: auto,
  // theorem-label: auto,
  // equation-supplement: auto,
  // figure-supplement: auto,
)

#part("Comunicazioni Wireless")
#include "chapters/Lezione1.typ"
#include "chapters/Lezione2.typ"
#include "chapters/Lezione3.typ"
#part("Wireless Personal Area Network (WPAN)")
#include "chapters/Lezione4.typ"
#include "chapters/Lezione15.typ"
