import Foundation
import Photos

class PhotoLibraryController: NSObject {

    private(set) var assets: PHFetchResult<PHAsset>?

    func getMostRecentPhoto(completionHandler: ((UIImage?) -> Void)?) {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchOptions.fetchLimit = 1

        let fetchResult = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: fetchOptions)

        let requestOptions = PHImageRequestOptions()
        requestOptions.deliveryMode = .fastFormat

        if fetchResult.count > 0 {
            PHImageManager.default().requestImage(for: fetchResult.lastObject!, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFill, options: requestOptions, resultHandler: { (image, _) in
                DispatchQueue.main.async {
                    completionHandler?(image)
                }
            })
        }
    }

    func loadAllAssets(force: Bool = false) {
        if !force && assets != nil {
            return
        }

        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]

        assets = PHAsset.fetchAssets(with: .image, options: fetchOptions)
    }

    func removeAllAssets() {
        assets = nil
    }

    func photoWithMaximumQuality(at index: Int, completionHandler: ((UIImage?) -> Void)?) {
        photo(at: index, size: PHImageManagerMaximumSize, completionHandler: completionHandler, mode: .highQualityFormat)
    }

    func photo(at index: Int, size: CGSize, completionHandler: ((UIImage?) -> Void)?, mode: PHImageRequestOptionsDeliveryMode) {
        guard let assets = assets else {
            completionHandler?(nil)
            return
        }
        
        let options = PHImageRequestOptions()
        options.isNetworkAccessAllowed = true
        options.deliveryMode = mode

        PHImageManager.default().requestImage(for: assets[index], targetSize: size, contentMode: .aspectFill, options: options, resultHandler: { (image, _) in
            DispatchQueue.main.async {
                completionHandler?(image)
            }
        })

    }

    // Authorization

    private var accessResult: PhotoAccessResult = .authorized

    enum PhotoAccessResult {
        case authorized
        case notAuthorized
        case denied
    }

    func requestAuthorization(_ handler: @escaping (PhotoAccessResult) -> Void) {
        switch PHPhotoLibrary.authorizationStatus() {
            case .authorized:
                handler(.authorized)
            case .denied, .restricted:
                accessResult = .denied
                handler(.denied)
            case .notDetermined:
                PHPhotoLibrary.requestAuthorization({ (status) in
                    switch status {
                        case .denied, .restricted:
                            self.accessResult = .denied
                        default:
                            break
                    }
                    handler(self.accessResult)
                })
        }
    }
}
