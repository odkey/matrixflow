import json
import os

class Manager:
    def __init__(self):
        self.recipe_folder = "./recipes"
        self.recipe = ""

    def load_recipe(self, name="recipe.json"):
        path = os.path.join(self.recipe_folder, name)
        print(path)
        with open(path, "rb") as f:
            self.recipe = json.load(f)
        return self.recipe
