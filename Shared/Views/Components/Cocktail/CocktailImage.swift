import SwiftUI

struct CocktailImage: View {
	let data: CocktailData
	let size: CGFloat

	private let volumeIngredients: [IngredientQuantity]
	private let volumeSpacing: CGFloat
	private let volumeHeightWithoutSpacing: CGFloat

	init(data: CocktailData, size: CGFloat) {
		self.data = data
		self.size = size
		volumeIngredients = data.volumeIngredients.sorted(\.quantity.ounces, <)
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
	let dropIngredients: [IngredientQuantity]
	let dropWidth: CGFloat
	let dropHeight: CGFloat

	init(data: CocktailData, size: CGFloat) {
		self.dropIngredients = data.liquidIngredients.filter(\.quantity.unit, ==, .dash)
		self.dropWidth = size / 13
		self.dropHeight = size / 11
	}

	var body: some View {
		HStack(spacing: dropWidth / 4.5) {
			ForEach(dropIngredients) { ingredientQuantity in
				ForEach(0..<Int(ingredientQuantity.quantity.value)) { _ in
					Ellipse()
						.fill(ingredientQuantity.ingredient.color)
						.frame(width: self.dropWidth, height: self.dropHeight)
						.overlay(
							Ellipse()
								.stroke(Color.secondarySystemBackground, lineWidth: self.dropHeight / 8)
						)
				}
			}
		}
			.offset(y: -dropHeight / 2)
	}
}

struct CocktailImage_Previews: PreviewProvider {
	static let data = CocktailData.keyValues["bloodyMary"]!

	static var previews: some View {
		VStack {
			CocktailImage(data: data, size: 80)
			CocktailImage(data: data, size: 384)
		}
	}
}
