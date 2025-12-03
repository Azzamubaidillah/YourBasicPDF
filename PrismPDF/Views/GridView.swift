//
//  GridView.swift
//  YourBasicPDF
//
//  Created by Azzam Ubaidillah on 03/12/25.
//

import SwiftUI
import PDFKit
internal import UniformTypeIdentifiers

struct GridView: View {
    @ObservedObject var viewModel: PDFEditorViewModel
    
    let columns = [
        GridItem(.adaptive(minimum: 150))
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 20) {
                if let document = viewModel.pdfDocument {
                    ForEach(0..<document.pageCount, id: \.self) { index in
                        if let page = document.page(at: index) {
                            VStack {
                                Image(nsImage: page.thumbnail(of: CGSize(width: 140, height: 200), for: .artBox))
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(height: 180)
                                    .shadow(radius: 2)
                                
                                Text("Page \(index + 1)")
                                    .font(.caption)
                            }
                            .padding()
                            .background(viewModel.currentPage == page ? Color.accentColor.opacity(0.1) : Color.clear)
                            .cornerRadius(8)
                            .onTapGesture {
                                viewModel.scrollToPage(page)
                            }
                            .onDrag {
                                NSItemProvider(object: String(index) as NSString)
                            }
                            .onDrop(of: [.text], delegate: PageDropDelegate(viewModel: viewModel, pageIndex: index))
                        }
                    }
                }
            }
            .padding()
        }
    }
}

struct PageDropDelegate: DropDelegate {
    let viewModel: PDFEditorViewModel
    let pageIndex: Int
    
    func performDrop(info: DropInfo) -> Bool {
        guard let item = info.itemProviders(for: [.text]).first else { return false }
        
        item.loadItem(forTypeIdentifier: "public.text", options: nil) { (data, error) in
            if let data = data as? Data, let text = String(data: data, encoding: .utf8), let fromIndex = Int(text) {
                DispatchQueue.main.async {
                    if fromIndex != pageIndex {
                        viewModel.movePages(from: IndexSet(integer: fromIndex), toOffset: pageIndex)
                    }
                }
            }
        }
        return true
    }
}