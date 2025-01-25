//
//  ViewController.swift
//  ScrollerTest
//
//  Created by Andreas Verhoeven on 08/03/2021.
//

import UIKit
import AutoLayoutConvenience
import AveCommonHelperViews

class ViewController: UIViewController {
	func createHeaderView() -> UIView {
		let imageView = UIImageView(image: UIImage(systemName: "person.fill"), contentMode: .scaleAspectFit)
		imageView.tintColor = .systemGray2
		imageView.tintAdjustmentMode = .normal
		let iconView = CircleView(size: 58, backgroundColor: .secondarySystemFill, clipsToBounds: true)
		iconView.addSubview(imageView, filling: .superview, insets: .all(8))

		let headerView = UIView()
		headerView.addSubview(
			.horizontallyStacked(
				iconView.verticallyCentered(),
				.verticallyStacked(
					UILabel(text: "John Appleseed", textStyle: .headline, numberOfLines: 2),
					UILabel(text: "Premium Account", textStyle: .subheadline, color: .secondaryLabel, numberOfLines: 2),
					spacing: 2
				).verticallyCentered(),
				spacing: 16
			),
			filling: .layoutMargins,
			insets: .all(8)
		)

		return headerView
	}

	func createMenu() -> Menu {
		return Menu(
			children: [

				Action(title: "See All Friends", image: UIImage(systemName: "person.3")),
				.separator,
				TitleHeader(title: "Shared With:"),
				LazyMenuElement(shouldCache: false, provider: { completion in
					DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
						completion([
							Action(title: "John", image: UIImage(systemName: "person")),
							Action(title: "Diane", image: UIImage(systemName: "person")),
							Action(title: "Peter", image: UIImage(systemName: "person")),
							Action(title: "Christina", image: UIImage(systemName: "person")),
						])
					})
				})

				/*
				// an inline group of 3 buttons next to each other
				.mediumInlineGroup(
					Action(title: "Copy", image: UIImage(systemName: "doc.on.doc")),
					Action(title: "Cut", image: UIImage(systemName: "scissors")),
					Action(title: "Paste", image: UIImage(systemName: "clipboard"))
				),
				*/

				/*
				// a scrollable palette of circles
				.palette([
					Action(image: UIImage(systemName: "circle.fill")?.withTintColor(.systemRed, renderingMode: .alwaysOriginal), isSelected: true),
					Action(image: UIImage(systemName: "circle.fill")?.withTintColor(.systemOrange, renderingMode: .alwaysOriginal)),
					Action(image: UIImage(systemName: "circle.fill")?.withTintColor(.systemGreen, renderingMode: .alwaysOriginal)),
					Action(image: UIImage(systemName: "circle.fill")?.withTintColor(.systemBlue, renderingMode: .alwaysOriginal)),
					Action(image: UIImage(systemName: "circle.fill")?.withTintColor(.systemPurple, renderingMode: .alwaysOriginal)),
					Action(image: UIImage(systemName: "circle.fill")?.withTintColor(.systemPink, renderingMode: .alwaysOriginal)),

				]).paletteSelectionStyle(.openCircle),
				*/

			],
			headers: [
				// a custom profile view on top as a header
				//CustomView(view: createHeaderView())
			]
		)
	}


	let button = UIButton()

	@objc private func presentMenu(_ sender: Any) {
		MenuPresentation.presentMenu(createMenu(), source: .view(button), animated: true)
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		button.configuration = .filled()
		button.configuration?.title = "Show Menu"
		view.addSubview(button, pinnedTo: .topCenter, of: .safeArea, offset: CGPoint(x: 0, y: 4))

		button.addInteraction(MenuInteraction(menu: createMenu()))
	}
}
