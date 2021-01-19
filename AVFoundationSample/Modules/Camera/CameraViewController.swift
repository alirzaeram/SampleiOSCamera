//
//  ViewController.swift
//  AVFoundationSample
//
//  Created by Alireza on 1/18/21.
//

import UIKit
import AVFoundation
import Photos
import RxSwift

class CameraViewController: UIViewController {
    
    let viewModel = CameraViewModel()
    
    @IBOutlet weak var preview: UIView!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var recordButtonHeight: NSLayoutConstraint!
    @IBOutlet weak var openPhotosButton: UIButton!
    @IBOutlet weak var changeCameraButton: UIButton!
    
}
// MARK: - Life Cycle
extension CameraViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.bindViewModel()
        self.setupPreviewView()
        
    }
    
}

// MARK: - View Setup
extension CameraViewController {
    private func setupPreviewView() {
        preview.contentMode = UIView.ContentMode.scaleAspectFill
        
        self.recordButtonHeight.constant = 60.0
        self.recordButton.layer.cornerRadius = 60.0 / 2.0
        
        self.viewModel.prepare { (error) in
            if let error = error {
                print(error)
            }
            do {
                try self.viewModel.displayPreview(on: self.preview)
            }
            catch {
                print(error)
            }
        }
        
    }
    private func startRecording() {
        UIView.animate(withDuration: 0.2) {
            self.recordButton.layer.cornerRadius = 4.0
            
            self.openPhotosButton.alpha = 0.0
            self.changeCameraButton.alpha = 0.0
            
            
            self.view.layoutIfNeeded()
        }
    }
    private func stopRecording() {
        UIView.animate(withDuration: 0.2) {
            self.recordButton.layer.cornerRadius = 30.0
            
            self.openPhotosButton.alpha = 1.0
            self.changeCameraButton.alpha = 1.0
            
            self.view.layoutIfNeeded()
        } completion: {
            if $0 {
//                self.performSegue(withIdentifier: "CameraToPreview", sender: self)
            }
        }
    }
}

// MARK: - Rx
extension CameraViewController {
    private func bindViewModel() {
        self.viewModel
            .isRecording
            .asObservable()
            .subscribe(onNext: {
                if $0 {
                    self.viewModel.startRecordingVideo(viewController: self)
                }else {
                    self.viewModel.stopRecordingVideo()
                }
            })
            .disposed(by: self.viewModel.disponseBag)
    }
}

// MARK: - Actions
extension CameraViewController {
    @IBAction func record(_ sender: UIButton) {
        self.viewModel.isRecording.accept(!self.viewModel.isRecording.value)
    }
    @IBAction func openPhotos(_ sender: UIButton) {
        
    }
    @IBAction func changeCamera(_ sender: UIButton) {
        do {
            try self.viewModel.switchCameras()
        }catch {
            return
        }
    }
}
// MARK: - AVCaptureFileOutputRecordingDelegate
extension CameraViewController: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        
        self.startRecording()
    }
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        self.viewModel.videoFileURL = outputFileURL
        self.stopRecording()
    }
}
