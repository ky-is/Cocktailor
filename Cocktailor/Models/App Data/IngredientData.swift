import SwiftUI

enum IngredientIcon: String {
	case aperitif, drop, fizz, grains, liqueur, liquor, wine //TODO herb
}

enum IngredientCategory: String {
	case aperitif, dairy, fruit, garnish, herb, juice, liqueur, liquor, mixer, sweetener, wine
}

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
			let indexID = columns.firstIndex(of: "ID")!
			let indexName = columns.firstIndex(of: "Name")!
			let indexNicknames = columns.firstIndex(of: "Nicknames")!
			let indexAlcohol = columns.firstIndex(of: "Alcohol %")!
			let indexIcon = columns.firstIndex(of: "Icon")!
			let indexCategory = columns.firstIndex(of: "Category")!
			let indexColor = columns.firstIndex(of: "Color")!
			let indexOriginRegion = columns.firstIndex(of: "Origin Region")!
			let indexOriginYear = columns.firstIndex(of: "Origin Year")!
			let indexParent = columns.firstIndex(of: "Parent")!
			let indexHidden = columns.firstIndex(of: "Hidden")!
			let indexWikipediaPath = columns.firstIndex(of: "Wikipedia Path")!
			let indexTags = columns.firstIndex(of: "Tags")!
			for row in rows {
				let id = row[indexID]
				let name = row[indexName]
				let nicknames = row[indexNicknames].components(separatedBy: ", ")
				let alcohol = Double(row[indexAlcohol]) ?? 0
				let icon = IngredientIcon(rawValue: row[indexIcon])!
				let category = IngredientCategory(rawValue: row[indexCategory])!
				let color = systemColor(row[indexColor])
				let region = row[tsv: indexOriginRegion]
				let year = row[tsv: indexOriginYear]
				let wikipedia = row[tsv: indexWikipediaPath]
				let parentID = row[tsv: indexParent]
				let parent = results[optional: parentID]
				let hidden = row[tsv: indexHidden] == "TRUE"
				let tags = row[tsv: indexTags]?.components(separatedBy: ",")
				let ingredient = IngredientData(id: id, name: name, nicknames: nicknames, icon: icon, category: category, alcohol: alcohol, color: color, region: region, year: year, wikipedia: wikipedia, parent: parent, hidden: hidden, tags: tags)
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

	static let ownableIngredients: [IngredientData] = {
		return keyValues.values.filter { !$0.hidden }
	}()

	let id: String
	let name: String
	let nicknames: [String]
	let icon: IngredientIcon
	let category: IngredientCategory
	let alcohol: Double
	let color: Color
	let region: String?
	let year: String?
	let wikipedia: String?
	let parent: IngredientData?
	let hidden: Bool
	var children: [IngredientData] = []
	var tags: [String]
	var substitutions: [Substitute] = []

	init(id: String, name: String, nicknames: [String]? = nil, icon: IngredientIcon, category: IngredientCategory, alcohol: Double = 0, color: Color, region: String? = nil, year: String? = nil, wikipedia: String? = nil, parent: IngredientData? = nil, hidden: Bool, tags: [String]? = nil) {
		self.id = id
		self.name = name
		self.nicknames = nicknames ?? []
		self.icon = icon
		self.category = category
		self.alcohol = alcohol
		self.color = color
		self.region = region
		self.year = year
		self.wikipedia = wikipedia
		self.parent = parent
		self.hidden = hidden
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

	func usableIn<T>(available ingredientIDs: T) -> IngredientData? where T: Collection, T.Element == String {
		if ingredientIDs.contains(id) {
			return self
		}
		if let parentID = parent?.id {
			if ingredientIDs.contains(parentID) {
				return parent
			}
		} else if hidden {
			return self
		}
		for child in children {
			if ingredientIDs.contains(child.id) {
				return child
			}
		}
		return nil
	}

	func findSubstitute<T>(available ingredientIDs: T) -> IngredientData? where T: Collection, T.Element == String {
		for substitution in substitutions {
			let substituteID = substitution.ingredient.id
			if ingredientIDs.contains(substituteID) {
				return IngredientData.keyValues[substituteID]
			}
		}
		return nil
	}

	func bestIngredient<T>(available ingredientIDs: T) -> IngredientData? where T: Collection, T.Element == String {
		return usableIn(available: ingredientIDs) ?? findSubstitute(available: ingredientIDs)
	}
}
