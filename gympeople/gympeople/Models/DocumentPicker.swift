//
//  DocumentPicker.swift
//  gympeople
//
//  Created by Nathanael Tesfaye on 12/7/25.
//

import SwiftUI
import UniformTypeIdentifiers

struct DocumentPicker: UIViewControllerRepresentable {
    @Binding var documentData: Data?
    @Binding var fileName: String?
    @Environment(\.dismiss) var dismiss
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [
            UTType.pdf,
            UTType.image,
            UTType.jpeg,
            UTType.png
        ], asCopy: true)
        picker.delegate = context.coordinator
        picker.allowsMultipleSelection = false
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let parent: DocumentPicker
        
        init(_ parent: DocumentPicker) {
            self.parent = parent
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else {
                LOG.debug("No URL selected")
                parent.dismiss()
                return
            }
            
            LOG.debug("Document picked: \(url.lastPathComponent)")
            
            // Store the filename
            parent.fileName = url.lastPathComponent
            
            // Since we're using asCopy: true, we can access the file directly
            do {
                let data = try Data(contentsOf: url)
                LOG.debug("Read \(data.count) bytes from document")
                parent.documentData = data
            } catch {
                LOG.error("Failed to read document: \(error)")
            }
            
            parent.dismiss()
        }
        
        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            parent.dismiss()
        }
    }
}
