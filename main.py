class RecommendationSystem:
    def __init__(self, users, items, ratings):
        self.users = users
        self.items = items
        self.ratings = ratings

    def calculate_similarity(self, user1, user2):
        ratings1 = [rating for item, rating in self.ratings.items() if rating[user1] is not None]
        ratings2 = [rating for item, rating in self.ratings.items() if rating[user2] is not None]
        similarity = sum([a * b for a, b in zip(ratings1, ratings2)])
        return similarity

    def get_recommendations(self, user):
        similarities = {}
        for other_user in self.users:
            if other_user != user:
                similarities[other_user] = self.calculate_similarity(user, other_user)
        return sorted(similarities.items(), key=lambda x: x[1], reverse=True)

    def get_item_recommendations(self, user):
        recommendations = []
        for item, ratings in self.ratings.items():
            if ratings[user] is None:
                ratings_sum = 0
                for other_user in self.users:
                    if other_user != user and ratings[other_user] is not None:
                        ratings_sum += ratings[other_user] * self.calculate_similarity(user, other_user)
                recommendations.append((item, ratings_sum))
        return sorted(recommendations, key=lambda x: x[1], reverse=True)

class User:
    def __init__(self, name):
        self.name = name

class Item:
    def __init__(self, name):
        self.name = name

class Rating:
    def __init__(self):
        self.ratings = {}

    def add_rating(self, user, item, rating):
        if user not in self.ratings:
            self.ratings[user] = {}
        self.ratings[user][item] = rating

    def get_rating(self, user, item):
        return self.ratings.get(user, {}).get(item)

users = [User("Alice"), User("Bob"), User("Charlie")]
items = [Item("Movie1"), Item("Movie2"), Item("Movie3")]
ratings = Rating()
ratings.add_rating("Alice", "Movie1", 5)
ratings.add_rating("Alice", "Movie2", 4)
ratings.add_rating("Bob", "Movie1", 4)
ratings.add_rating("Bob", "Movie3", 5)
ratings.add_rating("Charlie", "Movie2", 5)
ratings.add_rating("Charlie", "Movie3", 4)

system = RecommendationSystem([user.name for user in users], [item.name for item in items], ratings.ratings)
print(system.get_recommendations("Alice"))
print(system.get_item_recommendations("Alice"))