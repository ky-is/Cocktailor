import Foundation

enum IngredientTag: String {
	case aperitif
}

final class IngredientData: Identifiable {
	let id: String
	let name: String
	let nicknames: [String]
	let alcohol: Double
	let region: String?
	let wikipedia: String?
	let parent: IngredientData?
	let showSeparateFromParent: Bool
	var children: [IngredientData] = []
	var tags: [IngredientTag]

	init(id: String, name: String, nicknames: [String]? = nil, alcohol: Double = 0, region: String? = nil, wikipedia: String? = nil, parent: IngredientData? = nil, showSeparateFromParent: Bool = true, tags: [IngredientTag]? = nil) {
		self.id = id
		self.name = name
		self.nicknames = nicknames ?? []
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
}

struct Substitute {
	let ingredient: IngredientData
	let score: Double
}

private let absinthe = IngredientData(id: "absinthe", name: "absinthe", alcohol: 0.60, wikipedia: "Absinthe")
private let agave = IngredientData(id: "agave", name: "agave nectar")
private let amaretto = IngredientData(id: "amaretto", name: "amaretto", alcohol: 0.24, region: "Italy", wikipedia: "Amaretto")
private let bitters = IngredientData(id: "bitters", name: "Angostura bitters", nicknames: ["bitters"], alcohol: 0.447, region: "Trinidad and Tobago", wikipedia: "Angostura_bitters")
private let aperol = IngredientData(id: "aperol", name: "aperol", alcohol: 0.11, region: "Italy", wikipedia: "Aperol")
private let apple = IngredientData(id: "apple", name: "apple")
private let brandy = IngredientData(id: "brandy", name: "brandy", nicknames: ["eau de vie"], alcohol: 0.40, region: "worldwide", wikipedia: "Brandy")
private let brandyApple = IngredientData(id: "brandyApple", name: "apple brandy", alcohol: 0.40, wikipedia: "Apple_brandy")
private let brandyApricot = IngredientData(id: "brandyApricot", name: "apricot brandy", alcohol: 0.40, wikipedia: "Apricot_brandy")
private let brandyCognac = IngredientData(id: "brandyCognac", name: "Cognac", alcohol: 0.40, region: "France", wikipedia: "Cognac")
private let cachaca = IngredientData(id: "cachaca", name: "cachaça", alcohol: 0.40, region: "Brazil", wikipedia: "Cachaca")
private let campari = IngredientData(id: "campari", name: "campari", alcohol: 0.25, region: "Italy", wikipedia: "Cachaca")
private let champagne = IngredientData(id: "champagne", name: "champagne", alcohol: 0.12, region: "France (Champagne)", wikipedia: "Champagne")
private let cherryMaraschino = IngredientData(id: "cherryCocktail", name: "Maraschino cherry", nicknames: ["cocktail cherry"], wikipedia: "Maraschino_cherry")
private let coconutCream = IngredientData(id: "coconutCream", name: "cream of coconut", wikipedia: "Coconut_milk#Cream_of_coconut")
private let coffee = IngredientData(id: "coffee", name: "coffee", wikipedia: "Coffee")
private let cream = IngredientData(id: "cream", name: "cream", wikipedia: "Cream")
private let creamHeavy = IngredientData(id: "creamHeavy", name: "heavy cream", nicknames: ["whipping cream"], wikipedia: "Cream#Types")
private let irishCream = IngredientData(id: "irishCream", name: "Irish cream", alcohol: 0.175, region: "Ireland", wikipedia: "Apricot_brandy")
private let juiceCranberry = IngredientData(id: "juiceCranberry", name: "cranberry juice")
private let liqueurRasberry = IngredientData(id: "liquerRasberry", name: "rasberry liqueur", nicknames: ["chambour"], alcohol: 0.20, region: "France", wikipedia: "Chambord_(liqueur)")
private let liqueurBlackberry = IngredientData(id: "liquerBlackberry", name: "blackberry liqueur", nicknames: ["crème de mûre"], alcohol: 0.20, region: "France", wikipedia: "Crème_liqueur")
private let liqueurBlackcurrant = IngredientData(id: "liquerBlackcurrant", name: "blackcurrant liqueur", nicknames: ["crème de cassis"], alcohol: 0.20, region: "France (Burgundy)", wikipedia: "Crème_de_cassis")
//private let liqueurCherry = IngredientData(id: "liqueurCherry", name: "cherry liqueur", alcohol: 0.24)
private let liqueurChocolate = IngredientData(id: "liqueurChocolate", name: "chocolate liqueur", nicknames: ["crème de cacao"], alcohol: 0.25)
private let liqueurCoffee = IngredientData(id: "liqueurCoffee", name: "coffee liqueur", nicknames: ["Kahlúa"], alcohol: 0.20, region: "Mexico")
private let liqueurOrange = IngredientData(id: "liqueurOrange", name: "orange liqueur", nicknames: ["Curaçao", "Triple Sec", "Cointreau", "Grand Marnier"], alcohol: 0.40, region: "Netherlands/France")
private let mezcal = IngredientData(id: "mezcal", name: "mezcal", alcohol: 40, region: "Mexico", wikipedia: "Mezcal")
private let prosecco = IngredientData(id: "prosecco", name: "prosecco", alcohol: 0.11, region: "Italy", wikipedia: "Prosecco")
private let sodaClub = IngredientData(id: "sodaClub", name: "club soda", wikipedia: "Club_soda")
private let sodaCola = IngredientData(id: "sodaCola", name: "cola soda", wikipedia: "Cola")

private let rumLight = IngredientData(id: "rumLight", name: "light rum", nicknames: ["silver rum", "white rum"], alcohol: 0.40, wikipedia: "Rum")
private let rumGold = IngredientData(id: "rumGold", name: "gold rum", nicknames: ["silver rum", "light rum"], alcohol: 0.40, wikipedia: "Rum")
private let rumDark = IngredientData(id: "rumDark", name: "dark rum", nicknames: ["silver rum", "light rum"], alcohol: 0.40, wikipedia: "Rum")
private let sugar = IngredientData(id: "sugar", name: "sugar", wikipedia: "Sugar")
private let sugarBrown = IngredientData(id: "sugarBrown", name: "brown sugar", wikipedia: "Brown_sugar")
private let vermouthDry = IngredientData(id: "vermouthDry", name: "dry vermouth", alcohol: 0.18, region: "Italy", wikipedia: "Vermouth")
private let vermouthSweet = IngredientData(id: "vermouthSweet", name: "sweet vermouth", alcohol: 0.165, region: "Italy", wikipedia: "Vermouth")
private let whiskey = IngredientData(id: "whiskey", name: "whiskey", alcohol: 0.40, region: "Worldwide", wikipedia: "Whiskey")
private let whiskeyBourbon = IngredientData(id: "whiskeyBourbon", name: "Bourbon", alcohol: 0.40, region: "United States (Kentucky)", wikipedia: "Bourbon")
private let whiskeyIrish = IngredientData(id: "whiskeyIrish", name: "Irish whiskey", alcohol: 0.40, region: "Ireland", wikipedia: "Irish_whiskey")
private let whiskeyRye = IngredientData(id: "whiskeyRye", name: "rye whiskey", alcohol: 0.40, region: "United States", wikipedia: "Rye_whiskey")
private let whiskeyScotch = IngredientData(id: "whiskeyScotch", name: "Scotch whiskey", alcohol: 0.40, region: "Scotland", wikipedia: "Scotch_whisky")

private let egg = IngredientData(id: "egg", name: "egg")
private let lemon = IngredientData(id: "lemon", name: "lemon")
private let lime = IngredientData(id: "lime", name: "lime")
private let mapleSyrup = IngredientData(id: "mapleSyrup", name: "maple syrup")

let ingredients: [String: IngredientData] = {
	let items = [
		absinthe,
		agave,
		amaretto,
		bitters,
		aperol,
		apple,
		brandy,
		brandyApple,
		brandyApricot,
		brandyCognac,
		cachaca,
		campari,
		champagne,
		cherryMaraschino,
		coffee,
		egg,
		IngredientData(id: "eggyolk", name: "egg yolk", parent: egg, showSeparateFromParent: false),
		IngredientData(id: "eggwhite", name: "egg white", parent: egg, showSeparateFromParent: false),
		irishCream,
		juiceCranberry,
		lemon,
		lime,
		liqueurRasberry,
		liqueurBlackberry,
		liqueurBlackcurrant,
		liqueurCoffee,
		liqueurOrange,
		mapleSyrup,
		prosecco,
		rumLight,
		rumGold,
		rumDark,
		sodaClub,
		whiskey,
		whiskeyBourbon,
		whiskeyRye,
		whiskeyScotch,
	]
	var results = [String: IngredientData]()
	for item in items {
		results[item.id] = item
	}
	return results
}()


let substitutions: [String: [Substitute]] = {
	let substitutes = [
		(lemon, lime, 0.5),
		(agave, mapleSyrup, 0.5),
		(brandy, brandyApple, 0.5),
		(brandy, brandyCognac, 0.5),
		(cream, creamHeavy, 0.5),
		(rumLight, rumGold, 0.5),
		(rumGold, rumDark, 0.5),
//		(rumLight, cachaca, 0.2),
		(liqueurBlackberry, liqueurBlackcurrant, 0.5),
		(sugar, sugarBrown, 0.8),
		(champagne, prosecco, 0.8),
		(whiskey, whiskeyBourbon, 0.8),
		(whiskey, whiskeyIrish, 0.8),
		(whiskey, whiskeyRye, 0.8),
		(whiskey, whiskeyScotch, 0.8),
		(whiskeyIrish, whiskeyScotch, 0.8),
	]
	var results = [String: [Substitute]]()
	substitutes.forEach { (first, second, score) in
		if results[first.id] == nil {
			results[first.id] = []
			results[second.id] = []
		}
		results[first.id]!.append(Substitute(ingredient: second, score: score))
		results[second.id]!.append(Substitute(ingredient: first, score: score))
	}
	return results
}()
