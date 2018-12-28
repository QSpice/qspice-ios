import UIKit

/// Drives the modal card transition using property animators
class ModalCardTransitionDriver {

    private let context: ModalCardTransitionContext

    private(set) var transitionAnimator: UIViewPropertyAnimator!
    private var frameAnimator: UIViewPropertyAnimator?

    private var isInteractive: Bool {
        return context.transitionContext.isInteractive
    }

    static let duration: TimeInterval = 0.35
    private let presenting: Bool

    enum ViewFrameState {
        case hidden, middle, visible
    }

    init(presenting: Bool, context: ModalCardTransitionContext) {
        self.context = context
        self.presenting = presenting

        context.panGestureRecognizer.addTarget(self, action: #selector(updateTransition))

        let transitionCtx = context.transitionContext
        let containerView = transitionCtx.containerView

        guard let toViewController = transitionCtx.viewController(forKey: .to),
            let fromViewController = transitionCtx.viewController(forKey: .from)
            else { return }

        let topViewController = presenting ? toViewController : fromViewController
        let topView = topViewController.view!
        var topViewFrame = transitionCtx.finalFrame(for: topViewController)
        topViewFrame.size = CGSize(width: containerView.frame.width, height: min(containerView.frame.inset(by: containerView.safeAreaInsets).height, containerView.frame.height * context.endpoint))

        let overlayAlpha: CGFloat

        if presenting {
            overlayAlpha = 0.0

            // preparation of animation views
            // topView is placed inside a contentContainer so that it can overshoot
            // its final height while still having a background at the bottom (content container view)
            topView.frame = topViewFrame
            context.overlayView.frame = containerView.frame
            context.contentContainerView.frame = containerView.frame
            context.contentContainerView.frame.origin = originFor(state: .hidden)
            context.contentContainerView.backgroundColor = topView.backgroundColor
            context.contentContainerView.layer.maskedCorners = topView.layer.maskedCorners
            context.contentContainerView.layer.cornerRadius = topView.layer.cornerRadius

            containerView.addSubview(context.overlayView)
            context.contentContainerView.addSubview(topView)
            containerView.addSubview(context.contentContainerView)

        } else {
            overlayAlpha = 1.0
        }

        context.overlayView.alpha = overlayAlpha

        // transition animator is only responsible from overlay alpha
        self.setupTransitionAnimator({
            self.context.overlayView.alpha = 1.0 - overlayAlpha
        }, transitionCompletion: { (_, ended) in
            if ended && !presenting {
                context.contentContainerView.removeFromSuperview()
                context.overlayView.removeFromSuperview()
            }
        })

        if !isInteractive {
            animate(.end)
        }
    }

    // The origins of the presented view for its initial and target frame
    private var viewPositions: (initial: CGPoint, target: CGPoint) {
        let initialPosition: CGPoint
        let finalPosition: CGPoint

        if presenting {
            initialPosition = originFor(state: .hidden)
            finalPosition = originFor(state: .visible)
        } else {
            initialPosition = originFor(state: .visible)
            finalPosition = originFor(state: .hidden)
        }

        return (initialPosition, finalPosition)
    }

    /// origin for different visibility levels of the presented view
    private func originFor(state: ViewFrameState) -> CGPoint {
        let containerView = context.transitionContext.containerView
        switch state {
        case .hidden:
            // the view should be positioned off screen
            return CGPoint(x: 0.0, y: containerView.frame.height)
        case .visible:
            // the view should be position at the ratio of the screen specified by endpoint
            let expectedY = (1.0 - context.endpoint) * containerView.frame.height - containerView.safeAreaInsets.bottom

            // view shouldn't go past the top safe area
            return CGPoint(x: 0.0, y: max(containerView.safeAreaInsets.top, expectedY))
        default:
            return .zero
        }
    }

    // relative velocity of the view for a spring damping system
    // controlled by a pan gesture recognizer
    private var timingCurveVelocity: CGVector {
        let gestureVelocity = context.panGestureRecognizer.velocity(in: context.contentContainerView)

        let currentPosition = context.contentContainerView.frame.origin
        let targetPosition = viewPositions.target

        let dy = abs(targetPosition.y - currentPosition.y)

        guard dy > 0.0 else {
            return .zero
        }

        return CGVector(dx: 0.0, dy: gestureVelocity.y / dy)
    }

    private func animate(_ position: UIViewAnimatingPosition) {
        let timingParameters = UISpringTimingParameters(mass: 4.5, stiffness: 900, damping: 95, initialVelocity: timingCurveVelocity)
        let frameAnimator = UIViewPropertyAnimator(duration: ModalCardTransitionDriver.duration, timingParameters: timingParameters)

        let (initialPosition, targetPosition) = self.viewPositions

        frameAnimator.addAnimations {
            self.context.contentContainerView.frame.origin = position == .end ? targetPosition : initialPosition
        }

        // Start the property animator and keep track of it
        // Animator never reaches end when being driven interactively
        // animates seperately but alongside the transition animator
        frameAnimator.startAnimation()
        self.frameAnimator = frameAnimator

        transitionAnimator.isReversed = (position == .start)

        if transitionAnimator.state == .inactive {
            transitionAnimator.startAnimation()
        } else {
            transitionAnimator.continueAnimation(withTimingParameters: nil, durationFactor: transitionAnimator.fractionComplete == 1.0 ? 0.0 : 1.0)
        }
    }

    private func setupTransitionAnimator(_ transitionAnimations: @escaping () -> Void, transitionCompletion: @escaping (UIViewAnimatingPosition, Bool) -> Void) {
        transitionAnimator = UIViewPropertyAnimator(duration: ModalCardTransitionDriver.duration, curve: presenting ? .easeOut : .easeIn, animations: transitionAnimations)
        transitionAnimator.scrubsLinearly = false

        transitionAnimator.addCompletion { [weak self] position in

            let completed = (position == .end)
            transitionCompletion(position, completed)

            self?.context.transitionContext.completeTransition(completed)
        }
    }

    @objc private func updateTransition(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .began, .changed:
            // make the transition interactive
            if transitionAnimator.isRunning {
                pauseAnimation()
            }

            let contentContainerView = context.contentContainerView
            let contentFrame = context.contentContainerView.frame

            let translation = gesture.translation(in: context.contentContainerView)

            let step = (presenting ? -1.0 : 1.0) * (translation.y / context.contentContainerView.bounds.midY)

            let percentComplete = transitionAnimator.fractionComplete + step

            if contentFrame.origin.y > viewPositions.initial.y {
                // Update the transition animator's fractionCompete to scrub it's animations
                transitionAnimator.fractionComplete = percentComplete

                // Inform the transition context of the updated percent complete
                context.transitionContext.updateInteractiveTransition(percentComplete)
            }

            let potentialPosition = contentContainerView.center.y + translation.y

            let insets = context.transitionContext.containerView.safeAreaInsets
            var minY: CGFloat = contentContainerView.frame.height / 2 + insets.top
            let boundsExceeded = contentFrame.origin.y + translation.y <= viewPositions.initial.y

            if !context.exceedsEndpoint && boundsExceeded {
                minY = contentContainerView.center.y
            }

            contentContainerView.center.y = max(minY, potentialPosition)

            // Reset the gestures translation
            gesture.setTranslation(CGPoint.zero, in: contentContainerView)
        case .ended, .cancelled:
            endInteraction()
        default: break
        }
    }

    private var completionPosition: UIViewAnimatingPosition {
        let completionThreshold: CGFloat = context.endpoint / 3
        let flickMagnitude: CGFloat = 1200
        let velocity = context.panGestureRecognizer.velocity(in: context.transitionContext.containerView).vector
        let isFlick = (velocity.magnitude > flickMagnitude)
        let isFlickDown = isFlick && (velocity.dy > 0.0)
        let isFlickUp = isFlick && (velocity.dy < 0.0)

        if (presenting && isFlickUp) || (!presenting && isFlickDown) {
            return .end
        } else if (presenting && isFlickDown) || (!presenting && isFlickUp) {
            return .start
        } else if transitionAnimator.fractionComplete > completionThreshold {
            return .end
        } else {
            return .start
        }
    }

    private func endInteraction() {
        // Ensure the context is currently interactive
        guard isInteractive else { return }

        // Inform the transition context of whether we are finishing or cancelling the transition
        if self.completionPosition == .end {
            context.transitionContext.finishInteractiveTransition()
        } else {
            context.transitionContext.cancelInteractiveTransition()
        }

        // Begin the animation phase of the transition to either the start or finsh position
        animate(completionPosition)
    }

    private func pauseAnimation() {
        frameAnimator?.stopAnimation(true)

        // Pause the transition animator
        transitionAnimator.pauseAnimation()

        // Inform the transition context that we have paused
        context.transitionContext.pauseInteractiveTransition()
    }
}
