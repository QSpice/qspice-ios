import UIKit

/// Stores transition context state during presentation and dismissal
/// of a media picker transition
class MediaPickerTransitionContext {
    let transitionContext: UIViewControllerContextTransitioning
    let panGestureRecognizer: UIPanGestureRecognizer
    let blurView: UIVisualEffectView

    init(transitionContext: UIViewControllerContextTransitioning, panGestureRecognizer: UIPanGestureRecognizer, blurView: UIVisualEffectView) {
        self.transitionContext = transitionContext
        self.panGestureRecognizer = panGestureRecognizer
        self.blurView = blurView
    }
}
