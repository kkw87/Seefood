//
//  ViewController.swift
//  Seefood
//
//  Created by Kevin Wang on 11/6/18.
//  Copyright © 2018 Kevin Wang. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var photoImageView: UIImageView!
    
    // MARK: - Instance Variables
    private let imagePicker = UIImagePickerController()
    
    // MARK: - VC Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = false
    }
    
    
    // MARK: - Camera selection functions
    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    func detect(image : CIImage) {
        
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else {
            fatalError("Loading CoreML Model failed")
        }
        
        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("Model failed to process image")
            }
            

            if let firstResult = results.first {
                if firstResult.identifier.contains("hotdog") {
                    self.navigationItem.title = "Hot Dog"
                } else {
                    self.navigationItem.title = "Not hot dog"
                }
            }
            
        }
        
        let handler = VNImageRequestHandler(ciImage : image)
        
        do {
            try handler.perform([request])
        } catch {
            print(error)
        }
        
    }
    
}

extension ViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            return
        }
        
        guard let ciImage = CIImage(image: selectedImage) else {
            fatalError("Unable to convert image to CIImage")
        }
        
        detect(image: ciImage)
        photoImageView.image = selectedImage
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
}
