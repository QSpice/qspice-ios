import UIKit

class MediaPickerTransition: NSObject, UIViewControllerAnimatedTransitioning {
    private var initiallyInteractive = false
    private var needsPresenting = true

    private(set) weak var fromViewController: UIViewController?
    private(set) weak var toViewController: UIViewController?

    private var transitionDriver: MediaPickerTransitionDriver?
    private let presentingPanGestureRecognizer: UIPanGestureRecognizer = UIPanGestureRecognizer()
    private let dismissingPanGestureRecognizer: UIPanGestureRecognizer = UIPanGestureRecognizer()

    init(fromViewController: UIViewController, toViewController: UIViewController) {
        super.init()

        self.fromViewController = fromViewController
        self.toViewController = toViewController

        prepare(panGestureRecognizer: presentingPanGestureRecognizer)
        prepare(panGestureRecognizer: dismissingPanGestureRecognizer)
        presentingPanGestureRecognizer.addTarget(self, action: #selector(initiateTransitionInteractively))
        dismissingPanGestureRecognizer.addTarget(self, action: #selector(endTransitionInteractively))

        fromViewController.view.addGestureRecognizer(presentingPanGestureRecognizer)
        toViewController.view.addGestureRecognizer(dismissingPanGestureRecognizer)
    }

    private func prepare(panGestureRecognizer: UIPanGestureRecognizer) {
        panGestureRecognizer.delegate = self
        panGestureRecognizer.maximumNumberOfTouches = 1
    }

    @objc private func initiateTransitionInteractively(gesture: UIPanGestureRecognizer) {
        if needsPresenting && gesture.state == .began && transitionDriver == nil {
            initiallyInteractive = true

            guard let toViewController = toViewController else {
                return
            }

            fromViewController?.present(toViewController, animated: true)
        }
    }

    @objc private func endTransitionInteractively(gesture: UIPanGestureRecognizer) {
        if !needsPresenting && gesture.state == .began && transitionDriver == nil {
            initiallyInteractive = true

            toViewController?.dismiss(animated: true)
        }
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return MediaPickerTransitionDriver.duration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {}

    private let blurView: UIVisualEffectView = {
        let visualEffect = UIVisualEffectView()
        visualEffect.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        return visualEffect
    }()
}

extension MediaPickerTransition: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if let scrollView = otherGestureRecognizer.view as? UIScrollView {
            if scrollView.contentOffset.y > 0 {
                return false
            }
        }

        return true
    }

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let transitionDriver = transitionDriver else {
            if let gestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer {
                let translation = gestureRecognizer.translation(in: gestureRecognizer.view)
                let translationIsVertical = abs(translation.y) > abs(translation.x)

                return (needsPresenting ? (translation.y < 0) : (translation.y > 0)) && translationIsVertical
            }
            return false
        }

        return transitionDriver.isInteractive
    }
}

extension MediaPickerTransition: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }

    func animationEnded(_ transitionCompleted: Bool) {
        if transitionCompleted {
            needsPresenting = !needsPresenting
        }

        transitionDriver = nil
        initiallyInteractive = false
    }

    func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return self
    }

    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return self
    }

}

extension MediaPickerTransition: UIViewControllerInteractiveTransitioning {
    func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        let panGestureRecognizer: UIPanGestureRecognizer

        if needsPresenting {
            panGestureRecognizer = presentingPanGestureRecognizer
        } else {
            panGestureRecognizer = dismissingPanGestureRecognizer
        }

        let context = MediaPickerTransitionContext(transitionContext: transitionContext, panGestureRecognizer: panGestureRecognizer, blurView: blurView)

        transitionDriver = MediaPickerTransitionDriver(needsPresenting: needsPresenting, context: context)
    }

    var wantsInteractiveStart: Bool {
        return initiallyInteractive
    }

    func interruptibleAnimator(using transitionContext: UIViewControllerContextTransitioning) -> UIViewImplicitlyAnimating {
        return (transitionDriver?.transitionAnimator)!
    }
}
