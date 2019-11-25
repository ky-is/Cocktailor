import SwiftUI

struct ButtonFavorite: View {
	let data: IngredientData
	@Binding var entry: IngredientEntry?

	@Environment(\.managedObjectContext) private var managedObjectContext

	private func toggleFavorite() {
		if let entry = entry {
			managedObjectContext.perform {
				entry.favorite.toggle()
				DataModel.saveContext()
			}
		} else {
			managedObjectContext.perform {
				let entry = IngredientEntry(context: self.managedObjectContext)
				entry.id = self.data.id
				entry.favorite = true
				DataModel.saveContext()
			}
		}
	}

	var body: some View {
		Button(action: toggleFavorite) {
			Image(systemName: entry?.favorite ?? false ? "star.fill" : "star")
				.foregroundColor(.yellow)
		}
	}
}

struct ButtonOwned<Content>: View where Content: View {
	let data: IngredientData
	@Binding var entry: IngredientEntry?
	let content: (() -> Content)?

	@Environment(\.managedObjectContext) private var managedObjectContext

	private func toggleOwned() {
		if let entry = entry {
			managedObjectContext.perform {
				entry.owned.toggle()
				try? self.managedObjectContext.save()
			}
		} else {
			managedObjectContext.perform {
				let entry = IngredientEntry(context: self.managedObjectContext)
				entry.id = self.data.id
				entry.owned = true
				try? self.managedObjectContext.save()
			}
		}
	}

	var body: some View {
		Button(action: toggleOwned) {
			content?()
		}
	}
}

struct ButtonOwnedContent: View {
	let data: IngredientData
	let selected: Bool
	let hasCocktail: Bool

	var body: some View {
		Group {
			Image(systemName: selected ? "checkmark" : "circle")
				.frame(width: 28)
				.foregroundColor(selected ? .accentColor : .tertiary)
			IngredientIcon(data: data)
			Text(data.name.localizedCapitalized)
				.foregroundColor(hasCocktail ? .primary : .secondary)
		}
	}
}

struct IngredientButtons_Previews: PreviewProvider {
	static var previews: some View {
		let data = IngredientData(id: "test", name: "test", category: .mixer, color: .white)
		return VStack {
			ButtonFavorite(data: data, entry: .constant(nil))
			ButtonOwned(data: data, entry: .constant(nil)) {
				ButtonOwnedContent(data: data, selected: true, hasCocktail: true)
			}
		}
	}
}

struct IngredientIcon: View {
	let data: IngredientData

	var body: some View {
		Circle()
			.stroke(Color.secondarySystemBackground, lineWidth: 1)
			.overlay(
				Circle().fill(data.color.opacity(0.5))
		)
			.frame(width: 24, height: 24)
	}
}
