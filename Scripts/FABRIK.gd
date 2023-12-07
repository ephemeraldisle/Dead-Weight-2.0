extends Node2D

var chain_nodes = [] # Array to hold the nodes in the chain
var distances = [] # Array to hold the distances between nodes
var max_angle = -PI # Maximum angle a node can rotate
@onready var target: Node2D = %Target

func _ready():
	# Assuming the chain nodes are all children of this node
	for child in get_children():
		chain_nodes.append(child)
		print(child.name)
	calculate_distances()

func _process(delta: float) -> void:
	solve(target.global_position)

func calculate_distances():
	for i in range(chain_nodes.size() - 1):
		distances.append(chain_nodes[i].position.distance_to(chain_nodes[i + 1].position))

func solve(target_position):
	# Forward reaching
	chain_nodes[-1].position = self.to_local(target_position)
	for i in range(chain_nodes.size() - 2, -1, -1):
		var dir = (chain_nodes[i].position - chain_nodes[i + 1].position).normalized()
		chain_nodes[i].position = chain_nodes[i + 1].position + dir * distances[i]

	# Backward reaching
	chain_nodes[0].position = Vector2.ZERO
	for i in range(chain_nodes.size() - 1):
		var dir = (chain_nodes[i + 1].position - chain_nodes[i].position).normalized()
		chain_nodes[i + 1].position = chain_nodes[i].position + dir * distances[i]
		chain_nodes[i].rotation = dir.angle()
		
	# Limit angles
	for i in range(1, chain_nodes.size() - 1):
		var angle = chain_nodes[i - 1].position.angle_to_point(chain_nodes[i + 1].position)
		var dir = (chain_nodes[i + 1].position - chain_nodes[i - 1].position).normalized()
		chain_nodes[i].position = chain_nodes[i - 1].position + dir * distances[i - 1]
		chain_nodes[i].rotation = dir.angle()
