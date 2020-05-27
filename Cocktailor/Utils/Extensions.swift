import SwiftUI
import Combine

extension Collection {
	var nonEmpty: Self? {
		return isEmpty ? nil : self
	}

	subscript(optional index: Index) -> Element? {
		return indices.contains(index) ? self[index] : nil
	}
}

extension Collection where Element == String {
	subscript(tsv index: Index) -> Element? {
		guard indices.contains(index) else {
			return nil
		}
		let value = self[index]
		return value.nonEmpty
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

extension Dictionary {
	subscript(optional key: Key?) -> Value? {
		guard let key = key else {
			return nil
		}
		return self[key]
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

extension Publisher {
	func replace<T>(with value: T) -> Publishers.Map<Self, T> {
		return map { _ in value }
	}
}

extension Sequence {
	func reduce<Result>(_ initialValue: Result, _ operation: (Result, Result) -> Result, _ keyPath: KeyPath<Element, Result>) -> Result {
		return reduce(initialValue) { operation($0, $1[keyPath: keyPath]) }
	}

	func contains<Value>(_ keyPath: KeyPath<Element, Value>, _ operation: (Value, Value) -> Bool, _ comparedTo: Value) -> Bool {
		return contains { operation($0[keyPath: keyPath], comparedTo) }
	}

	func filter<Value>(_ keyPath: KeyPath<Element, Value>, _ operation: (Value, Value) -> Bool, _ comparedTo: Value) -> [Element] {
		return filter { operation($0[keyPath: keyPath], comparedTo) }
	}

	func sorted<Value>(_ keyPath: KeyPath<Element, Value>, _ operation: (Value, Value) -> Bool) -> [Element] {
		return sorted { operation($0[keyPath: keyPath], $1[keyPath: keyPath]) }
	}
}
