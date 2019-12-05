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
	case cl, dash, ml, part, oz, piece, tsp

	var volume: Double {
		switch self {
		case .cl:
			return 0.33814
		case .dash:
			return 0.021
		case .ml:
			return 0.033814
		case .part:
			return 1
		case .oz:
			return 1
		case .tsp:
			return 1/6
		default:
			return 0
		}
	}
}

struct Quantity: Hashable {
	let value: Double
	let unit: QuantityUnit
	let ounces: Double

	init(value: Double, unit: QuantityUnit) {
		self.value = value
		self.unit = unit
		self.ounces = value * unit.volume
	}
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
			let indexID = columns.firstIndex(of: "ID")!
			let indexName = columns.firstIndex(of: "Name")!
			let indexNicknames = columns.firstIndex(of: "Nicknames")!
			let indexGlass = columns.firstIndex(of: "Glass")!
			let indexIce = columns.firstIndex(of: "Ice")!
			let indexEquipment = columns.firstIndex(of: "Equipment")!
			let indexIngredients = columns.firstIndex(of: "Ingredients")!
			let indexQuantities = columns.firstIndex(of: "Quantities")!
			let indexRim = columns.firstIndex(of: "Rim")!
			let indexGarnishes = columns.firstIndex(of: "Garnishes")!
			let indexOriginRegion = columns.firstIndex(of: "Origin Region")!
			let indexOriginYear = columns.firstIndex(of: "Origin Year")!
			let indexWikipediaPath = columns.firstIndex(of: "Wikipedia Path")!
			let indexTags = columns.firstIndex(of: "Tags")!
			for row in rows {
				let id = row[indexID]
				let name = row[indexName]
				let nicknames = row[indexNicknames].components(separatedBy: ", ")
				let glass = BarGlasses(rawValue: row[indexGlass])!
				let iceString = row[tsv: indexIce]
				let ice = iceString != nil ? IceStyle(rawValue: iceString!) : nil
				let ingredients = row[indexIngredients].components(separatedBy: " ")
				let quantities = row[indexQuantities].components(separatedBy: " ")
				let ingredientsById = IngredientData.keyValues
				let ingredientQuantities: [IngredientQuantity] = zip(ingredients, quantities).map { (ingredientID, quantityAndUnit) in
					let ingredient = ingredientsById[ingredientID]!
					let suffixLength: Int, unit: QuantityUnit
					if quantityAndUnit.hasSuffix("cl") {
						suffixLength = 2
						unit = .cl
					} else if quantityAndUnit.hasSuffix("dash") {
						suffixLength = 4
						unit = .dash
					} else if quantityAndUnit.hasSuffix("ml") {
						suffixLength = 2
						unit = .ml
					} else if quantityAndUnit.hasSuffix("oz") {
						suffixLength = 2
						unit = .oz
					} else if quantityAndUnit.hasSuffix("piece") {
						suffixLength = 5
						unit = .piece
					} else if quantityAndUnit.hasSuffix("tsp") {
						suffixLength = 3
						unit = .tsp
					} else {
						suffixLength = 0
						unit = .part
					}
					let quantity = Double(quantityAndUnit.dropLast(suffixLength))!
					return IngredientQuantity(ingredient, quantity, unit)
				}
				let region = row[tsv: indexOriginRegion]
				let year = row[tsv: indexOriginYear]
				let wikipedia = row[tsv: indexWikipediaPath]
				let tags = row[tsv: indexTags]?.components(separatedBy: ",")
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

	lazy var liquidIngredients: [IngredientQuantity] = {
		return ingredients.filter { $0.quantity.unit != .piece }
	}()
	lazy var volumeIngredients: [IngredientQuantity] = {
		return liquidIngredients.filter { $0.quantity.unit != .dash }
	}()

	lazy var totalQuantity: Double = {
		return volumeIngredients.reduce(0) { $0 + $1.quantity.ounces }
	}()

	lazy var alcohol: Double = {
		return liquidIngredients.reduce(0) { $0 + $1.ingredient.alcohol * $1.quantity.ounces } / totalQuantity
	}()
}
