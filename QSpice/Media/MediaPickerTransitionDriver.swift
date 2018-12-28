import UIKit

/// Drives the media picker transition using property animators
class MediaPickerTransitionDriver {
    public var isInteractive: Bool {
        return context.transitionContext.isInteractive
    }

    static let duration = 0.35
    private let context: MediaPickerTransitionContext
    private let needsPresenting: Bool
    private(set) var transitionAnimator: UIViewPropertyAnimator!
    private var frameAnimator: UIViewPropertyAnimator?

    private var viewFrames: (initial: (top: CGRect, bottom: CGRect), target: (top: CGRect, bottom: CGRect)) {
        let initialTopFrame: CGRect
        let initialBottomFrame: CGRect
        let finalTopFrame: CGRect
        let finalBottomFrame: CGRect

        let containerView = context.transitionContext.containerView
        let containerFrame = containerView.frame

        // photo picker header is 0.15 * height
        var topFramePresented = containerFrame
        topFramePresented.origin.y = containerFrame.height * -0.85

        // bottom frame initially off screen below top view
        var bottomFrameHidden = containerFrame
        bottomFrameHidden.origin.y = containerFrame.height * 0.85

        if needsPresenting {
            initialTopFrame = containerFrame
            initialBottomFrame = bottomFrameHidden

            finalTopFrame = topFramePresented
            finalBottomFrame = containerFrame
        } else {
            initialTopFrame = topFramePresented
            initialBottomFrame = containerFrame

            finalTopFrame = containerFrame
            finalBottomFrame = bottomFrameHidden
        }

        let initial = (top: initialTopFrame, bottom: initialBottomFrame)
        let target = (top: finalTopFrame, bottom: finalBottomFrame)

        return (initial, target)

    }

    private var viewControllers: (top: UIViewController?, bottom: UIViewController?) {
        guard let toViewController = context.transitionContext.viewController(forKey: .to),
            let fromViewController = context.transitionContext.viewController(forKey: .from)
            else {
                return (nil, nil)
        }

        let topViewController = needsPresenting ? fromViewController : toViewController
        let bottomViewController = needsPresenting ? toViewController : fromViewController

        return (topViewController, bottomViewController)
    }

    init(needsPresenting: Bool, context: MediaPickerTransitionContext) {
        self.needsPresenting = needsPresenting
        self.context = context

        context.panGestureRecognizer.addTarget(self, action: #selector(updateTransition))

        let transitionCtx = context.transitionContext
        let containerView = transitionCtx.containerView

        guard let topViewController = viewControllers.top,
            let bottomViewController = viewControllers.bottom as? PhotoPickerViewController
            else { return }

        // topView will always be the camera, bottomView will always be the photo library
        let topView = topViewController.view!
        let bottomView = bottomViewController.view!

        (topView.frame, bottomView.frame) = viewFrames.initial

        let initialAlpha: CGFloat
        let finalEffect: UIVisualEffect?

        if needsPresenting {
            initialAlpha = 0.0
            finalEffect = UIBlurEffect(style: .light)
            context.blurView.frame = topView.frame
            topView.addSubview(context.blurView)
            containerView.addSubview(bottomView)

        } else {
            initialAlpha = 1.0
            finalEffect = nil
        }

        bottomViewController.headerTitle.alpha = initialAlpha

        self.setupTransitionAnimator({
            bottomViewController.headerTitle.alpha = 1.0 - initialAlpha
            self.context.blurView.effect = finalEffect
        }, transitionCompletion: { (_, ended) in
            if ended && !needsPresenting {
                context.blurView.removeFromSuperview()
                bottomView.removeFromSuperview()
            }
        })

        if !isInteractive {
            animate(.end)
        }

    }

    private var timingCurveVelocity: CGVector {
        let gestureVelocity = context.panGestureRecognizer.velocity(in: context.transitionContext.containerView)

        guard let topViewController = viewControllers.top else {
            return .zero
        }

        // Take top view controller or bottom view controller,
        // the delta should be the same
        let currentFrame = topViewController.view.frame
        let targetFrame = viewFrames.target.top

        let dy = abs(currentFrame.origin.y - targetFrame.origin.y)

        guard dy > 0.0 else {
            return .zero
        }

        let range: CGFloat = 45.0
        let clippedVelocity = clip(-range, range, gestureVelocity.y)

        return CGVector(dx: 0.0, dy: (clippedVelocity / dy))
    }

    private func animate(_ position: UIViewAnimatingPosition) {
        guard let topViewController = viewControllers.top, let bottomViewController = viewControllers.bottom else {
            return
        }

        let timingParameters = UISpringTimingParameters(mass: 2.5, stiffness: 1300, damping: 95, initialVelocity: timingCurveVelocity)
        let frameAnimator = UIViewPropertyAnimator(duration: ModalCardTransitionDriver.duration, timingParameters: timingParameters)

        let (finalTopFrame, finalBottomFrame) = (position == .end ? self.viewFrames.target : self.viewFrames.initial)
        frameAnimator.addAnimations {
            (topViewController.view.frame, bottomViewController.view.frame) = (finalTopFrame, finalBottomFrame)
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
            transitionAnimator.continueAnimation(withTimingParameters: nil, durationFactor: transitionAnimator.fractionComplete)
        }
    }

    private func setupTransitionAnimator(_ transitionAnimations: @escaping () -> Void, transitionCompletion: @escaping (UIViewAnimatingPosition, Bool) -> Void) {
        transitionAnimator = UIViewPropertyAnimator(duration: MediaPickerTransitionDriver.duration, curve: needsPresenting ? .easeOut : .easeIn, animations: transitionAnimations)
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

            if transitionAnimator.isRunning {
                pauseAnimation()
            }

            let containerView = context.transitionContext.containerView
            let (topViewController, bottomViewController) = viewControllers
            let gestureView = needsPresenting ? topViewController?.view : bottomViewController?.view
            let translation = gesture.translation(in: containerView)

            let viewOrigin = (needsPresenting ? -1.0 : 1.0) * (gestureView?.frame.origin.y ?? 0.0)
            let percentComplete = clip(0.0, 1.0, viewOrigin / (containerView.frame.height * 0.85))

            transitionAnimator.fractionComplete = percentComplete

            context.transitionContext.updateInteractiveTransition(percentComplete)

            [topViewController?.view, bottomViewController?.view].forEach { view in
                view?.center.y += translation.y
            }

            gesture.setTranslation(.zero, in: containerView)
        case .ended, .cancelled:
            endInteraction()
        default: break
        }
    }

    private var completionPosition: UIViewAnimatingPosition {
        let completionThreshold: CGFloat = 0.5
        let flickMagnitude: CGFloat = 1200
        let velocity = context.panGestureRecognizer.velocity(in: context.transitionContext.containerView).vector
        let isFlick = (velocity.magnitude > flickMagnitude)
        let isFlickDown = isFlick && (velocity.dy > 0.0)
        let isFlickUp = isFlick && (velocity.dy < 0.0)

        if (needsPresenting && isFlickUp) || (!needsPresenting && isFlickDown) {
            return .end
        } else if (needsPresenting && isFlickDown) || (!needsPresenting && isFlickUp) {
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
