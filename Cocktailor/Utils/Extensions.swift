import SwiftUI

extension Binding {
	init(_ get: @escaping () -> Value) {
		self.init(get: get, set: { _ in })
	}
}

extension String {
	func pluralize(_ count: Int, withNumber: Bool = true) -> String {
		let pluralString = self + (count == 1 ? "" : "s")
		return withNumber ? "\(count) \(pluralString)" : pluralString
	}
}

extension Color {
	static let brown = Self(UIColor.brown)

	static let tertiary = Self(UIColor.tertiaryLabel)
	static let systemBackground = Self(UIColor.systemBackground)
	static let secondarySystemBackground = Self(UIColor.secondarySystemBackground)
}

extension Collection {
	subscript(safe index: Index) -> Element? {
		return indices.contains(index) ? self[index] : nil
	}
}

extension Dictionary {
	subscript(optional key: Key?) -> Value? {
		guard let key = key else {
			return nil
		}
		return self[key]
	}
}

extension Collection where Element == String {
	subscript(tsv index: Index) -> String? {
		guard indices.contains(index) else {
			return nil
		}
		let value = self[index]
		return value.isEmpty ? nil : value
	}
}

extension EdgeInsets {
	static let zero = Self(top: 0, leading: 0, bottom: 0, trailing: 0)
}

#if DEBUG
extension PreviewDevice {
	static let iPadPro11 = PreviewDevice(rawValue: "iPad Pro (11-inch)")
	static let iPadPro13 = PreviewDevice(rawValue: "iPad Pro (12.9-inch)")
}
#endif

extension UIApplication {
	func endEditing() {
		sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
	}
}
