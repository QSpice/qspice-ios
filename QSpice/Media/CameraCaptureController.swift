import UIKit
import AVFoundation

@objc protocol CameraCaptureControllerDelegate {
    @objc optional func camera(_ camera: CameraCaptureController, willBeginSession session: AVCaptureSession)
    @objc optional func camera(_ camera: CameraCaptureController, didBeginSession session: AVCaptureSession)
    @objc optional func cameraSessionDidChange(_ camera: CameraCaptureController, isRunning running: Bool)

    @objc optional func cameraWillCapturePhoto(_ camera: CameraCaptureController)
    @objc optional func cameraDidCapturePhoto(_ camera: CameraCaptureController)
    @objc optional func cameraDidFinishProcessingPhoto(_ camera: CameraCaptureController, photo: Data?)

    @objc optional func cameraWillFocus(_ camera: CameraCaptureController, at location: CGPoint)
    @objc optional func cameraDidFocus(_ camera: CameraCaptureController, at location: CGPoint)
    @objc optional func cameraWillChangeDevice(_ camera: CameraCaptureController)
    @objc optional func cameraDidChangeDevice(_ camera: CameraCaptureController)

}

class CameraCaptureController: UIViewController {

    weak var delegate: CameraCaptureControllerDelegate?
    var isFlashEnabled: Bool = false

    // MARK: View Controller Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // prepare UI
        preparePreview()

        // setup the video preview view
        previewView.session = session

        requestAccess()

        sessionQueue.async {
            self.configureSession()
        }

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        delegate?.camera?(self, willBeginSession: session)
        sessionQueue.async {
            switch self.setupResult {
                case .success:
                    self.addObservers()
                    self.session.startRunning()
                    self.isSessionRunning = self.session.isRunning

                    DispatchQueue.main.async {
                        self.delegate?.camera?(self, didBeginSession: self.session)
                        self.centerFocus()
                    }

                case .notAuthorized:
                    DispatchQueue.main.async {
                        // TODO: Create a proper view controller to display no access message
                        let message = "Elephery doesn't have permission to use the camera, please change privacy settings"
                        let alertController = UIAlertController(title: "Elephery", message: message, preferredStyle: .alert)
                        alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                        alertController.addAction(UIAlertAction(title: "Settings", style: .default, handler: { _ in
                            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:])
                        }))
                        self.present(alertController, animated: true, completion: nil)
                    }
                case .configurationFailed:
                    DispatchQueue.main.async {
                        let message = "Unable to capture media"
                        let alertController = UIAlertController(title: "Elephery", message: message, preferredStyle: .alert)
                        alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))

                        self.present(alertController, animated: true, completion: nil)
                    }
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        sessionQueue.async {
            if self.setupResult == .success {
                self.session.stopRunning()
                self.isSessionRunning = self.session.isRunning
                self.removeObservers()
            }
        }

        super.viewWillDisappear(animated)
    }

    // MARK: Session Management

    private enum SessionSetupResult {
        case success
        case notAuthorized
        case configurationFailed
    }

    private var isSessionRunning = false

    private let session = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "session queue")

    private var setupResult: SessionSetupResult = .success

    private var videoDeviceInput: AVCaptureDeviceInput!

    private func requestAccess() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .authorized:
                // the user has previously granted access to the camera
                break
            case .notDetermined:
                // the user has not yet been presented with the option to grant
                // video access. Suspend the session queue to delay session
                // setup until the access request has completed
                self.sessionQueue.suspend()
                AVCaptureDevice.requestAccess(for: .video) { granted in
                    if !granted {
                        self.setupResult = .notAuthorized
                    }
                    self.sessionQueue.resume()
                }
            default:
                setupResult = .notAuthorized
        }
    }

    private func configureSession() {
        if setupResult != .success {
            return
        }

        session.beginConfiguration()
        session.sessionPreset = .high

        // Add video input
        do {
            var defaultVideoDevice: AVCaptureDevice?

            // Choose the back dual camera if available, otherwise default to a wide angle camera
            if let dualCameraDevice = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: .back) {
                defaultVideoDevice = dualCameraDevice
            } else if let backCameraDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
                defaultVideoDevice = backCameraDevice
            } else if let frontCameraDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) {
                // in some cases where users break their phone, the back wide angle camera is not available
                defaultVideoDevice = frontCameraDevice
            }

            configureDevice(defaultVideoDevice!)

            let videoDeviceInput = try AVCaptureDeviceInput(device: defaultVideoDevice!)

            if session.canAddInput(videoDeviceInput) {
                session.addInput(videoDeviceInput)
                self.videoDeviceInput = videoDeviceInput

                DispatchQueue.main.async {
                    self.previewView.videoPreviewLayer.connection?.videoOrientation = .portrait
                }
            } else {
                print("Could not add video device input to the session")
                setupResult = .configurationFailed
                session.commitConfiguration()
                return
            }

        } catch {
            print("Could not add video device input to the session")
            setupResult = .configurationFailed
            session.commitConfiguration()
            return
        }

        // TODO: Add audio input for video, when video is supported

        // Add photo output
        if session.canAddOutput(photoOutput) {
            session.addOutput(photoOutput)

            photoOutput.isHighResolutionCaptureEnabled = true
        } else {
            print("Could not add photo output to the session")
            setupResult = .configurationFailed
            session.commitConfiguration()
            return
        }

        session.commitConfiguration()
    }

    // Device Configuration

    internal var orientation: UIDeviceOrientation = .portrait

    let videoDeviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera, .builtInDualCamera],
                                                                               mediaType: .video, position: .unspecified)

    private func configureDevice(_ device: AVCaptureDevice) {
        do {
            try device.lockForConfiguration()

            if device.isFocusModeSupported(.continuousAutoFocus) {
                device.focusMode = .continuousAutoFocus
                if device.isSmoothAutoFocusSupported {
                    device.isSmoothAutoFocusEnabled = true
                }
            }

            if device.isExposureModeSupported(.continuousAutoExposure) {
                device.exposureMode = .continuousAutoExposure
            }

            if device.isWhiteBalanceModeSupported(.continuousAutoWhiteBalance) {
                device.whiteBalanceMode = .continuousAutoWhiteBalance
            }

            device.isSubjectAreaChangeMonitoringEnabled = true

            device.unlockForConfiguration()

        } catch {
            print("Could not lock device for configuration: \(error)")
        }
    }

    @objc public func changeCamera() {
        self.delegate?.cameraWillChangeDevice?(self)

        sessionQueue.async {
            let currentVideoDevice = self.videoDeviceInput.device
            let currentPosition = currentVideoDevice.position

            let preferredPosition: AVCaptureDevice.Position
            let preferredDeviceType: AVCaptureDevice.DeviceType

            switch currentPosition {
                case .unspecified, .front:
                    preferredPosition = .back
                    preferredDeviceType = .builtInDualCamera
                case .back:
                    preferredPosition = .front
                    preferredDeviceType = .builtInWideAngleCamera
            }

            let devices = self.videoDeviceDiscoverySession.devices
            var newVideoDevice: AVCaptureDevice?

            // First look for a device with both preferred position and device type
            // Otherwise, look for a device with only the preferred position
            if let device = devices.first(where: { $0.position == preferredPosition && $0.deviceType == preferredDeviceType }) {
                newVideoDevice = device
            } else if let device = devices.first(where: { $0.position == preferredPosition }) {
                newVideoDevice = device
            }

            if let videoDevice = newVideoDevice {
                do {
                    let videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)

                    self.session.beginConfiguration()

                    // remove the existing device input first, since using the front and back camera simultaneously is not supported
                    self.session.removeInput(self.videoDeviceInput)

                    if self.session.canAddInput(videoDeviceInput) {
                        NotificationCenter.default.removeObserver(self, name: .AVCaptureDeviceSubjectAreaDidChange, object: currentVideoDevice)
                        NotificationCenter.default.addObserver(self, selector: #selector(self.subjectAreaDidChange), name: .AVCaptureDeviceSubjectAreaDidChange, object: videoDeviceInput.device)
                        self.session.addInput(videoDeviceInput)
                        self.videoDeviceInput = videoDeviceInput
                    } else {
                        self.session.addInput(self.videoDeviceInput)
                    }

                    self.session.commitConfiguration()
                } catch {
                    print("Error occured while creating video device input: \(error)")
                }
            }

            DispatchQueue.main.async {
                self.delegate?.cameraDidChangeDevice?(self)
            }

        }
    }

    private func centerFocus() {
        let location = CGPoint(x: previewView.frame.midX, y: previewView.frame.midY)
        focus(with: .continuousAutoFocus, exposureMode: .continuousAutoExposure, at: location, monitorSubjectAreaChange: false)
    }

    public func focus(with focusMode: AVCaptureDevice.FocusMode, exposureMode: AVCaptureDevice.ExposureMode, at location: CGPoint, monitorSubjectAreaChange: Bool) {

        self.delegate?.cameraWillFocus?(self, at: location)

        let devicePoint = previewView.videoPreviewLayer.captureDevicePointConverted(fromLayerPoint: location)

        sessionQueue.async {
            let device = self.videoDeviceInput.device
            do {
                try device.lockForConfiguration()

                if device.isFocusPointOfInterestSupported && device.isFocusModeSupported(focusMode) {
                    device.focusPointOfInterest = devicePoint
                    device.focusMode = focusMode
                }

                if device.isExposurePointOfInterestSupported && device.isExposureModeSupported(exposureMode) {
                    device.exposurePointOfInterest = devicePoint
                    device.exposureMode = exposureMode
                }

                device.isSubjectAreaChangeMonitoringEnabled = monitorSubjectAreaChange
                device.unlockForConfiguration()

                DispatchQueue.main.async {
                    self.delegate?.cameraDidFocus?(self, at: location)
                }

            } catch {
                print("Could not lock device for configuration: \(error)")
            }
        }
    }

    override var shouldAutorotate: Bool {
        return false
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    // MARK: Capturing Photos

    private var photoCaptureProcessor: PhotoCaptureProcessor?

    private let photoOutput = AVCapturePhotoOutput()

    @objc public func takePhoto() {
        var videoPreviewLayerOrientation = previewView.videoPreviewLayer.connection?.videoOrientation

        if let currentDeviceOrientation = AVCaptureVideoOrientation(rawValue: self.orientation.rawValue) {
            videoPreviewLayerOrientation = currentDeviceOrientation
        }

        sessionQueue.async {
            if let photoOutputConnection = self.photoOutput.connection(with: .video) {
                photoOutputConnection.videoOrientation = videoPreviewLayerOrientation!
                if self.videoDeviceInput.device.position == .front {
                    photoOutputConnection.isVideoMirrored = true
                }
            }

            var photoSettings = AVCapturePhotoSettings()

            // Capture HEIF photo when supported
            if #available(iOS 11, *), self.photoOutput.availablePhotoCodecTypes.contains(.hevc) {
                photoSettings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.hevc])
            }

            if self.videoDeviceInput.device.isFlashAvailable {
                photoSettings.flashMode = self.isFlashEnabled ? .on : .off
            }

            photoSettings.isHighResolutionPhotoEnabled = true
            if !photoSettings.__availablePreviewPhotoPixelFormatTypes.isEmpty {
                photoSettings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String: photoSettings.__availablePreviewPhotoPixelFormatTypes.first!]
            }

            // Initialize Photo Capture Processor
            self.photoCaptureProcessor = PhotoCaptureProcessor(with: photoSettings, willCapturePhoto: {
                self.delegate?.cameraWillCapturePhoto?(self)
            }, didCapturePhoto: {
                self.delegate?.cameraDidCapturePhoto?(self)
            }, completionHandler: { (photoCaptureProcessor) in
                let photoData = photoCaptureProcessor.photoData

                self.sessionQueue.async {
                    self.photoCaptureProcessor = nil
                }

                DispatchQueue.main.async {
                    self.delegate?.cameraDidFinishProcessingPhoto?(self, photo: photoData)
                }
            })

            self.photoOutput.capturePhoto(with: photoSettings, delegate: self.photoCaptureProcessor!)
        }
    }

    // MARK: KVO and Notifications

    internal var keyValueObservations = [NSKeyValueObservation]()

    internal func addObservers() {
        let runningSessionObservation = session.observe(\.isRunning, options: .new) { _, change in
            guard let isSessionRunning = change.newValue else { return }
            DispatchQueue.main.async {
                self.delegate?.cameraSessionDidChange?(self, isRunning: isSessionRunning)
            }
        }

        keyValueObservations.append(runningSessionObservation)

        NotificationCenter.default.addObserver(self, selector: #selector(subjectAreaDidChange), name: .AVCaptureDeviceSubjectAreaDidChange, object: videoDeviceInput.device)
        NotificationCenter.default.addObserver(self, selector: #selector(sessionRuntimeError), name: .AVCaptureSessionRuntimeError, object: session)

        // A session can only run when the app is full screen
        NotificationCenter.default.addObserver(self, selector: #selector(sessionWasInterrupted), name: .AVCaptureSessionWasInterrupted, object: session)
        NotificationCenter.default.addObserver(self, selector: #selector(sessionInterruptionEnded), name: .AVCaptureSessionInterruptionEnded, object: session)

    }

    private func removeObservers() {
        NotificationCenter.default.removeObserver(self)

        for keyValueObservation in keyValueObservations {
            keyValueObservation.invalidate()
        }

        keyValueObservations.removeAll()
    }

    @objc
    private func subjectAreaDidChange(notification: NSNotification) {
        centerFocus()
    }

    @objc
    private func sessionRuntimeError(notification: NSNotification) {
        guard let error = notification.userInfo?[AVCaptureSessionErrorKey] as? AVError else { return }

        print("Capture session runtime error: \(error)")

        // Try to restart the session running if media services
        // were reset and the last start running succeded
        if error.code == .mediaServicesWereReset {
            sessionQueue.async {
                if self.isSessionRunning {
                    self.session.startRunning()
                    self.isSessionRunning = self.session.isRunning
                }
            }
        }
    }

    @objc
    private func sessionWasInterrupted(notification: NSNotification) {
        if let userInfoValue = notification.userInfo?[AVCaptureSessionInterruptionReasonKey] as AnyObject?,
            let reasonIntegerValue = userInfoValue.integerValue,
            let reason = AVCaptureSession.InterruptionReason(rawValue: reasonIntegerValue) {

            print("Capture session was interrupted with reason \(reason)")
        }
    }

    @objc
    private func sessionInterruptionEnded(notification: NSNotification) {
        print("Capture session interruption ended")

    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    // MARK: Views

    private let previewView = PreviewView()

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        previewView.frame = view.bounds

    }

    private func preparePreview() {
        view.backgroundColor = .black
        view.addSubview(previewView)
    }

}
