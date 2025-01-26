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

Sometimes you just want to show a separator between elements, without introducing a whole submenu that complicate things. This is where `Separator` comes in. It's a separator.

#### Example

```
Separator()
```

The separator is marked in red here:

<img width="272" alt="Image" src="https://github.com/user-attachments/assets/60e37c52-5524-4fc0-991c-010041af6718" />

#### Properties:

- `isHidden` if set to true, this element won't be shown at all

</details>
<details>
<summary>TitleHeader</summary>

### TitleHeader

Sometimes you want to have a title header, without introducing a whole submenu. This is where `TitleHeader` comes in.


#### Example

```
TitleHeader("My Title")
```

The title header is marked in red here:

<img width="267" alt="Image" src="https://github.com/user-attachments/assets/77f49d68-f3c0-4c63-aa37-a6ea8bb65bfc" />

#### Properties:

- `title` the title to show
- `isHidden` if set to true, this element won't be shown at all

</details>
<details>
<summary>SearchField</summary>

### SearchField

Embeds a search field in the menu. Best used as a `headers` element in a (sub)menu.

#### Example

````
// we define a set of languages as Actions
let languages = [
  Action(title: "Dutch"),
  Action(title: "English"),
  Action(title: "French"),
  Action(title: "German"),
  Action(title: "Italian"),
  Action(title: "Spanish"),
  Action(title: "Swedish"),
]

// next we have a search field that on search filters the languages by hiding the elements that don't match'
let searchField = SearchField(placeholder: "Search For a Language", updater: { searchText in
  for language in languages {
    language.isHidden = (searchText.isEmpty == false && language.title?.localizedCaseInsensitiveContains(searchText) == false)
  }
})

// and finally we build a menu with the languages as children and the searchField as a header
return Menu(children: languages, headers: [searchField])
````

This shows as:

![Image](https://github.com/user-attachments/assets/499f6b35-0864-4f9d-9748-029026893fe0)

#### Properties:

- `placeholder` the placeholder that is shown in the search field when the user didn't any text yet
- `searchText` the search text to show in the search field by default. Will be updated when the user types in the search field
- `updater` the callback that will be called when the user types in the search field.
- `shouldAutomaticallyFocusOnAppearance` if true, the search field will become first responder when it appears to the user
- `isEnabled` if false, the search field cannot be focused 
- `isHidden` if set to true, this element won't be shown at all

</details>
<details>
<summary>CustomView</summary>

### CustomView

This allows you to embed a custom view in a menu. The element cannot be highlighted and the custom view can be interacted with by the user (e.g. you can place controls in it). This element is best used a `headers` element.

The view you supply can take up the full width of the menu and is free to determine its own height.

#### Example

```
// a function that creates a header view for us with a profile photo and a name and subtitle
let headerView = createHeaderView()

// next we create an element for it
let customViewElement = CustomView(view: headerView)

let menu = Menu(children: [...], headers: [customViewElement])

```

This results in:

<img width="292" alt="Image" src="https://github.com/user-attachments/assets/ee9b35b8-8912-4fb5-9090-f7a42af90060" />

#### Properties:

- `view` the custom view. This is a `ReusableViewConfiguration` for more flexibility. See the discussion below.
- `isHidden` if set to true, this element won't be shown at all

#### Convenience Initializers:

- `init(view: UIView)` takes an existing view and shows it
- `init(viewProvider: @escaping () -> UIView)` creates the view on demand by calling the `viewProvider` block when needed

#### Reusable Views

If you use `CustomViewAction` as a one-off element, you usually don't need reusablity and can use one of the convenience initializers. However, if you build a __subclass__ or __reusable__ Element, your element can be shown a lot of times and you need to account for __reusability__ by using a full `ReusableViewConfiguration`. 

See the discussion on `ReusableViewConfiguration` below.

</details>
<details>
<summary>CustomViewAction</summary>

### CustomViewAction

This allows you to embed a custom view in a menu and have the highlight and tap the element. When the element is tapped, a handler is called and the menu is dismissed, like a regular `Action`. The custom view cannot be interacted with by the user. 

The view you supply can take up the full width of the menu and is free to determine its own height.

#### Example

```
// a function that creates a header view for us with a profile photo and a name and subtitle
let headerView = createHeaderView()

// next we create an element for it and register a handler
let customViewActionElement = CustomView(view: headerView, handler: { _ in
  print("Selected!") 
})

let menu = Menu(children: [customViewActionElement])

```

This results in:

<img width="292" alt="Image" src="https://github.com/user-attachments/assets/ee9b35b8-8912-4fb5-9090-f7a42af90060" />

#### Properties:

- `view` the custom view. This is a `ReusableViewConfiguration` for more flexibility. See the discussion below.

##### Attributes

- `isEnabled` if false, the element cannot be selected. The custom view can change the appearance of the menu.
- `isDestructive` set this if the element is for a destructive operation. The custom view can change the appearance of the menu.
- `isHidden` if set to true, this element won't be shown at all

##### Interaction
- `handler` the handler that will be invoked when the user taps on the item
- `keepsMenuPresented` if true, the menu will not be dismissed when the user taps on the item

#### Convenience Initializers:

- `init(view: UIView)` takes an existing view and shows it
- `init(viewProvider: @escaping () -> UIView)` creates the view on demand by calling the `viewProvider` block when needed

#### Reusable Views

If you use `CustomViewAction` as a one-off element, you usually don't need reusablity and can use one of the convenience initializers. However, if you build a __subclass__ or __reusable__ MenuElement, your element can be shown a lot of times and you need to account for __reusability__ by using a full `ReusableViewConfiguration`. 

See the discussion on `ReusableViewConfiguration` below.

</details>
<details>
<summary>CustomContentViewAction</summary>

### CustomContentViewAction

This allows you to make a custom `Action` element with a custom view as content and a custom `trailing accessory`. The custom view and trailing accessory are positioned and managed for you, so that it follows the layout of other `Action` elements. E.g, your content might be insetted from the edges of the menu, depending on the configuration of the action and other.

A `CustomContentViewAction` also can show a checkmark and has a `handler` when it is tapped on. The views you provide are not interactable.

#### Example

````
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
let customContentViewAction = CustomContentViewAction(contentView: contentView, trailingAccessoryView: trailingAccessoryView, isSelected: true)

// and create our menu with our custom action
return Menu(children: [
	Action(title: "Preferences", image: UIImage(systemName: "gear")),
	.separator,
	Action(title: "Use Language", image: UIImage(systemName: "globe"), isSelected: true),
	Action(title: "Use Location", image: UIImage(systemName: "location")),
	customContentViewAction
])
````

This results in the following menu, where the bottom element is using a custom content view: notice the `(beta)` label in a different font and color on the title and the use of an emoji as image. 

<img width="269" alt="Image" src="https://github.com/user-attachments/assets/d7b94ca4-4ee8-4776-b51f-519d69680fcb" />

#### Properties:

- `contentView` the custom content view that is placed where the `title` of a normal `Action` is shown. This is a `ReusableViewConfiguration` for more flexibility. See the discussion below.
- `trailingAccessoryView` the trailing accessory view that is placed where the `image` of a normal `Action` is shown. This is a `ReusableViewConfiguration` for more flexibility. See the discussion below.

##### Attributes

- `isSelected` if true, the item will be shown with a checkmark indicating selection
- `isEnabled` if false, the element cannot be selected
- `isDestructive` set this if the element is for a destructive operation
- `isHidden` if set to true, this element won't be shown at all

##### Interaction
- `handler` the handler that will be invoked when the user taps on the item
- `keepsMenuPresented` if true, the menu will not be dismissed when the user taps on the item
   
#### Reusable Views

You usually use this element when you want to provide a __subclass__ or a __reusable__ MenuElement. Because your custom element can be shown a lot of times in a menu, you need to account for __reusability__ for performance reasons. 

See the discussion on `ReusableViewConfiguration` below.

</details>
<details>
<summary>Group</summary>

### Group

This element can be used to logically group a list of other elements - it doesn't do anything. 

You can also use this for subclassing to hide your internal element representation. For example, if you want to provide a `Language` element you could either:

- subclass `Action` and add a `languageCode` property which then sets the `title`. All the original properties of `Action` can still be set, including `title`.
- subclass `Group`, add a `languageCode` property and have an internal `action` element that you override. This way, you don't leak out that you use an `Action` for displaying your contents. See the example below.

#### Example

````
class Language: Group {
  var languageCode: String {
    didSet {
      guard languageCode != oldValue else { return }
      action.title = languageNameFromCode(languageCode)
      setNeedsUpdate()
    }
  }
  
  private let action = UIAction()
  
  public var displayedElements: [MenuElement] {
    return [action]
  }
  
  init(code: String) {
    self.languageCode = code
	action.title = languageNameFromCode(code)
	super.init()
  }
}

let englishLanguageElement = Language(code: "en")
let spanishLanguageElement = Language(code: "es")

let menu = Menu(children: [englishLanguageElement, spanishLanguageElement])
```

As you can see, people instantiating a `Language` subclass Element cannot see how it's internal implementation uses an `Action` row to actual display content.


#### Properties:

- `displayedElements` override this in subclasses to dynamically provide the content of the group
- `isHidden` if set to true, this element won't be shown at all

</details>

## Presenting Menus

AveMenuKit gives you freedom in where and how you present your menus - as opposed to UIKit, where you cannot freely present your menu - you always have to use UIKit's interaction and gestures.

You can use two ways to present menus: 

- `MenuInteraction` presents the menu for you on tap & long press
- `MenuPresentation` you are in charge of presenting the menu when you need

### MenuInteraction

A `MenuInteraction` can be added to any `UIView` or `UIControl` and will add appropriate gesture recognizers to show the menu when tapped or long pressed.

#### Example

The simplest form is to add an interaction with a passed in menu:

```
let myButton = UIButton()
let myMenu = createMyMenu()
myButton.addInteraction(MenuInteraction(menu: myMenu))
```

You can also dynamically provide a menu every time it is needed:

```
let myButton = UIButton()
myButton.addInteraction(MenuInteraction(menuProvider: { [weak self] in
  // this will be called every time the menu is presented 
  return self?.createMyMenu()
}))
``` 

#### Properties:

- `menuProvider` a closure that will be called every time a menu is needed
- `menu` convenience - set a menu that will be used for every presentation
- `attachmentPointProvider` if you want to attach the menu at a different point, use this closure and return the point where the menu should attach to the control.
- `preferredElementOrder` the preferred order of the elements in the menu

#### Methods:

- `presentMenu(animated:)` presents the menu if possible
- `dismissMenu(animated:)` dismisses any presented menu

### MenuPresentation

If you want more control over how a menu is presented and when, you use `MenuPresentation`. Now you are in charge of presenting the menu on user interaction and you can configure it any way you want.

#### Example

The simplest way of presenting a menu is using the static `presentMenu()` helper:

```
func onButtonTap() {
  let myMenu = createMyMenu()
  MenuPresentation.presentMenu(myMenu, source: .view(myButton), animated: true)
}

```

If you want more control, you can also instantiate a `MenuPresentation` and even keep it around for a long time:

```
// configure a presentation
let presentation = MenuPresentation()
presentation.source = .view(myButton, attachmentPoint: CGPoint(x: 100, y: 10))
presentation.preferredElementOrder = .fixed
presentation.dismissalCallback = { [weak myButton] in
  myButton.isHighlighted = false 
}

// and present the menu
myButton.isHighlighted = true
presentation.present(animated: true)
```

#### Properties:

- `menu` the menu to present - must be set before calling `present()`
- `source` the source view or bar button item that presents the animation - must be set before calling `present()`
- `preferredElementOrder` the preferred order of the elements in the menu
- `transferringLongPressGestureRecognizer` used to transfer long presses to the menu, so the user can smoothly select items after a long press by just moving their finger.
- `dismissalCallback` will be called when the menu is no longer presented


#### Methods:

- `present(animated:)` presents the menu. `menu` and `source` must be set
- `dismiss(animated:)` dismisses the currently presented menu.
- `presentMenu(...)` static convenience method to present a menu in one go. Returns the created `MenuPresentation` that is already presenting a menu.

#### Transferring Long Presses

If you present a menu on long press, it would be nice if the user can just move their finger towards the menu and select a menu element in one go, without ever lifting their finger. You can achieve this by setting `transferringLongPressGestureRecognizer`: the menu will transfer the long press gesture to the menu and allow smooth selection.

You can even set this after using the static `presentMenu()` helper:

```
func onLongPressStarted(sender: UILongPressGestureRecognizer) {
  let presentation = MenuPresentation.presentMenu(myMenu, source: .view(myButton), animated: true)
  presentation.transferringLongPressGestureRecognizer = sender
}
```

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

### When to Use Which Element?

### ReusableViewConfiguration

While for one-off header views you usually don't need __reusability__ of views, you might want to. If you create an element (or a subclass) that can be used many times in a menu, you need to make your view reusable: if your `CustomView` element is shown, the system will ask try to use an already cached one by checking for the `reuseIdentifier` of your `ReusableViewConfiguration` and only when there is none will ask you to create one via the `provider` callback of your `ReusableViewConfiguration`. Then, it will ask you to configure the view (which was either cached or newly created) via the `update` handler of the `ReusableViewConfiguration`.

This system allows the menu to be performant when there are many offscreen elements and the menu is scrollable. It works the same way as `UITableViewCell` and `UICollectionViewCell` reusability. `ReusableViewConfiguration` allows you to specify which level of reusability you want. See more in the section on `ReusableViewConfiguration`.

### MenuMetrics
