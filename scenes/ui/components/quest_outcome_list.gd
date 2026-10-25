
extends VBoxContainer

@onready var body: Panel = $body
@onready var quest_titel: Label = $Header/MarginContainer/HBoxContainer/QuestTitel
@onready var success_label: Label = $Header/MarginContainer/HBoxContainer/Sucess
@onready var failure_label: Label = $Header/MarginContainer/HBoxContainer/Failure
@onready var flavor_text: RichTextLabel = $body/MarginContainer/Body/FlavorText

@onready var item_box: Control = $body/MarginContainer/Body/MarginContainer/Reward/reward/ItemBox
@onready var item_texture: TextureRect = $body/MarginContainer/Body/MarginContainer/Reward/reward/ItemBox/TextureRect
@onready var item_label: Label = $body/MarginContainer/Body/MarginContainer/Reward/reward/ItemBox/Label

@onready var corruption_box: Control = $body/MarginContainer/Body/MarginContainer/Reward/reward/ItemBox2
@onready var corruption_texture: TextureRect = $body/MarginContainer/Body/MarginContainer/Reward/reward/ItemBox2/TextureRect
@onready var corruption_label: Label = $body/MarginContainer/Body/MarginContainer/Reward/reward/ItemBox2/Label

@onready var mermaid_box: Control = $body/MarginContainer/Body/MarginContainer/Reward/reward/MermaidBox
@onready var mermaid_texture: TextureRect = $body/MarginContainer/Body/MarginContainer/Reward/reward/MermaidBox/TextureRect
@onready var mermaid_label: Label = $body/MarginContainer/Body/MarginContainer/Reward/reward/MermaidBox/Label


func _ready() -> void:
	body.hide()
	success_label.hide()
	failure_label.hide()

	item_box.hide()
	corruption_box.hide()
	mermaid_box.hide()


func setup(
	quest: Node,
	outcome: EnumConstants.QuestCompletionState,
	mermaid: Node,
	item: Node = null
) -> void:
	quest_titel.text = quest.quest_name
	flavor_text.text = _get_outcome_description(quest, outcome)

	success_label.hide()
	failure_label.hide()

	match outcome:
		EnumConstants.QuestCompletionState.SUCCESS:
			success_label.text = "Erfolgreich"
			success_label.show()

		EnumConstants.QuestCompletionState.NEUTRAL:
			success_label.text = "Neutral"
			success_label.show()

		EnumConstants.QuestCompletionState.FAILURE:
			failure_label.text = "Gescheitert"
			failure_label.show()

		EnumConstants.QuestCompletionState.FINAL_SUCCESS:
			success_label.text = "Finaler Erfolg"
			success_label.show()

	_setup_item_reward(quest, outcome, item)
	_setup_corruption_reward(quest, outcome)
	_setup_mermaid(mermaid, outcome)


func _get_outcome_description(
	quest: Node,
	outcome: EnumConstants.QuestCompletionState
) -> String:
	match outcome:
		EnumConstants.QuestCompletionState.SUCCESS:
			return quest.quest_success_outcome

		EnumConstants.QuestCompletionState.NEUTRAL:
			return quest.quest_neutral_outcome

		EnumConstants.QuestCompletionState.FAILURE:
			return quest.quest_failure_outcome

		EnumConstants.QuestCompletionState.FINAL_SUCCESS:
			return quest.quest_success_outcome

	return ""


func _setup_item_reward(
	quest: Node,
	outcome: EnumConstants.QuestCompletionState,
	item: Node
) -> void:
	item_box.hide()

	var successful := (
		outcome == EnumConstants.QuestCompletionState.SUCCESS
		or outcome == EnumConstants.QuestCompletionState.FINAL_SUCCESS
	)

	if not successful or not quest.rewards_item or item == null:
		return

	item_label.text = item.item_name
	item_texture.texture = item.item_picture
	item_texture.visible = item.item_picture != null

	item_box.show()


func _setup_corruption_reward(
	quest: Node,
	outcome: EnumConstants.QuestCompletionState
) -> void:
	corruption_box.hide()

	var successful := (
		outcome == EnumConstants.QuestCompletionState.SUCCESS
		or outcome == EnumConstants.QuestCompletionState.FINAL_SUCCESS
	)

	if not successful or not quest.rewards_corruption_reduction:
		return

	corruption_texture.hide()
	corruption_label.text = "Korruption −%s" % str(
		quest.reward_corruption_reduction
	)

	corruption_box.show()


func _setup_mermaid(mermaid: Node, outcome: EnumConstants.QuestCompletionState) -> void:
	mermaid_box.hide()

	if mermaid == null:
		return

	mermaid_label.text = mermaid.mermaid_name

	if outcome == EnumConstants.QuestCompletionState.FAILURE:
		mermaid_label.text += " (verloren)"

	mermaid_texture.texture = mermaid.mermaid_head_shot
	mermaid_texture.visible = mermaid.mermaid_head_shot != null

	mermaid_box.show()


func _on_header_pressed() -> void:
	body.visible = not body.visible
