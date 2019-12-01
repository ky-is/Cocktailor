import SwiftUI

struct Substitute {
	let ingredient: IngredientData
	let score: Double
}

func systemColor(_ string: String) -> Color {
	switch string {
	case "black":
		return .black
	case "blue":
		return .blue
	case "brown":
		return .brown
	case "green":
		return .green
	case "orange":
		return .orange
	case "pink":
		return .pink
	case "purple":
		return .purple
	case "red":
		return .red
	case "white":
		return .white
	case "yellow":
		return .yellow
	case "clear":
		return .clear
	default:
		print("UNKNOWN COLOR", string)
		return .clear
	}
}

final class IngredientData: Hashable, Identifiable {
	static let keyValues: [String: IngredientData] = {
		var results = [String: IngredientData]()
		TSV.cocktailData("Ingredients") { columns, rows in
			for row in rows {
				let id = row[0]
				let name = row[1]
				let nicknames = row[2].components(separatedBy: ", ")
				let alcohol = Double(row[3]) ?? 0
				let icon = IngredientIcon(rawValue: row[4])!
				let category = IngredientCategory(rawValue: row[5])!
				let color = systemColor(row[6])
				let region = row[tsv: 7]
//				let year = row[tsv: 8]
				let wikipedia = row[tsv: 9]
				let parentID = row[tsv: 10]
				let parent = results[optional: parentID]
				let tags = row[tsv: 11]?.components(separatedBy: ",")
				let ingredient = IngredientData(id: id, name: name, nicknames: nicknames, icon: icon, category: category, alcohol: alcohol, color: color, region: region, wikipedia: wikipedia, parent: parent, tags: tags)
				results[id] = ingredient
			}
		}
		TSV.cocktailData("Ingredient Substitutes") { columns, rows in
			for row in rows {
				let aID = row[0]
				let bID = row[1]
				guard let ingredientA = results[aID], let ingredientB = results[bID] else {
					#if DEBUG
					print("Missing ingredient for substitution", aID, bID)
					#endif
					continue
				}
				let corellation = Double(row[2])!
				ingredientA.substitutions.append(Substitute(ingredient: ingredientB, score: corellation))
				ingredientB.substitutions.append(Substitute(ingredient: ingredientA, score: corellation))
			}
		}
		return results
	}()

	let id: String
	let name: String
	let nicknames: [String]
	let icon: IngredientIcon
	let category: IngredientCategory
	let alcohol: Double
	let color: Color
	let region: String?
	let wikipedia: String?
	let parent: IngredientData?
	let showSeparateFromParent: Bool
	var children: [IngredientData] = []
	var tags: [String]
	var substitutions: [Substitute] = []

	init(id: String, name: String, nicknames: [String]? = nil, icon: IngredientIcon, category: IngredientCategory, alcohol: Double = 0, color: Color, region: String? = nil, wikipedia: String? = nil, parent: IngredientData? = nil, showSeparateFromParent: Bool = true, tags: [String]? = nil) {
		self.id = id
		self.name = name
		self.nicknames = nicknames ?? []
		self.icon = icon
		self.category = category
		self.alcohol = alcohol
		self.color = color
		self.region = region
		self.wikipedia = wikipedia
		self.parent = parent
		self.showSeparateFromParent = showSeparateFromParent
		self.tags = tags ?? []
		if let parent = parent {
			parent.children.append(self)
			substitutions.append(Substitute(ingredient: parent, score: 1))
		}
	}

	static func == (lhs: IngredientData, rhs: IngredientData) -> Bool {
		lhs.id == rhs.id
	}

	func hash(into hasher: inout Hasher) {
		hasher.combine(id)
	}

	var substitutionIDs: [String] {
		return substitutions.map { $0.ingredient.id }
	}

	func getCocktails() -> [CocktailData] {
		return CocktailData.keyValues.values.filter { cocktail in
			return cocktail.ingredients.contains { $0.ingredient.id == id }
		}
	}
}

enum IngredientIcon: String {
	case drop, fizz, grains, liquor, liqueur, aperitif //TODO herb
}

enum IngredientCategory: String {
	case aperitif, dairy, fruit, garnish, herb, juice, liqueur, liquor, mixer, sweetener, wine
}
