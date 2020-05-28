import Combine
import SwiftUI

struct SoftwareKeyboardModifier: ViewModifier {
	@Binding var offset: CGFloat

	@State private var subscription: AnyCancellable?

	func body(content: Content) -> some View {
		content
//			.padding(.bottom, self.offset)
			.edgesIgnoringSafeArea(self.offset == 0 ? [] : .bottom)
			.onAppear(perform: subscribeToKeyboardEvents)
	}

	private let keyboardWillOpen = NotificationCenter.default
		.publisher(for: UIResponder.keyboardWillShowNotification)
		.map { $0.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! CGRect }
		.map { $0.height } //TODO(11E608c) .map(\.height) compiler error

	private let keyboardWillHide = NotificationCenter.default
		.publisher(for: UIResponder.keyboardWillHideNotification)
		.replace(with: CGFloat.zero)

	private func subscribeToKeyboardEvents() {
		subscription?.cancel()
		subscription = Publishers.Merge(keyboardWillOpen, keyboardWillHide)
			.subscribe(on: RunLoop.main)
			.assign(to: \.self.offset, on: self)
	}
}
