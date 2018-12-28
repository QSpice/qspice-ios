import UIKit

@objc protocol PhotoEditingDelegate {
    @objc optional func photoEditor(_ photoEditor: PhotoEditingViewController, didFinishProcessingPhoto image: UIImage?)
    @objc optional func photoEditorDidCancel(_ photoEditor: PhotoEditingViewController)
}

class PhotoEditingViewController: UIViewController {

    // MARK: View Controller Lifecycle
    weak var delegate: PhotoEditingDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black

        scrollView.delegate = self

        prepareGestureRecognizers()
        setupSubviews()
        prepareView()

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        animateButtonAppearance()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        switch editingMode {
            case .normal:
                centerScrollViewContent(in: view.frame)
            case .crop:
                scrollView.contentInset = calculateScrollViewInsets(for: cropView.gridRect)
                scrollView.minimumZoomScale = minimumZoomScale
                scrollView.zoomScale = minimumZoomScale
                centerScrollViewContent(in: cropView.gridRect)
        }

    }

    // MARK: Gesture Recognition

    @objc private func doneEditing() {
        switch editingMode {
            case .normal:
                delegate?.photoEditor?(self, didFinishProcessingPhoto: imageView.image)
            case .crop:
                let rect = convertToPixelRect(cropView.gridRect)
                let image = imageView.image?.crop(rect: rect)
                delegate?.photoEditor?(self, didFinishProcessingPhoto: image)

        }
    }

    @objc private func cancelPhotoEditing() {
        delegate?.photoEditorDidCancel?(self)
    }

    private func prepareGestureRecognizers() {
        backButton.addTarget(self, action: #selector(cancelPhotoEditing), for: .touchUpInside)
        doneButton.addTarget(self, action: #selector(doneEditing), for: .touchUpInside)
    }

    // MARK: Image Management

    public enum EditingMode {
        case normal
        case crop
    }

    private(set) var editingMode: EditingMode = .normal

    private func convertToPixelRect(_ rect: CGRect) -> CGRect {
        let contentInset = scrollView.contentInset
        let contentOffset = scrollView.contentOffset
        let scale = scrollView.zoomScale

        var position = CGPoint.zero
        position.x = (contentInset.left + contentOffset.x) / scale
        position.y = (contentInset.top + contentOffset.y) / scale

        var size = CGSize.zero
        size.width = rect.width / scale
        size.height = rect.height / scale

        return CGRect(origin: position, size: size)
    }

    // ScrollView Management

    private func calculateScrollViewInsets(for rect: CGRect) -> UIEdgeInsets {
        let bottom = view.frame.height - (rect.origin.y + rect.height)
        let right = view.frame.width - (rect.origin.x + rect.width)

        return UIEdgeInsets(top: rect.origin.y, left: rect.origin.x, bottom: bottom, right: right)

    }

    private var minimumZoomScale: CGFloat {
        let bounds = cropView.gridRect

        let xScale = bounds.width / imageSize.width
        let yScale = bounds.height / imageSize.height

        return CGFloat.maximum(xScale, yScale)
    }

    private var imageSize: CGSize {
        guard let image = imageView.image else { return CGSize.zero }

        return CGSize(width: image.size.width, height: image.size.height)
    }

    private func centerScrollViewContent(in rect: CGRect) {
        let viewFrame = view.frame
        let imageFrame = imageView.frame
        var imageOrigin = CGPoint(x: -scrollView.contentInset.left, y: -scrollView.contentInset.top)

        if imageFrame.width > rect.width {
            imageOrigin.x = -(viewFrame.width - imageFrame.width) / 2
        }

        if imageFrame.height > rect.height {
            imageOrigin.y = -(viewFrame.height - imageFrame.height) / 2

        }

        scrollView.contentOffset = imageOrigin
    }

    // MARK: Initialization

    convenience init(image: UIImage) {
        self.init(image: image, editingMode: .normal)
        self.imageView.image = image

    }

    init(image: UIImage, editingMode: EditingMode) {
        self.editingMode = editingMode
        self.imageView.image = image

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    // MARK: Views

    private func prepareView() {
        //imageView.frame.size = imageSize
        //scrollView.contentSize = imageView.frame.size

        switch editingMode {
        case .normal:
            scrollView.isScrollEnabled = false

        case .crop:
            imageView.frame.size = imageSize
            scrollView.contentSize = imageSize
            scrollView.isScrollEnabled = true
            view.insertSubview(cropView, at: 1)
        }
    }

    // animated constraints for buttons
    var backButtonCenterXAnchor: NSLayoutConstraint!
    var backButtonLeftAnchor: NSLayoutConstraint!
    var doneButtonCenterXAnchor: NSLayoutConstraint!
    var doneButtonRightAnchor: NSLayoutConstraint!

    /**
        Animates action buttons from center to edges using AutoLayout
    */
    private func animateButtonAppearance() {
        backButtonCenterXAnchor.isActive = false
        backButtonLeftAnchor.isActive = true
        doneButtonCenterXAnchor.isActive = false
        doneButtonRightAnchor.isActive = true
        backButton.layer.opacity = 0.0
        doneButton.layer.opacity = 0.0

        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseOut, animations: {
            self.view.layoutIfNeeded()
            self.backButton.layer.opacity = 1.0
            self.doneButton.layer.opacity = 1.0
        }, completion: nil)
    }

    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true

        return imageView
    }()

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.decelerationRate = UIScrollView.DecelerationRate.fast
        scrollView.maximumZoomScale = 4.0
        scrollView.minimumZoomScale = 1.0
        scrollView.alwaysBounceVertical = true
        scrollView.alwaysBounceHorizontal = true
        scrollView.bouncesZoom = true
        scrollView.clipsToBounds = true
        scrollView.contentMode = .scaleAspectFit

        return scrollView
    }()

    private let cropView: CroppingView = {
        let cropView = CroppingView()
        cropView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        return cropView
    }()

    private let backButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(#imageLiteral(resourceName: "photo_edit_back_button.pdf"), for: .normal)

        return button
    }()

    private let doneButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(#imageLiteral(resourceName: "photo_edit_done_button.pdf"), for: .normal)

        return button
    }()

    private func setupSubviews() {
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        view.addSubview(backButton)
        view.addSubview(doneButton)

        cropView.frame = view.frame
        scrollView.frame = view.frame
        imageView.frame = view.frame

        backButtonCenterXAnchor = backButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        backButtonLeftAnchor = backButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 32)
        doneButtonCenterXAnchor = doneButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        doneButtonRightAnchor = doneButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -32)

        NSLayoutConstraint.activate([
            backButtonCenterXAnchor,
            backButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -32),

            doneButtonCenterXAnchor,
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -32)

        ])
    }

    // MARK: Device Configuration

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

}

extension PhotoEditingViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
