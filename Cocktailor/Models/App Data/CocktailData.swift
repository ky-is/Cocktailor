import CoreGraphics
import Foundation

enum CocktailTag: String {
	case aperitif
}

enum BarEquipment {
	case barspoon, mixingGlass, muddler, shaker, strainer
}

enum BarGlasses: String {
	case cocktail, collins, highball, hurricane, irishCoffee, margarita, oldFashioned, wine

	var liquidOffsetProportion: CGFloat {
		switch self {
		case .cocktail:
			return 114 / 1024
		case .collins:
			return 173 / 1024
		case .highball:
			return 242 / 1024
		case .oldFashioned:
			return 357 / 1024
		case .wine:
			return 112 / 1024
		default:
			return 0
		}
	}

	var liquidHeightProportion: CGFloat {
		switch self {
		case .cocktail:
			return 400 / 1024
		case .collins:
			return 678 / 1024
		case .highball:
			return 602 / 1024
		case .oldFashioned:
			return 382 / 1024
		case .wine:
			return 420 / 1024
		default:
			return 1
		}
	}
}

enum Garnish {
	case lemon, lime, nutmeg
}

enum IceStyle: String {
	case blend, cube, crush
}

enum QuantityUnit: String {
	case cl, dash, part, piece, tsp
}

struct Quantity: Hashable {
	let value: Double
	let unit: QuantityUnit
}

final class IngredientQuantity: Hashable, Identifiable {
	let id: String
	let ingredient: IngredientData
	let quantity: Quantity

	init(_ ingredient: IngredientData, _ quantity: Double, _ unit: QuantityUnit = .part) {
		self.id = ingredient.id
		self.ingredient = ingredient
		self.quantity = Quantity(value: quantity, unit: unit)
	}

	static func == (lhs: IngredientQuantity, rhs: IngredientQuantity) -> Bool {
		lhs.id == rhs.id
	}

	func hash(into hasher: inout Hasher) {
		hasher.combine(id)
	}
}

private typealias IQ = IngredientQuantity

final class CocktailData: Hashable, Identifiable {
	static let keyValues: [String: CocktailData] = {
		var results = [String: CocktailData]()
		TSV.cocktailData("Cocktails") { columns, rows in
			for row in rows {
				let id = row[0]
				let name = row[1]
				let nicknames = row[2].components(separatedBy: ", ")
				let glass = BarGlasses(rawValue: row[3])!
				let iceString = row[tsv: 4]
				let ice = iceString != nil ? IceStyle(rawValue: iceString!) : nil
				let ingredients = row[6].components(separatedBy: " ")
				let quantities = row[7].components(separatedBy: " ")
				let ingredientsById = IngredientData.keyValues
				let ingredientQuantities: [IngredientQuantity] = zip(ingredients, quantities).map { (ingredientID, quantityAndUnit) in
					let ingredient = ingredientsById[ingredientID]!
					let suffixLength: Int, unit: QuantityUnit
					if quantityAndUnit.hasSuffix("cl") {
						suffixLength = 2
						unit = .cl
					} else if quantityAndUnit.hasSuffix("piece") {
						suffixLength = 5
						unit = .piece
					} else if quantityAndUnit.hasSuffix("tsp") {
						suffixLength = 3
						unit = .tsp
					} else {
						if Double(quantityAndUnit) == nil {
							fatalError("Unknown unit: \(quantityAndUnit)")
						}
						suffixLength = 0
						unit = .part
					}
					let quantity = Double(quantityAndUnit.dropLast(suffixLength))!
					return IngredientQuantity(ingredient, quantity, unit)
				}
				let region = row[tsv: 9]
				let year = row[tsv: 10]
				let wikipedia = row[tsv: 11]
				let tags = row[tsv: 12]?.components(separatedBy: ",")
				let cocktail = CocktailData(id: id, name: name, nicknames: nicknames, ingredients: ingredientQuantities, ice: ice, garnish: nil, glass: glass, equipment: [], region: region, year: year, wikipedia: wikipedia, related: [], tags: [])
				results[id] = cocktail
			}
		}
		return results
	}()

	static func == (lhs: CocktailData, rhs: CocktailData) -> Bool {
		lhs.id == rhs.id
	}

	func hash(into hasher: inout Hasher) {
		hasher.combine(id)
	}

	let id: String
	let name: String
	let nicknames: [String]
	let alcohol: Double
	let ingredients: [IngredientQuantity]
	let ice: IceStyle?
	let garnish: Garnish?
	let glass: BarGlasses
	let equipment: [BarEquipment]
	let region: String?
	let year: String?
	let wikipedia: String?
	var related: [CocktailData]
	var tags: [CocktailTag]

	init(id: String, name: String, nicknames: [String]? = nil, ingredients: [IngredientQuantity], ice: IceStyle? = nil, garnish: Garnish? = nil, glass: BarGlasses, equipment: [BarEquipment], region: String? = nil, year: String? = nil, wikipedia: String? = nil, related: [CocktailData] = [], tags: [CocktailTag]? = nil) {
		self.id = id
		self.name = name
		self.nicknames = nicknames ?? []
		self.alcohol = 0 //TODO calculate from ingredients
		self.ingredients = ingredients
		self.glass = glass
		self.ice = ice
		self.garnish = garnish
		self.equipment = equipment
		self.region = region
		self.year = year
		self.wikipedia = wikipedia
		self.related = related
		self.tags = tags ?? []
	}

	lazy var fillIngredients: [IngredientQuantity] = {
		return ingredients.filter { $0.quantity.unit != .dash && $0.quantity.unit != .piece }
	}()

	lazy var totalQuantity: Double = {
		return fillIngredients.reduce(0) { $0 + $1.quantity.value }
	}()
}
