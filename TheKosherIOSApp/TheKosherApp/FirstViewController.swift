//
//  FirstViewController.swift
//  TheKosherApp
//
//  Created by Rajan Marathe on 14/10/18.
//  Copyright © 2018 Rajan Marathe. All rights reserved.
//

import UIKit
import AVFoundation
import MobileCoreServices
import CoreImage
import CoreML
import Vision
import ImageIO
import MessageUI

class FirstViewController: UIViewController, AVCapturePhotoCaptureDelegate, MFMailComposeViewControllerDelegate {
    @IBOutlet weak var cameraPreview: UIView!
    @IBOutlet weak var capturePhotoButton: UIButton!
    @IBOutlet weak var classificationLabel: UILabel!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var constraintBottomCamPreviewView: NSLayoutConstraint!
    @IBOutlet weak var agencyDetailsView: UIView!
    @IBOutlet weak var agencyNameLabel: UILabel!
    @IBOutlet weak var agencyAddressLabel: UILabel!
    @IBOutlet weak var agencyLogoImageView: UIImageView!
    @IBOutlet weak var cRcApprovedLabel: UILabel!
    @IBOutlet weak var dismissAgencyDetailsViewButton: UIButton!
    @IBOutlet weak var constraintBottomAgencyDetailsView: NSLayoutConstraint!
    @IBOutlet weak var constraintHeightOfAgencyNameLabel: NSLayoutConstraint!
    @IBOutlet weak var scanAgainButton: UIButton!
    @IBOutlet weak var reportAnIssueButton: UIButton!
    @IBOutlet weak var capturedImageView: UIImageView!
    
    let photoSettings = AVCapturePhotoSettings()
    let captureSession = AVCaptureSession()
    let stillImageOutput = AVCapturePhotoOutput()
    var previewLayer: AVCaptureVideoPreviewLayer!
    var activeInput: AVCaptureDeviceInput!
    var error: NSError?
    let shapeLayer = CAShapeLayer()
    var agencyListArr = [[String : Any]]()
    var capturedImage : UIImage?
    var fileName = ""
    
    let kosherModel = ImageClassifier()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.setupCamera()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        let url = Bundle.main.url(forResource: "Agencies", withExtension: "json")!
        do {
            let jsonData = try Data(contentsOf: url)
            let json = try JSONSerialization.jsonObject(with: jsonData) as! [[String : Any]]
            let sortedArray = (json as NSArray).sortedArray(using: [NSSortDescriptor(key: "real name", ascending: true)]) as! [[String:AnyObject]]
            agencyListArr = sortedArray
        }
        catch {
            print(error)
        }
//        print(self.cameraPreview.frame)
//        self.cameraPreview.layoutIfNeeded()
//        print(self.cameraPreview.frame)
        DispatchQueue.main.async {
            // HN added this to detect phone size and draw radius accordingly
            var radius = 0.0
            var midX = 0.0
            var midY = 0.0
            
            if UIDevice().userInterfaceIdiom == .phone {
                switch UIScreen.main.nativeBounds.height {
                //iphone 6,7,8
                case 1334:
                     radius = 60.0
                     midX = UIAccelerationValue((self.cameraPreview.frame.midX - 60))
                     midY = UIAccelerationValue((self.cameraPreview.frame.midY - 150))
                //iphone 6+,7+,8+
                case 1920, 2208:
                    radius = 80.0
                    midX = UIAccelerationValue((self.cameraPreview.frame.midX - 80))
                    midY = UIAccelerationValue((self.cameraPreview.frame.midY - 200))
                // all other phones
                default:
                     radius = 85.0//self.cameraPreview.frame.size.width
                     midX = UIAccelerationValue((self.cameraPreview.frame.midX - 90))
                     midY = UIAccelerationValue((self.cameraPreview.frame.midY - 190))
                }
            }
            
            
            let path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: self.cameraPreview.frame.size.width, height: self.cameraPreview.frame.size.height), cornerRadius: 0)
           //let rect = CGRect(x: midX, y: midY, width: 2 * radius, height: 2 * radius)
            let circlePath = UIBezierPath(roundedRect: CGRect(x: midX, y: midY, width: 2 * radius, height: 2 * radius), cornerRadius: CGFloat(radius))
            path.append(circlePath)
            path.usesEvenOddFillRule = true
            
            let fillLayer = CAShapeLayer()
            fillLayer.path = path.cgPath
            fillLayer.fillRule = CAShapeLayerFillRule.evenOdd
            fillLayer.fillColor = UIColor.black.cgColor
            fillLayer.opacity = 0.6
            self.cameraPreview.layer.addSublayer(fillLayer)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
    }
    
    // MARK: - Image Classification
    
    /// - Tag: MLModelSetup
    lazy var classificationRequest: VNCoreMLRequest = {
        do {
            /*
             Use the Swift class `MobileNet` Core ML generates from the model.
             To use a different Core ML classifier model, add it to the project
             and replace `MobileNet` with that model's generated Swift class.
             */
            let model = try VNCoreMLModel(for: ImageClassifier().model)
            
            let request = VNCoreMLRequest(model: model, completionHandler: { [weak self] request, error in
                self?.processClassifications(for: request, error: error)
            })
            request.imageCropAndScaleOption = .centerCrop
            return request
        } catch {
            fatalError("Failed to load Vision ML model: \(error)")
        }
    }()
    
    /// - Tag: PerformRequests
    func updateClassifications(for image: UIImage) {
        classificationLabel.text = "Classifying..."
        
        let orientation = CGImagePropertyOrientation(rawValue: UInt32(image.imageOrientation.rawValue))
        guard let ciImage = CIImage(image: image) else { fatalError("Unable to create \(CIImage.self) from \(image).") }
        
        DispatchQueue.global(qos: .userInitiated).async {
            let handler = VNImageRequestHandler(ciImage: ciImage, orientation: orientation!)
            do {
                try handler.perform([self.classificationRequest])
            } catch {
                /*
                 This handler catches general image processing errors. The `classificationRequest`'s
                 completion handler `processClassifications(_:error:)` catches errors specific
                 to processing that request.
                 */
                print("Failed to perform classification.\n\(error.localizedDescription)")
            }
        }
    }
    
    /// Updates the UI with the results of the classification.
    /// - Tag: ProcessClassifications
    func processClassifications(for request: VNRequest, error: Error?) {
        DispatchQueue.main.async {
            guard let results = request.results else {
                self.classificationLabel.text = "Unable to classify image.\n\(error!.localizedDescription)"
                return
            }
            // The `results` will always be `VNClassificationObservation`s, as specified by the Core ML model in this project.
            let classifications = results as! [VNClassificationObservation]
            
            if classifications.isEmpty {
                self.classificationLabel.text = "Nothing recognized."
            } else {
                // Display top classifications ranked by confidence in the UI.
                let topClassifications = classifications.prefix(2)
                let descriptions = topClassifications.map { classification in
                    // Formats the classification for display; e.g. "(0.37) cliff, drop, drop-off".
                    return String(format: "%@", classification.identifier)//(format: "  (%.2f) %@", classification.confidence, classification.identifier)
                }
                self.classificationLabel.text = descriptions[0]//"Classification:\n" + descriptions.joined(separator: "\n")
                let index = self.agencyListArr.index(where: {($0["Names of Folders"] as! String) == self.classificationLabel.text})
                let agencyDict = self.agencyListArr[index!]
                self.constraintBottomAgencyDetailsView.constant = -5
                self.agencyNameLabel.text = (agencyDict ["real name"] as! String).isEmpty ? "Not Available" : (agencyDict ["real name"] as! String)
                
                let heightOfAgencyName = heightForLabel(text: self.agencyNameLabel.text!, font: UIFont.boldSystemFont(ofSize: 14), width: self.agencyNameLabel.frame.width)
                if heightOfAgencyName > 20 {
                    self.constraintHeightOfAgencyNameLabel.constant  = 34
                } else {
                    self.constraintHeightOfAgencyNameLabel.constant = 17
                }
                
                var strAddress = "Not Available"
                if (agencyDict ["City"] as! String).isEmpty && !(agencyDict ["State"] as! String).isEmpty {
                    strAddress = (agencyDict ["State"] as! String)
                } else if !(agencyDict ["City"] as! String).isEmpty && (agencyDict ["State"] as! String).isEmpty {
                    strAddress = (agencyDict ["City"] as! String)
                } else if !(agencyDict ["City"] as! String).isEmpty && !(agencyDict ["State"] as! String).isEmpty {
                    strAddress = (agencyDict ["City"] as! String) + ", " + (agencyDict ["State"] as! String)
                }
                
                let cRcText = (agencyDict ["CRC Approved"] as! String == "y") ? "Approved by the cRc" : " "
                
                self.agencyAddressLabel.text = strAddress
                self.cRcApprovedLabel.text = cRcText
                
                let imageStr = (agencyDict ["Logo File Name"] as! String)
                let image = UIImage(named: imageStr)
                self.agencyLogoImageView.image = image
                self.reportAnIssueButton.tag = index!
                // choose a name for your image
                self.fileName = "Captured-" + (agencyDict ["Names of Folders"] as! String) + ".jpeg"
            }
        }
    }
    
    func setupCamera() {
        let devices = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .back)
        if let captureDevice = devices {
            do {
                let input = try AVCaptureDeviceInput(device: captureDevice)
                if captureSession.canAddInput(input) {
                    captureSession.addInput(input)
                    activeInput = input
                }
            } catch {
                print("Error setting device video input: \(error)")
            }
            
            captureSession.sessionPreset = AVCaptureSession.Preset.photo
            captureSession.startRunning()
            if captureSession.canAddOutput(stillImageOutput) {
                captureSession.addOutput(stillImageOutput)
            }
            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            previewLayer.frame = self.view.layer.bounds//CGRect(x: 0, y: 0, width: cameraPreview.bounds.size.width, height: cameraPreview.bounds.size.height)
            previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
            cameraPreview.layer.addSublayer(previewLayer)
        }
    }
    
    func cropToBounds(image: UIImage, width: Double, height: Double) -> UIImage {
        
        let cgimage = image.cgImage!

        let rect: CGRect = CGRect(x: 825, y: 1180, width: 700, height: 700)
        
        // Create bitmap image from context using the rect
        let imageRef: CGImage = cgimage.cropping(to: rect)!
        
        
        // Create a new image based on the imageRef and rotate back to the original orientation
        let image: UIImage = UIImage(cgImage: imageRef, scale: image.scale, orientation: image.imageOrientation)
        capturedImage = image
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)

        updateClassifications(for: image)
        return image
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        let imageData = photo.fileDataRepresentation()
//        UIImageWriteToSavedPhotosAlbum(UIImage(data: imageData!)!, nil, nil, nil)
        self.capturedImageView.image = UIImage(data: imageData!)
        self.capturedImageView.isHidden = false
        self.cameraPreview.isHidden = true
        _ = self.cropToBounds(image: UIImage(data: imageData!)!, width: 675, height: 725)
    }
    
    @IBAction func capturePhotoButtonAction(_ sender: UIButton) {
        
        let previewPixelType = photoSettings.availablePreviewPhotoPixelFormatTypes.first!
        let previewFormat = [kCVPixelBufferPixelFormatTypeKey as String: previewPixelType,
                             kCVPixelBufferWidthKey as String: 160,
                             kCVPixelBufferHeightKey as String: 160]
        photoSettings.previewPhotoFormat = previewFormat
        self.stillImageOutput.capturePhoto(with: AVCapturePhotoSettings.init(from: photoSettings), delegate: self)
    }
    
    @IBAction func dismissAgencyDetailsViewButtonAction(_ sender: UIButton) {
        self.capturedImageView.isHidden = true
        self.cameraPreview.isHidden = false
        self.constraintBottomAgencyDetailsView.constant = -190
        self.reportAnIssueButton.tag = -1
    }
    
    @IBAction func reportAnIssueButtonAction(_ sender: UIButton) {
        
        let strEmailAddress = "Appthekosher@gmail.com"
        
        if !strEmailAddress.isEmpty {
            if MFMailComposeViewController.canSendMail() {
                let composeVC = MFMailComposeViewController()
                composeVC.mailComposeDelegate = self
                
                // create the destination file url to save your image
                composeVC.addAttachmentData((self.capturedImage?.jpegData(compressionQuality: 1.0))!, mimeType: "image/jpeg", fileName: self.fileName)
                composeVC.setToRecipients([strEmailAddress])
                composeVC.setSubject("Report An Error")
                composeVC.setMessageBody("No need to write anything! Just press send and the app sends all relevant information. \n\n\n\n\n\n\n\nSent from The Kosher App!", isHTML: false)
                
                // Present the view controller modally.
                self.present(composeVC, animated: true, completion: nil)
            }
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        // Check the result or perform other tasks.
        // Dismiss the mail compose view controller.
        controller.dismiss(animated: true, completion: nil)
    }
}
