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
		let fillIngredients = data.ingredients.filter({ $0.quantity.type == .parts }).sorted(by: { $0.quantity.value < $1.quantity.value })
		let ingredientSpacing: CGFloat = height >= 128 ? 1 : 0.5
		let heightWithoutSpacing = height - ingredientSpacing * CGFloat(fillIngredients.count - 1)
		return ZStack(alignment: .top) {
			Image(data.glass.rawValue)
				.resizable()
				.aspectRatio(contentMode: .fit)
				.foregroundColor(.secondary)
			VStack(spacing: ingredientSpacing) {
				ForEach(fillIngredients) { ingredientQuantity in
					ZStack {
						Color.secondarySystemBackground
						ingredientQuantity.ingredient.color
							.opacity(0.75)
					}
						.frame(height: CGFloat(ingredientQuantity.quantity.value / self.data.totalQuantity) * self.data.glass.heightProportion * heightWithoutSpacing)
				}
			}
				.background(Color.systemBackground)
				.position(x: height / 2, y: data.glass.offsetProportion * height + height * data.glass.heightProportion / 2)
				.mask(
					Image("\(data.glass.rawValue)-fill")
						.resizable()
						.aspectRatio(contentMode: .fit)
						.foregroundColor(.black)
						.frame(height: height)
				)
		}
			.frame(width: height, height: height)
	}
}

struct CocktailButtons_Previews: PreviewProvider {
	static var previews: some View {
		let data = moscowMule
		return VStack {
			CocktailButtonFavorite(data: data, entry: .constant(nil))
			CocktailButtonMade(data: data, entry: .constant(nil))
			CocktailImage(data: data, height: 512)
		}
	}
}
