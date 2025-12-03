//
//  SignatureCanvasView.swift
//  YourBasicPDF
//
//  Created by Azzam Ubaidillah on 03/12/25.
//

import SwiftUI
import AppKit

struct Line {
    var points: [CGPoint]
    var color: Color = .black
    var lineWidth: CGFloat = 2.0
}

struct SignatureCanvasView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: PDFEditorViewModel
    
    @State private var lines: [Line] = []
    @State private var currentLine: Line = Line(points: [])
    
    var body: some View {
        VStack {
            HStack {
                Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
                Spacer()
                Text("Sign Here")
                    .font(.headline)
                Spacer()
                Button("Done") {
                    saveSignature()
                    presentationMode.wrappedValue.dismiss()
                }
            }
            .padding()
            
            Canvas { context, size in
                for line in lines {
                    var path = Path()
                    path.addLines(line.points)
                    context.stroke(path, with: .color(line.color), lineWidth: line.lineWidth)
                }
                
                // Draw current line
                var path = Path()
                path.addLines(currentLine.points)
                context.stroke(path, with: .color(currentLine.color), lineWidth: currentLine.lineWidth)
            }
            .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .local)
                .onChanged({ value in
                    let newPoint = value.location
                    if currentLine.points.isEmpty {
                        currentLine.points.append(newPoint)
                    } else {
                        currentLine.points.append(newPoint)
                    }
                })
                .onEnded({ value in
                    lines.append(currentLine)
                    currentLine = Line(points: [])
                })
            )
            .frame(height: 300)
            .background(Color.white)
            .border(Color.gray, width: 1)
            .padding()
            .onHover { inside in
                if inside {
                    NSCursor.crosshair.push()
                } else {
                    NSCursor.pop()
                }
            }
            
            Button("Clear") {
                lines = []
                currentLine = Line(points: [])
            }
            .padding(.bottom)
        }
        .frame(width: 500, height: 400)
    }
    
    private func saveSignature() {
        let image = generateImage()
        viewModel.addSignature(image)
    }
    
    private func generateImage() -> NSImage {
        let size = CGSize(width: 500, height: 300)
        let image = NSImage(size: size)
        
        image.lockFocus()
        if let context = NSGraphicsContext.current?.cgContext {
            context.setFillColor(NSColor.clear.cgColor)
            context.fill(CGRect(origin: .zero, size: size))
            
            context.setStrokeColor(NSColor.black.cgColor)
            context.setLineWidth(2.0)
            context.setLineCap(.round)
            context.setLineJoin(.round)
            
            for line in lines {
                context.beginPath()
                if let first = line.points.first {
                    context.move(to: first)
                    for point in line.points.dropFirst() {
                        context.addLine(to: point)
                    }
                }
                context.strokePath()
            }
        }
        image.unlockFocus()
        
        return image
    }
}