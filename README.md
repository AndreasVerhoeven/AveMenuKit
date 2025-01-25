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

## Menus & Element Documentation

In general, we mimick the `UIMenu` API, with some slight differences (e.g. we use `isSelected` instead of `state`) and extra options and elements.

Here's a list of the elements that make up a menu:

<details>
<summary>Menu</summary>

### Menu

A menu shows a list of items and submenus. You can embed a menu into another menu: it's either a submenu that opens on top of the menu or an inline menu by setting the `displaysInline` property to true.

#### Example

A regular (main) menu with different elements:

<img width="277" alt="Main Menu" src="https://github.com/user-attachments/assets/0173bfd8-7bf5-4e84-82f2-f1f218ace014" />

An inline submenu (in the red square):

<img width="267" alt="Image" src="https://github.com/user-attachments/assets/ef72c8c6-1908-49d2-82e4-bc36f7bf6b64" />

An opened non-inline submenu:

<img width="262" alt="Image" src="https://github.com/user-attachments/assets/8e5f220c-5e09-417e-947f-dba80b9feb0d" /> 

#### Properties:
 
- `title` the title of the menu
- `subTitle` the subtitle of the menu
- `image` the image of the menu

##### Attributes

- `isEnabled` if false, the element cannot be selected
- `isDestructive` set this if the element is for a destructive operation
- `isHidden` if set to true, this element won't be shown at all

##### Children

-  `children` the elements that make up this menu
- `headers` elements that will be presented sticky at the top of the menu

##### Configuration

- `preferredElementSize` you can set this to `small` or `medium` to show the elements in this menu in a side-by-side configuration
- `displaysInline` if this is true, a menu that's part of another menu will have it's elements be shown inside of its parent, instead of opening a new submenu
- `displaysAsPalette` displays this menu as a palette. See the `Palette` section
- `betweenMenusSeparatorStyle` this determines if separators are shown between different inline menus
- `onlyDismissesSubMenu` if set to true, tapping an element in this submenu will not dismiss the whole menu, but just close the submenu so we go back to the parent menu.

</details>
<details>
<summary>Action</summary>

### Action

An `Action` is the most common element you see in a menu: it has a title, image and will call a `handler` when it's tapped. An action can also be in a selected state showing a checkmark by setting the `isSelected` flag to true.

#### Example

```
Menu(children: [
  Action(title: "Preferences", image: UIImage(systemName: "gear")),
  Action(title: "Synchronize", image: UIImage(systemName: "cloud"), isEnabled: false),
  Action(title: "Show Categories", image: UIImage(systemName: "bookmark"), isSelected: true),
  Action(title: "Sort By", subtitle: "Newest First", image: UIImage(systemName: "arrow.up.arrow.down")),
  Action(title: "Delete", image: UIImage(systemName: "trash"), isDestructive: true),
])
```
Will result in the following menu:

<img width="262" alt="Image" src="https://github.com/user-attachments/assets/d5aeb231-8ee8-4a3c-bbde-62502cae2a3c" />

##### Properties

- `title` the title of the action
- `subTitle` the subtitle of the action
- `image` the image of the action
- `selectedImage` the image that will be used if `isSelected = true`

##### Attributes

- `isSelected` if true, the item will be shown with a checkmark indicating selection
- `isEnabled` if false, the element cannot be selected
- `isDestructive` set this if the element is for a destructive operation
- `isHidden` if set to true, this element won't be shown at all

##### Interaction
- `handler` the handler that will be invoked when the user taps on the item
- `keepsMenuPresented` if true, the menu will not be dismissed when the user taps on the item

</details>
<details>
<summary>LazyMenuElement</summary>

### LazyMenuElement

A placeholder menu element that will replace itself with the result of a provider callback. You use this to load menu contents on demand. Set the `shouldCache` flag to determine if the provided contents will be cached or not. If not cached, every time the (sub)menu reappears the provider is queried for contents again.


#### Example
```
LazyMenuElement(shouldCache: false, provider: { completion in
  // pretend we are loading data from somewhere that takes 3 seconds
  DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
    completion([
      Action(title: "John"),
      Action(title: "Diane"),
      Action(title: "Peter"),
      Action(title: "Christina"),
    ])
  })
})
```

Will result in the following:

![Image](https://github.com/user-attachments/assets/f496a17c-76ca-4241-bf3a-c58931f52db2)

#### Properties

- `provider` the provider closure that will be called to provide contents. A `completion` handler will be called that should be called with the new contents.
- `shouldCache` if shouldCache is true, once the content is provided it will never be queried again, even if the (sub)menu is hidden and presented later again. If true, the provider will be queried whenever the (sub)menu appears again.
- `isHidden` if set to true, this element won't be shown at all

</details>
<details>
<summary>Separator</summary>

### Separator

</details>
<details>
<summary>TitleHeader</summary>

### TitleHeader

</details>
<details>
<summary>SearchField</summary>

### SearchField

</details>
<details>
<summary>CustomView</summary>

### CustomView

</details>
<details>
<summary>CustomViewAction</summary>

### CustomViewAction

</details>
<details>
<summary>CustomContentViewAction</summary>

### CustomContentViewAction

</details>
<details>
<summary>Group</summary>

### Group

</details>

## Presenting Menus

### MenuPresentation

### MenuInteraction

## Menu Styles:

<details>
<summary>Small & Medium Elements</summary>

### Small & Medium Elements

</details>
<details>
<summary>Palette Menus</summary>

### Palette Menus

</details>


## Details on Custom Views

### When to use what?

### ReusableViewConfiguration

### MenuMetrics
