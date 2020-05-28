import SwiftUI

struct IngredientButtonFavorite: View {
	let data: IngredientData
	@ObservedObject var entry: IngredientEntry

	@Environment(\.managedObjectContext) private var context

	init(data: IngredientData, entry: IngredientEntry?) {
		self.data = data
		self.entry = entry ?? IngredientEntry(id: data.id, insertInto: nil)
	}

	var body: some View {
		Button(action: {
			self.context.performAndSave {
				self.context.insert(self.entry)
				self.entry.favorite.toggle()
			}
		}) {
			Image(systemName: entry.favorite ? "star.fill" : "star")
				.foregroundColor(.yellow)
		}
	}
}

struct IngredientButtonOwned: View {
	let data: IngredientData
	@ObservedObject var entry: IngredientEntry
	let hasCocktail: Bool
	let withContent: Bool

	@Environment(\.managedObjectContext) private var context

	init(data: IngredientData, entry: IngredientEntry?, hasCocktail: Bool, withContent: Bool) {
		self.data = data
		self.entry = entry ?? IngredientEntry(id: data.id, insertInto: nil)
		self.hasCocktail = hasCocktail
		self.withContent = withContent
	}

	var body: some View {
		Button(action: {
			self.context.performAndSave {
				self.context.insert(self.entry)
				self.entry.owned.toggle()
			}
		}) {
			IngredientButtonSelectedContent(data: data, selected: entry.owned, hasCocktail: hasCocktail, withContent: withContent)
		}
	}
}

struct IngredientButtonSelectedContent: View {
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
		Group {
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
				.aspectRatio(contentMode: .fill)
				.foregroundColor(data.color.opacity(0.75))
			Image("Ingredients/\(data.icon.rawValue)-outline")
				.resizable()
				.aspectRatio(contentMode: .fit)
				.foregroundColor(.secondary)
		}
			.frame(width: size * 0.8, height: size)
	}
}

struct IngredientButtons_Previews: PreviewProvider {
	static let data = IngredientData.keyValues["mezcal"]!

	static var previews: some View {
		VStack {
			IngredientButtonFavorite(data: data, entry: nil)
			IngredientButtonOwned(data: data, entry: nil, hasCocktail: true, withContent: true)
			IngredientImage(data: data, size: 128)
		}
	}
}
