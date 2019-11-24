import SwiftUI

extension Binding {
	init(_ get: @escaping () -> Value) {
		self.init(get: get, set: { _ in })
	}
}
