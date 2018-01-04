//
//  ViewController.swift
//  seeFood
//
//  Created by Kullapat siribodhi on 1/4/2561 BE.
//  Copyright © 2561 Kullapat siribodhi. All rights reserved.
//

import UIKit
import CoreML
import Vision
import ChameleonFramework

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    
    let imagePicker = UIImagePickerController()
    
//    let imagePickerController = ImagePickerController()
  
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
    }
    

    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let userPickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
             imageView.image = userPickedImage

            guard let ciimage =  CIImage(image: userPickedImage) else {
                fatalError("Could not convert UIImage to CIImage")
            }

            detect(image: ciimage)
        }
        imagePicker.dismiss(animated: true, completion: nil)

    }
    
    func detect(image: CIImage){
        
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else{
            fatalError("CoreML Failed")
        }
        
        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("Model failed to process image")
            }
            
            
            if let firstResult = results.first{
                
                let textAttribute = [NSAttributedStringKey.foregroundColor:UIColor.white]
                self.navigationController?.navigationBar.titleTextAttributes = textAttribute
                self.cameraButton.tintColor = UIColor.white
                
                if firstResult.identifier.contains("hotdog"){
                    self.navigationItem.title = "Hot Dog : \(String(firstResult.confidence*100))%"
                    self.navigationController?.navigationBar.barTintColor = UIColor.flatGreen
                } else {
                    self.navigationItem.title = "Not Hot Dog!"
                    self.navigationController?.navigationBar.barTintColor = UIColor.flatRed
                }
            
                print("\(firstResult.identifier)")
            }else{
                fatalError("Error")
            }
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        do {
            try handler.perform([request])
        }catch {
            print(error)
        }
        
        
    }
  
    @IBAction func cameraTapped(_ sender: Any) {
        present(imagePicker, animated: true, completion: nil)

    }
    

}

