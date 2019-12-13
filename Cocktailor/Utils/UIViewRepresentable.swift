import SwiftUI
import UIKit

struct BlurView: UIViewRepresentable {
	let style: UIBlurEffect.Style

	func makeUIView(context: UIViewRepresentableContext<BlurView>) -> UIView {
		let view = UIView(frame: .zero)
		view.backgroundColor = .clear
		let blurEffect = UIBlurEffect(style: style)
		let blurView = UIVisualEffectView(effect: blurEffect)
		blurView.translatesAutoresizingMaskIntoConstraints = false
		view.insertSubview(blurView, at: 0)
		NSLayoutConstraint.activate([
			blurView.heightAnchor.constraint(equalTo: view.heightAnchor),
			blurView.widthAnchor.constraint(equalTo: view.widthAnchor),
		])
		return view
	}

	func updateUIView(_ uiView: UIView,context: UIViewRepresentableContext<BlurView>) {
	}
}

struct MultilineTextView: UIViewRepresentable {
	let placeholder: String
	@Binding var text: String
	let dismiss: (String) -> Void

	internal func makeCoordinator() -> Coordinator {
		Coordinator(self)
	}

	func makeUIView(context: Context) -> UITextView {
		let view = UITextView()
		view.backgroundColor = .clear
		view.font = .systemFont(ofSize: 20)
		view.delegate = context.coordinator
		return view
	}

	func updateUIView(_ textView: UITextView, context: Context) {
		let showPlaceholder = !context.coordinator.isEditing && text.isEmpty
		textView.text = showPlaceholder ? placeholder : text
		textView.textColor = showPlaceholder ? .secondaryLabel : .label
	}

	internal final class Coordinator: NSObject, UITextViewDelegate {
		var parent: MultilineTextView
		var isEditing = false

		init(_ uiTextView: MultilineTextView) {
			self.parent = uiTextView
		}

		func textViewDidBeginEditing(_ textView: UITextView) {
			isEditing = true
		}

		func textViewDidEndEditing(_ textView: UITextView) {
			isEditing = false
			parent.dismiss(textView.text)
		}

		func textViewDidChange(_ textView: UITextView) {
			parent.text = textView.text
		}
	}
}

struct UIViewRepresentable_Previews: PreviewProvider {
	static var previews: some View {
		VStack {
			BlurView(style: .systemChromeMaterial)
			MultilineTextView(placeholder: "Test placeholder", text: .constant(""), dismiss: { _ in })
				.background(Color.secondarySystemBackground)
				.padding()
		}
	}
}

