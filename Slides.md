# 3D Touch

new on the iPhone 6s and 6s Plus

---

# 3D Touch

still not available for the iPhone simulator

`(╯°□°）╯︵ ┻━┻`

---

# 3D Touch for Apps

- quick actions
- peek and pop
- pressure sensitivity

---

# Quick Actions

up to 4 total

- static
- dynamic
- custom icon
- menu layout varies slightly
  - order always going away from icon

---


## Static Quick Actions

Info.plist

```xml
	<key>UIApplicationShortcutItems</key>
	<array>
		<dict>
			<key>UIApplicationShortcutItemIconType</key>
			<string>UIApplicationShortcutIconTypeShare</string>
			<key>UIApplicationShortcutItemSubtitle</key>
			<string></string>
			<key>UIApplicationShortcutItemTitle</key>
			<string>Static Quick Action</string>
			<key>UIApplicationShortcutItemType</key>
			<string>$(PRODUCT_BUNDLE_IDENTIFIER).Static</string>
			<key>UIApplicationShortcutItemUserInfo</key>
			<dict>
				<key>secondShortcutKey1</key>
				<string>secondShortcutValue1</string>
			</dict>
		</dict>
```

---


## Dynamic Quick Actions

`UIApplicationShortcutItem` protocol

---


## Quick Action Icons

- `UIApplicationShortcutItemIconType`
  - system icon

- `UIApplicationShortcutItemIconFile`
  - custom icon

---


# Peek and Pop

- preview content
- up to 5 actions
- actions are nestable
- left/right actions (a la Mail) not available for apps 😪

---


## Peek

Peek == Preview

---


## Peek Setup

- implement `UIViewControllerPreviewingDelegate`
- check for `forceTouchCapability`
- call `registerForPreviewingWithDelegate(_:sourceview:)`

---


## `registerForPreviewingWithDelegate`

Test for 3D Touch Support

```swift
if traitCollection.forceTouchCapability == .Available {
    registerForPreviewingWithDelegate(self, sourceView: view)
```

---


## `UIViewControllerPreviewingDelegate`

```swift
func previewingContext(previewingContext: UIViewControllerPreviewing,
                       viewControllerForLocation location: CGPoint)
                       -> UIViewController?
                       
func previewingContext(previewingContext: UIViewControllerPreviewing,
                       commitViewController viewControllerToCommit: UIViewController)
```

---


### `previewingContext:viewControllerForLocation:`

`_UIPreviewInteractionTouchObservingGestureRecognizer`

Asks the delegate to provide a view controller for the preview.
Returning nil cancels the preview.

- previewingContext: UIViewControllerPreviewing
- location: a CGPoint center of the 3D Touch

---


### `previewingContext:commitViewController:`

Called when the "pop" gesture is triggered
`_UIRevealGestureRecognizer`

- previewingContext: `UIViewControllerPreviewing`
- viewControllerToCommit: `UIViewController`

---


## Peek/Preview Actions

- `UIPreviewAction` class
- `UIPreviewActionItem` protocol
- properties
  - title
  - style (normal, destructive, selected✔)
  - handler: closure invoked when selected

---


## Peeked View Controller

The called view controller overrides `previewActionItems()`

```swift
func previewActionItems() -> [UIPreviewActionItem]
```

---


### Nested Actions

- `UIPreviewActionGroup` class
- `UIPreviewActionItem` protocol
- properties
  - title (Convention...)
  - style
  - actions: array of `UIPreviewAction`

---


# Pressure Sensitivity

- raw force applied to screen
- `UITouch.force`
- `UITouch.maximumPossibleForce`


---


# Source

`https://github.com/phatblat/3DTouchDemo`

---


# New in Xcode 7.1 beta 3

> Interface Builder supports enabling Peek & Pop for segues. Peek & Pop segues will be omitted when running on OS versions prior to iOS 9.1. (22886994)

---


## Peek/Pop segues

- only available for "action" or "selection" segues
- buttons
- table view
- collection view

---


## No Peek/Pop segues for you!

- manual segues
- action segues from gesture recognizers

---


# Demo

Collection Peek

---


## Segue Issues

- how to pass data for selection from table/collection VC
  - `prepareForSegue`
- selected `indexPath`?

---


### prepareForSegue

Get selected cell in `prepareForSegue:sender:`
- `collectionView?.indexPathsForSelectedItems()` returns nil

---


### Determine Selection When Preview is Triggered

`previewingContext:viewControllerForLocation:` is called before prepareForSegue
 - `collectionView?.indexPathForItemAtPoint(location)`
 - save `indexPath`
 - returning nil doesn't cancel preview

---


# Pop (aka Commit)

- `prepareForSegue` is called again
- don't clear selection state before 2nd call

---


# Source

`https://github.com/phatblat/CollectionPeek`
