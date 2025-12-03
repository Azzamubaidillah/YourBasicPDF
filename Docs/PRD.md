PRD: Project “Acrobat Replacement” (Strategic, Achievable Scope)

A Modern, Lightweight, Fast macOS PDF Editor Built with SwiftUI + PDFKit

(Updated Version with Additional Features)

⸻

1. Strategic Positioning

Instead of replicating 100% of Adobe Acrobat’s enterprise/enterprise-tier capabilities, this PRD targets the 80% of Acrobat workflows real users perform daily, delivering them in a cleaner, faster, Apple-native UI.

🚀 Goal

Replace 80% of Acrobat’s daily workflow for 95% of normal users, without the lag, bloat, or subscription lock-in.

🎯 Non-goal
	•	No deep enterprise features:
digital certificates, PDF/A validation, deep JS forms, accessibility tagging.
	•	No server/cloud dependency.
	•	No true PDF content-stream rewriting.

🏆 Positioning Statement

A modern macOS PDF editor that delivers everything users actually need from Acrobat—fast, offline, simple, and beautifully native.

⸻

2. Core Value Proposition

✔️ Fast PDF engine using SwiftUI + CoreGraphics
✔️ All essential daily PDF editing tools
✔️ Modern Apple-native UI
✔️ Fully offline
✔️ Bloat-free Acrobat alternative
✔️ One-time purchase model

⸻

3. User Personas

1. Knowledge Workers

Legal, HR, finance → combine, annotate, sign, export, organize.

2. Students

Highlight, annotate, combine lecture notes, compress scans.

3. Designers & Creatives

Quick edits without opening Adobe.

4. Developers & PMs

Clean metadata, reorder pages, extract sections.

5. Administrators

Compress scanned PDFs under upload limits.

⸻

4. Feature Prioritization

(All features below are now updated to include your requests)

⸻

Tier 1 — MVP (Replace ~60% of Acrobat Usage)

🔹 PDF Operations
	•	Merge PDFs
	•	Split PDFs (range, presets, auto-split)
	•	Extract pages
	•	Delete pages
	•	Reorder pages (drag-and-drop)
	•	Rotate pages (90° / 180° / 270°)
	•	Add blank pages (A4/Letter)
	•	Insert pages from another PDF
	•	Organize pages visually

🔹 PDF Compression
	•	Presets: High / Medium / Low
	•	Manual quality slider
	•	Downscale images (auto)
	•	Estimated output size preview

🔹 PDF Viewer
	•	Sidebar thumbnails
	•	Page scrubber
	•	Zoom, fit-to-width, continuous scroll
	•	Dark mode
	•	Multi-page layout preview

🔹 Metadata Editing
	•	Title
	•	Author
	•	Subject
	•	Keywords

🔹 Signatures & Forms
	•	Add handwritten signature
	•	Add image signature
	•	Fill AcroForm fields

⸻

Tier 2 — Productivity Tools (Replace 75–80% of Acrobat Usage)

🔹 Annotation Tools
	•	Highlight text
	•	Underline / strikethrough
	•	Sticky note / comment
	•	Freehand drawing
	•	Shapes: rectangle, circle, arrow
	•	Add text boxes
	•	Adjustable opacity, color, thickness

🔹 Export Tools
	•	Export selected pages
	•	Export pages to PNG/JPEG
	•	Batch export
	•	JPG ⇄ PDF conversion
	•	Import JPG/PNG → convert to PDF
	•	Export PDF pages → JPG/PNG

🔹 Watermark / Page Numbering
	•	Add text watermark (position, opacity, rotation)
	•	Add image watermark (logo)
	•	Add page numbers (header/footer, margins, styles)

🔹 PDF Password Tools
	•	Unlock password-protected PDFs (if user knows password)
	•	Protect PDFs with:
	•	User password (open)
	•	Owner password (permissions)
	•	Permissions: printing / copying / editing

⸻

Tier 3 — Advanced Features (Optional, For Later Versions)

(Still achievable, but secondary priority)

🔸 OCR (VisionKit / Tesseract local)
🔸 True redaction (content removal)
🔸 Encryption presets
🔸 PDF/A export
🔸 Accessibility tagging (very low priority)

⸻

5. User Experience & UI Philosophy

🎨 Guiding Principles
	•	Minimal and macOS-native
	•	Zero clutter
	•	Drag-and-drop everywhere
	•	One-screen productivity
	•	Real-time previews
	•	Non-blocking operations (async)

Layout
	•	Sidebar: thumbnails, reorder, delete
	•	Toolbar: Merge | Split | Compress | Annotate | Sign | Edit | Protect
	•	Canvas: PDFKitView
	•	Right Panel: tool properties (color, size, watermark options, metadata fields)

⸻

6. Technical Architecture

Frameworks
	•	SwiftUI — app structure & UI
	•	PDFKit — viewing, basic page operations
	•	CoreGraphics (Quartz) — compression, rendering, watermarking, password protection
	•	Combine — state management
	•	FileManager + UTType — file IO

Architecture
	•	MVVM
	•	PDFEditorViewModel — master state & logic
	•	PDFService — splitting/merging/export/watermark/password
	•	CompressionEngine — image downscale + JPEG re-render
	•	AnnotationService — highlight, notes, shapes, text boxes
	•	SecurityEngine — password protect/unlock

⸻

7. Milestones & Timeline

Phase 1 — MVP (3–4 weeks)
	•	Core viewer
	•	Merge/split/organize/reorder/delete pages
	•	Compression engine
	•	Export tools
	•	Metadata editor
	•	Signing + form filling
	•	JPG ⇄ PDF conversion
	•	Page rotation + blank pages
	•	Basic password protection/unlock

Phase 2 — Annotation Suite (3–4 weeks)
	•	Highlights
	•	Drawing
	•	Text boxes
	•	Notes/comments
	•	Shapes
	•	UI for annotations panel

Phase 3 — Extended Tools (2–4 weeks)
	•	Watermark tools
	•	Page numbering
	•	Batch exports
	•	Advanced export styles

Phase 4 — Optional Advanced Features (4–8 weeks)
	•	OCR
	•	Redaction
	•	PDF/A
	•	Accessibility tagging

⸻

8. Risks & Mitigations

Risk	Mitigation
PDFKit limitations	Offload to Quartz for rendering/writing
Large file memory pressure	Pagination, async render queues
Annotation engine complexity	Build modular annotation architecture
Password protection edge cases	Thorough tests with various PDF versions
Watermark and page-number alignment	Live preview & flexible layout system


⸻

9. Differentiators vs Adobe Acrobat

✔️ Simpler & cleaner
✔️ Faster & native
✔️ Zero cloud dependencies
✔️ One-time purchase pricing
✔️ Lightweight but powerful
✔️ Apple-native gestures, animations, color schemes
