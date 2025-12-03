//
//  ConversionService.swift
//  YourBasicPDF
//
//  Created by Azzam Ubaidillah on 03/12/25.
//

import PDFKit
import SwiftUI

class ConversionService {
    
    func imagesToPDF(images: [NSImage]) -> PDFDocument {
        let pdfDocument = PDFDocument()
        
        for (index, image) in images.enumerated() {
            if let page = PDFPage(image: image) {
                pdfDocument.insert(page, at: index)
            }
        }
        
        return pdfDocument
    }
    
    func pdfToImages(document: PDFDocument) -> [URL] {
        var imageURLs: [URL] = []
        let tempDir = FileManager.default.temporaryDirectory
        
        for i in 0..<document.pageCount {
            guard let page = document.page(at: i) else { continue }
            let pageRect = page.bounds(for: .mediaBox)
            // let renderer = ImageRenderer(content: Image(nsImage: page.thumbnail(of: pageRect.size, for: .mediaBox)))
            
            // Note: PDFPage.thumbnail might be low res. 
            // Better approach for high quality export:
            // Use PDFPage.draw(with:in:) into a CGContext backed by an image.
            
            let imageSize = pageRect.size
            let image = NSImage(size: imageSize)
            image.lockFocus()
            if let context = NSGraphicsContext.current?.cgContext {
                context.setFillColor(NSColor.white.cgColor)
                context.fill(pageRect)
                page.draw(with: .mediaBox, to: context)
            }
            image.unlockFocus()
            
            if let tiffData = image.tiffRepresentation,
               let bitmap = NSBitmapImageRep(data: tiffData),
               let pngData = bitmap.representation(using: .png, properties: [:]) {
                
                let fileName = "page_\(i + 1).png"
                let fileURL = tempDir.appendingPathComponent(fileName)
                
                do {
                    try pngData.write(to: fileURL)
                    imageURLs.append(fileURL)
                } catch {
                    print("Error saving image: \(error)")
                }
            }
        }
        
        return imageURLs
    }
}