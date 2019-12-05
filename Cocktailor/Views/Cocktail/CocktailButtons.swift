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
	let size: CGFloat

	private let volumeIngredients: [IngredientQuantity]
	private let volumeSpacing: CGFloat
	private let volumeHeightWithoutSpacing: CGFloat

	init(data: CocktailData, size: CGFloat) {
		self.data = data
		self.size = size
		volumeIngredients = data.volumeIngredients.sorted { $0.quantity.ounces < $1.quantity.ounces }
		volumeSpacing = size >= 128 ? 1 : 0.5
		volumeHeightWithoutSpacing = size - volumeSpacing * CGFloat(volumeIngredients.count - 1)
	}

	var body: some View {
		ZStack(alignment: .top) {
			Image("Glasses/\(data.glass.rawValue)")
				.resizable()
				.aspectRatio(contentMode: .fit)
				.foregroundColor(.secondary)
			ZStack(alignment: .top) {
				VStack(spacing: volumeSpacing) {
					ForEach(volumeIngredients) { ingredientQuantity in
						ZStack {
							Color.secondarySystemBackground
							ingredientQuantity.ingredient.color
								.opacity(0.75)
						}
							.frame(height: CGFloat(ingredientQuantity.quantity.ounces / self.data.totalQuantity) * self.data.glass.liquidHeightProportion * self.volumeHeightWithoutSpacing)
					}
				}
				CocktailDrops(data: data, size: size)
			}
				.background(Color.systemBackground)
				.position(x: size / 2, y: size * data.glass.liquidOffsetProportion + size * data.glass.liquidHeightProportion / 2)
				.mask(
					Image("Glasses/\(data.glass.rawValue)-fill")
						.resizable()
						.aspectRatio(contentMode: .fit)
						.foregroundColor(.black)
						.frame(height: size)
				)
		}
			.frame(width: size, height: size)
	}
}

private struct CocktailDrops: View {
	let dropCircumference: CGFloat

	private let dropIngredients: [IngredientQuantity]

	init(data: CocktailData, size: CGFloat) {
		self.dropCircumference = size / 20
		dropIngredients = data.liquidIngredients.filter { $0.quantity.unit == .dash }
	}

	var body: some View {
		var index = -1
		return Group {
			ForEach(dropIngredients) { ingredientQuantity in
				Group {
					ForEach(0..<Int(ingredientQuantity.quantity.value), id: \.self) { _ -> AnyView in
						index += 1
						let direction = CGFloat((index % 2) == 0 ? -1 : 1)
						return AnyView(
							Circle()
								.fill(ingredientQuantity.ingredient.color)
								.frame(width: self.dropCircumference, height: self.dropCircumference)
								.offset(x: direction * CGFloat(index) * self.dropCircumference / 1.5 + (direction > 0 ? .zero : direction * self.dropCircumference * 2/3))
						)
					}
				}
			}
		}
			.offset(y: dropCircumference / 8)
	}
}

struct CocktailButtons_Previews: PreviewProvider {
	static var previews: some View {
		let data = CocktailData.keyValues["oldFashioned"]!
		return VStack {
			CocktailButtonFavorite(data: data, entry: .constant(nil))
			CocktailButtonMade(data: data, entry: .constant(nil))
			CocktailImage(data: data, size: 512)
		}
	}
}
