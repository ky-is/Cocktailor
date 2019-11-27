enum CocktailTag: String {
	case aperitif
}

enum BarEquipment {
	case barspoon, mixingGlass, muddler, shaker, strainer
}

enum BarGlasses: String {
	case cocktail, collins, highball, hurricane, irishCoffee, margarita, oldFashioned
}

enum IceStyle {
	case cube
}

enum QuantityType: String {
	case dashes, parts, pieces, tsp
}

struct Quantity: Hashable {
	let value: Double
	let type: QuantityType
}

struct IngredientQuantity: Hashable, Identifiable {
	let id: String
	let ingredient: IngredientData
	let quantity: Quantity

	init(_ ingredient: IngredientData, _ quantity: Double, _ type: QuantityType = .parts) {
		self.id = ingredient.id
		self.ingredient = ingredient
		self.quantity = Quantity(value: quantity, type: type)
	}

	static func == (lhs: IngredientQuantity, rhs: IngredientQuantity) -> Bool {
		lhs.id == rhs.id
	}
}

private typealias IQ = IngredientQuantity

final class CocktailData: Hashable, Identifiable {
	static let keyValues: [String: CocktailData] = {
		let items = [
			bramble,
			caipirinha,
			darkAndStormy,
			irishCoffee,
			maiTai,
			manhattan,
			margarita,
			mojito,
			moscowMule,
			screwdriver,
		]
		var results = [String: CocktailData]()
		for item in items {
			results[item.id] = item
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
	let glass: BarGlasses
	let equipment: [BarEquipment]
	let region: String?
	let wikipedia: String?
	var related: [CocktailData]
	var tags: [CocktailTag]
	let totalQuantity: Double

	init(id: String, name: String, nicknames: [String]? = nil, alcohol: Double, ingredients: [IngredientQuantity], ice: IceStyle? = nil,glass: BarGlasses, equipment: [BarEquipment], region: String? = nil, wikipedia: String? = nil, related: [CocktailData] = [], tags: [CocktailTag]? = nil) {
		self.id = id
		self.name = name
		self.nicknames = nicknames ?? []
		self.alcohol = alcohol
		self.ingredients = ingredients
		self.glass = glass
		self.ice = ice
		self.equipment = equipment
		self.region = region
		self.wikipedia = wikipedia
		self.related = related
		self.tags = tags ?? []
		self.totalQuantity = ingredients.reduce(0) { $0 + $1.quantity.value }
	}
}

let bramble = CocktailData(id: "bramble", name: "Bramble", alcohol: 0.22, ingredients: [IQ(gin, 2), IQ(lemon, 3/4), IQ(syrupSimple, 1/2), IQ(liqueurBlackberry, 3/4)], glass: .oldFashioned, equipment: [.barspoon], wikipedia: "Bramble_(cocktail)", related: [])
let caipirinha = CocktailData(id: "caipirinha", name: "Caipirinha", alcohol: 0.33, ingredients: [IQ(cachaca, 2), IQ(lime, 4, .pieces), IQ(sugar, 2, .tsp)], ice: .cube, glass: .oldFashioned, equipment: [.muddler], wikipedia: "Caipirinha", related: [])
let darkAndStormy = CocktailData(id: "darkAndStormy", name: "Dark and Stormy", alcohol: 0.12, ingredients: [IQ(rumDark, 3), IQ(gingerBeer, 5)], ice: .cube, glass: .collins, equipment: [.barspoon], wikipedia: "Dark_%27n%27_Stormy", related: [])
let irishCoffee = CocktailData(id: "irishCoffee", name: "Irish Coffee", alcohol: 0.09, ingredients: [IQ(whiskeyIrish, 4), IQ(sugarBrown, 2, .tsp), IQ(coffee, 9), IQ(cream, 3)], glass: .irishCoffee, equipment: [.barspoon], wikipedia: "Irish_coffee", related: [])
let maiTai = CocktailData(id: "maiTai", name: "Mai Tai", alcohol: 0.26, ingredients: [IQ(rumLight, 4), IQ(rumDark, 2), IQ(liqueurOrange, 1.5), IQ(syrupAlmond, 1.5), IQ(lime, 1)], ice: .cube, glass: .collins, equipment: [.shaker, .strainer], wikipedia: "Mai_Tai", related: [])
let manhattan = CocktailData(id: "manhattan", name: "Manhattan", alcohol: 0.27, ingredients: [IQ(whiskeyRye, 5), IQ(vermouthSweet, 2), IQ(bitters, 2, .dashes)], ice: .cube, glass: .cocktail, equipment: [.mixingGlass, .barspoon], region: "New York", wikipedia: "Manhattan_(cocktail)", related: [])
let margarita = CocktailData(id: "margarita", name: "Margarita", alcohol: 0.30, ingredients: [IQ(tequila, 1.75), IQ(liqueurOrange, 1), IQ(lime, 3/4, .pieces)], glass: .margarita, equipment: [.shaker, .strainer], wikipedia: "Margarita", related: [])
let mojito = CocktailData(id: "mojito", name: "Mojito", alcohol: 0.09, ingredients: [IQ(rumLight, 4), IQ(syrupSimple, 4, .tsp), IQ(lime, 3), IQ(sodaClub, 6), IQ(herbMint, 12, .pieces)], glass: .collins, equipment: [.muddler], region: "Cuba", wikipedia: "Mojito", related: [])
let moscowMule = CocktailData(id: "moscowMule", name: "Moscow Mule", alcohol: 0.09, ingredients: [IQ(vodka, 2.25), IQ(lime, 1/4), IQ(gingerBeer, 6)], glass: .collins, equipment: [.barspoon], wikipedia: "Moscow_mule", related: [])
let screwdriver = CocktailData(id: "screwdriver", name: "Screwdriver", alcohol: 0.10, ingredients: [IQ(vodka, 2), IQ(juiceOrange, 4)], ice: .cube, glass: .collins, equipment: [.barspoon], wikipedia: "Screwdriver_(cocktail)", related: [])
