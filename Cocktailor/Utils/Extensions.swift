import SwiftUI

extension Binding {
	init(_ get: @escaping () -> Value) {
		self.init(get: get, set: { _ in })
	}
}

extension String {
	func pluralize(_ count: Int) -> String {
		return "\(count) \(self)\(count == 1 ? "" : "s")"
	}
}
