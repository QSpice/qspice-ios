import UIKit

@objc protocol PhotoPickerDelegate {
    @objc func photoPicker(_ photoPicker: PhotoPickerViewController, didSelect image: UIImage?)
}

class PhotoPickerViewController: UIViewController {

    weak var delegate: PhotoPickerDelegate?

    private let controller = PhotoLibraryController()
    private static let cellIdentifier = "photoLibraryCell"
    private let spacing: CGFloat = 4.0

    // MARK: View Controller Lifecycle

    private let photoCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .black
        collectionView.bounces = false
        collectionView.backgroundColor = .white

        return collectionView
    }()

    private let header: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear

        return view
    }()

    let headerTitle: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "CAMERA ROLL"
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        label.textColor = .white

        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        photoCollectionView.register(PHPhotoCollectionViewCell.self, forCellWithReuseIdentifier: PhotoPickerViewController.cellIdentifier)
        photoCollectionView.dataSource = self
        photoCollectionView.delegate = self

        setupSubviews()

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        controller.loadAllAssets()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

        controller.removeAllAssets()
    }

    private func setupSubviews() {
        view.addSubview(header)
        view.addSubview(headerTitle)
        view.addSubview(photoCollectionView)

        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: view.topAnchor),
            header.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.15),
            header.widthAnchor.constraint(equalTo: photoCollectionView.widthAnchor, multiplier: 1.0),

            headerTitle.bottomAnchor.constraint(equalTo: header.bottomAnchor, constant: -16),
            headerTitle.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16),

            photoCollectionView.topAnchor.constraint(equalTo: header.bottomAnchor),
            photoCollectionView.leftAnchor.constraint(equalTo: view.leftAnchor),
            photoCollectionView.rightAnchor.constraint(equalTo: view.rightAnchor),
            photoCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

}

// MARK: UICollectionViewDataSource

extension PhotoPickerViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return controller.assets?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoPickerViewController.cellIdentifier, for: indexPath) as? PHPhotoCollectionViewCell
            else { return UICollectionViewCell() }

        controller.photo(at: indexPath.item, size: cell.bounds.size, completionHandler: { image in
            cell.imageView.image = image
        })

        return cell
    }

}

// MARK: UICollectionViewDelegate

extension PhotoPickerViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        controller.photoWithMaximumQuality(at: indexPath.item) { (image) in
            self.delegate?.photoPicker(self, didSelect: image)
        }
    }

}

extension PhotoPickerViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width

        let cellWidth = (width - 2 * spacing) / 3.0

        return CGSize(width: cellWidth, height: cellWidth)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .zero
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return spacing
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return spacing
    }
}
