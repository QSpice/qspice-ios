import UIKit

protocol ModalCardTransitioning {
    func presentationSize(context: UIViewControllerContextTransitioning) -> CGSize
}

/// UIViewController animated, interactive and interruptible transition.
/// Displays a view controller as a modal card appearing from the bottom
class ModalCardTransition: NSObject, UIViewControllerAnimatedTransitioning {
    private(set) weak var viewController: UIViewController?
    private var presenting = true
    private var transitionDriver: ModalCardTransitionDriver?
    private var panGestureRecognizer = UIPanGestureRecognizer()
    private var initiallyInteractive = false

    var endpoint: CGFloat = 1.0
    var exceedsEndpoint = true

    init(viewController: UIViewController) {
        self.viewController = viewController
        super.init()

        prepareGestureRecognizers()
    }

    private func prepareGestureRecognizers() {
        panGestureRecognizer.delegate = self
        panGestureRecognizer.maximumNumberOfTouches = 1
        panGestureRecognizer.addTarget(self, action: #selector(initiateTransitionInteractively))
        contentContainerView.addGestureRecognizer(panGestureRecognizer)

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismiss))
        overlayView.addGestureRecognizer(tapGestureRecognizer)
    }

    @objc private func initiateTransitionInteractively(_ panGesture: UIPanGestureRecognizer) {
        if panGesture.state == .began && transitionDriver == nil {
            initiallyInteractive = true
            viewController?.dismiss(animated: true)
        }
    }

    @objc private func dismiss() {
        viewController?.dismiss(animated: true)
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return ModalCardTransitionDriver.duration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {}

    /// Animation container for holding the presented view
    private let contentContainerView: UIView = {
        let view = UIView()
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        return view
    }()

    /// Animation view for dimming the presenting view
    private let overlayView: UIView = {
        let view = UIView()
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.backgroundColor = UIColor(white: 0.0, alpha: 0.35)

        return view
    }()
}

extension ModalCardTransition: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if otherGestureRecognizer.view is UIScrollView {
            return false
        }

        return true
    }
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard transitionDriver != nil else {
            let translation = panGestureRecognizer.translation(in: panGestureRecognizer.view)
            let translationIsVertical = (abs(translation.y) > abs(translation.x))

            return translationIsVertical
        }

        return true
    }
}

extension ModalCardTransition: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {

        self.presenting = true

        return self
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.presenting = false

        return self
    }

    func animationEnded(_ transitionCompleted: Bool) {
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

extension ModalCardTransition: UIViewControllerInteractiveTransitioning {
    func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        if presenting, let modalCardTransitioning = transitionContext.viewController(forKey: .to) as? ModalCardTransitioning {
            let size = modalCardTransitioning.presentationSize(context: transitionContext)

            // bound height to endpoint
            endpoint = min(endpoint, size.height / transitionContext.containerView.frame.height)
        }

        let context = ModalCardTransitionContext(transitionContext: transitionContext,
                                        contentContainerView: contentContainerView,
                                        overlayView: overlayView,
                                        gestureRecognizer: panGestureRecognizer,
                                        endpoint: endpoint)
        context.exceedsEndpoint = exceedsEndpoint

        transitionDriver = ModalCardTransitionDriver(presenting: presenting, context: context)
    }

    var wantsInteractiveStart: Bool {
        return initiallyInteractive
    }

    func interruptibleAnimator(using transitionContext: UIViewControllerContextTransitioning) -> UIViewImplicitlyAnimating {
        return (transitionDriver?.transitionAnimator)!
    }
}
