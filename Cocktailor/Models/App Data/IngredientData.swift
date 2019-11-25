struct Substitute {
	let ingredient: IngredientData
	let score: Double
}

final class IngredientData: Hashable, Identifiable {
	static let keyValues: [String: IngredientData] = {
		[
			(lemon, lime, 0.5),
			//	(agave, syrupMaple, 0.5),
			(brandy, brandyApple, 0.5),
			(brandy, brandyCognac, 0.5),
			(cream, creamHeavy, 0.5),
			(rumLight, rumGold, 0.5),
			(rumGold, rumDark, 0.5),
			//	(rumLight, cachaca, 0.2),
			(liqueurBlackberry, liqueurBlackcurrant, 0.5),
			(sugar, sugarBrown, 0.8),
			//	(champagne, prosecco, 0.8),
			(whiskey, whiskeyBourbon, 0.8),
			(whiskey, whiskeyIrish, 0.8),
			(whiskey, whiskeyRye, 0.8),
			(whiskey, whiskeyScotch, 0.8),
			(whiskeyIrish, whiskeyScotch, 0.8),
		].forEach { (first, second, score) in
			first.substitutions.append(Substitute(ingredient: second, score: score))
			second.substitutions.append(Substitute(ingredient: first, score: score))
		}
		let items = [
//			absinthe,
//			agave,
//			amaretto,
			bitters,
			aperol,
//			apple,
			brandy,
			brandyApple,
			brandyApricot,
			brandyCognac,
			cachaca,
			campari,
//			champagne,
//			cherryMaraschino,
			coconutCream,
			coffee,
			cream,
			creamHeavy,
			egg,
			gin,
			gingerBeer,
//			IngredientData(id: "eggyolk", name: "egg yolk", parent: egg, showSeparateFromParent: false),
//			IngredientData(id: "eggwhite", name: "egg white", parent: egg, showSeparateFromParent: false),
			irishCream,
			juiceCranberry,
			lemon,
			lime,
			liqueurRasberry,
			liqueurBlackberry,
			liqueurBlackcurrant,
			liqueurChocolate,
			liqueurCoffee,
			liqueurOrange,
			mezcal,
			prosecco,
			rumLight,
			rumGold,
			rumDark,
			sodaClub,
			sodaCola,
			sugar,
			sugarBrown,
			syrupMaple,
			syrupSimple,
			tequila,
			vermouthDry,
			vermouthSweet,
			whiskey,
			whiskeyBourbon,
			whiskeyIrish,
			whiskeyRye,
			whiskeyScotch,
			vodka,
		]
		var results = [String: IngredientData]()
		for item in items {
			results[item.id] = item
		}
		return results
	}()

	let id: String
	let name: String
	let nicknames: [String]
	let category: IngredientCategory
	let alcohol: Double
	let region: String?
	let wikipedia: String?
	let parent: IngredientData?
	let showSeparateFromParent: Bool
	var children: [IngredientData] = []
	var tags: [String]
	var substitutions: [Substitute] = []

	init(id: String, name: String, nicknames: [String]? = nil, category: IngredientCategory, alcohol: Double = 0, region: String? = nil, wikipedia: String? = nil, parent: IngredientData? = nil, showSeparateFromParent: Bool = true, tags: [String]? = nil) {
		self.id = id
		self.name = name
		self.nicknames = nicknames ?? []
		self.category = category
		self.alcohol = alcohol
		self.region = region
		self.wikipedia = wikipedia
		self.parent = parent
		self.showSeparateFromParent = showSeparateFromParent
		self.tags = tags ?? []
		if parent != nil {
			parent?.children.append(self)
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
}

enum IngredientCategory: String {
	case aperitif, dairy, fruit, garnish, juice, liqueur, liquor, mixer, sweetener, wine
}

//let absinthe = IngredientData(id: "absinthe", name: "absinthe", alcohol: 0.60, wikipedia: "Absinthe")
//let agave = IngredientData(id: "agave", name: "agave nectar", category: .sweetener)
//let amaretto = IngredientData(id: "amaretto", name: "amaretto", category: .aperitif, alcohol: 0.24, region: "Italy", wikipedia: "Amaretto"])
let aperol = IngredientData(id: "aperol", name: "aperol", category: .aperitif, alcohol: 0.11, region: "Italy", wikipedia: "Aperol")
let bitters = IngredientData(id: "bitters", name: "bitters", nicknames: ["Angostura bitters"], category: .aperitif, alcohol: 0.447, region: "Trinidad and Tobago", wikipedia: "Angostura_bitters")
//let apple = IngredientData(id: "apple", category: .fruit, name: "apple")
let brandy = IngredientData(id: "brandy", name: "brandy", nicknames: ["eau de vie"], category: .liquor, alcohol: 0.40, region: "worldwide", wikipedia: "Brandy")
let brandyApple = IngredientData(id: "brandyApple", name: "apple brandy", category: .liquor, alcohol: 0.40, wikipedia: "Apple_brandy")
let brandyApricot = IngredientData(id: "brandyApricot", name: "apricot brandy", category: .liquor, alcohol: 0.40, wikipedia: "Apricot_brandy")
let brandyCognac = IngredientData(id: "brandyCognac", name: "Cognac", category: .liquor, alcohol: 0.40, region: "France", wikipedia: "Cognac")
let cachaca = IngredientData(id: "cachaca", name: "cachaça", category: .liquor, alcohol: 0.40, region: "Brazil", wikipedia: "Cachaca")
let campari = IngredientData(id: "campari", name: "campari", category: .aperitif, alcohol: 0.25, region: "Italy", wikipedia: "Campari")
//let champagne = IngredientData(id: "champagne", name: "champagne", alcohol: 0.12, region: "France (Champagne)", wikipedia: "Champagne")
//let cherryMaraschino = IngredientData(id: "cherryCocktail", name: "Maraschino cherry", nicknames: ["cocktail cherry"], wikipedia: "Maraschino_cherry")
let coconutCream = IngredientData(id: "coconutCream", name: "cream of coconut", category: .juice, wikipedia: "Coconut_milk#Cream_of_coconut")
let coffee = IngredientData(id: "coffee", name: "coffee", category: .mixer, wikipedia: "Coffee") //TODO cat
let cream = IngredientData(id: "cream", name: "cream", category: .dairy, wikipedia: "Cream")
let creamHeavy = IngredientData(id: "creamHeavy", name: "heavy cream", nicknames: ["whipping cream"], category: .dairy, wikipedia: "Cream#Types")
let egg = IngredientData(id: "egg", name: "egg", category: .dairy)
let gin = IngredientData(id: "gin", name: "gin", category: .liquor, alcohol: 0.40, region: "Worldwide", wikipedia: "Gin")
let gingerBeer = IngredientData(id: "gingerBeer", name: "ginger beer", category: .mixer)
let herbMint = IngredientData(id: "herbMint", name: "mint", category: .garnish, wikipedia: "Mint")
let irishCream = IngredientData(id: "irishCream", name: "Irish cream", category: .liqueur, alcohol: 0.175, region: "Ireland", wikipedia: "Irish_cream")
let juiceCranberry = IngredientData(id: "juiceCranberry", name: "cranberry juice", category: .juice)
let juiceOrange = IngredientData(id: "juiceOrange", name: "orange juice", category: .juice)
let lemon = IngredientData(id: "lemon", name: "lemon", category: .fruit)
let lime = IngredientData(id: "lime", name: "lime", category: .fruit)
let liqueurRasberry = IngredientData(id: "liquerRasberry", name: "rasberry liqueur", nicknames: ["chambour"], category: .liqueur, alcohol: 0.20, region: "France", wikipedia: "Chambord_(liqueur)")
let liqueurBlackberry = IngredientData(id: "liquerBlackberry", name: "blackberry liqueur", nicknames: ["crème de mûre"], category: .liqueur, alcohol: 0.20, region: "France", wikipedia: "Crème_liqueur")
let liqueurBlackcurrant = IngredientData(id: "liquerBlackcurrant", name: "blackcurrant liqueur", nicknames: ["crème de cassis"], category: .liqueur, alcohol: 0.20, region: "France (Burgundy)", wikipedia: "Crème_de_cassis")
//let liqueurCherry = IngredientData(id: "liqueurCherry", name: "cherry liqueur", category: .liqueur, alcohol: 0.24)
let liqueurChocolate = IngredientData(id: "liqueurChocolate", name: "chocolate liqueur", nicknames: ["crème de cacao"], category: .liqueur, alcohol: 0.25)
let liqueurCoffee = IngredientData(id: "liqueurCoffee", name: "coffee liqueur", nicknames: ["Kahlúa"], category: .liqueur, alcohol: 0.20, region: "Mexico")
let liqueurOrange = IngredientData(id: "liqueurOrange", name: "orange liqueur", nicknames: ["Curaçao", "Triple Sec", "Cointreau", "Grand Marnier"], category: .liqueur, alcohol: 0.40, region: "Netherlands/France")
let mezcal = IngredientData(id: "mezcal", name: "mezcal", category: .liquor, alcohol: 0.40, region: "Mexico", wikipedia: "Mezcal")
let prosecco = IngredientData(id: "prosecco", name: "prosecco", category: .wine, alcohol: 0.11, region: "Italy", wikipedia: "Prosecco")
let rumLight = IngredientData(id: "rumLight", name: "light rum", nicknames: ["silver rum", "white rum"], category: .liquor, alcohol: 0.40, wikipedia: "Rum")
let rumGold = IngredientData(id: "rumGold", name: "gold rum", nicknames: ["silver rum", "light rum"], category: .liquor, alcohol: 0.40, wikipedia: "Rum")
let rumDark = IngredientData(id: "rumDark", name: "dark rum", nicknames: ["silver rum", "light rum"], category: .liquor, alcohol: 0.40, wikipedia: "Rum")
let sodaClub = IngredientData(id: "sodaClub", name: "club soda", category: .mixer, wikipedia: "Club_soda")
let sodaCola = IngredientData(id: "sodaCola", name: "cola soda", category: .mixer, wikipedia: "Cola")
let sugar = IngredientData(id: "sugar", name: "sugar", category: .sweetener, wikipedia: "Sugar")
let sugarBrown = IngredientData(id: "sugarBrown", name: "brown sugar", category: .sweetener, wikipedia: "Brown_sugar")
let syrupMaple = IngredientData(id: "syrupMaple", name: "maple syrup", category: .sweetener)
let syrupSimple = IngredientData(id: "syrupSimple", name: "simple syrup", category: .sweetener)
let syrupAlmond = IngredientData(id: "syrupAlmond", name: "almond syrup", nicknames: ["Orgeat syrup"], category: .sweetener, wikipedia: "Orgeat_syrup")
let tequila = IngredientData(id: "tequila", name: "tequila", category: .liquor, alcohol: 0.40, region: "Mexico", wikipedia: "Tequila")
let vermouthDry = IngredientData(id: "vermouthDry", name: "dry vermouth", category: .liquor, alcohol: 0.18, region: "Italy", wikipedia: "Vermouth")
let vermouthSweet = IngredientData(id: "vermouthSweet", name: "sweet vermouth", category: .wine, alcohol: 0.165, region: "Italy", wikipedia: "Vermouth")
let whiskey = IngredientData(id: "whiskey", name: "whiskey", category: .liquor, alcohol: 0.40, region: "Worldwide", wikipedia: "Whiskey")
let whiskeyBourbon = IngredientData(id: "whiskeyBourbon", name: "Bourbon", category: .liquor, alcohol: 0.40, region: "United States (Kentucky)", wikipedia: "Bourbon")
let whiskeyIrish = IngredientData(id: "whiskeyIrish", name: "Irish whiskey", category: .liquor, alcohol: 0.40, region: "Ireland", wikipedia: "Irish_whiskey")
let whiskeyRye = IngredientData(id: "whiskeyRye", name: "rye whiskey", category: .liquor, alcohol: 0.40, region: "United States", wikipedia: "Rye_whiskey")
let whiskeyScotch = IngredientData(id: "whiskeyScotch", name: "Scotch whiskey", category: .liquor, alcohol: 0.40, region: "Scotland", wikipedia: "Scotch_whisky")
let vodka = IngredientData(id: "vodka", name: "vodka", category: .liquor, alcohol: 0.40, region: "Russia", wikipedia: "Vodka")