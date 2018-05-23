import json
import os

class Manager:
    def __init__(self):
        self.recipe_dir = "./recipes"
        self.recipe = ""

    def load_recipe(self, recipe_path="", name="recipe.json"):
        path = os.path.join(self.recipe_dir, recipe_path, name)
        print(path)
        with open(path, "rb") as f:
            self.recipe = json.load(f)
        return self.recipe
