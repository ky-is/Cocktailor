enum CocktailTag: String {
	case aperitif
}

enum BarEquipment {
	case barspoon, shaker, strainer
}

enum BarGlasses {
	case collins, highball, margarita, oldFashioned
}

enum IceStyle {
	case cube
}

struct IngredientQuantity {
	let ingredient: IngredientData
	let parts: Double

	init(_ ingredient: IngredientData, _ parts: Double) {
		self.ingredient = ingredient
		self.parts = parts
	}
}

private typealias IQ = IngredientQuantity

final class CocktailData: Identifiable {
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
	}
}

let cocktails: [String: CocktailData] = {
	let items = [
		CocktailData(id: "bramble", name: "Bramble", alcohol: 0.22, ingredients: [IQ(gin, 2), IQ(lemon, 3/4), IQ(syrupSimple, 1/2), IQ(liqueurBlackberry, 3/4)], glass: .oldFashioned, equipment: [.barspoon], wikipedia: "Bramble_(cocktail)", related: []),
		CocktailData(id: "darkAndStormy", name: "Dark and Stormy", alcohol: 0.12, ingredients: [IQ(rumDark, 3), IQ(gingerBeer, 5)], ice: .cube, glass: .collins, equipment: [.barspoon], wikipedia: "Dark_%27n%27_Stormy", related: []),
		CocktailData(id: "margarita", name: "Margarita", alcohol: 0.30, ingredients: [IQ(tequila, 1.75), IQ(liqueurOrange, 1), IQ(lime, 3/4)], glass: .margarita, equipment: [.shaker, .strainer], wikipedia: "Margarita", related: []),
		CocktailData(id: "moscowMule", name: "Moscow mule", alcohol: 0.09, ingredients: [IQ(vodka, 2.25), IQ(lime, 1/4), IQ(gingerBeer, 6)], glass: .collins, equipment: [.barspoon], wikipedia: "Moscow_mule", related: []),
	]
	var results = [String: CocktailData]()
	for item in items {
		results[item.id] = item
	}
	return results
}()
