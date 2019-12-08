import Combine
import SwiftUI

struct SoftwareKeyboardModifier: ViewModifier {
	@Binding var offset: CGFloat

	func body(content: Content) -> some View {
		content
//			.padding(.bottom, self.offset)
			.edgesIgnoringSafeArea(self.offset == 0 ? Edge.Set() : .bottom)
			.onAppear(perform: subscribeToKeyboardEvents)
	}

	private let keyboardWillOpen = NotificationCenter.default
		.publisher(for: UIResponder.keyboardWillShowNotification)
		.map { $0.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! CGRect }
		.map { $0.height }

	private let keyboardWillHide =  NotificationCenter.default
		.publisher(for: UIResponder.keyboardWillHideNotification)
		.map { _ in CGFloat.zero }

	private func subscribeToKeyboardEvents() {
		_ = Publishers.Merge(keyboardWillOpen, keyboardWillHide)
			.subscribe(on: RunLoop.main)
			.assign(to: \.self.offset, on: self)
	}
}
