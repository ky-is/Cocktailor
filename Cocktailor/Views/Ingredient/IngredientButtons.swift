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

struct IngredientButtonOwned: View {
	let data: IngredientData
	@Binding var entry: IngredientEntry?
	let hasCocktail: Bool
	let withContent: Bool

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
			IngredientButtonOwnedContent(data: data, selected: entry?.owned ?? false, hasCocktail: hasCocktail, withContent: withContent)
		}
	}
}

struct IngredientButtonOwnedContent: View {
	let data: IngredientData
	let selected: Bool
	let hasCocktail: Bool
	let withContent: Bool

	var body: some View {
		Group {
			Image(systemName: selected ? "checkmark" : "circle")
				.frame(width: 28)
				.foregroundColor(selected ? .accentColor : .tertiary)
			if withContent {
				IngredientListItem(data: data, available: hasCocktail, substitute: nil)
			}
		}
	}
}

struct IngredientListItem: View {
	let data: IngredientData
	let available: Bool
	let substitute: IngredientData?

	var body: some View {
		HStack {
			IngredientImage(data: data, size: 36)
			VStack(alignment: .leading) {
				Text(data.name.localizedCapitalized)
					.foregroundColor(available ? .primary : .secondary)
				if substitute != nil {
					HStack {
						Text("substitute ")
						+
						Text(substitute!.name)
							.bold()
					}
						.font(.subheadline)
				}
			}
		}
	}
}

struct IngredientImage: View {
	let data: IngredientData
	let size: CGFloat

	var body: some View {
		ZStack {
			Image("Ingredients/\(data.icon.rawValue)")
				.resizable()
				.aspectRatio(contentMode: .fit)
				.foregroundColor(data.color.opacity(0.75))
			Image("Ingredients/\(data.icon.rawValue)-outline")
				.resizable()
				.aspectRatio(contentMode: .fit)
				.foregroundColor(Color.secondary)
		}
			.frame(height: size)
	}
}

struct IngredientButtons_Previews: PreviewProvider {
	static var previews: some View {
		let data = IngredientData.keyValues["mezcal"]!
		return VStack {
			IngredientButtonFavorite(data: data, entry: .constant(nil))
			IngredientButtonOwned(data: data, entry: .constant(nil), hasCocktail: true, withContent: true)
			IngredientImage(data: data, size: 128)
		}
	}
}
