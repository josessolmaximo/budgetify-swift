//
//  ImagePicker.swift
//  ExpenseTracker
//
//  Created by Joses Solmaximo on 18/11/22.
//

import SwiftUI
import PhotosUI

struct ImagePicker: UIViewControllerRepresentable {
    let isCameraSheetShown: Binding<String?>
    
    let callback: ((_ image: UIImage, _ imageData: Data) -> Void)?
    
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> PHPickerViewController {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 0
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
    
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: UIViewControllerRepresentableContext<ImagePicker>) {

    }

    func makeCoordinator() -> Coordinator {
        return ImagePicker.Coordinator(self)
    }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        var parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            if !results.isEmpty {
                for img in results {
                    if img.itemProvider.canLoadObject(ofClass: UIImage.self){
                        img.itemProvider.loadObject(ofClass: UIImage.self) { image, err in
                            guard let safeImage = image as? UIImage else {
                                Logger.e(err?.localizedDescription ?? "Error loading image")
                                return
                            }
                            
                            if let imageData = safeImage.jpegData(compressionQuality: 0.1) {
                                self.parent.callback?(safeImage, imageData)
                            }
                        }
                    }
                }
            } else {
                self.parent.isCameraSheetShown.wrappedValue = nil
            }
        }
    }
}

struct CameraPicker: UIViewControllerRepresentable {
    let callback: ((_ image: UIImage, _ imageData: Data) -> Void)?

    func makeUIViewController(context: UIViewControllerRepresentableContext<CameraPicker>) -> UIImagePickerController {

        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .camera
        
        imagePicker.delegate = context.coordinator

        return imagePicker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<CameraPicker>) {

    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

        var parent: CameraPicker

        init(_ parent: CameraPicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

            if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                if let imageData = image.jpegData(compressionQuality: 0.1){
                    self.parent.callback?(image, imageData)
                }
            }
        }
    }
}
