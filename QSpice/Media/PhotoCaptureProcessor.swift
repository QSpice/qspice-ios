import UIKit
import AVFoundation

class PhotoCaptureProcessor: NSObject {
    private(set) var requestedPhotoSettings: AVCapturePhotoSettings

    private let willCapturePhoto: () -> Void
    private let didCapturePhoto: () -> Void

    private let completionHandler: (PhotoCaptureProcessor) -> Void

    var photoData: Data?

    init(with requestedPhotoSettings: AVCapturePhotoSettings,
         willCapturePhoto: @escaping () -> Void,
         didCapturePhoto: @escaping () -> Void,
         completionHandler: @escaping (PhotoCaptureProcessor) -> Void) {

        self.requestedPhotoSettings = requestedPhotoSettings
        self.willCapturePhoto = willCapturePhoto
        self.didCapturePhoto = didCapturePhoto
        self.completionHandler = completionHandler
    }
}

extension PhotoCaptureProcessor: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, willCapturePhotoFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
        willCapturePhoto()
    }

    func photoOutput(_ output: AVCapturePhotoOutput, didCapturePhotoFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
        didCapturePhoto()
    }

    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            print("Error capturing photo: \(error)")
        } else {
            photoData = photo.fileDataRepresentation()
        }
    }

    func photoOutput(_ output: AVCapturePhotoOutput, didFinishCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings, error: Error?) {
        if let error = error {
            print("Error capturing photo: \(error)")
            completionHandler(self)
            return
        }

        completionHandler(self)
    }
}
