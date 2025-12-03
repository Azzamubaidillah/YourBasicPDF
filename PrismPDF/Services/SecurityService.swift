//
//  SecurityService.swift
//  YourBasicPDF
//
//  Created by Azzam Ubaidillah on 03/12/25.
//

import PDFKit

class SecurityService {
    
    func protectPDF(document: PDFDocument, userPassword: String?, ownerPassword: String?) -> URL? {
        let tempDir = FileManager.default.temporaryDirectory
        let outputURL = tempDir.appendingPathComponent(UUID().uuidString).appendingPathExtension("pdf")
        
        var options: [PDFDocumentWriteOption: Any] = [:]
        
        if let userPass = userPassword, !userPass.isEmpty {
            options[.userPasswordOption] = userPass
        }
        
        if let ownerPass = ownerPassword, !ownerPass.isEmpty {
            options[.ownerPasswordOption] = ownerPass
        }
        
        // If no passwords, just write normally
        
        // If no passwords, just write normally
        
        if document.write(to: outputURL, withOptions: options) {
            return outputURL
        } else {
            print("Error protecting PDF: Write failed")
            return nil
        }
    }
    
    func unlockPDF(url: URL, password: String) -> PDFDocument? {
        if let document = PDFDocument(url: url) {
            if document.isLocked {
                if document.unlock(withPassword: password) {
                    return document
                } else {
                    return nil // Wrong password
                }
            } else {
                return document // Not locked
            }
        }
        return nil
    }
}