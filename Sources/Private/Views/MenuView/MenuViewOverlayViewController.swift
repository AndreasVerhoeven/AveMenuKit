//
//  MenuViewOverlayViewController.swift
//  Menu
//
//  Created by Andreas Verhoeven on 14/01/2025.
//

import UIKit

/// This view controller is presented "with" animation, so that keyboards are
/// properly animated, but it's duration is 0, so that we immediately get displayed.
/// We drive the animation in viewDidAppear() and viewWillDisappear(),
/// so that we can actually have easily interruptable animations - when disappearing,
/// we move the "animation" view to the window while it animates the disappearance.
final class MenuViewOverlayViewController: UIViewController {
	let menuView = MenuView()
	var presentation: MenuPresentation?

	// MARK: - UIViewController
	override func loadView() {
		view = UIView()
		view.isUserInteractionEnabled = false
		view.backgroundColor = .clear
	}

	override func viewWillTransition(to size: CGSize, with coordinator: any UIViewControllerTransitionCoordinator) {
		super.viewWillTransition(to: size, with: coordinator)
		guard isBeingPresented == false else { return }

		menuView.dismiss(animated: false)
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)

		guard let window = view.window else { return }
		menuView.willDismissCallback = { [weak self] animated in
			guard let self else { return }
			dismiss(animated: animated)
		}
		menuView.frame = CGRect(origin: .zero, size: window.bounds.size)
		menuView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		window.addSubview(menuView)
		menuView.present(animated: animated)
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)

		menuView.performDismiss(animated: animated) { [menuView] in
			menuView.removeFromSuperview()
		}
	}

	// MARK: - UIResponder
	override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
		if presses.contains(where: { $0.key?.keyCode == .keyboardEscape }) {
			menuView.dismiss(animated: true)
		}
	}
}


extension MenuViewOverlayViewController: UIViewControllerTransitioningDelegate {
	func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> (any UIViewControllerAnimatedTransitioning)? {
		return self
	}

	func animationController(forDismissed dismissed: UIViewController) -> (any UIViewControllerAnimatedTransitioning)? {
		return self
	}
}

extension MenuViewOverlayViewController: UIViewControllerAnimatedTransitioning {
	func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
		if let view = transitionContext.view(forKey: .to), let controller = transitionContext.viewController(forKey: .to) {
			view.frame = transitionContext.finalFrame(for: controller)
			transitionContext.containerView.addSubview(view)
		}
		transitionContext.completeTransition(true)
	}

	func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
		return 0
	}
}

