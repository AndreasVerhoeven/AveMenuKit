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
				// an inline group of 3 buttons next to each other
				.mediumInlineGroup(
					Action(title: "Copy", image: UIImage(systemName: "doc.on.doc")),
					Action(title: "Cut", image: UIImage(systemName: "scissors")),
					Action(title: "Paste", image: UIImage(systemName: "clipboard"))
				),

				// a scrollable palette of circles
				.palette([
					Action(image: UIImage(systemName: "circle.fill")?.withTintColor(.systemRed, renderingMode: .alwaysOriginal), isSelected: true),
					Action(image: UIImage(systemName: "circle.fill")?.withTintColor(.systemOrange, renderingMode: .alwaysOriginal)),
					Action(image: UIImage(systemName: "circle.fill")?.withTintColor(.systemGreen, renderingMode: .alwaysOriginal)),
					Action(image: UIImage(systemName: "circle.fill")?.withTintColor(.systemBlue, renderingMode: .alwaysOriginal)),
					Action(image: UIImage(systemName: "circle.fill")?.withTintColor(.systemPurple, renderingMode: .alwaysOriginal)),
					Action(image: UIImage(systemName: "circle.fill")?.withTintColor(.systemPink, renderingMode: .alwaysOriginal)),

				]).paletteSelectionStyle(.openCircle),

				// a standard inline menu with regular items
				.inline(
					Action(title: "Preferences", image: UIImage(systemName: "gear")),
					Action(title: "Bookmarks", image: UIImage(systemName: "bookmark"))
				),

				// a sub menu with a special search header
				Menu(title: "Contacts", children: [
					Action(title: "John"),
					Action(title: "Diane"),
					Action(title: "Mark"),
				], headers: [
					SearchField(placeholder: "Search Contacts"),
				]),

				// an element that will be loaded on demand after 2 seconds
				.uncachedLazy({ completion in
					DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
						completion([
							// a separator
							.separator,
							Action(title: "More..."),
						])
					}
				})

			],
			headers: [
				// a custom profile view on top as a header
				CustomView(view: createHeaderView())
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
