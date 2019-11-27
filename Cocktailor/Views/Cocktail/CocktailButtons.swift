import SwiftUI

struct CocktailButtonFavorite: View {
	let data: CocktailData
	@Binding var entry: CocktailEntry?

	@Environment(\.managedObjectContext) private var managedObjectContext

	private func toggleFavorite() {
		managedObjectContext.perform {
			let entry = self.entry ?? CocktailEntry(context: self.managedObjectContext)
			entry.dateFavorited = entry.dateFavorited == nil ? Date() : nil
			DataModel.saveContext()
		}
	}

	var body: some View {
		Button(action: toggleFavorite) {
			Image(systemName: entry?.dateFavorited != nil ? "star.fill" : "star")
				.foregroundColor(.yellow)
		}
	}
}

struct CocktailButtonMade: View {
	let data: CocktailData
	@Binding var entry: CocktailEntry?

	@Environment(\.managedObjectContext) private var managedObjectContext

	private func toggleMade() {
		managedObjectContext.perform {
			let entry: CocktailEntry
			if let oldEntry = self.entry {
				entry = oldEntry
			} else {
				entry = CocktailEntry(context: self.managedObjectContext)
				entry.id = self.data.id
			}
			let made = CocktailMade(context: self.managedObjectContext)
			made.servings = 1 //TODO
			made.date = Date()
			made.cocktailEntry = entry
			try? self.managedObjectContext.save()
		}
	}

	var body: some View {
		let makings = self.entry?.makings?.sortedArray(using: [NSSortDescriptor(keyPath: \CocktailMade.date, ascending: true)]) as? [CocktailMade]
		let date = makings?.first?.date
		return Button(action: toggleMade) {
			if date != nil {
				Text(date!.description)
			}
			Text("Made it!")
		}
	}
}

struct CocktailImage: View {
	let data: CocktailData
	let height: CGFloat

	var body: some View {
		ZStack {
			Image(data.glass.rawValue)
				.resizable()
			VStack {
				ForEach(data.ingredients.filter { $0.quantity.type == .parts }) { ingredientQuantity in
					ZStack {
						ingredientQuantity.ingredient.color
							.frame(height: CGFloat(ingredientQuantity.quantity.value / self.data.totalQuantity) * self.height)
						Text(ingredientQuantity.ingredient.name)
							.foregroundColor(.gray)
					}
				}
			}
//			Image("\(data.glass.rawValue)-outline")
//				.resizable()
//				.foregroundColor(Color.secondary)
		}
			.frame(height: height)
	}
}

struct CocktailButtons_Previews: PreviewProvider {
	static var previews: some View {
		let data = bramble
		return VStack {
			CocktailButtonFavorite(data: data, entry: .constant(nil))
			CocktailButtonMade(data: data, entry: .constant(nil))
			CocktailImage(data: data, height: 128)
		}
	}
}
