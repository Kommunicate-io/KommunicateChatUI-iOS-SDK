/// Usage of `ALKCurvedButton`
import ApplozicSwift
import UIKit

/// Using default font and color
var button = ALKCurvedButton(title: "Demo Button")

/// Using custom font and color
let font = UIFont.boldSystemFont(ofSize: 20)
let color = UIColor.red
button = ALKCurvedButton(title: "Demo Button 2", font: font, color: color)

/// Restricting button width
button = ALKCurvedButton(title: "Long text inside button for multiline", maxWidth: 200)
