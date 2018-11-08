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
    
    // MARK: - Constants
    struct Constants {
        static let IsAHotDogMessage = "Hotdog"
        static let IsNotAHotDogMessage = "Not hotdog"
    }
    
    // MARK: - Outlets
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var hotDogDisplay: UIImageView!
    @IBOutlet weak var backgroundHotDogView: UIImageView!
    
    // MARK: - Instance Variables
    private let imagePicker = UIImagePickerController()
    
    private var currentImage : UIImage? {
        get {
            return photoImageView.image
        } set {
            photoImageView.image = newValue
            backgroundHotDogView.isHidden = true
            imagePicker.dismiss(animated: true, completion: nil)
        }
    }
    
    private var isAhotDog = false {
        didSet {
            if isAhotDog {
                self.navigationItem.title = Constants.IsAHotDogMessage
                self.navigationController?.navigationBar.barTintColor = UIColor.green
                self.navigationController?.navigationBar.isTranslucent = false
                hotDogDisplay.image = UIImage(named: "hotdog")
            } else {
                self.navigationItem.title = Constants.IsNotAHotDogMessage
                self.navigationController?.navigationBar.barTintColor = UIColor.red
                self.navigationController?.navigationBar.isTranslucent = false
                hotDogDisplay.image = UIImage(named: "not-hotdog")
            }
        }
    }
    
    
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
    
    private func detect(image : CIImage) {
        
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else {
            fatalError("Loading CoreML Model failed")
        }
        
        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("Model failed to process image")
            }
            

            if let firstResult = results.first {
                if firstResult.identifier.contains("hotdog") {
                        self.isAhotDog = true
                } else {
                        self.isAhotDog = false
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
        currentImage = selectedImage
    }
    
}
