import SwiftUI

struct CocktailButtonFavorite: View {
	let data: CocktailData
	@Binding var entry: CocktailEntry?

	private func toggleFavorite() {
		DataModel.perform {
			let entry = self.entry ?? CocktailEntry(id: self.data.id)
			entry.dateFavorited = entry.dateFavorited == nil ? Date() : nil
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
		DataModel.perform {
			let entry = self.entry ?? CocktailEntry(id: self.data.id)
			let made = CocktailMade(context: self.managedObjectContext)
			made.servings = 1 //TODO
			made.date = Date()
			made.cocktailEntry = entry
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
	let dropWidth: CGFloat
	let dropHeight: CGFloat

	private let dropIngredients: [IngredientQuantity]

	init(data: CocktailData, size: CGFloat) {
		self.dropWidth = size / 16
		self.dropHeight = size / 12
		dropIngredients = data.liquidIngredients.filter { $0.quantity.unit == .dash }
	}

	var body: some View {
		HStack(spacing: dropWidth / 4) {
			ForEach(dropIngredients) { ingredientQuantity in
				Group {
					ForEach(0..<Int(ingredientQuantity.quantity.value), id: \.self) { _ in
						ZStack {
							Ellipse()
								.fill(ingredientQuantity.ingredient.color)
							Ellipse()
								.stroke(Color.secondarySystemBackground, lineWidth: self.dropHeight / 8)
						}
							.frame(width: self.dropWidth, height: self.dropHeight)
					}
				}
			}
		}
			.offset(y: -dropHeight / 2)
	}
}

struct CocktailButtons_Previews: PreviewProvider {
	static var previews: some View {
		let data = CocktailData.keyValues["bloodyMary"]!
		return VStack {
			CocktailButtonFavorite(data: data, entry: .constant(nil))
			CocktailButtonMade(data: data, entry: .constant(nil))
			CocktailImage(data: data, size: 80)
			CocktailImage(data: data, size: 384)
		}
	}
}
