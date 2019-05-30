//
//  ViewController.swift
//  FaceFinder
//
//  Created by Mahesh Prasad on 30/05/19.
//  Copyright © 2019 CreatesApps. All rights reserved.
//

import UIKit
import Vision
class ViewController: UIViewController {

    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var msgLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        spinner.hidesWhenStopped = true
        setupImageView()
    }

    func setupImageView() {
        guard let image = UIImage(named: "download") else {return}
        
        guard let cgImage = image.cgImage else {
            print("Could not find CGImage")
            return
        }
        
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        
        let scaleHeight = (view.frame.width/image.size.width) * image.size.height
        
        
        imageView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: scaleHeight)
        view.addSubview(imageView)
        spinner.startAnimating()
        
        DispatchQueue.global(qos: .background).async {
            self.performVisionRequest(for: cgImage,with: scaleHeight)
        }
        
        
    }
    
    
    func createFaceOutline(for rectange: CGRect) {
        let yellowView = UIView()
        yellowView.backgroundColor = .clear
        yellowView.layer.borderColor = UIColor.yellow.cgColor
        yellowView.layer.borderWidth = 3
        yellowView.layer.cornerRadius = 0
        yellowView.alpha = 0.0
        yellowView.frame = rectange
        self.view.addSubview(yellowView)
        
        UIView.animate(withDuration: 0.3) {
            yellowView.alpha = 0.75
            self.spinner.alpha = 0.0
            self.msgLabel.alpha = 0.0
        }
        self.spinner.stopAnimating()
    }
    
    
    
    func performVisionRequest(for image: CGImage, with scaleHeight: CGFloat) {
        let faceDetectionRequest = VNDetectFaceRectanglesRequest { (request, error) in
            if let error = error {
                print("Failed to detect face:",error)
                return
            }
            
            request.results?.forEach({ (result) in
                guard let faceObservation = result as? VNFaceObservation else {return}
                
                DispatchQueue.main.async {
                    let width = self.view.frame.width * faceObservation.boundingBox.width
                    let height = scaleHeight * faceObservation.boundingBox.height
                    let x = self.view.frame.width * faceObservation.boundingBox.origin.x
                    let y = scaleHeight * (1-faceObservation.boundingBox.origin.y) - height
                    
                    let faceRectangle = CGRect(x: x, y: y, width: width, height: height)
                    self.createFaceOutline(for: faceRectangle)
                }
            })
        }
        
        let imageRequestHandler = VNImageRequestHandler(cgImage: image, options: [:])
        
        do{
            try imageRequestHandler.perform([faceDetectionRequest])
        }catch {
            print("Failed to perform image request:",error.localizedDescription)
            return
        }
        
    }

}

