# AveMenuKit

A reimplementation of iOS context menus with more features: headers, custom views, show the menu whenever you want. Behavior and design of the original iOS context menus is 1:1 mimicked.

## Screenshots

<img src= "https://github.com/user-attachments/assets/934353e1-e682-4b9f-9a12-a2eb651c119e" width=200>
<img src= "https://github.com/user-attachments/assets/a660b754-c9c1-4983-9aeb-0dd71143e30e" width=200>
<img src= "https://github.com/user-attachments/assets/e99c4603-e5ba-45fd-860f-dae191211b97" width=200>

## Description

AveMenuKit is a reimplementation of iOS context menus. Since iOS 14, it's possible to show `UIMenu` from controls and bar button items. However, this is pretty locked down: 

- you can't use custom header views (Apple itself can)
- you can't present the menu yourself, you have to use `UIContextMenuInteraction` (Apple itself can)
- you can't dynamically update the menu when it's being displayed (Apple itself can)
- you can't use custom rows (Apple itself can)
- newer options, such as palettes and smaller elements are not backwards compatible.

This reimplementation unlocks those limitations by providing a similar API without any of these restrictions, and it's fully backwards compatible up to iOS 13.

### Example:

```
let myHeaderView = createProfileHeaderView()

let menu = Menu(
	children: [
		Action(title: "Preferences", image: UIImage(systemName: "gear") handler: { _ in handlePreferences() }),
		
		// we want a separator, no need to build a whole menu hierarchy
		.separator,
		
		Action(title: "Include Attachments", isSelected: true),
		
		// show a submenu with 2 elements
		.submenu(title: "Display As",
				Action(title: "Icons", isSelected: true),
				Action(title: "Titles", isSelected: false)
		)
	],

	headers: [
		// here we add a header element to the menu that is our profile view
		CustomView(view: myHeaderView)
	]
)

// we can just present the menu whenever we want
MenuPresentation.presentMenu(menu, source: .view(myButton), animated: true)

```
