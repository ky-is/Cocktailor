import SwiftUI

struct IngredientButtonFavorite: View {
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

struct IngredientButtonOwned<Content: View>: View {
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

struct IngredientButtonOwnedContent: View {
	let data: IngredientData
	let selected: Bool
	let hasCocktail: Bool

	var body: some View {
		Group {
			Image(systemName: selected ? "checkmark" : "circle")
				.frame(width: 28)
				.foregroundColor(selected ? .accentColor : .tertiary)
			IngredientImage(data: data)
				.frame(width: 32)
			Text(data.name.localizedCapitalized)
				.foregroundColor(hasCocktail ? .primary : .secondary)
		}
	}
}

struct IngredientImage: View {
	let data: IngredientData

	var body: some View {
		ZStack {
			Image(data.icon.rawValue)
				.resizable()
				.aspectRatio(contentMode: .fit)
				.foregroundColor(data.color.opacity(0.75))
			Image("\(data.icon.rawValue)-outline")
				.resizable()
				.aspectRatio(contentMode: .fit)
				.foregroundColor(Color.secondary)
		}
	}
}

struct IngredientButtons_Previews: PreviewProvider {
	static var previews: some View {
		let data = lime
		return VStack {
			IngredientButtonFavorite(data: data, entry: .constant(nil))
			IngredientButtonOwned(data: data, entry: .constant(nil)) {
				IngredientButtonOwnedContent(data: data, selected: true, hasCocktail: true)
			}
			IngredientImage(data: lime)
		}
	}
}
