extends Node
class_name GlobalSignals

signal unitDied(unit: Unit)

signal craterCreated(unit: Unit, radius: float, scatter_grade: float)

signal skillUsed()

signal startGame()

signal endGame()
