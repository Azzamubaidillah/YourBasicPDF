//
//  SignatureService.swift
//  YourBasicPDF
//
//  Created by Azzam Ubaidillah on 03/12/25.
//

import PDFKit
import SwiftUI

class SignatureService {
    
    func createSignatureAnnotation(image: NSImage, page: PDFPage, bounds: CGRect) -> PDFAnnotation {
        // Create a stamp annotation (or generic annotation with appearance stream)
        // PDFAnnotationSubtype.stamp is often used for signatures, or just a free text/ink.
        // But for an image, we usually use a stamp or a custom annotation.
        // Let's use a standard annotation and set its appearance.
        
        // let annotation = PDFAnnotation(bounds: bounds, forType: .stamp, withProperties: nil)
        
        // We need to set the appearance of the annotation to the image.
        // PDFKit doesn't make this super easy directly on PDFAnnotation without drawing.
        // However, we can subclass or just set the appearance.
        
        // A simpler way for "Stamp" is to just set the image if supported, but PDFAnnotation doesn't have an 'image' property directly exposed for all types.
        // Actually, for .stamp, we can try setting the appearance stream.
        
        // Alternative: Use a custom draw method.
        // But let's try to keep it standard.
        
        // Let's use a workaround: Draw the image into a PDFAppearanceStream or just subclass.
        // For MVP, let's try to use the standard way to add an image to a page:
        // Create a PDFAnnotation of type .stamp and set its appearance.
        
        // Actually, PDFKit on macOS allows `PDFAnnotation(bounds:forType:withProperties:)`.
        // We can draw the image in the `draw` method if we subclass.
        
        // Let's use a subclass for ImageAnnotation.
        
        return ImageStampAnnotation(image: image, bounds: bounds, properties: nil)
    }
}

class ImageStampAnnotation: PDFAnnotation {
    var image: NSImage?
    
    init(image: NSImage, bounds: CGRect, properties: [AnyHashable : Any]?) {
        self.image = image
        super.init(bounds: bounds, forType: .stamp, withProperties: properties)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func draw(with box: PDFDisplayBox, in context: CGContext) {
        guard let image = image else { return }
        guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else { return }
        
        context.saveGState()
        // Flip context because PDF coordinate system is bottom-up
        // But `draw` is usually called with a transform already?
        // PDFKit drawing is a bit tricky.
        // Let's try drawing directly.
        
        // Actually, `draw` provides a context where (0,0) is the origin of the page usually, or the annotation?
        // It's usually the page context.
        
        // Let's rely on the bounds.
        let rect = self.bounds
        
        // Draw image
        context.draw(cgImage, in: rect)
        
        context.restoreGState()
    }
}