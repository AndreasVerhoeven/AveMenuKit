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

	func customContentViewAction() -> CustomContentViewAction {
		// Our custom content view is a label that shows an attributed string to
		// show a (beta) label in a custom font and color.
		let contentView = ReusableViewConfiguration.reusableView(
			reuseIdentifier: "MyLabel",
			provider: {
				// simple label - we could do more configuration here if needed
				return UILabel()
			}, updater: { label, metrics, animated in
				// configure our label with the metrics
				label.numberOfLines = metrics.maximumNumberOfLines
				label.textColor = metrics.contentColor
				label.font = metrics.contentFont

				// and set an attributed string as the label text
				let attributedText = NSMutableAttributedString(string: "AutoSummary")
				attributedText.append(NSAttributedString(string: " (beta)", attributes: [
					.font: UIFont.preferredFont(forTextStyle: .caption1),
					.foregroundColor: metrics.contentColor.withAlphaComponent(0.5),
					.baselineOffset: 5,
				]))
				label.attributedText = attributedText
			}
		)

		// `Action` can only show images, but we want to show an emoji, so
		// our trailing accessory is a `UILabel` that shows an emoji.
		//
		// We use the `viewClass` variant here, since we don't configure the label
		let trailingAccessoryView = ReusableViewConfiguration.reusableView(
			reuseIdentifier: "MyAccessoryLabel",
			viewClass: UILabel.self,
			updater: { label, metrics, animated in
				label.font = metrics.contentFont
				label.numberOfLines = 1
				label.text = "😍"
			}
		)

		// configure our `CustomContentViewAction`. Notice how we can use the `isSelected` property, just like with regular Actions
		return CustomContentViewAction(contentView: contentView, trailingAccessoryView: trailingAccessoryView, isSelected: true)
	}

	func createMenu() -> Menu {
		return Menu(
			children:[
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
				customContentViewAction(),
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
