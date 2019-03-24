import UIKit
import AVFoundation
import QSpiceKit

@objc protocol MediaPickerDelegate {
    @objc optional func mediaPicker(_ mediaPicker: MediaPickerViewController, didFinishPicking media: UIImage?)
}

final class MediaPickerViewController: CameraCaptureController {

    weak var pickerDelegate: MediaPickerDelegate?
    private let photoLibraryController = PhotoLibraryController()

    // MARK: View Controller Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        delegate = self

        prepareGestureRecognizers()

        transition = MediaPickerTransition(fromViewController: self, toViewController: photoPickerViewController)
        photoPickerViewController.delegate = self
        photoPickerViewController.transitioningDelegate = transition

        setupSubviews()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        photoLibraryController.requestAuthorization { [unowned self] (status) in
            if status == .authorized {
                self.photoLibraryController.getMostRecentPhoto { (image) in
                    self.photoLibraryPreview.image = image
                }
            }
        }

        addObservers()
    }

    // MARK: Gestures

    private var focusTapGestureRecognizer: UITapGestureRecognizer!
    private var panGestureRecognizer: UIPanGestureRecognizer!

    private func prepareGestureRecognizers() {
        focusTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(focusAndExpose))
        view.addGestureRecognizer(focusTapGestureRecognizer)

        flashButton.addTarget(self, action: #selector(toggleFlash), for: .touchUpInside)
        dismissButton.addTarget(self, action: #selector(dismissCamera), for: .touchUpInside)
        changeCameraButton.addTarget(self, action: #selector(changeCamera), for: .touchUpInside)
        shutterButton.addTarget(self, action: #selector(takePhoto), for: .touchUpInside)

        photoLibraryPreview.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(presentPhotoLibrary)))

    }

    var transition: MediaPickerTransition?

    private var photoPickerViewController: PhotoPickerViewController = {
        let photoLibrary = PhotoPickerViewController()
        photoLibrary.modalPresentationStyle = .custom

        return photoLibrary
    }()

    @objc private func presentPhotoLibrary() {
        present(photoPickerViewController, animated: true)
    }

    @objc private func focusAndExpose(gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: gesture.view)
        focus(with: .autoFocus, exposureMode: .autoExpose, at: location, monitorSubjectAreaChange: true)
    }

    @objc private func toggleFlash() {
        flashButton.isOn = !flashButton.isOn
        isFlashEnabled = flashButton.isOn
    }

    @objc private func dismissCamera() {
        dismiss(animated: true, completion: nil)
    }

    // MARK: Notifications and Observers

    override func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(orientationDidChange), name: UIDevice.orientationDidChangeNotification, object: nil)

    }

    @objc func orientationDidChange(notification: NSNotification) {
        updateDeviceOrientation()

        UIView.animate(withDuration: 0.25) {
            self.rotateView(self.flashButton, for: self.orientation)
            self.rotateView(self.changeCameraButton, for: self.orientation)
            self.rotateView(self.photoLibraryPreview, for: self.orientation)
        }
    }

    // MARK: Device

    private func updateDeviceOrientation() {
        let deviceOrientation = UIDevice.current.orientation

        if deviceOrientation.isFlat || !deviceOrientation.isValidInterfaceOrientation {
            return
        }

        orientation = deviceOrientation
    }

    // MARK: Views
    var controlsEnabled: Bool = true {
        didSet {
            shutterButton.isEnabled = controlsEnabled
            changeCameraButton.isEnabled = controlsEnabled
            flashButton.isEnabled = controlsEnabled
            focusTapGestureRecognizer.isEnabled = controlsEnabled
        }
    }

    private func rotateView(_ view: UIView, for orientation: UIDeviceOrientation) {
        switch orientation {
        case .portrait:
            view.transform = CGAffineTransform(rotationAngle: 0.0)
        case .landscapeRight:
            view.transform = CGAffineTransform(rotationAngle: -CGFloat.π / 2)
        case .landscapeLeft:
            view.transform = CGAffineTransform(rotationAngle: CGFloat.π / 2)
        default:
            break
        }
    }

    private func showFocusIndicator(at location: CGPoint) {
        let focusView = UIImageView(frame: CGRect(x: 0, y: 0, width: shutterButton.frame.width, height: shutterButton.frame.height))
        focusView.tintColor = .white
        focusView.image = #imageLiteral(resourceName: "crosshair.pdf")
        focusView.center = location
        focusView.alpha = 0.0
        focusView.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        view.addSubview(focusView)

        UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseInOut, animations: {
            focusView.alpha = 1.0
            focusView.transform = CGAffineTransform.identity
        }, completion: { _ in
            UIView.animate(withDuration: 0.15, delay: 0.5, options: .curveEaseInOut, animations: {
                focusView.alpha = 0.0
            }, completion: { _ in
                focusView.removeFromSuperview()
            })
        })
    }

    private let dismissButton: CancelButton = {
        let button = CancelButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.lineWidth = 2.0

        return button
    }()

    private let photoLibraryPreview: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = true
        imageView.backgroundColor = Colors.darkGrey
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.borderWidth = 2.0
        imageView.layer.cornerRadius = 8.0

        return imageView
    }()

    private let shutterButton: CameraButton = {
        let button = CameraButton()
        button.translatesAutoresizingMaskIntoConstraints = false

        return button
    }()

    // Flash and change camera button stack view
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .equalCentering
        stackView.spacing = 16.0
        return stackView
    }()

    private let flashButton: FlashButton = {
        let button = FlashButton()
        button.isOn = false
        button.imageView?.contentMode = .scaleAspectFit
        button.tintColor = .white
        return button
    }()

    private let changeCameraButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.imageView?.contentMode = .scaleAspectFit
        button.setImage(#imageLiteral(resourceName: "switch_camera.pdf"), for: .normal)
        button.tintColor = .white

        return button
    }()

    private func setupSubviews() {
        stackView.addArrangedSubview(flashButton)
        stackView.addArrangedSubview(changeCameraButton)
        view.addSubview(dismissButton)
        view.addSubview(shutterButton)
        view.addSubview(stackView)
        view.addSubview(photoLibraryPreview)

        NSLayoutConstraint.activate([
            /* DISMISS BUTTON CONSTRAINTS */
            dismissButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            dismissButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16),
            dismissButton.heightAnchor.constraint(equalToConstant: 24),
            dismissButton.widthAnchor.constraint(equalTo: dismissButton.heightAnchor),

            /* SHUTTER BUTTON CONSTRAINTS */
            shutterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -32),
            shutterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            shutterButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.16),
            shutterButton.heightAnchor.constraint(equalTo: shutterButton.widthAnchor),

            /* PHOTO LIBRARY PREVIEW CONSTRAINTS */
            photoLibraryPreview.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 32),
            photoLibraryPreview.centerYAnchor.constraint(equalTo: shutterButton.centerYAnchor),
            photoLibraryPreview.heightAnchor.constraint(equalTo: shutterButton.heightAnchor, multiplier: 0.6),
            photoLibraryPreview.widthAnchor.constraint(equalTo: photoLibraryPreview.heightAnchor),

            /* LIGHTNING AND CHANGE CAMERA CONSTRAINTS */
            stackView.leftAnchor.constraint(equalTo: shutterButton.rightAnchor, constant: 32),
            stackView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -32),
            stackView.centerYAnchor.constraint(equalTo: shutterButton.centerYAnchor),
            stackView.heightAnchor.constraint(equalTo: shutterButton.heightAnchor, multiplier: 0.4)
        ])
    }
}

extension MediaPickerViewController: PhotoEditingDelegate {
    func photoEditorDidCancel(_ photoEditor: PhotoEditingViewController) {
        photoEditor.dismiss(animated: false, completion: nil)
    }

    func photoEditor(_ photoEditor: PhotoEditingViewController, didFinishProcessingPhoto image: UIImage?) {
        pickerDelegate?.mediaPicker?(self, didFinishPicking: image)
    }
}

extension MediaPickerViewController: PhotoPickerDelegate {
    func photoPicker(_ photoPicker: PhotoPickerViewController, didSelect image: UIImage?) {
        guard let image = image else {
            return
        }

        let photoEditor = PhotoEditingViewController(image: image, editingMode: .crop)
        photoEditor.delegate = self

        photoPicker.present(photoEditor, animated: false, completion: nil)
    }
}

extension MediaPickerViewController: CameraCaptureControllerDelegate {
    func camera(_ camera: CameraCaptureController, willBeginSession session: AVCaptureSession) {
        controlsEnabled = false
    }

    func camera(_ camera: CameraCaptureController, didBeginSession session: AVCaptureSession) {
        controlsEnabled = true
    }

    func cameraDidFinishProcessingPhoto(_ camera: CameraCaptureController, photo: Data?) {
        guard let photoData = photo, let image = UIImage(data: photoData) else { return }

        let photoEditor = PhotoEditingViewController(image: image, editingMode: .crop)
        photoEditor.delegate = self

        present(photoEditor, animated: false, completion: nil)

    }

    func cameraSessionDidChange(_ camera: CameraCaptureController, isRunning running: Bool) {
        let numberOfDevices = camera.videoDeviceDiscoverySession.uniqueDevicePositionsCount

        changeCameraButton.isEnabled = running && numberOfDevices > 1
        shutterButton.isEnabled = running
        flashButton.isEnabled = running
        focusTapGestureRecognizer.isEnabled = running

    }

    func cameraWillCapturePhoto(_ camera: CameraCaptureController) {
        controlsEnabled = false
    }

    func cameraWillFocus(_ camera: CameraCaptureController, at location: CGPoint) {
        showFocusIndicator(at: location)
    }

    func cameraWillChangeDevice(_ camera: CameraCaptureController) {
        controlsEnabled = false
    }

    func cameraDidChangeDevice(_ camera: CameraCaptureController) {
        controlsEnabled = true
    }
}
